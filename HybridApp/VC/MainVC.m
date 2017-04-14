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
#import "GlobalObject.h"
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"
#import "DrawerNavigation.h"
#import "KeychainItemWrapper.h"
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import <KakaoLink/KakaoLink.h>
#import <AddressBook/AddressBook.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface MainVC ()<CLLocationManagerDelegate>
@property (strong, nonatomic) DrawerNavigation *rootNav;
@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(push:) name:@"reloadWebView" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(token:) name:@"tokenInit" object:nil];
    
    self.rootNav = (DrawerNavigation *)self.navigationController;
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    if([[defaults stringForKey:SLIDE_MOVE] isEqualToString:@"FALSE"]){
        WebViewVC *_webViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewVC"];
        _webViewVC.urlString = [defaults stringForKey:SLIDE_MOVE_URL];
        _webViewVC.titleString = [defaults stringForKey:SLIDE_MOVE_TITLE];
        _webViewVC.buttonString = [defaults stringForKey:SLIDE_MOVE_BUTTON_TITLE];
        _webViewVC.buttonUrlString = [defaults stringForKey:SLIDE_MOVE_BUTTON_URL];
        _webViewVC.viewNum = @"2";
        
        [self.rootNav pushViewController:_webViewVC animated:NO];
    }else{
        // 웹뷰
        mainWebView = [[UIWebView alloc] init];
        mainWebView.delegate = self;
        mainWebView.scalesPageToFit = YES;
        [self.view addSubview:mainWebView];
        
        // 주소변환
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        [locationManager startUpdatingLocation];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        [locationManager setDelegate:self];
        
        CLLocation* location = [locationManager location];
        CLLocationCoordinate2D coordinate = [location coordinate];
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                NSLog(@"Failed to reverse-geocode: %@", [error localizedDescription]);
                return;
            }
            
            NSString *addressValue;
            
            for(CLPlacemark *placemark in placemarks){
                NSString *country = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressCountryKey];
                NSString *state = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressStateKey];
                NSString *city = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressCityKey];
                NSString *street = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressStreetKey];
                
                addressValue = [NSString stringWithFormat:@"%@ %@ %@ %@", country, state, city, street];
            }
            
            NSString *urlString = [NSString stringWithFormat:@"http://emview.godohosting.com/api_help.php?a=%f&b=%f&c=%@&d=%@&e=%@" , coordinate.latitude , coordinate.longitude , addressValue , [self getUUID] , @""];
            NSString *encodedString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSURL *weburl = [NSURL URLWithString:encodedString];
            NSURL *url = weburl;
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [mainWebView loadRequest:request];
        }];
        
        // 버튼 뷰
        buttonView = [[UIView alloc] init];
        buttonView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:buttonView];
        
        // 웹뷰 하단 버튼 뷰
        webviewBottomView = [[UIView alloc] init];
        webviewBottomView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:webviewBottomView];
        
        [self viewFrameInit];
        [self viewBottomButtonBgInit];
        [self viewBottomWebviewBgInit];
        
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
        [button1 setTitle:@"버튼1" forState:UIControlStateNormal];
        [button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button1.frame = CGRectMake(0, 0, WIDTH_FRAME/5, 50);
        [button1 addTarget:self action:@selector(button1Action:) forControlEvents:UIControlEventTouchUpInside];
        [buttonView addSubview:button1];
        
        UIView *heightLine1 = [[UIView alloc] initWithFrame:CGRectMake(WIDTH_FRAME/5 - 0.5, 0, 1, 50)];
        heightLine1.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        [buttonView addSubview:heightLine1];
        
        UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
        [button2 setTitle:@"버튼2" forState:UIControlStateNormal];
        [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button2.frame = CGRectMake(WIDTH_FRAME/5, 0, WIDTH_FRAME/5, 50);
        [button2 addTarget:self action:@selector(button2Action:) forControlEvents:UIControlEventTouchUpInside];
        [buttonView addSubview:button2];
        
        UIView *heightLine2 = [[UIView alloc] initWithFrame:CGRectMake((WIDTH_FRAME/5)*2 - 0.5, 0, 1, 50)];
        heightLine2.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        [buttonView addSubview:heightLine2];
        
        UIButton *button3 = [UIButton buttonWithType:UIButtonTypeSystem];
        [button3 setTitle:@"버튼3" forState:UIControlStateNormal];
        [button3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button3.frame = CGRectMake((WIDTH_FRAME/5)*2, 0, WIDTH_FRAME/5, 50);
        [button3 addTarget:self action:@selector(button3Action:) forControlEvents:UIControlEventTouchUpInside];
        [buttonView addSubview:button3];
        
        UIView *heightLine3 = [[UIView alloc] initWithFrame:CGRectMake((WIDTH_FRAME/5)*3 - 0.5, 0, 1, 50)];
        heightLine3.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        [buttonView addSubview:heightLine3];
        
        UIButton *button4 = [UIButton buttonWithType:UIButtonTypeSystem];
        [button4 setTitle:@"버튼4" forState:UIControlStateNormal];
        [button4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button4.frame = CGRectMake((WIDTH_FRAME/5)*3, 0, WIDTH_FRAME/5, 50);
        [button4 addTarget:self action:@selector(button4Action:) forControlEvents:UIControlEventTouchUpInside];
        [buttonView addSubview:button4];
        
        UIView *heightLine4 = [[UIView alloc] initWithFrame:CGRectMake((WIDTH_FRAME/5)*4 - 0.5, 0, 1, 50)];
        heightLine4.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        [buttonView addSubview:heightLine4];
        
        UIButton *button5 = [UIButton buttonWithType:UIButtonTypeSystem];
        [button5 setTitle:@"버튼5" forState:UIControlStateNormal];
        [button5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button5.frame = CGRectMake((WIDTH_FRAME/5)*4, 0, WIDTH_FRAME/5, 50);
        [button5 addTarget:self action:@selector(button5Action:) forControlEvents:UIControlEventTouchUpInside];
        [buttonView addSubview:button5];
        
        UIView *centerLine = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT_FRAME - 50.5, WIDTH_FRAME, 1)];
        centerLine.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        [self.view addSubview:centerLine];
        
        backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_prev"]];
        backImage.frame = CGRectMake((WIDTH_FRAME/5)/2 - 15, 10, 30, 30);
        [webviewBottomView addSubview:backImage];
        
        fowardImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_next"]];
        fowardImage.frame = CGRectMake((WIDTH_FRAME/5) + ((WIDTH_FRAME/5)/2 - 15), 10, 30, 30);
        [webviewBottomView addSubview:fowardImage];
        
        homeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_home"]];
        homeImage.frame = CGRectMake((WIDTH_FRAME/5)*2 + ((WIDTH_FRAME/5)/2 - 15), 10, 30, 30);
        [webviewBottomView addSubview:homeImage];
        
        reloadImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_reload"]];
        reloadImage.frame = CGRectMake((WIDTH_FRAME/5)*3 + ((WIDTH_FRAME/5)/2 - 15), 10, 30, 30);
        [webviewBottomView addSubview:reloadImage];
        
        shareImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_share"]];
        shareImage.frame = CGRectMake((WIDTH_FRAME/5)*4 + ((WIDTH_FRAME/5)/2 - 15), 10, 30, 30);
        [webviewBottomView addSubview:shareImage];
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0, WIDTH_FRAME/5, 50);
        [backButton addTarget:self action:@selector(backButton:) forControlEvents:UIControlEventTouchUpInside];
        [webviewBottomView addSubview:backButton];
        
        UIButton *fowardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        fowardButton.frame = CGRectMake(WIDTH_FRAME/5, 0, WIDTH_FRAME/5, 50);
        [fowardButton addTarget:self action:@selector(fowardButton:) forControlEvents:UIControlEventTouchUpInside];
        [webviewBottomView addSubview:fowardButton];
        
        UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        homeButton.frame = CGRectMake((WIDTH_FRAME/5)*2, 0, WIDTH_FRAME/5, 50);
        [homeButton addTarget:self action:@selector(homeButton:) forControlEvents:UIControlEventTouchUpInside];
        [webviewBottomView addSubview:homeButton];
        
        UIButton *reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        reloadButton.frame = CGRectMake((WIDTH_FRAME/5)*3, 0, WIDTH_FRAME/5, 50);
        [reloadButton addTarget:self action:@selector(reloadButton:) forControlEvents:UIControlEventTouchUpInside];
        [webviewBottomView addSubview:reloadButton];
        
        UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shareButton.frame = CGRectMake((WIDTH_FRAME/5)*4, 0, WIDTH_FRAME/5, 50);
        [shareButton addTarget:self action:@selector(shareButton:) forControlEvents:UIControlEventTouchUpInside];
        [webviewBottomView addSubview:shareButton];
        
        popupView = [[PopupView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [self.view addSubview:popupView];
        popupView.hidden = YES;
        
        // 로딩관련
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.frame = CGRectMake(self.view.frame.size.width/2 - activityView.bounds.size.width/2, self.view.frame.size.height/2 - activityView.bounds.size.height/2, activityView.bounds.size.width, activityView.bounds.size.height);
        activityView.color = [UIColor blackColor];
        [self.view addSubview:activityView];
        [self.view bringSubviewToFront:activityView];
    }
    
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

// 하단 뷰 숨기기, 배경색
- (void)viewFrameInit{
    if([[defaults stringForKey:BOTTOM_BUTTON_HIDDEN] isEqualToString:@"NO"] || [defaults stringForKey:BOTTOM_BUTTON_HIDDEN].length == 0){
        buttonView.hidden = NO;
        if([[defaults stringForKey:BOTTOM_WEBVIEW_HIDDEN] isEqualToString:@"NO"] || [defaults stringForKey:BOTTOM_WEBVIEW_HIDDEN].length == 0){
            mainWebView.frame = CGRectMake(0, 0, WIDTH_FRAME, HEIGHT_FRAME - 100);
            buttonView.frame = CGRectMake(0, HEIGHT_FRAME - 100, WIDTH_FRAME, 50);
            webviewBottomView.frame = CGRectMake(0, HEIGHT_FRAME - 50, WIDTH_FRAME, 50);
            webviewBottomView.hidden = NO;
        }else{
            mainWebView.frame = CGRectMake(0, 0, WIDTH_FRAME, HEIGHT_FRAME - 50);
            buttonView.frame = CGRectMake(0, HEIGHT_FRAME - 50, WIDTH_FRAME, 50);
            webviewBottomView.hidden = YES;
        }
    }else{
        buttonView.hidden = YES;
       if([[defaults stringForKey:BOTTOM_WEBVIEW_HIDDEN] isEqualToString:@"NO"] || [defaults stringForKey:BOTTOM_WEBVIEW_HIDDEN].length == 0){
           mainWebView.frame = CGRectMake(0, 0, WIDTH_FRAME, HEIGHT_FRAME - 50);
           webviewBottomView.frame = CGRectMake(0, HEIGHT_FRAME - 50, WIDTH_FRAME, 50);
           webviewBottomView.hidden = NO;
       }else{
           mainWebView.frame = CGRectMake(0, 0, WIDTH_FRAME, HEIGHT_FRAME);
           webviewBottomView.hidden = YES;
       }
    }
    
    popupViewWhite = [[UIView alloc] init];
    popupViewWhite.frame = CGRectMake(0, 0, mainWebView.frame.size.width, mainWebView.frame.size.height);
    popupViewWhite.backgroundColor = [UIColor whiteColor];
    //popupViewWhite.alpha = 0.8;
    [self.view addSubview:popupViewWhite];
    popupViewWhite.hidden = YES;
}

- (void)viewBottomButtonBgInit{
    NSString *bgColor = [defaults stringForKey:BOTTOM_BUTTON_COLOR];
    if([bgColor isEqualToString:@"default"] || bgColor.length == 0){
        buttonView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    }else{
        bgColor = [bgColor stringByReplacingOccurrencesOfString:@"#" withString:@""];
        buttonView.backgroundColor = [self colorWithHexString:bgColor];
    }
}

- (void)viewBottomWebviewBgInit{
    backImage.image = [UIImage imageNamed:@"tab_prev"];
    fowardImage.image = [UIImage imageNamed:@"tab_next"];
    homeImage.image = [UIImage imageNamed:@"tab_home"];
    reloadImage.image = [UIImage imageNamed:@"tab_reload"];
    shareImage.image = [UIImage imageNamed:@"tab_share"];
    
    NSString *bgColor = [defaults stringForKey:BOTTOM_WEBVIEW_COLOR];
    if([bgColor isEqualToString:@"default"] || bgColor.length == 0){
        webviewBottomView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    }else{
        bgColor = [bgColor stringByReplacingOccurrencesOfString:@"#" withString:@""];
        if([bgColor isEqualToString:@"32353c"]){
            backImage.image = [UIImage imageNamed:@"tab_prev_w"];
            fowardImage.image = [UIImage imageNamed:@"tab_next_w"];
            homeImage.image = [UIImage imageNamed:@"tab_home_w"];
            reloadImage.image = [UIImage imageNamed:@"tab_reload_w"];
            shareImage.image = [UIImage imageNamed:@"tab_share_w"];
        }
        webviewBottomView.backgroundColor = [self colorWithHexString:bgColor];
    }
}

#pragma mark -
#pragma mark Button View

- (void)button1Action:(UIButton*)sender{
    NSURL *url = [NSURL URLWithString:@"https://m.naver.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [mainWebView loadRequest:request];
}

- (void)button2Action:(UIButton*)sender{
    NSURL *url = [NSURL URLWithString:@"http://m.daum.net"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [mainWebView loadRequest:request];
}

- (void)button3Action:(UIButton*)sender{
    NSURL *url = [NSURL URLWithString:@"https://www.google.co.kr"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [mainWebView loadRequest:request];
}

- (void)button4Action:(UIButton*)sender{
    NSURL *url = [NSURL URLWithString:@"https://www.yahoo.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [mainWebView loadRequest:request];
}

- (void)button5Action:(UIButton*)sender{
    NSURL *url = [NSURL URLWithString:@"http://m.11st.co.kr/MW/html/main.html"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [mainWebView loadRequest:request];
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
        
        // 로딩바 보이기 숨기기
        if([fURL hasPrefix:@"js2ios://ProgressBar?"]){
            NSArray *loadingArr1 = [fURL componentsSeparatedByString:@"name="];
            NSString *loadingStr1 = [loadingArr1 objectAtIndex:1];
            NSArray *loadingArr2 = [loadingStr1 componentsSeparatedByString:@"&"];
            NSString *loadingMsg = [loadingArr2 objectAtIndex:0];
            
            NSArray *loadingArr3 = [fURL componentsSeparatedByString:@"return="];
            NSString *loadingStr3 = [loadingArr3 objectAtIndex:1];
            NSArray *loadingArr4 = [loadingStr3 componentsSeparatedByString:@"&"];
            NSString *loadingReturn = [loadingArr4 objectAtIndex:0];
            
            if([loadingMsg isEqualToString:@"true"]){
                [defaults setObject:@"true" forKey:LOADINGBAR_HIDDEN];
            }else{
                [defaults setObject:@"false" forKey:LOADINGBAR_HIDDEN];
            }
            [defaults setObject:@"false" forKey:LOADINGBAR_TIME];
            
            NSString *javaValue = [NSString stringWithFormat:@"javascript:%@('%@')", loadingReturn, loadingMsg];
            [mainWebView stringByEvaluatingJavaScriptFromString:javaValue];
            
        // 로딩바 3초 딜레이 완료후
        }else if([fURL hasPrefix:@"js2ios://ProgressBar3?"]){
            NSArray *loadingArr1 = [fURL componentsSeparatedByString:@"name="];
            NSString *loadingStr1 = [loadingArr1 objectAtIndex:1];
            NSArray *loadingArr2 = [loadingStr1 componentsSeparatedByString:@"&"];
            NSString *loadingMsg = [loadingArr2 objectAtIndex:0];
            
            NSArray *loadingArr3 = [fURL componentsSeparatedByString:@"return="];
            NSString *loadingStr3 = [loadingArr3 objectAtIndex:1];
            NSArray *loadingArr4 = [loadingStr3 componentsSeparatedByString:@"&"];
            NSString *loadingReturn = [loadingArr4 objectAtIndex:0];
            
            if([loadingMsg isEqualToString:@"true"]){
                 [defaults setObject:@"true" forKey:LOADINGBAR_TIME];
            }else{
                 [defaults setObject:@"false" forKey:LOADINGBAR_TIME];
            }
            
            NSString *javaValue = [NSString stringWithFormat:@"javascript:%@('%@')", loadingReturn, loadingMsg];
            [mainWebView stringByEvaluatingJavaScriptFromString:javaValue];
            
        // 토스트 메세지
        }else if([fURL hasPrefix:@"js2ios://showToast?"]){
            NSArray *toastArr1 = [fURL componentsSeparatedByString:@"name="];
            NSString *toastStr1 = [toastArr1 objectAtIndex:1];
            NSArray *toastArr2 = [toastStr1 componentsSeparatedByString:@"&"];
            NSString *toastMsg = [toastArr2 objectAtIndex:0];
            
            [self.navigationController.view makeToast:toastMsg];
        
        // 앱 화면이동(4방향)
        }else if([fURL hasPrefix:@"js2ios://SubNotActivity?"]){
            NSArray *appArr1 = [fURL componentsSeparatedByString:@"action="];
            NSString *appStr1 = [appArr1 objectAtIndex:1];
            NSArray *appArr2 = [appStr1 componentsSeparatedByString:@"&"];
            NSString *appValue = [appArr2 objectAtIndex:0];
            
            NSArray *urlArr1 = [fURL componentsSeparatedByString:@"url="];
            NSString *urlStr1 = [urlArr1 objectAtIndex:1];
            NSArray *urlArr2 = [urlStr1 componentsSeparatedByString:@"&"];
            [defaults setObject:[urlArr2 objectAtIndex:0] forKey:SLIDE_MOVE_URL];
            
            NSArray *titleArr1 = [fURL componentsSeparatedByString:@"title="];
            NSString *titleStr1 = [titleArr1 objectAtIndex:1];
            NSArray *titleArr2 = [titleStr1 componentsSeparatedByString:@"&"];
            [defaults setObject:[titleArr2 objectAtIndex:0] forKey:SLIDE_MOVE_TITLE];
            
            NSArray *buttonArr1 = [fURL componentsSeparatedByString:@"button="];
            NSString *buttonStr1 = [buttonArr1 objectAtIndex:1];
            NSArray *buttonArr2 = [buttonStr1 componentsSeparatedByString:@"&"];
            [defaults setObject:[buttonArr2 objectAtIndex:0] forKey:SLIDE_MOVE_BUTTON_TITLE];
            
            NSArray *buttonUrlArr1 = [fURL componentsSeparatedByString:@"button_url="];
            NSString *buttonUrlStr1 = [buttonUrlArr1 objectAtIndex:1];
            NSArray *buttonUrlArr2 = [buttonUrlStr1 componentsSeparatedByString:@"&"];
            [defaults setObject:[buttonUrlArr2 objectAtIndex:0] forKey:SLIDE_MOVE_BUTTON_URL];
            
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
            _webViewVC.urlString = [defaults stringForKey:SLIDE_MOVE_URL];
            _webViewVC.titleString = [defaults stringForKey:SLIDE_MOVE_TITLE];
            _webViewVC.buttonString = [defaults stringForKey:SLIDE_MOVE_BUTTON_TITLE];
            _webViewVC.buttonUrlString = [defaults stringForKey:SLIDE_MOVE_BUTTON_URL];
            _webViewVC.viewNum = @"1";
            
            CATransition *transition = [CATransition animation];
            transition.duration = 0.4;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionPush;
            transition.subtype = supTypeValue;
            [self.view.window.layer addAnimation:transition forKey:nil];
            [self.rootNav pushViewController:_webViewVC animated:NO];
            //[self presentViewController:_webViewVC animated:YES completion:nil];
            
        // 슬라이드 메뉴화면
        }else if([fURL hasPrefix:@"js2ios://SubActivity?"]){
            NSArray *urlArr1 = [fURL componentsSeparatedByString:@"url="];
            NSString *urlStr1 = [urlArr1 objectAtIndex:1];
            NSArray *urlArr2 = [urlStr1 componentsSeparatedByString:@"&"];
            [defaults setObject:[urlArr2 objectAtIndex:0] forKey:SLIDE_MOVE_URL];
            
            NSArray *titleArr1 = [fURL componentsSeparatedByString:@"title="];
            NSString *titleStr1 = [titleArr1 objectAtIndex:1];
            NSArray *titleArr2 = [titleStr1 componentsSeparatedByString:@"&"];
            [defaults setObject:[titleArr2 objectAtIndex:0] forKey:SLIDE_MOVE_TITLE];
            
            NSArray *buttonArr1 = [fURL componentsSeparatedByString:@"button="];
            NSString *buttonStr1 = [buttonArr1 objectAtIndex:1];
            NSArray *buttonArr2 = [buttonStr1 componentsSeparatedByString:@"&"];
            [defaults setObject:[buttonArr2 objectAtIndex:0] forKey:SLIDE_MOVE_BUTTON_TITLE];
            
            NSArray *buttonUrlArr1 = [fURL componentsSeparatedByString:@"button_url="];
            NSString *buttonUrlStr1 = [buttonUrlArr1 objectAtIndex:1];
            NSArray *buttonUrlArr2 = [buttonUrlStr1 componentsSeparatedByString:@"&"];
            [defaults setObject:[buttonUrlArr2 objectAtIndex:0] forKey:SLIDE_MOVE_BUTTON_URL];
            
            NSArray *splitArr1 = [fURL componentsSeparatedByString:@"new="];
            NSString *splitStr1 = [splitArr1 objectAtIndex:1];
            NSArray *splitArr2 = [splitStr1 componentsSeparatedByString:@"&"];
            MENU_IMAGE_SPLIT = [splitArr2 objectAtIndex:0];
            
            WebViewVC *_webViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"webViewVC"];
            _webViewVC.urlString = [defaults stringForKey:SLIDE_MOVE_URL];
            _webViewVC.titleString = [defaults stringForKey:SLIDE_MOVE_TITLE];
            _webViewVC.buttonString = [defaults stringForKey:SLIDE_MOVE_BUTTON_TITLE];
            _webViewVC.buttonUrlString = [defaults stringForKey:SLIDE_MOVE_BUTTON_URL];
            _webViewVC.viewNum = @"2";
            
            [self.rootNav pushViewController:_webViewVC animated:NO];
          
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
        
        // ISP 호출하는 경우
        }else if([fURL hasPrefix:@"ispmobile://"]) {
            NSURL *appURL = [NSURL URLWithString:fURL];
            if([[UIApplication sharedApplication] canOpenURL:appURL]) {
                [[UIApplication sharedApplication] openURL:appURL];
            } else {
                //[self showAlertViewWithEvent:@"모바일 ISP가 설치되어 있지 않아\nApp Store로 이동합니다." tagNum:99];
                return NO;
            }
        
        // 카카오톡 웹링크
        }else if([fURL hasPrefix:@"js2ios://kakaoshareweb?"]) {
            NSArray *talkArr1 = [fURL componentsSeparatedByString:@"url="];
            NSString *talkStr1 = [talkArr1 objectAtIndex:1];
            NSArray *talkArr2 = [talkStr1 componentsSeparatedByString:@"&"];
            urlValue = [talkArr2 objectAtIndex:0];
            
            NSArray *talkArr3 = [fURL componentsSeparatedByString:@"name="];
            NSString *talkStr3 = [talkArr3 objectAtIndex:1];
            NSArray *talkArr4 = [talkStr3 componentsSeparatedByString:@"&"];
            NSString *nameValue = [talkArr4 objectAtIndex:0];
            
            NSArray *talkArr5 = [fURL componentsSeparatedByString:@"return="];
            NSString *talkStr5 = [talkArr5 objectAtIndex:1];
            NSArray *talkArr6 = [talkStr5 componentsSeparatedByString:@"&"];
            NSString *returnValue = [talkArr6 objectAtIndex:0];
            
            KLKTemplate *template = [KLKFeedTemplate feedTemplateWithBuilderBlock:^(KLKFeedTemplateBuilder * _Nonnull feedTemplateBuilder) {
                // 컨텐츠
                feedTemplateBuilder.content = [KLKContentObject contentObjectWithBuilderBlock:^(KLKContentBuilder * _Nonnull contentBuilder) {
                    contentBuilder.title = @"WEB";
                    contentBuilder.desc = @"";
                    contentBuilder.imageURL = [NSURL URLWithString:@"http://mud-kage.kakao.co.kr/dn/NTmhS/btqfEUdFAUf/FjKzkZsnoeE4o19klTOVI1/openlink_640x640s.jpg"];
                    contentBuilder.link = [KLKLinkObject linkObjectWithBuilderBlock:^(KLKLinkBuilder * _Nonnull linkBuilder) {
                        linkBuilder.mobileWebURL = [NSURL URLWithString:@"https://dev.kakao.com"];
                    }];
                }];
                
                // 버튼
                [feedTemplateBuilder addButton:[KLKButtonObject buttonObjectWithBuilderBlock:^(KLKButtonBuilder * _Nonnull buttonBuilder) {
                    buttonBuilder.title = @"웹으로 이동";
                    buttonBuilder.link = [KLKLinkObject linkObjectWithBuilderBlock:^(KLKLinkBuilder * _Nonnull linkBuilder) {
                        linkBuilder.mobileWebURL = [NSURL URLWithString:@"http://www.naver.com"];
                    }];
                }]];
            }];
            
            [[KLKTalkLinkCenter sharedCenter] sendDefaultWithTemplate:template success:^(NSDictionary<NSString *,NSString *> * _Nullable warningMsg, NSDictionary<NSString *,NSString *> * _Nullable argumentMsg) {
                // 성공
            } failure:^(NSError * _Nonnull error) {
                // 에러
            } handledFailure:^(NSError * _Nonnull error) {
                // SDK에 의해 처리된 에러
            }];

        // 카카오톡 앱링크
        }else if([fURL hasPrefix:@"js2ios://kakaoshare?"]) {
            NSArray *talkArr1 = [fURL componentsSeparatedByString:@"url="];
            NSString *talkStr1 = [talkArr1 objectAtIndex:1];
            NSArray *talkArr2 = [talkStr1 componentsSeparatedByString:@"&"];
            urlValue = [talkArr2 objectAtIndex:0];
            
            NSArray *talkArr3 = [fURL componentsSeparatedByString:@"name="];
            NSString *talkStr3 = [talkArr3 objectAtIndex:1];
            NSArray *talkArr4 = [talkStr3 componentsSeparatedByString:@"&"];
            NSString *nameValue = [talkArr4 objectAtIndex:0];
            
            NSArray *talkArr5 = [fURL componentsSeparatedByString:@"return="];
            NSString *talkStr5 = [talkArr5 objectAtIndex:1];
            NSArray *talkArr6 = [talkStr5 componentsSeparatedByString:@"&"];
            NSString *returnValue = [talkArr6 objectAtIndex:0];
            
            KLKTemplate *template = [KLKFeedTemplate feedTemplateWithBuilderBlock:^(KLKFeedTemplateBuilder * _Nonnull feedTemplateBuilder) {
                feedTemplateBuilder.content = [KLKContentObject contentObjectWithBuilderBlock:^(KLKContentBuilder * _Nonnull contentBuilder) {
                    contentBuilder.title = @"APP";
                    contentBuilder.desc = @"";
                    contentBuilder.imageURL = [NSURL URLWithString:@""];
                    contentBuilder.link = [KLKLinkObject linkObjectWithBuilderBlock:^(KLKLinkBuilder * _Nonnull linkBuilder) {
                        linkBuilder.mobileWebURL = [NSURL URLWithString:@""];
                    }];
                }];
                
                 [feedTemplateBuilder addButton:[KLKButtonObject buttonObjectWithBuilderBlock:^(KLKButtonBuilder * _Nonnull buttonBuilder) {
                     buttonBuilder.title = @"앱으로 이동";
                     buttonBuilder.link = [KLKLinkObject linkObjectWithBuilderBlock:^(KLKLinkBuilder * _Nonnull linkBuilder) {
                         linkBuilder.iosExecutionParams = [NSString stringWithFormat:@"key=%@&return=%@", urlValue, returnValue];
                         linkBuilder.androidExecutionParams = [NSString stringWithFormat:@"key=%@&return=%@", urlValue, returnValue];
                     }];
                 }]];
            }];
            
            [[KLKTalkLinkCenter sharedCenter] sendDefaultWithTemplate:template success:^(NSDictionary<NSString *,NSString *> * _Nullable warningMsg, NSDictionary<NSString *,NSString *> * _Nullable argumentMsg) {
                // 성공
            } failure:^(NSError * _Nonnull error) {
                // 에러
            } handledFailure:^(NSError * _Nonnull error) {
                // SDK에 의해 처리된 에러
            }];
            
            /*
            if ([KOAppCall canOpenKakaoTalkAppLink]) {
                [KOAppCall openKakaoTalkAppLink:[self dummyLinkObjects]];
            } else {
                NSLog(@"Cannot open kakaotalk.");
            }
             */
            
        // 디바이스 넘버
        }else if([fURL hasPrefix:@"js2ios://GetPhoneId?"]){
            NSString *deviceValue = [NSString stringWithFormat:@"javascript:setDeviceidNumber('%@')", [self getUUID]];
            [mainWebView stringByEvaluatingJavaScriptFromString:deviceValue];
        
        // 앱 화면이동 숨기기
        }else if([fURL hasPrefix:@"js2ios://SETEXIT_TYPE1?"]){
            NSArray *alertArr1 = [fURL componentsSeparatedByString:@"name="];
            NSString *alertStr1 = [alertArr1 objectAtIndex:1];
            NSArray *alertArr2 = [alertStr1 componentsSeparatedByString:@"&"];
            NSString *alertValue = [alertArr2 objectAtIndex:0];
            
            if([alertValue isEqualToString:@"true"]){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"true" delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
                [alertView show];
            }
            
            [defaults setObject:@"TRUE" forKey:SLIDE_MOVE];
        
        // 앱 화면이동 보이기
        }else if([fURL hasPrefix:@"js2ios://SETEXIT_TYPE2?"]){
            NSArray *alertArr1 = [fURL componentsSeparatedByString:@"name="];
            NSString *alertStr1 = [alertArr1 objectAtIndex:1];
            NSArray *alertArr2 = [alertStr1 componentsSeparatedByString:@"&"];
            NSString *alertValue = [alertArr2 objectAtIndex:0];
            
            if([alertValue isEqualToString:@"false"]){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"false" delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil];
                [alertView show];
            }
            
            [defaults setObject:@"FALSE" forKey:SLIDE_MOVE];
            
        // 위도, 경도 넘기기
        }else if([fURL hasPrefix:@"js2ios://setPageNum?"]){
            NSArray *locationArr1 = [fURL componentsSeparatedByString:@"return="];
            NSString *locationStr1 = [locationArr1 objectAtIndex:1];
            NSArray *locationArr2 = [locationStr1 componentsSeparatedByString:@"&"];
            NSString *locationValue = [locationArr2 objectAtIndex:0];
            
            CLLocationManager *locationManager = [[CLLocationManager alloc] init];
            [locationManager startUpdatingLocation];
            [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
            [locationManager setDelegate:self];
            
            CLLocation* location = [locationManager location];
            CLLocationCoordinate2D coordinate = [location coordinate];
            
            NSString *javaValue = [NSString stringWithFormat:@"javascript:%@('%f','%f','%@','')", locationValue, coordinate.latitude, coordinate.longitude, [self getUUID]];
            [mainWebView stringByEvaluatingJavaScriptFromString:javaValue];
        }
    
        return NO;
    }else if ([[[request URL] absoluteString] hasPrefix:@"hybridapi:"]){
     
        // 하단 버튼 메뉴 bg
        if([fURL hasPrefix:@"hybridapi://new_setBottomMenuStyle?"]){
            NSArray *bgArr = [fURL componentsSeparatedByString:@"?"];
            NSString *bgStr = [bgArr objectAtIndex:1];
            if([bgStr isEqualToString:@"default"]){
                bgStr = @"default";
            }
            [defaults setObject:bgStr forKey:BOTTOM_BUTTON_COLOR];
            
            [self viewBottomButtonBgInit];
        
        // 하단 버튼 메뉴 숨기기
        }else if([fURL hasPrefix:@"hybridapi://new_hideBottomMenu"]){
            [defaults setObject:@"YES" forKey:BOTTOM_BUTTON_HIDDEN];
            
            [self viewFrameInit];
         
        // 하단 버튼 메뉴 보이기
        }else if([fURL hasPrefix:@"hybridapi://new_showBottomMenu"]){
            [defaults setObject:@"NO" forKey:BOTTOM_BUTTON_HIDDEN];
            
            [self viewFrameInit];
        
        // 하단 웹뷰 메뉴 bg
        }else if([fURL hasPrefix:@"hybridapi://setBottomMenuStyle?"]){
            NSArray *bgArr = [fURL componentsSeparatedByString:@"?"];
            NSString *bgStr = [bgArr objectAtIndex:1];
            [defaults setObject:bgStr forKey:BOTTOM_WEBVIEW_COLOR];
                
            [self viewBottomWebviewBgInit];
        
        // 하단 웹뷰 메뉴 숨기기
        }else if([fURL hasPrefix:@"hybridapi://hideBottomMenu"]){
            [defaults setObject:@"YES" forKey:BOTTOM_WEBVIEW_HIDDEN];
            
            [self viewFrameInit];
            
        // 하단 웹뷰 메뉴 보이기
        }else if([fURL hasPrefix:@"hybridapi://showBottomMenu"]){
            [defaults setObject:@"NO" forKey:BOTTOM_WEBVIEW_HIDDEN];
            
            [self viewFrameInit];
        
        // 슬라이드 메뉴 bg
        }else if([fURL hasPrefix:@"hybridapi://setActionStyle?"]){
            NSArray *bgArr = [fURL componentsSeparatedByString:@"?"];
            NSString *bgStr = [bgArr objectAtIndex:1];
            [defaults setObject:bgStr forKey:SLIDE_MENU_COLOR];
        
        // 페이지 공유
        }else if([fURL hasPrefix:@"hybridapi://shareUrl"]){
            NSArray *actionItems = @[mainWebView.request.URL];
            UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:actionItems applicationActivities:nil];
            
            [self presentViewController:avc animated:YES completion:nil];
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
            if([fURL isEqualToString:@"about:blank"] || [fURL isEqualToString:@"https://m.search.naver.com/remote_frame"]){
            }else{
                [self loadingStart];
            }
        }
    }
}

// 웹뷰가 컨텐츠를 모두 읽은 후에 실행된다.
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"end");
    [self loadingEnd];
    
    if([TOKEN_CHECK1 isEqualToString:@"0"]){
        TOKEN_CHECK1 = @"1";
        NSString *jsValue = [NSString stringWithFormat:@"javascript:hybrid_init('%@','%@')", [defaults stringForKey:TOKEN_KEY], @"true"];
        [mainWebView stringByEvaluatingJavaScriptFromString:jsValue];
    }
}

// 컨텐츠를 읽는 도중 오류가 발생할 경우 실행된다.
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"ERROR : %@", error);
}

#pragma mark -
#pragma mark WebView Button Action

- (void)backButton:(UIButton*)sender {
    [mainWebView goBack];
}

- (void)fowardButton:(UIButton*)sender {
    [mainWebView goForward];
}

- (void)homeButton:(UIButton*)sender {
    NSString *urlString = [NSString stringWithFormat:@"http://emview.godohosting.com/api_help.php"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [mainWebView loadRequest:request];
}

- (void)reloadButton:(UIButton*)sender {
    [mainWebView reload];
}

- (void)shareButton:(UIButton*)sender {
    NSArray *actionItems = @[mainWebView.request.URL];
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:actionItems applicationActivities:nil];
    
    [self presentViewController:avc animated:YES completion:nil];
}

#pragma mark -
#pragma mark Loading Method

- (void)loadingStart{
    popupView.hidden = NO;
    popupViewWhite.hidden = YES;
    
    if([[defaults stringForKey:LOADINGBAR_HIDDEN] isEqualToString:@"true"] || [defaults stringForKey:LOADINGBAR_HIDDEN].length == 0){
        activityView.color = [UIColor whiteColor];
        [activityView startAnimating];
    }else{
       
    }
    
    if([[defaults stringForKey:LOADINGBAR_TIME] isEqualToString:@"true"]){
        popupView.hidden = YES;
        popupViewWhite.hidden = NO;
        [self performSelector:@selector(loadingThreeEnd) withObject:nil afterDelay:3.0];
        [self.view bringSubviewToFront:popupViewWhite];
        [self.view bringSubviewToFront:activityView];
        activityView.color = [UIColor blackColor];
        [activityView startAnimating];
    }
}

- (void)loadingEnd{
    if([[defaults stringForKey:LOADINGBAR_TIME] isEqualToString:@"true"]){
        
    }else{
        [activityView stopAnimating];
        popupView.hidden = YES;
    }
}

- (void)loadingThreeEnd{
    [activityView stopAnimating];
    popupViewWhite.hidden = YES;
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

#pragma mark -
#pragma mark Hex Color

- (UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

#pragma mark -
#pragma mark UUID

- (NSString*) getUUID{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"UUID" accessGroup:nil];
    
    NSString *uuid = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    
    if( uuid == nil || uuid.length == 0){
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        
        uuid = [NSString stringWithString:(__bridge NSString *) uuidStringRef];
        CFRelease(uuidStringRef);
        
        [wrapper setObject:uuid forKey:(__bridge id)(kSecAttrAccount)];
    }

    return uuid;
}

#pragma mark -
#pragma mark Kakao Link

- (NSArray *)dummyLinkObjects {
    KakaoTalkLinkObject *label = [KakaoTalkLinkObject createLabel:@"HYBRID"];
    
    KakaoTalkLinkAction *androidAppAction = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformAndroid devicetype:KakaoTalkLinkActionDeviceTypePhone marketparam:@{@"referrer":@"utm_source%3Dios%26utm_medium%3Dkakaotalk%26utm_term%3Dmenu%26utm_content%3Dmenu%26utm_campaign%3Dmenu", @"another_param_name":@"another_param_value"} execparam:@{@"param_name1":@"param_value1",@"param_name1":@"param_value2"}];
    KakaoTalkLinkAction *iphoneAppAction = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformIOS devicetype:KakaoTalkLinkActionDeviceTypePhone execparam:nil];
    KakaoTalkLinkAction *ipadAppAction = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformIOS devicetype:KakaoTalkLinkActionDeviceTypePad execparam:nil];
    KakaoTalkLinkAction *webAppAction = [KakaoTalkLinkAction createWebAction:urlValue];
    KakaoTalkLinkObject *appLink = [KakaoTalkLinkObject createAppButton:@"앱으로 이동" actions:@[androidAppAction, iphoneAppAction, ipadAppAction, webAppAction]];
    
    return @[label, appLink];
}

