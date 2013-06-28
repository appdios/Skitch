//
//  YMMenuView.m
//  Skitch
//
//  Created by Sumit Kumar on 6/28/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMMenuView.h"
#import "YMShapeView.h"
#import "YMColorView.h"
#import <QuartzCore/QuartzCore.h>

@interface YMMenuView()

@property (nonatomic, strong) YMShapeView *shapeView;
@property (nonatomic, strong) YMColorView *colorView;
@end
@implementation YMMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        [self addSubViews];
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 2;
        self.layer.shadowOpacity = 0.4;
    }
    return self;
}

- (void)addSubViews
{
    self.shapeView = [[YMShapeView alloc] init];
    [self addSubview:self.shapeView];

    self.colorView = [[YMColorView alloc] init];
    [self addSubview:self.colorView];
}

- (void)layoutSubviews
{
    self.shapeView.frame = CGRectMake(0, 0, 54, self.bounds.size.height);
    self.colorView.frame = CGRectMake(CGRectGetMaxX(self.shapeView.frame), 0, 54, self.bounds.size.height);
}

@end
