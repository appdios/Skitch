//
//  UIImageView+Additional.m
//  Skitch
//
//  Created by Aditi Kamal on 7/4/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "UIImageView+Additional.h"

@implementation UIImageView (Additional)

-(UIImage*)crop:(CGRect)frame
{
    // Find the scalefactors  UIImageView's widht and height / UIImage width and height
    CGFloat widthScale =  self.bounds.size.width / self.image.size.width;
    CGFloat heightScale = self.bounds.size.height / self.image.size.height;
    
    // Calculate the right crop rectangle
    frame.origin.x = frame.origin.x * (1 / widthScale);
    frame.origin.y = frame.origin.y * (1 / heightScale);
    frame.size.width = frame.size.width * (1 / widthScale);
    frame.size.height = frame.size.height * (1 / heightScale);
    
    // Create a new UIImage
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.image.CGImage, frame);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return croppedImage;
}

@end
