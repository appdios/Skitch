//
//  YMProperty.m
//  Skitch
//
//  Created by Sumit Kumar on 6/25/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMProperty.h"

@interface YMProperty()
@property (nonatomic) YMShapeType shapeType;
@property (nonatomic, strong) UIColor *color;
@end

@implementation YMProperty

+ (YMProperty *) sharedInstance
{
    static YMProperty *sharedInstance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YMProperty alloc] init];
        sharedInstance.shapeType = YMShapeTypeArrow;
        sharedInstance.color = [UIColor blackColor];
    });
    
    return sharedInstance;
}

+ (YMShapeType)currentShapeType
{
    YMProperty *property = [YMProperty sharedInstance];
    return property.shapeType;
}

+ (void)setCurrentShapeType:(YMShapeType)type
{
    YMProperty *property = [YMProperty sharedInstance];
    property.shapeType = type;
}

+ (UIColor*)currentColor
{
    YMProperty *property = [YMProperty sharedInstance];
    return property.color;
}

+ (void)setCurrentColor:(UIColor*)color
{
    YMProperty *property = [YMProperty sharedInstance];
    property.color = color;
}

@end