#pragma mark -
#pragma mark Noti

- (void)push:(NSNotification *)noti{
    NSURL *url = [NSURL URLWithString:[defaults stringForKey:TOKEN_URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [mainWebView loadRequest:request];
}

- (void)token:(NSNotification *)noti{
    NSString *jsValue = [NSString stringWithFormat:@"javascript:hybrid_init('%@','%@')", [defaults stringForKey:TOKEN_KEY], @"true"];
    [mainWebView stringByEvaluatingJavaScriptFromString:jsValue];
    
    // 주소변환
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    [locationManager startUpdatingLocation];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [locationManager setDelegate:self];
    
    CLLocation* location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Failed to reverse-geocode: %@", [error localizedDescription]);
            return;
        }
        
        NSString *addressValue;
        
        for(CLPlacemark *placemark in placemarks){
            NSString *country = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressCountryKey];
            NSString *state = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressStateKey];
            NSString *city = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressCityKey];
            NSString *street = [placemark.addressDictionary objectForKey:(NSString*)kABPersonAddressStreetKey];
            
            addressValue = [NSString stringWithFormat:@"%@ %@ %@ %@", country, state, city, street];
        }
        
        NSString *urlString = [NSString stringWithFormat:@"http://emview.godohosting.com/api_help.php?a=%f&b=%f&c=%@&d=%@&e=%@" , coordinate.latitude , coordinate.longitude , addressValue , [self getUUID] , @""];
        NSString *encodedString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *weburl = [NSURL URLWithString:encodedString];
        NSURL *url = weburl;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [mainWebView loadRequest:request];
    }];
}

@end

@implementation UIWebView (Javascript)
- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id *)frame {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil];
    [alert show];
}
@end
