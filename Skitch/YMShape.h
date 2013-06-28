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
    YMShapeTypePolygon
}YMShapeType;

@interface YMShape : NSObject

@property (nonatomic) CGPathRef path;
@property (nonatomic) YMShapeType type;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSString *text;

+ (YMShape*)currentShapeFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint;
+ (YMShape*)rectangleShapeInRect:(CGRect)rect;
+ (YMShape*)circularShapeInRect:(CGRect)rect;
+ (YMShape*)arrowShapeFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint;
+ (YMShape*)roundedRectangleShapeInRect:(CGRect)rect;
@end
