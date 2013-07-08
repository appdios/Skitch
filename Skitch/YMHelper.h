//
//  YMHelper.h
//  Skitch
//
//  Created by Aditi Kamal on 7/6/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YMHelper : NSObject
CGFloat distanceBetween(CGPoint point1,CGPoint point2);
CGPoint rotatePoint(CGPoint p, float angle, CGPoint centerPoint);
@end
