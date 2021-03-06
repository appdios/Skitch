//
//  YMGalleryViewController.h
//  Skitch
//
//  Created by Aditi Kamal on 7/7/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@protocol YMGallerydelegate <NSObject>

- (void)artSelectedAtIndex:(NSInteger)index;
- (IBAction)addNew;

@end

@interface YMGalleryViewController : UICollectionViewController<UIActionSheetDelegate,MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) id<YMGallerydelegate> delegate;
@end
