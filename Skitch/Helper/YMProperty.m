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
        sharedInstance.color = [UIColor redColor];
        sharedInstance.arts = [NSMutableArray arrayWithArray:[YMProperty readArts]];
        sharedInstance.selectedArts = [NSMutableArray array];
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

+ (YMArt*)newArt{
    YMProperty *property = [YMProperty sharedInstance];
    YMArt *art = [[YMArt alloc] init];
    art.tag = [property.arts count] + 1;
    [property.arts addObject:art];
    return art;
}

+ (void)saveArt:(YMArt*)art{
    YMProperty *property = [YMProperty sharedInstance];
    __block NSInteger artIndex = 0;
    [property.arts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (((YMArt*)obj).tag == art.tag) {
            artIndex = idx;
            *stop = YES;
        }
    }];
    if (artIndex < [property.arts count]) {
        [property.arts replaceObjectAtIndex:artIndex withObject:art];
    }
    else{
        [property.arts addObject:art];
    }
}

+ (void)markArtSelectedAtIndex:(NSInteger)index{
    YMProperty *property = [YMProperty sharedInstance];
    YMArt *art = [property.arts objectAtIndex:index];
    if (![property.selectedArts containsObject:art]) {
        [property.selectedArts addObject:art];
    }
}

+ (void)markArtSelected:(YMArt*)art{
    YMProperty *property = [YMProperty sharedInstance];
    if (![property.selectedArts containsObject:art]) {
        [property.selectedArts addObject:art];
    }
}

+ (void)markArtUnSelected:(YMArt*)art{
    YMProperty *property = [YMProperty sharedInstance];
    if ([property.selectedArts containsObject:art]) {
        [property.selectedArts removeObject:art];
    }
}

+ (void)saveArts{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [documentsDir stringByAppendingPathComponent:@"arts"];
    [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:nil];
    
    YMProperty *property = [YMProperty sharedInstance];
    NSInteger imageIndex = 0;
    for (YMArt *art in property.arts) {
        [[self class] saveImage:art.image withFileName:[NSString stringWithFormat:@"%d",imageIndex] ofType:@"png" inDirectory:filePath];
        imageIndex ++;
    }
}

+ (NSArray*)readArts{
    NSMutableArray *artsArray = [NSMutableArray array];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [documentsDir stringByAppendingPathComponent:@"arts"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *savedArts = [fileManager contentsOfDirectoryAtPath:filePath error:nil];
    for (NSString *aString in savedArts) {
        if ([aString hasSuffix:@".png"]) {
            UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",filePath,aString]];
            if (image) {
                YMArt *art = [[YMArt alloc] init];
                art.image = image;
                art.tag = [artsArray count]+1;
                [artsArray addObject:art];
            }
        }
    }
    return artsArray;
}

+ (void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
}

@end
