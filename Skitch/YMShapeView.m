//
//  YMShapeView.m
//  Skitch
//
//  Created by Sumit Kumar on 6/28/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMShapeView.h"
#import <QuartzCore/QuartzCore.h>
#import "YMProperty.h"

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
    for (int i=0; i<5; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5, 10 + 54*i, 44, 44)];
        button.layer.borderWidth = 2.0;
        button.tag = i;
        [button addTarget:self action:@selector(shapeChanged:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        switch (i) {
            case 0:
                [button setTitle:@"A" forState:UIControlStateNormal];
                break;
            case 1:
                [button setTitle:@"C" forState:UIControlStateNormal];
                break;
            case 2:
                [button setTitle:@"RR" forState:UIControlStateNormal];
                break;
            case 3:
                [button setTitle:@"R" forState:UIControlStateNormal];
                break;
            case 4:
                [button setTitle:@"T" forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }
}

- (void)shapeChanged:(UIButton*)button
{
    [YMProperty setCurrentShapeType:button.tag];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kShapeChanged" object:nil];
}


@end
