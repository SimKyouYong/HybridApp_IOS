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
#import "GlobalHeader.h"
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"
#import "DrawerNavigation.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface MainVC ()<CLLocationManagerDelegate>
@property (strong, nonatomic) DrawerNavigation *rootNav;
@end

@implementation MainVC

@synthesize mainWebView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rootNav = (DrawerNavigation *)self.navigationController;
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    // 로딩관련
    loadingView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 170)/2, (self.view.frame.size.height - 170)/2, 170, 170)];
    loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    loadingView.clipsToBounds = YES;
    loadingView.layer.cornerRadius = 10.0;
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(65, 40, activityView.bounds.size.width, activityView.bounds.size.height);
    [loadingView addSubview:activityView];
    
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, 130, 42)];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.numberOfLines = 2;
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.adjustsFontSizeToFitWidth = YES;
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = [NSString stringWithFormat:@"로딩중..."];
    [loadingView addSubview:loadingLabel];
    [self.view addSubview:loadingView];
    loadingView.hidden = YES;
    
    NSString *urlString = [NSString stringWithFormat:@"http://snap40.cafe24.com/Hybrid/hybridmain.html"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [mainWebView loadRequest:request];
    
    popupView = [[PopupView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:popupView];
    popupView.hidden = YES;
    
    [self.view bringSubviewToFront:loadingView];
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && [self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [_locationManager requestWhenInUseAuthorization];
    }
    else
    {
        [self.locationManager startUpdatingLocation];
        [self.locationManager stopUpdatingLocation];
    }
}

#pragma mark -
#pragma mark Network Connect

- (BOOL)connectedToNetwork
{
    /*
     www.apple.com URL을 통해 인터넷 연결 상태를 확인합니다.
     ReachableViaWiFi && ReachableViaWWAN
     : Wi-fi와 LTE 둘다 안된다면 인터넷이 연결되지 않은 상태입니다.
     */
    
    Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    BOOL internet;
    
    if ((internetStatus != ReachableViaWiFi) && (internetStatus != ReachableViaWWAN)) {
        internet = NO;
    } else {
        internet = YES;
    }
    return internet;
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
            
            NSArray *titleArr1 = [fURL componentsSeparatedByString:@"title="];
            NSString *titleStr1 = [titleArr1 objectAtIndex:1];
            NSArray *titleArr2 = [titleStr1 componentsSeparatedByString:@"&"];
            NSString *titleValue = [titleArr2 objectAtIndex:0];
            
            NSArray *buttonArr1 = [fURL componentsSeparatedByString:@"button="];
            NSString *buttonStr1 = [buttonArr1 objectAtIndex:1];
            NSArray *buttonArr2 = [buttonStr1 componentsSeparatedByString:@"&"];
            NSString *buttonValue = [buttonArr2 objectAtIndex:0];
            
            NSArray *buttonUrlArr1 = [fURL componentsSeparatedByString:@"button_url="];
            NSString *buttonUrlStr1 = [buttonUrlArr1 objectAtIndex:1];
            NSArray *buttonUrlArr2 = [buttonUrlStr1 componentsSeparatedByString:@"&"];
            NSString *buttonUrlValue = [buttonUrlArr2 objectAtIndex:0];
            
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
            _webViewVC.titleString = titleValue;
            _webViewVC.buttonString = buttonValue;
            _webViewVC.buttonUrlString = buttonUrlValue;
            
            CATransition *transition = [CATransition animation];
            transition.duration = 0.4;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionPush;
            transition.subtype = supTypeValue;
            [self.view.window.layer addAnimation:transition forKey:nil];
            [self.rootNav pushViewController:_webViewVC animated:NO];
            //[self presentViewController:_webViewVC animated:YES completion:nil];
        
        // 위도 경도
        }else if([fURL hasPrefix:@"js2ios://Location?"]){
            CLLocationManager *locationManager = [[CLLocationManager alloc] init];
            [locationManager startUpdatingLocation];
            [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
            [locationManager setDelegate:self];
            
            CLLocation* location = [locationManager location];
            CLLocationCoordinate2D coordinate = [location coordinate];
            
            NSString *alertMsg = [NSString stringWithFormat:@"위도 : %f\n경도 : %f", coordinate.latitude, coordinate.longitude];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:alertMsg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
            [alertView show];
        
        //ISP 호출하는 경우
        }else if([fURL hasPrefix:@"ispmobile://"]) {
                NSURL *appURL = [NSURL URLWithString:fURL];
                if([[UIApplication sharedApplication] canOpenURL:appURL]) {
                    [[UIApplication sharedApplication] openURL:appURL];
                } else {
                    //[self showAlertViewWithEvent:@"모바일 ISP가 설치되어 있지 않아\nApp Store로 이동합니다." tagNum:99];
                    return NO;
                }
            }
        
        return NO;
    }
    
    return YES;
}

// 웹뷰가 컨텐츠를 읽기 시작한 후에 실행된다.
- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"start");
    
    if([INTERNET_ON_OFF isEqualToString:@"ON"]){
        if([self connectedToNetwork] == 0){
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"네트워크에 접속할 수 없습니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
            [alertView show];
        }else{
            [self loadingStart];
        }
    }
}

// 웹뷰가 컨텐츠를 모두 읽은 후에 실행된다.
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"end");
    [self loadingEnd];
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
    NSString *urlString = [NSString stringWithFormat:@"http://snap40.cafe24.com/Hybrid/hybridmain.html"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [mainWebView loadRequest:request];
}

- (IBAction)refreshButton:(id)sender {
    [mainWebView reload];
}

- (IBAction)dropButton:(id)sender {
    NSArray *actionItems = @[mainWebView.request.URL];
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:actionItems applicationActivities:nil];
    
    [self presentViewController:avc animated:YES completion:nil];
}

#pragma mark -
#pragma mark Loading Method

- (void)loadingStart{
    if([POPUP_VIEW_ON_OFF isEqualToString:@"ON"]){
        popupView.hidden = NO;
    }
    if([PROGRESS_ON_OFF isEqualToString:@"ON"]){
        loadingView.hidden = NO;
        [activityView startAnimating];
    }
}

- (void)loadingEnd{
    loadingView.hidden = YES;
    [activityView stopAnimating];
    popupView.hidden = YES;
}

#pragma mark -
#pragma mark GPS

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", [locations lastObject]);
}

- (void)startStandardUpdates {
    NSLog(@"startStandardUpdates");
}

@end

@implementation UIWebView (Javascript)
- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id *)frame {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
    [alert show];
}
@end
