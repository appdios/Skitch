//
//  YMGalleryViewController.m
//  Skitch
//
//  Created by Aditi Kamal on 7/7/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMGalleryViewController.h"
#import "YMYammerAuthorizationViewController.h"
#import "SVProgressHUD.h"

@interface YMGalleryViewController ()
@property (nonatomic) BOOL editMode;
@property (nonatomic, strong) UIToolbar *toolBar;
@end

@implementation YMGalleryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"My Gallery";
    
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"GalleryCell"];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
        layout.itemSize = CGSizeMake(220, 170);
        layout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
        layout.minimumInteritemSpacing = 5;
        layout.minimumLineSpacing = 20;
    }
    else{
        layout.itemSize = CGSizeMake(65, 100);
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.minimumInteritemSpacing = 5;
        layout.minimumLineSpacing = 10;
    }
    
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editGallery:)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStyleBordered target:self action:@selector(addNew)];
    self.navigationItem.leftBarButtonItem = addButton;
    
    self.toolBar = [[UIToolbar alloc] init];
    [self.toolBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];

    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleBordered target:self action:@selector(share)];
    
    UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(delete)];
    
    UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    [self.toolBar setItems:[NSArray arrayWithObjects:shareItem,flexibleSpaceItem,deleteItem, nil]];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.editMode) {
        self.toolBar.center = CGPointMake(self.toolBar.center.x, self.view.bounds.size.height - self.toolBar.frame.size.height/2);
    }
}

- (void)addNew{
    [self resetGallery];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate addNew];
    }];
}

- (void)delete{
    [[[YMProperty sharedInstance] arts] removeObjectsInArray:[[YMProperty sharedInstance] selectedArts]];
    [[[YMProperty sharedInstance] selectedArts] removeAllObjects];
    [self.collectionView reloadData];
}

- (void)share{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Yammer",@"Email",@"Save to photo album", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self gotoYammer];
            break;
        case 1:
            [self emailImage];
            break;
        case 2:
            [self saveToAlbum];
            break;
            
        default:
            break;
    }
}

- (void)gotoYammer{
    YMYammerAuthorizationViewController *yammerController = [[YMYammerAuthorizationViewController alloc] init];
    UINavigationController *yammerNavController = [[UINavigationController alloc] initWithRootViewController:yammerController];
    [self presentViewController:yammerNavController animated:YES completion:nil];
}

- (void)emailImage{
    [SVProgressHUD show];
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"Photo from iPhone!"];
    
    for (YMArt *art in [[YMProperty sharedInstance] selectedArts]) {
        NSData *data = UIImagePNGRepresentation(art.image);
        [picker addAttachmentData:data mimeType:@"image/png" fileName:@"SkitchImage"];
    }
    
    [self presentViewController:picker animated:YES completion:^{
        [SVProgressHUD dismiss];
    }];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


- (void)saveToAlbum{
    [SVProgressHUD show];
    for (YMArt *art in [[YMProperty sharedInstance] selectedArts]) {
        UIImageWriteToSavedPhotosAlbum(art.image, nil, nil, nil);
    }
    [SVProgressHUD showSuccessWithStatus:@"Saved"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.toolBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 50);
}

- (void)editGallery:(UIBarButtonItem*)button{
    self.editMode = !self.editMode;
    if (self.editMode) {
        button.title = @"Done";
        self.toolBar.center = CGPointMake(self.toolBar.center.x, self.view.bounds.size.height + self.toolBar.frame.size.height/2);
        [self.view addSubview:self.toolBar];
        [UIView animateWithDuration:0.3 animations:^{
            self.toolBar.center = CGPointMake(self.toolBar.center.x, self.view.bounds.size.height - self.toolBar.frame.size.height/2);
        }];
    }
    else{
        [self resetGallery];
    }
}

- (void)resetGallery{
    [[[YMProperty sharedInstance] selectedArts] removeAllObjects];
    [self.collectionView reloadData];
    self.navigationItem.rightBarButtonItem.title = @"Edit";
    [UIView animateWithDuration:0.3 animations:^{
        self.toolBar.center = CGPointMake(self.toolBar.center.x, self.view.bounds.size.height + self.toolBar.frame.size.height/2);
    } completion:^(BOOL finished) {
        [self.toolBar removeFromSuperview];
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [[[YMProperty sharedInstance] arts] count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];

    YMArt *art = [[[YMProperty sharedInstance] arts] objectAtIndex:indexPath.row];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:art.image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.masksToBounds = YES;
    cell.backgroundView = imageView;

    if (self.editMode) {
        if ([[[YMProperty sharedInstance] selectedArts] containsObject:art]) {
            cell.layer.borderWidth = 2.0;
            cell.layer.borderColor = [UIColor blueColor].CGColor;
            cell.layer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1.0 alpha:0.2].CGColor;
        }
        else{
            cell.layer.borderWidth = 0.0;
        }
    }
    else{
        cell.layer.borderWidth = 0.0;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.editMode) {
        YMArt *art = [[[YMProperty sharedInstance] arts] objectAtIndex:indexPath.row];

        if ([[[YMProperty sharedInstance] selectedArts] containsObject:art]) {
            [YMProperty markArtUnSelected:art];
        }
        else{
            [YMProperty markArtSelected:art];
        }
        [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    }
    else{
        [self resetGallery];
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate artSelectedAtIndex:indexPath.row];
        }];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
