//
//  YMNetwork.h
//  Skitch
//
//  Created by Sumit Kumar on 7/8/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YMNetworkDelegate <NSObject>
- (void)groupsAvailable:(id)groups error:(NSError*)error;
- (void)messageSentWithError:(NSError*)error;
- (void)imageUploadedWithId:(NSNumber*)fileId error:(NSError*)error;
@end


@interface YMNetwork : NSObject
+ (void)getGroupsForDelegate:(id<YMNetworkDelegate>)delegate;
+ (void)postMessage:(NSString*)message toGroup:(NSString*)groupId withAttachmentIds:(NSArray*)attachmentIds forDelegate:(id<YMNetworkDelegate>)delegate;
+ (void)uploadImage:(UIImage*)image toGroup:(NSString*)groupId delegate:(id<YMNetworkDelegate>)delegate;
@end
