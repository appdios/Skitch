//
//  YMSketchView.h
//  Skitch
//
//  Created by Sumit Kumar on 6/25/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMSketchViewDelegate <NSObject>
- (void)blurInRect:(CGRect)rect;
- (void)touchStart;
- (void)touchEnd;
@end
@interface YMSketchView : UIView<UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *shapes;
@property (nonatomic, weak) id<YMSketchViewDelegate> sketchDelegate;

- (void)readyForScreenshot;
@end
