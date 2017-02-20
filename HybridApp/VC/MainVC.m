//
//  MainVC.m
//  HybridApp
//
//  Created by Joseph_iMac on 2017. 2. 17..
//  Copyright © 2017년 Joseph_iMac. All rights reserved.
//

#import "MainVC.h"
#import "UIView+Toast.h"
#import "WebViewVC.h"

@interface MainVC ()

@end

@implementation MainVC

@synthesize mainWebView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *urlString = [NSString stringWithFormat:@"http://snap40.cafe24.com/Hybrid/hybridmain.html"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [mainWebView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSString *)decodeStr:(NSString *)str{
    
    CFStringRef s = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (CFStringRef)str, CFSTR(""), kCFStringEncodingUTF8);
    NSString* decoded = [NSString stringWithFormat:@"%@", (__bridge NSString*)s];
    CFRelease(s);
    return decoded;
}

#pragma mark -
#pragma mark Webview Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    fURL = [NSString stringWithFormat:@"%@", request.URL];
    fURL = [self decodeStr:fURL];
    NSLog(@"fURL : %@", fURL);
    
    if ([[[request URL] absoluteString] hasPrefix:@"js2ios:"]){
        
        // 토스트 메세지
        if([fURL hasPrefix:@"js2ios://showToast?"]){
            NSArray *toastArr1 = [fURL componentsSeparatedByString:@"name="];
            NSString *toastStr1 = [toastArr1 objectAtIndex:1];
            NSArray *toastArr2 = [toastStr1 componentsSeparatedByString:@"&"];
            NSString *toastMsg = [toastArr2 objectAtIndex:0];
            
            [self.navigationController.view makeToast:toastMsg];
        
        // 앱 화면이동(4방향)
        }else if([fURL hasPrefix:@"js2ios://SubActivity?"]){
            NSArray *appArr1 = [fURL componentsSeparatedByString:@"action="];
            NSString *appStr1 = [appArr1 objectAtIndex:1];
            NSArray *appArr2 = [appStr1 componentsSeparatedByString:@"&"];
            NSString *appValue = [appArr2 objectAtIndex:0];
            
            NSArray *urlArr1 = [fURL componentsSeparatedByString:@"url="];
            NSString *urlStr1 = [urlArr1 objectAtIndex:1];
            NSArray *urlArr2 = [urlStr1 componentsSeparatedByString:@"&"];
            NSString *urlValue = [urlArr2 objectAtIndex:0];
            
            NSString *supTypeValue = @"";
            if([appValue isEqualToString:@"top"]){
                supTypeValue = kCATransitionFromTop;
            }else if([appValue isEqualToString:@"bottom"]){
                supTypeValue = kCATransitionFromBottom;
            }else if([appValue isEqualToString:@"left"]){
                supTypeValue = kCATransitionFromLeft;
            }else if([appValue isEqualToString:@"right"]){
                supTypeValue = kCATransitionFromRight;
            }
            
            WebViewVC *_webViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewVC"];
            _webViewVC.urlString = urlValue;
            CATransition *transition = [CATransition animation];
            transition.duration = 0.4;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionPush;
            transition.subtype = supTypeValue;
            [self.view.window.layer addAnimation:transition forKey:nil];
            [self presentViewController:_webViewVC animated:YES completion:nil];
        }
        
        return NO;
    }
    
    return YES;
}

// 웹뷰가 컨텐츠를 읽기 시작한 후에 실행된다.
- (void)webViewDidStartLoad:(UIWebView *)webView{
    //NSLog(@"start");
}

// 웹뷰가 컨텐츠를 모두 읽은 후에 실행된다.
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
}

// 컨텐츠를 읽는 도중 오류가 발생할 경우 실행된다.
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"ERROR : %@", error);
}

#pragma mark -
#pragma mark Button Action

- (IBAction)backButton:(id)sender {
    [mainWebView goBack];
}

- (IBAction)fowardButton:(id)sender {
    [mainWebView goForward];
}

- (IBAction)homeButton:(id)sender {
}

- (IBAction)refreshButton:(id)sender {
    [mainWebView reload];
}

- (IBAction)dropButton:(id)sender {
    NSArray *actionItems = @[mainWebView.request.URL];
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:actionItems applicationActivities:nil];
    
    [self presentViewController:avc animated:YES completion:nil];
}

@end
