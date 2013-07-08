//
//  YMImageAttachmentView.m
//  Skitch
//
//  Created by Sumit Kumar on 7/8/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMImageAttachmentView.h"
#import "UIImage+Yammer.h"

@interface YMImageAttachmentView()

@property (nonatomic, strong) UIScrollView *scrollView;
@end
@implementation YMImageAttachmentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollView.delegate = self;
        self.scrollView.scrollsToTop = NO;
        [self addSubview:self.scrollView];
    }
    return self;
}

-(void)buttonClicked:(id)sender {
    
}

-(void)insertThumbnails {
    CGFloat x = 0;
    CGFloat thumbnailWidth = 50.0;
    CGFloat padding = 5.0;
    
    NSInteger artsCount = [[[YMProperty sharedInstance] selectedArts] count];
    for (int index = 0; index < artsCount; index ++ , x += thumbnailWidth + padding) {
        YMArt *art = [[[YMProperty sharedInstance] selectedArts] objectAtIndex:index];
        UIButton *subview = [[UIButton alloc] initWithFrame:CGRectMake(x, padding, thumbnailWidth, self.bounds.size.height - 2 * padding)];
        subview.layer.borderWidth = 1.0;
        subview.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [subview setImage:[art.image imageScaledToFitSize:subview.bounds.size] forState:UIControlStateNormal];
        [subview addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.scrollView addSubview:subview];
    }
    
    CGRect tmpRect = self.scrollView.frame;
    tmpRect.size.width = x;
    self.scrollView.contentSize = tmpRect.size;
    
    // crop container width
    if (tmpRect.size.width < self.frame.size.width) {
        CGRect containerRect = self.frame;
        containerRect.size = tmpRect.size;
        self.frame = containerRect;
    }
}

@end
