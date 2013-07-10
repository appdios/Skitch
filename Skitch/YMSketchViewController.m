//
//  YMSketchViewController.m
//  Skitch
//
//  Created by Sumit Kumar on 6/25/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMSketchViewController.h"
#import "YMMenuView.h"
#import "YMYammerAuthorizationViewController.h"
#import "YMGalleryViewController.h"
#import "UIImage+Yammer.h"
#import "YMArt.h"
#import <Social/Social.h>
#import "SVProgressHUD.h"

@interface YMSketchViewController ()
@property (nonatomic, strong) UIImageView *backView;
@property (nonatomic, strong) YMMenuView *menuView;
@property (nonatomic, strong) YMArt *currentArt;
@property (nonatomic, strong) UIImageView *helpView;
@property (nonatomic, strong) UILabel *helpLabel;
@property (nonatomic, strong) UIPopoverController *popOver;
@property (nonatomic) CGFloat menuViewVisible;
@property (nonatomic) BOOL helpShown;
@end

@implementation YMSketchViewController

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

    self.sketchView.backgroundColor = [UIColor whiteColor];
    self.sketchView.sketchDelegate = self;
    
    self.backView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backView.contentMode = UIViewContentModeCenter;
    self.backView.backgroundColor = [UIColor whiteColor];
    self.backView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:self.backView belowSubview:self.sketchView];
        
    self.menuView = [[YMMenuView alloc] initWithFrame:CGRectMake(-64*2, 0, 64*2, self.view.bounds.size.height)];
    [self.view addSubview:self.menuView];
    
    self.helpView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gesturearrow"]];
    self.helpView.alpha = 0.8;
    
    self.helpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    self.helpLabel.backgroundColor = [UIColor clearColor];
    self.helpLabel.text = @"Slide for menu";
    self.helpLabel.font = [UIFont systemFontOfSize:14];
    self.helpLabel.textColor = [UIColor darkGrayColor];
        
    [self.shareButton setImage:[UIImage imageNamed:@"sendbutton"] forState:UIControlStateNormal];
    [self.addButton setImage:[UIImage imageNamed:@"addbutton"] forState:UIControlStateNormal];
    [self.galleryButton setImage:[UIImage imageNamed:@"gallerybutton"] forState:UIControlStateNormal];
    [self.undoButton setImage:[UIImage imageNamed:@"undobutton"] forState:UIControlStateNormal];
    
    self.menuViewVisible = NO;

    self.undoButton.hidden = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMenu) name:@"kShowMenuNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMenu) name:@"kHideMenuNotification" object:nil];

    [self performSelector:@selector(showStartMenu) withObject:nil afterDelay:0.1];
    
    self.helpShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"kHelpShown"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.backView.frame = self.view.bounds;
}

- (IBAction)addNew{
    UIImage *image = [self getImage];
    self.currentArt.image = image;
    [YMProperty saveArt:self.currentArt];
    
    [self.sketchView.shapes removeAllObjects];
    [self.sketchView setNeedsDisplay];
    self.backView.image = nil;
    [self showStartMenu];
}

- (IBAction)undo{
    [self.sketchView.shapes removeLastObject];
    [self.sketchView setNeedsDisplay];
    if ([self.sketchView.shapes count] > 0) {
        self.undoButton.hidden = NO;
    }
    else{
        self.undoButton.hidden = YES;
    }
}

- (IBAction)gotoGallery{
    UIImage *image = [self getImage];
    self.currentArt.image = image;
    [YMProperty saveArt:self.currentArt];
    
    YMGalleryViewController *galleryController = [[YMGalleryViewController alloc] initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    galleryController.delegate = self;
    UINavigationController *galleryNavController = [[UINavigationController alloc] initWithRootViewController:galleryController];
    [self presentViewController:galleryNavController animated:YES completion:nil];
}

- (IBAction)shareClicked:(id)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Yammer",@"Facebook",@"Twitter", @"Email",@"Save to photo album", nil];
    [actionSheet showInView:self.view];
}

- (void)showStartMenu{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Take a photo",@"Choose a photo",@"Start with blank", nil];
    actionSheet.tag = 100;
    [actionSheet showInView:self.view];
}

- (void)artSelectedAtIndex:(NSInteger)index{
    YMArt *art = [[[YMProperty sharedInstance] arts] objectAtIndex:index];
    self.currentArt = art;
    self.backView.image = art.image;
    [self.sketchView.shapes removeAllObjects];
    [self.sketchView setNeedsDisplay];
    self.sketchView.backgroundColor = [UIColor clearColor];
}

- (void)showMenu{
    if (self.menuViewVisible) {
        return;
    }
    self.menuViewVisible = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.menuView.frame = CGRectMake(0, 0, 64*2, self.view.bounds.size.height);
    }];
}

- (void)hideMenu{
    self.menuViewVisible = NO;
    [UIView animateWithDuration:0.2 animations:^{
        self.menuView.frame = CGRectMake(-64*2, 0, 64*2, self.view.bounds.size.height);
    }];
}


- (void)openCamera{
    UIImagePickerController *imageController = [[UIImagePickerController alloc] init];
    imageController.delegate = self;
    [imageController setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentViewController:imageController animated:YES completion:nil];
}

