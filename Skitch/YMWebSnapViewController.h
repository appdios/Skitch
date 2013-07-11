//
//  YMWebSnapViewController.h
//  Skitch
//
//  Created by Sumit Kumar on 7/11/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMWebSnapDelegate <NSObject>

- (void)snapedImageFromWeb:(UIImage*)image;

@end

@interface YMWebSnapViewController : UIViewController<UIWebViewDelegate> 

@property (nonatomic, weak) IBOutlet UIWebView* webView;
@property (nonatomic, weak) IBOutlet UIToolbar* toolbar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* cancel;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* snap;
@property (nonatomic, weak) IBOutlet UINavigationBar* navBar;
@property (nonatomic, weak) id<YMWebSnapDelegate> delegate;

@property (nonatomic, strong) UIButton* forward;
@property (nonatomic, strong) UIButton* back;

@property (nonatomic, strong) UILabel* pageTitle;
@property (nonatomic, strong) UITextField* addressField;

- (void)updateButtons;
- (void)updateTitle:(UIWebView*)aWebView;
- (void)updateAddress:(NSURLRequest*)request;
- (void)loadAddress:(id)sender event:(UIEvent*)event;
- (void)informError:(NSError*)error;


@end
