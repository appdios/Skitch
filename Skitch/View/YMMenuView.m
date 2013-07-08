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

@interface YMMenuView()

@property (nonatomic, strong) YMShapeView *shapeView;
@property (nonatomic, strong) YMColorView *colorView;
@property (nonatomic) CGFloat initialTouchPositionX;
@property (nonatomic) CGFloat lastTouchPositionX;
@end
@implementation YMMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menuback"]];
        [self addSubViews];
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 2;
        self.layer.shadowOpacity = 0.4;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

- (void)panGesture:(UIPanGestureRecognizer*)recognizer{
    CGPoint currentTouchPoint     = [recognizer locationInView:self];
    CGFloat currentTouchPositionX = currentTouchPoint.x;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.initialTouchPositionX = currentTouchPositionX;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat panAmount =  currentTouchPositionX - self.initialTouchPositionX;
        recognizer.view.center = CGPointMake((recognizer.view.center.x + panAmount) <= 64 ? (recognizer.view.center.x + panAmount) : 64,recognizer.view.center.y);
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        [self handleHorizontalAnimation:currentTouchPositionX];
    }
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
    self.lastTouchPositionX = currentTouchPositionX;

}

-(void) handleHorizontalAnimation:(CGFloat)currentTouchPositionX
{
    BOOL openDrawer = YES;
    if (self.lastTouchPositionX < currentTouchPositionX) {
        openDrawer = NO;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.center = openDrawer ? CGPointMake(self.bounds.size.width/2.0, self.center.y) :  CGPointMake(-self.bounds.size.width/2.0, self.center.y);
    } completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kHideMenuNotification" object:nil];
    }];
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
    self.colorView.frame = CGRectMake(0, 0, 64, self.bounds.size.height);
    self.shapeView.frame = CGRectMake(CGRectGetMaxX(self.colorView.frame), 0, 64, self.bounds.size.height);
}

@end
