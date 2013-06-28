//
//  YMColorView.m
//  Skitch
//
//  Created by Sumit Kumar on 6/26/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMColorView.h"
#import <QuartzCore/QuartzCore.h>
#import "YMProperty.h"

@implementation YMColorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addColorButtons];
    }
    return self;
}

- (void)addColorButtons
{
    for (int i=0; i<10; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5, 10 + 54*i, 44, 44)];
        button.layer.cornerRadius = 22;
        button.layer.borderWidth = 2.0;
        [button addTarget:self action:@selector(colorChanged:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        switch (i) {
            case 0:
                button.backgroundColor = [UIColor redColor];
                break;
            case 1:
                button.backgroundColor = [UIColor greenColor];
                break;
            case 2:
                button.backgroundColor = [UIColor blueColor];
                break;
            case 3:
                button.backgroundColor = [UIColor blackColor];
                break;
            case 4:
                button.backgroundColor = [UIColor whiteColor];
                break;
            case 5:
                button.backgroundColor = [UIColor darkGrayColor];
                break;
            case 6:
                button.backgroundColor = [UIColor lightGrayColor];
                break;
            case 7:
                button.backgroundColor = [UIColor yellowColor];
                break;
            case 8:
                button.backgroundColor = [UIColor purpleColor];
                break;
            case 9:
                button.backgroundColor = [UIColor magentaColor];
                break;
            case 10:
                button.backgroundColor = [UIColor brownColor];
                break;
                
            default:
                break;
        }
    }
}

- (void)colorChanged:(UIButton*)button
{
    [YMProperty setCurrentColor:button.backgroundColor];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kColorChanged" object:button.backgroundColor];
}

@end
