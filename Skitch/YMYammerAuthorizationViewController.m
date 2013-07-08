//
//  YMYammerAuthorizationViewController.m
//  Skitch
//
//  Created by Aditi Kamal on 7/6/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMYammerAuthorizationViewController.h"
#import "SVProgressHUD.h"
#import "YMPostViewController.h"

@interface YMYammerAuthorizationViewController ()

@end

@implementation YMYammerAuthorizationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"kAccessToken"];
    if (accessToken) {
        [self goToPostMessage];
    }
    else{
        [self.navigationController setNavigationBarHidden:YES];
        [self getAccessToken];
    }
    
}

- (void)goToPostMessage{
    [self.navigationController setNavigationBarHidden:NO];
    YMPostViewController *postController = [[YMPostViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:postController animated:YES];
}

- (void)getAccessToken{
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.delegate = self;
    [self.view addSubview:webView];
    
    NSString *urlString = @"https://www.yammer.com/dialog/oauth?client_id=09PCeq4LoiTUJpC1gSJQeQ&redirect_uri=http://www.appdios.com&response_type=token";
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    [webView loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    [SVProgressHUD show];

    NSURL *url = [request URL];
    NSLog(@"%@",[url description]);
    if ([[url description] hasPrefix:@"http://www.appdios.com/#access_token="]) {
        NSArray *urlComponents = [[url description] componentsSeparatedByString:@"#access_token="];
        NSString *accessToken = [urlComponents lastObject];
        if (accessToken) {
            [SVProgressHUD dismiss];
            NSLog(@"%@",accessToken);
            [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"kAccessToken"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            webView.delegate = nil;
            [self goToPostMessage];
            return NO;
        }
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
