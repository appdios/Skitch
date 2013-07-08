//
//  YMShapeView.m
//  Skitch
//
//  Created by Sumit Kumar on 6/28/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMShapeView.h"

@interface YMShapeView()
@property (nonatomic, strong) UIButton *currentSelectedButton;

@end
@implementation YMShapeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addShapeButtons];
    }
    return self;
}

- (void)addShapeButtons
{
    CGSize imageSize = CGSizeMake(40, 40);
    for (int i=0; i<7; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5, 10 + (imageSize.height+10)*i, imageSize.width, imageSize.height)];
        button.tag = i;
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [button addTarget:self action:@selector(shapeChanged:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        switch (i) {
            case 0:
                self.currentSelectedButton = button;
                button.backgroundColor = [UIColor lightGrayColor];
                [button setImage:[UIImage imageNamed:@"arrowshape"] forState:UIControlStateNormal];
                break;
            case 1:
                [button setImage:[UIImage imageNamed:@"circleshape"] forState:UIControlStateNormal];
                break;
            case 2:
                [button setImage:[UIImage imageNamed:@"rrectshape"] forState:UIControlStateNormal];
                break;
            case 3:
                [button setImage:[UIImage imageNamed:@"rectshape"] forState:UIControlStateNormal];
                break;
            case 4:
                [button setImage:[UIImage imageNamed:@"textshape"] forState:UIControlStateNormal];
                break;
            case 5:
                [button setImage:[UIImage imageNamed:@"lineshape"] forState:UIControlStateNormal];
                break;
            case 6:
                [button setImage:[UIImage imageNamed:@"blurshape"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }
}

- (void)shapeChanged:(UIButton*)button
{
    [UIView animateWithDuration:0.3 animations:^{
        self.currentSelectedButton.backgroundColor = [UIColor clearColor];
        button.backgroundColor = [UIColor lightGrayColor];
    }];
    
    self.currentSelectedButton = button;
    [YMProperty setCurrentShapeType:button.tag];
}


@end
