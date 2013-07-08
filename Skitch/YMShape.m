//
//  YMShape.m
//  Skitch
//
//  Created by Sumit Kumar on 6/25/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMShape.h"
#import "YMProperty.h"

@implementation YMShape

+ (YMShape*)currentShapeFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    CGRect rect = CGRectMake(startPoint.x, startPoint.y, endPoint.x - startPoint.x, endPoint.y - startPoint.y);
    switch ([YMProperty currentShapeType]) {
        case YMShapeTypeRectangle:
            return [YMShape rectangleShapeInRect:rect];
            break;
        case YMShapeTypeRoundedRectangle:
            return [YMShape roundedRectangleShapeInRect:rect];
            break;
        case YMShapeTypeCircular:
            return [YMShape circularShapeInRect:rect];
            break;
        case YMShapeTypeArrow:
            return [YMShape arrowShapeFromPoint:startPoint toPoint:endPoint];
            break;
        case YMSHapeTypeText:
            return [YMShape textShapeInRect:rect];
            break;
        case YMShapeTypeLine:
            return [YMShape lineShapeFromPoint:startPoint toPoint:endPoint];
            break;
        case YMShapeTypeBlur:
            return [YMShape rectangleShapeInRect:rect];
            break;
        default:
            break;
    }
    return nil;
}

+ (YMShape*)textShapeInRect:(CGRect)rect
{
    YMShape *shape = [[YMShape alloc] init];
    shape.type = YMSHapeTypeText;
    shape.text = @"Hello";
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, nil, rect);
    shape.path = pathRef;
    shape.color = [YMProperty currentColor];
    shape.transform = CGAffineTransformIdentity;
    return shape;
}

+ (YMShape*)rectangleShapeInRect:(CGRect)rect
{
    YMShape *shape = [[YMShape alloc] init];
    shape.type = [YMProperty currentShapeType];
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddRect(pathRef, nil, rect);
    shape.path = pathRef;

    shape.color = [YMProperty currentColor];
    shape.transform = CGAffineTransformIdentity;
    return shape;
}

+ (YMShape*)circularShapeInRect:(CGRect)rect
{
    YMShape *shape = [[YMShape alloc] init];
    shape.type = YMShapeTypeCircular;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathAddEllipseInRect(pathRef, nil, rect);
    shape.path = pathRef;

    shape.color = [YMProperty currentColor];
    shape.transform = CGAffineTransformIdentity;
    return shape;
}

+ (YMShape*)arrowShapeFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    YMShape *shape = [[YMShape alloc] init];
    shape.type = YMShapeTypeArrow;
        
    CGFloat distance = distanceBetween(startPoint, endPoint);
    CGFloat height = distance*0.1;
    
	CGFloat numberOfV = 11;
	
	CGPoint  pointArrowSide1 = CGPointMake(startPoint.x+8.5*(distance/numberOfV), startPoint.y - height);
    CGPoint  pointArrowSide2 = CGPointMake(startPoint.x+9*(distance/numberOfV), startPoint.y - height/2);
    CGPoint  pointArrowSide3 = CGPointMake(startPoint.x+9*(distance/numberOfV), startPoint.y + height/2);
    CGPoint  pointArrowSide4 = CGPointMake(startPoint.x+8.5*(distance/numberOfV), startPoint.y + height);
	
	double angleInRadian = atan2(endPoint.y-startPoint.y,endPoint.x-startPoint.x);
    
	
    pointArrowSide1 = rotatePoint(pointArrowSide1, angleInRadian, startPoint);
    pointArrowSide2 = rotatePoint(pointArrowSide2, angleInRadian, startPoint);
    pointArrowSide3 = rotatePoint(pointArrowSide3, angleInRadian, startPoint);
    pointArrowSide4 = rotatePoint(pointArrowSide4, angleInRadian, startPoint);
    
    CGMutablePathRef pathRef = CGPathCreateMutable();

    CGPathMoveToPoint(pathRef, nil, startPoint.x, startPoint.y);
    CGPathAddLineToPoint(pathRef, nil, pointArrowSide2.x, pointArrowSide2.y);
    CGPathAddLineToPoint(pathRef, nil, pointArrowSide1.x, pointArrowSide1.y);
    CGPathAddLineToPoint(pathRef, nil, endPoint.x, endPoint.y);
    CGPathAddLineToPoint(pathRef, nil, pointArrowSide4.x, pointArrowSide4.y);
    CGPathAddLineToPoint(pathRef, nil, pointArrowSide3.x, pointArrowSide3.y);

    CGPathCloseSubpath(pathRef);
    
    shape.path = pathRef;
    
    shape.color = [YMProperty currentColor];
    shape.transform = CGAffineTransformIdentity;
    return shape;
}

+ (YMShape*)lineShapeFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    YMShape *shape = [[YMShape alloc] init];
    shape.type = YMShapeTypeLine;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    CGPathMoveToPoint(pathRef, nil, startPoint.x, startPoint.y);
    CGPathAddLineToPoint(pathRef, nil, endPoint.x, endPoint.y);

    shape.path = pathRef;
    
    shape.color = [YMProperty currentColor];
    shape.transform = CGAffineTransformIdentity;
    return shape;
}


+ (YMShape*)roundedRectangleShapeInRect:(CGRect)rect
{
    YMShape *shape = [[YMShape alloc] init];
    shape.type = YMShapeTypeRoundedRectangle;
    
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    
    NSInteger radius = 6;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGPathMoveToPoint(pathRef, nil, minx, midy);
    CGPathAddArcToPoint(pathRef, nil, minx, miny, midx, miny, radius);
    CGPathAddArcToPoint(pathRef, nil, maxx, miny, maxx, midy, radius);
    CGPathAddArcToPoint(pathRef, nil, maxx, maxy, midx, maxy, radius);
    CGPathAddArcToPoint(pathRef, nil, minx, maxy, minx, midy, radius);
    CGPathCloseSubpath(pathRef);
    
    shape.path = pathRef;
    
    shape.color = [YMProperty currentColor];
    shape.transform = CGAffineTransformIdentity;
    return shape;
}


- (void)dealloc
{
    if (_path) {
        CGPathRelease(_path);
    }
}

@end
