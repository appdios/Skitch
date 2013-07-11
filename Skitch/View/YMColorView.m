//
//  YMColorView.m
//  Skitch
//
//  Created by Sumit Kumar on 6/26/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMColorView.h"

@interface YMColorView()

@property (nonatomic, strong) UIButton *currentSelectedButton;
@end
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
    CGSize buttonSize = CGSizeMake(40, 40);
    for (int i=0; i<9; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 30 + (buttonSize.height + 10)*i, buttonSize.width, buttonSize.height)];
        button.tag = i;
        [button addTarget:self action:@selector(colorChanged:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        button.layer.borderWidth = 4.0;
        button.layer.cornerRadius = buttonSize.width/2;

        UIColor *selectedColor = [UIColor redColor];
        switch (i) {
            case 0:
                selectedColor = [UIColor redColor];
                break;
            case 1:
                selectedColor = [UIColor colorWithRed:0.0 green:163.0/255.0 blue:31.0/255.0 alpha:1.0];
                break;
            case 2:
                selectedColor = [UIColor colorWithRed:0.0 green:47.0/255.0 blue:161.0/255.0 alpha:1.0];
                break;
            case 3:
                selectedColor = [UIColor blackColor];
                break;
            case 4:
                selectedColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
                break;
            case 5:
                selectedColor = [UIColor colorWithRed:1.0 green:160.0/255.0 blue:16.0/255.0 alpha:1.0];
                break;
            case 6:
                selectedColor = [UIColor colorWithRed:45.0/255.0 green:202.0/255.0 blue:244.0/255.0 alpha:1.0];
                break;
            case 7:
                selectedColor = [UIColor magentaColor];
                break;
            case 8:
                selectedColor = [UIColor brownColor];
                break;
            case 9:
                selectedColor = [UIColor purpleColor];
                break;
                
            default:
                break;
        }
        button.layer.borderColor = selectedColor.CGColor;
        if (i==0) {
            button.backgroundColor = selectedColor;
            self.currentSelectedButton = button;
        }
        else{
            button.backgroundColor = [UIColor clearColor];
        }
    }
}

- (void)colorChanged:(UIButton*)button
{
    UIColor *selectedColor = [[UIColor alloc] initWithCGColor:button.layer.borderColor];

    [UIView animateWithDuration:0.1 animations:^{
        [self.currentSelectedButton setBackgroundColor:[UIColor clearColor]];
        self.currentSelectedButton = button;
        
        [button setBackgroundColor:selectedColor];
    }];
    
    
    [YMProperty setCurrentColor:selectedColor];
}

@end
