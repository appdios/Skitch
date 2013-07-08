//
//  YMNetwork.m
//  Skitch
//
//  Created by Sumit Kumar on 7/8/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMNetwork.h"

static const NSString *kYammerBaseURL = @"https://www.yammer.com/api/v1/";

@implementation YMNetwork

+ (void)getGroupsForDelegate:(id<YMNetworkDelegate>)delegate{
    NSString *host = [NSString stringWithFormat:@"%@%@",kYammerBaseURL,@"groups.json?sort_by=top_recent_activity&mine=1"];
    NSURL *url = [NSURL URLWithString:host];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"kAccessToken"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:[NSString stringWithFormat:@"Bearer %@",accessToken] forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"%@",[connectionError description]);
            [delegate groupsAvailable:nil error:connectionError];
        }
        else{
            id responseObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@",responseObj);
            [delegate groupsAvailable:responseObj error:nil];
        }
    }];
}

+ (void)postMessage:(NSString*)message toGroup:(NSString*)groupId forDelegate:(id<YMNetworkDelegate>)delegate{
        
    NSMutableData *data = [NSMutableData new];
    [data appendData:[[NSString stringWithFormat:@"%@=%@", @"body",message]
                      dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    [data appendData:[[NSString stringWithFormat:@"&%@=%@", @"group_id",groupId]
                      dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    
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
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"%@",[connectionError description]);
            [delegate messageSentWithError:connectionError];
        }
        else{
            [delegate messageSentWithError:nil];
        }
    }];
}

+ (void)uploadImage:(UIImage*)image toGroup:(NSString*)groupId delegate:(id<YMNetworkDelegate>)delegate
{
    NSData *uploadData = UIImagePNGRepresentation(image);
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://files.yammer.com/v2/files?group_id=%@",groupId]]];
    NSMutableData *postData = [NSMutableData new];
    
    NSString *boundary = @"0YKhTmLbOuNdArY";
    [postData appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"Content-Disposition: form-data; name=\"userfile\"; filename=\"file.png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];


    [postData appendData:uploadData];
    
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"kAccessToken"];

    [urlRequest setValue:[NSString stringWithFormat:@"Bearer %@",accessToken] forHTTPHeaderField:@"Authorization"];
    [urlRequest setValue:@"Accept" forHTTPHeaderField:@"*/*"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
//    [urlRequest setValue:[NSString stringWithFormat:@"%d",[postData length]] forHTTPHeaderField:@"Content-Length"];
//    [urlRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    [urlRequest setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"%@",[connectionError description]);
        }
        else{
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str);
            id responseObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@",responseObj);
        }
    }];
}

@end
