//
//  YMShape.h
//  Skitch
//
//  Created by Sumit Kumar on 6/25/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    YMShapeTypeArrow,
    YMShapeTypeCircular,
    YMShapeTypeRoundedRectangle,
    YMShapeTypeRectangle,
    YMSHapeTypeText,
    YMShapeTypeLine,
    YMShapeTypeStar,
    YMShapeTypeBlur
}YMShapeType;

@interface YMShape : NSObject

@property (nonatomic) CGPathRef path;
@property (nonatomic) YMShapeType type;
@property (nonatomic) CGAffineTransform transform;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic) BOOL filled;

+ (YMShape*)currentShapeFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint;
+ (YMShape*)rectangleShapeInRect:(CGRect)rect;
+ (YMShape*)starShapeInRect:(CGRect)rect;
+ (YMShape*)circularShapeInRect:(CGRect)rect;
+ (YMShape*)arrowShapeFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint;
+ (YMShape*)roundedRectangleShapeInRect:(CGRect)rect;
+ (YMShape*)lineShapeFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint;

- (BOOL)isPointOnStroke:(CGPoint)point;
@end
