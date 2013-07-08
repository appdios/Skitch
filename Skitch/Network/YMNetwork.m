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

@end
