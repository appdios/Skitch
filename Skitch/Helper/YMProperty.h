//
//  YMProperty.h
//  Skitch
//
//  Created by Sumit Kumar on 6/25/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMShape.h"
#import "YMArt.h"

@interface YMProperty : NSObject
@property (nonatomic, strong) NSMutableArray *arts;
@property (nonatomic, strong) NSMutableArray *selectedArts;

+ (YMProperty *) sharedInstance;
+ (YMShapeType)currentShapeType;
+ (void)setCurrentShapeType:(YMShapeType)type;
+ (UIColor*)currentColor;
+ (void)setCurrentColor:(UIColor*)color;

+ (YMArt*)newArt;
+ (void)saveArt:(YMArt*)art;
+ (void)markArtSelectedAtIndex:(NSInteger)index;
+ (void)markArtSelected:(YMArt*)art;
+ (void)markArtUnSelected:(YMArt*)art;
@end
