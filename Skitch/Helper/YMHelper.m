//
//  YMHelper.m
//  Skitch
//
//  Created by Aditi Kamal on 7/6/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMHelper.h"

@implementation YMHelper



CGFloat distanceBetween(CGPoint point1,CGPoint point2)
{
    CGFloat distance;
    CGFloat temp;
    temp=((point1.x-point2.x)*(point1.x-point2.x))+((point1.y-point2.y)*(point1.y-point2.y));
    distance=sqrt(temp);
    return distance;
}

CGPoint rotatePoint(CGPoint p, float angle, CGPoint centerPoint)
{
    float s = sin(angle);
    float c = cos(angle);
    
    // translate point back to origin:
    p.x -= centerPoint.x;
    p.y -= centerPoint.y;
    
    // rotate point
    float xnew = p.x * c - p.y * s;
    float ynew = p.x * s + p.y * c;
    
    // translate point back:
    p.x = xnew + centerPoint.x;
    p.y = ynew + centerPoint.y;
    
    return p;
}

@end
