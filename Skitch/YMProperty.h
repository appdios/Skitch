//
//  YMProperty.h
//  Skitch
//
//  Created by Sumit Kumar on 6/25/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMShape.h"

@interface YMProperty : NSObject

+ (YMShapeType)currentShapeType;
+ (void)setCurrentShapeType:(YMShapeType)type;
+ (UIColor*)currentColor;
+ (void)setCurrentColor:(UIColor*)color;
@end
