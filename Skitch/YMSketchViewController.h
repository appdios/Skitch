//
//  YMSketchViewController.h
//  Skitch
//
//  Created by Sumit Kumar on 6/25/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMSketchView.h"
#import <MessageUI/MessageUI.h>
#import "YMGalleryViewController.h"
#import "YMWebSnapViewController.h"

@interface YMSketchViewController : UIViewController<UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, YMSketchViewDelegate, YMGallerydelegate, YMWebSnapDelegate>

@property (nonatomic, weak) IBOutlet YMSketchView *sketchView;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, weak) IBOutlet UIButton *galleryButton;
@property (nonatomic, weak) IBOutlet UIButton *undoButton;
@end
