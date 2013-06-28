//
//  YMSketchViewController.m
//  Skitch
//
//  Created by Sumit Kumar on 6/25/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMSketchViewController.h"
#import "YMMenuView.h"
#import <QuartzCore/QuartzCore.h>
#import "YMProperty.h"

@interface YMSketchViewController ()
@property (nonatomic, strong) UIImageView *backView;
@property (nonatomic, strong) YMMenuView *menuView;
@property (nonatomic) BOOL menuVisible;
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

    self.backView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.backView setImage:[UIImage imageNamed:@"11"]];

    self.menuView = [[YMMenuView alloc] initWithFrame:CGRectMake(-54*2, 0, 54*2, self.view.bounds.size.height)];
    [self.view addSubview:self.menuView];
    
    self.menuButton.backgroundColor = self.menuView.backgroundColor;
    self.menuButton.layer.cornerRadius = 8.0;
    self.menuButton.layer.borderWidth = 1.0;
    self.menuVisible = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorChanged:) name:@"kColorChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shapeChanged:) name:@"kShapeChanged" object:nil];
}

- (void)colorChanged:(NSNotification*)notification
{
    [self.menuButton setTitleColor:[notification object] forState:UIControlStateNormal];
}

- (void)shapeChanged:(NSNotification*)notification
{
    switch ([YMProperty currentShapeType]) {
        case YMShapeTypeArrow:
            [self.menuButton setTitle:@"A" forState:UIControlStateNormal];
            break;
        case YMShapeTypeCircular:
            [self.menuButton setTitle:@"C" forState:UIControlStateNormal];
            break;
        case YMShapeTypeRectangle:
            [self.menuButton setTitle:@"R" forState:UIControlStateNormal];
            break;
        case YMShapeTypeRoundedRectangle:
            [self.menuButton setTitle:@"RR" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

- (IBAction)showColorMenu:(id)sender
{
    if (!self.menuVisible) {
        [UIView animateWithDuration:0.2 animations:^{
            self.menuView.frame = CGRectMake(0, 0, 54*2, self.view.bounds.size.height);
            self.menuButton.center = CGPointMake(self.menuButton.center.x + 54*2, self.menuButton.center.y);
        }];
    }
    else{
        [UIView animateWithDuration:0.2 animations:^{
            self.menuView.frame = CGRectMake(-54*2, 0, 54*2, self.view.bounds.size.height);
            self.menuButton.center = CGPointMake(self.menuButton.center.x - 54*2, self.menuButton.center.y);
        }];
    }
    self.menuVisible = !self.menuVisible;
}

- (IBAction)getImage
{
    CGSize size = self.view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, YES, 1.0);
    
    [self.backView.layer renderInContext:UIGraphicsGetCurrentContext()];

    [self.sketchView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
