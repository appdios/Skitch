//
//  YMNetwork.m
//  Skitch
//
//  Created by Sumit Kumar on 7/8/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMNetwork.h"
#import "AFNetworking.h"

static const NSString *kYammerBaseURL = @"https://www.yammer.com/api/v1/";

@implementation YMNetwork

+ (void)getGroupsForDelegate:(id<YMNetworkDelegate>)delegate{
    NSString *host = [NSString stringWithFormat:@"%@%@",kYammerBaseURL,@"groups.json?sort_by=top_recent_activity&mine=1"];
    NSURL *url = [NSURL URLWithString:host];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"kAccessToken"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:[NSString stringWithFormat:@"Bearer %@",accessToken] forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    
    AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
        NSLog(@"%@",JSON);
        [delegate groupsAvailable:JSON error:nil];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response,NSError *error, id JSON){
        NSLog(@"%@",[error description]);
        [delegate groupsAvailable:nil error:error];
    }];
    
    [requestOperation start];
}

+ (void)postMessage:(NSString*)message toGroup:(NSString*)groupId withAttachmentIds:(NSArray *)attachmentIds forDelegate:(id<YMNetworkDelegate>)delegate{
        
    NSMutableData *data = [NSMutableData new];
    [data appendData:[[NSString stringWithFormat:@"%@=%@", @"body",message]
                      dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    [data appendData:[[NSString stringWithFormat:@"&%@=%@", @"group_id",groupId]
                      dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    
    for (id attachmentId in attachmentIds) {
        [data appendData:[[NSString stringWithFormat:@"&%@=%@", @"attached_objects[]",[NSString stringWithFormat:@"uploaded_file:%@",attachmentId]]
                          dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    }
    
    NSString *host = [NSString stringWithFormat:@"%@%@",kYammerBaseURL,@"messages.json"];
    NSURL *url = [NSURL URLWithString:host];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"kAccessToken"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:[NSString stringWithFormat:@"Bearer %@",accessToken] forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d",[data length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    [request setHTTPBody:data];
    
    AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
        NSLog(@"%@",JSON);
        [delegate messageSentWithError:nil];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response,NSError *error, id JSON){
        NSLog(@"%@",[error description]);
        [delegate messageSentWithError:error];
    }];
    
    [requestOperation start];
}

+ (void)uploadImage:(UIImage*)image toGroup:(NSString*)groupId delegate:(id<YMNetworkDelegate>)delegate
{
    NSData *uploadData = UIImagePNGRepresentation(image);
    NSString *filename = @"image.png";
    NSString *mimetype = @"image/png";
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"kAccessToken"];

    AFHTTPClient *client = [[self class] uploadClientWithURL:@"https://files.yammer.com" andToken:accessToken];
    NSMutableURLRequest *urlRequest =[client multipartFormRequestWithMethod:@"POST" path:[NSString stringWithFormat:@"/v2/files"] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFormData:[groupId dataUsingEncoding:NSUTF8StringEncoding] name:@"group_id"];
        [formData appendPartWithFormData:[filename dataUsingEncoding:NSUTF8StringEncoding] name:@"file_name"];
        [formData appendPartWithFormData:[filename dataUsingEncoding:NSUTF8StringEncoding] name:@"name"];
        [formData appendPartWithFileData:uploadData name:@"file" fileName:filename mimeType:mimetype];
    }];
    
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    
    AFJSONRequestOperation *requestOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
        NSLog(@"%@",JSON);
        NSNumber *fileId = [JSON valueForKeyPath:@"latest_version.file_id"];
        [delegate imageUploadedWithId:fileId error:nil];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response,NSError *error, id JSON){
        NSLog(@"%@",[error userInfo]);
        [delegate imageUploadedWithId:nil error:error];
    }];
    
    [requestOperation start];
}

+ (AFHTTPClient *)uploadClientWithURL:(NSString *)url andToken:(NSString *)token
{
    NSURL *baseURL = [NSURL URLWithString:url];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [httpClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", token]];
    [httpClient setDefaultHeader:@"Accept" value:@"*/*"];
    return httpClient;
}

@end
