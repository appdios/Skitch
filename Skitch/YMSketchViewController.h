//
//  YMSketchViewController.h
//  Skitch
//
//  Created by Sumit Kumar on 6/25/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMSketchView.h"

@interface YMSketchViewController : UIViewController

@property (nonatomic, weak) IBOutlet YMSketchView *sketchView;
@property (nonatomic, weak) IBOutlet UIButton *menuButton;
@end
