//
//  YMWebSnapViewController.m
//  Skitch
//
//  Created by Sumit Kumar on 7/11/13.
//  Copyright (c) 2013 Yammer Inc. All rights reserved.
//

#import "YMWebSnapViewController.h"

static const CGFloat kLabelHeight = 14.0f;
static const CGFloat kMargin = 90.0f;
static const CGFloat kSpacer = 2.0f;
static const CGFloat kLabelFontSize = 12.0f;
static const CGFloat kAddressHeight = 26.0f;

@interface YMWebSnapViewController ()
@end

@implementation YMWebSnapViewController

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
    
    
    // The address field is the same with as the label and located just below
    // it with a gap of kSpacer
    CGRect addressFrame = CGRectMake(kMargin, 5,
                                     self.view.bounds.size.width - 100, self.navBar.frame.size.height - 10);
    UITextField *address = [[UITextField alloc] initWithFrame:addressFrame];
    address.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    address.borderStyle = UITextBorderStyleRoundedRect;
    address.font = [UIFont systemFontOfSize:17];
    address.keyboardType = UIKeyboardTypeURL;
    address.autocapitalizationType = UITextAutocapitalizationTypeNone;
    address.clearButtonMode = UITextFieldViewModeWhileEditing;
    [address addTarget:self
                action:@selector(loadAddress:event:)
      forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.navBar addSubview:address];
    self.addressField = address;
    
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    NSURL* url = [NSURL URLWithString:@"http://www.apple.com"];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    self.back = [[UIButton alloc] initWithFrame:CGRectMake(0, 2, 40, 40)];
    self.forward = [[UIButton alloc] initWithFrame:CGRectMake(40, 2, 40, 40)];
    [self.back setImage:[UIImage imageNamed:@"leftarrow"] forState:UIControlStateNormal];
    [self.forward setImage:[UIImage imageNamed:@"rightarrow"] forState:UIControlStateNormal];
    
    [self.back addTarget:self.webView action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.forward addTarget:self.webView action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navBar addSubview:self.back];
    [self.navBar addSubview:self.forward];
    
    [self updateButtons];
}


- (IBAction)dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)snapWebPage{
    CGSize size = self.webView.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, YES, 1.0);
    
    [self.webView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    [self.delegate snapedImageFromWeb:image];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// MARK: -
// MARK: UI methods

- (void)updateButtons
{
    self.forward.enabled = self.webView.canGoForward;
    self.back.enabled = self.webView.canGoBack;
}

- (void)updateTitle:(UIWebView*)aWebView
{
    NSString* pageTitle = [aWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.pageTitle.text = pageTitle;
}

- (void)updateAddress:(NSURLRequest*)request
{
    NSURL* url = [request mainDocumentURL];
    NSString* absoluteString = [url absoluteString];
    self.addressField.text = absoluteString;
}

- (void)loadAddress:(id)sender event:(UIEvent *)event
{
    NSString* urlString = self.addressField.text;
    NSURL* url = [NSURL URLWithString:urlString];
    if(!url.scheme)
    {
        NSString* modifiedURLString = [NSString stringWithFormat:@"http://%@", urlString];
        url = [NSURL URLWithString:modifiedURLString];
    }
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)informError:(NSError *)error
{
    NSString* localizedDescription = [error localizedDescription];
    UIAlertView* alertView = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:localizedDescription delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}

// MARK: -
// MARK: UIWebViewDelegate protocol
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self updateAddress:request];
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
    [self updateTitle:webView];
    NSURLRequest* request = [webView request];
    [self updateAddress:request];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
    [self informError:error];
}



@end