- (void)openGallery{
    
    UIImagePickerController *imageController = [[UIImagePickerController alloc] init];
    imageController.delegate = self;
    [imageController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (self.popOver) {
            self.popOver = nil;
        }
        self.popOver = [[UIPopoverController alloc] initWithContentViewController:imageController];
        [self setContentSizeForViewInPopover:self.view.bounds.size];
        [self.popOver presentPopoverFromRect:CGRectZero inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self presentViewController:imageController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    self.backView.image = [chosenImage imageScaledToFitSize:self.view.bounds.size];
    self.backView.image = [self getPickerImage];
    self.sketchView.backgroundColor = [UIColor clearColor];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        [self showStartMenu];
    }];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 100) {
        switch (buttonIndex) {
            case 0:
                [self openCamera];
                break;
            case 1:
                [self openGallery];
                break;
            case 2:
                self.sketchView.backgroundColor = [UIColor whiteColor];
                break;
            default:
                break;
        }
        self.currentArt = [YMProperty newArt];
    }
    else{
        if (buttonIndex==3) {
            return;
        }
        UIImage *image = [self getImage];
        switch (buttonIndex) {
            case 0:
                [self gotoYammer];
                break;
            case 1:
                [self postToFacebook];
                break;
            case 2:
                [self postToTwitter];
                break;
            case 3:
                [self emailImage:image];
                break;
            case 4:
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                break;
                
            default:
                break;
        }
    }
}

- (void)gotoYammer{
    UIImage *image = [self getImage];
    self.currentArt.image = image;
    [YMProperty saveArt:self.currentArt];
    
    [YMProperty markArtSelected:self.currentArt];
    
    YMYammerAuthorizationViewController *yammerController = [[YMYammerAuthorizationViewController alloc] init];
    UINavigationController *yammerNavController = [[UINavigationController alloc] initWithRootViewController:yammerController];
    [self presentViewController:yammerNavController animated:YES completion:nil];
}

- (void)postToFacebook{
    if(NSClassFromString(@"SLComposeViewController") != nil) {
        SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            [SVProgressHUD show];
            UIImage *image = [self getImage];
            [fbController addImage:image];
            [self presentViewController:fbController animated:YES completion:^{
                [SVProgressHUD dismiss];
            }];
            
        } else {
            // Service not available
        }
    }
}

- (void)postToTwitter{
    if(NSClassFromString(@"SLComposeViewController") != nil) {
        SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            [SVProgressHUD show];
            UIImage *image = [self getImage];
            [fbController addImage:image];
            [self presentViewController:fbController animated:YES completion:^{
                [SVProgressHUD dismiss];
            }];
            
        } else {
            // Service not available
        }
    }
}

- (UIImage*)getPickerImage
{
    CGSize size = self.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, YES, 1.0);
    
    if (self.backView) {
        [self.backView.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage*)getImage
{
    [self.sketchView readyForScreenshot];
    CGSize size = self.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, YES, 1.0);
    
    if (self.backView) {
        [self.backView.layer renderInContext:UIGraphicsGetCurrentContext()];
    }

    [self.sketchView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
}

- (void)emailImage:(UIImage *)image
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"Photo from iPhone!"];
    
    NSData *data = UIImagePNGRepresentation(image);
    [picker addAttachmentData:data mimeType:@"image/png" fileName:@"SkitchImage"];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

-(UIImage *)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    return cropped;
    
}

- (void)blurInRect:(CGRect)rect
{
    UIImage *img =  [self.backView.image imageCroppedToRect:rect];
    UIImage *blurImage = [img imageWithGaussianBlur];

    CGSize size = self.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    [self.backView.layer renderInContext:UIGraphicsGetCurrentContext()];
    [blurImage drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    self.backView.image=image;
}

- (void)touchStart{
    [UIView animateWithDuration:0.3 animations:^{
        self.shareButton.alpha =
        self.galleryButton.alpha =
        self.addButton.alpha =
        self.undoButton.alpha = 0.0;
    }];
}

- (void)touchEnd{
    if ([self.sketchView.shapes count] > 0) {
        self.undoButton.hidden = NO;
    }
    else{
        self.undoButton.hidden = YES;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.shareButton.alpha =
        self.galleryButton.alpha =
        self.addButton.alpha =
        self.undoButton.alpha = 1.0;
    }];
    
    if (!self.helpShown) {
        self.helpShown = YES;
        self.helpView.center = CGPointMake(self.helpView.bounds.size.width / 2, self.view.center.y);
        [self.view addSubview:self.helpView];
        
        self.helpLabel.center = CGPointMake(self.helpLabel.bounds.size.width / 2 + 5, self.view.center.y);
        [self.view addSubview:self.helpLabel];
        self.helpLabel.alpha = 0.1;
        
        [UIView animateWithDuration:1.0 animations:^{
            self.helpView.transform = CGAffineTransformMakeTranslation(100, 0);
            self.helpView.alpha = 0.0;
            self.helpLabel.alpha = 1.0;
        } completion:^(BOOL finished) {
            [self.helpView removeFromSuperview];
            [self.helpLabel removeFromSuperview];
        }];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kHelpShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
