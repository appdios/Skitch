//
//  YMGalleryViewController.m
//  Skitch
//
//  Created by Aditi Kamal on 7/7/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMGalleryViewController.h"

@interface YMGalleryViewController ()

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
    layout.itemSize = CGSizeMake(100, 100);
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [[[YMProperty sharedInstance] arts] count] + 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];

    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor lightGrayColor];
        cell.layer.borderWidth = 1.0;
        cell.layer.borderColor = [UIColor grayColor].CGColor;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addbutton"]];
        imageView.contentMode = UIViewContentModeCenter;
        cell.backgroundView = imageView;
    }
    else{
        YMArt *art = [[[YMProperty sharedInstance] arts] objectAtIndex:indexPath.row - 1];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:art.image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.layer.masksToBounds = YES;
        cell.backgroundView = imageView;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate artSelectedAtIndex:indexPath.row];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
