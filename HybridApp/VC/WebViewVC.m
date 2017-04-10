//
//  WebViewVC.m
//  HybridApp
//
//  Created by Joseph_iMac on 2017. 2. 18..
//  Copyright © 2017년 Joseph_iMac. All rights reserved.
//

#import "WebViewVC.h"
#import "DrawerNavigation.h"
#import "GlobalHeader.h"
#import "Reachability.h"
#import "GlobalObject.h"

@interface WebViewVC ()
@property (strong, nonatomic) DrawerNavigation *rootNav;
@end

@implementation WebViewVC

@synthesize titleText;
@synthesize menuButton;
@synthesize backButton;
@synthesize urlString;
@synthesize titleString;
@synthesize buttonString;
@synthesize buttonUrlString;
@synthesize viewNum;
@synthesize topView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rootNav = (DrawerNavigation *)self.navigationController;
    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    NSString *bgViewColor = [defaults stringForKey:SLIDE_MENU_COLOR];
    bgViewColor = [bgViewColor stringByReplacingOccurrencesOfString:@"#" withString:@""];
    topView.backgroundColor = [self colorWithHexString:bgViewColor];
    
    if([viewNum isEqualToString:@"2"]){
        menuButton.hidden = NO;
        backButton.hidden = YES;
    }else{
        menuButton.hidden = YES;
        backButton.hidden = NO;
    }
    
    titleText.text = titleString;
    if([buttonString isEqualToString:@"undefined"]){
        buttonString = @"저장하기";
    }
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [rightButton setTitle:buttonString forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightButton.frame = CGRectMake(WIDTH_FRAME - 100, 0, 100, 50);
    [rightButton addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightButton];

    // 웹뷰
    secondWebView = [[UIWebView alloc] init];
    secondWebView.delegate = self;
    secondWebView.scalesPageToFit = YES;
    [self.view addSubview:secondWebView];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [secondWebView loadRequest:request];
    
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
    [button1.layer setBorderWidth:0.5f];
    [buttonView addSubview:button1];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button2 setTitle:@"버튼2" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button2.frame = CGRectMake(WIDTH_FRAME/5, 0, WIDTH_FRAME/5, 50);
    [button2 addTarget:self action:@selector(button2Action:) forControlEvents:UIControlEventTouchUpInside];
    [button2.layer setBorderWidth:0.5f];
    [buttonView addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button3 setTitle:@"버튼3" forState:UIControlStateNormal];
    [button3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button3.frame = CGRectMake((WIDTH_FRAME/5)*2, 0, WIDTH_FRAME/5, 50);
    [button3 addTarget:self action:@selector(button3Action:) forControlEvents:UIControlEventTouchUpInside];
    [button3.layer setBorderWidth:0.5f];
    [buttonView addSubview:button3];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button4 setTitle:@"버튼4" forState:UIControlStateNormal];
    [button4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button4.frame = CGRectMake((WIDTH_FRAME/5)*3, 0, WIDTH_FRAME/5, 50);
    [button4 addTarget:self action:@selector(button4Action:) forControlEvents:UIControlEventTouchUpInside];
    [button4.layer setBorderWidth:0.5f];
    [buttonView addSubview:button4];
    
    UIButton *button5 = [UIButton buttonWithType:UIButtonTypeSystem];
    [button5 setTitle:@"버튼5" forState:UIControlStateNormal];
    [button5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button5.frame = CGRectMake((WIDTH_FRAME/5)*4, 0, WIDTH_FRAME/5, 50);
    [button5 addTarget:self action:@selector(button5Action:) forControlEvents:UIControlEventTouchUpInside];
    [button5.layer setBorderWidth:0.5f];
    [buttonView addSubview:button5];
    
    UIButton *pervButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pervButton setImage:[UIImage imageNamed:@"tab_prev"] forState:UIControlStateNormal];
    pervButton.frame = CGRectMake(0, 0, WIDTH_FRAME/5, 50);
    [backButton addTarget:self action:@selector(prevButton:) forControlEvents:UIControlEventTouchUpInside];
    [webviewBottomView addSubview:pervButton];
    
    UIButton *fowardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [fowardButton setImage:[UIImage imageNamed:@"tab_next"] forState:UIControlStateNormal];
    fowardButton.frame = CGRectMake(WIDTH_FRAME/5, 0, WIDTH_FRAME/5, 50);
    [fowardButton addTarget:self action:@selector(fowardButton:) forControlEvents:UIControlEventTouchUpInside];
    [webviewBottomView addSubview:fowardButton];
    
    UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homeButton setImage:[UIImage imageNamed:@"tab_home"] forState:UIControlStateNormal];
    homeButton.frame = CGRectMake((WIDTH_FRAME/5)*2, 0, WIDTH_FRAME/5, 50);
    [homeButton addTarget:self action:@selector(homeButton:) forControlEvents:UIControlEventTouchUpInside];
    [webviewBottomView addSubview:homeButton];
    
    UIButton *reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [reloadButton setImage:[UIImage imageNamed:@"tab_reload"] forState:UIControlStateNormal];
    reloadButton.frame = CGRectMake((WIDTH_FRAME/5)*3, 0, WIDTH_FRAME/5, 50);
    [reloadButton addTarget:self action:@selector(reloadButton:) forControlEvents:UIControlEventTouchUpInside];
    [webviewBottomView addSubview:reloadButton];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setImage:[UIImage imageNamed:@"tab_share"] forState:UIControlStateNormal];
    shareButton.frame = CGRectMake((WIDTH_FRAME/5)*4, 0, WIDTH_FRAME/5, 50);
    [shareButton addTarget:self action:@selector(shareButton:) forControlEvents:UIControlEventTouchUpInside];
    [webviewBottomView addSubview:shareButton];
}

// 하단 뷰 숨기기, 배경색
- (void)viewFrameInit{
    if([[defaults stringForKey:BOTTOM_BUTTON_HIDDEN] isEqualToString:@"NO"] || [defaults stringForKey:BOTTOM_BUTTON_HIDDEN].length == 0){
        buttonView.hidden = NO;
        if([[defaults stringForKey:BOTTOM_WEBVIEW_HIDDEN] isEqualToString:@"NO"] || [defaults stringForKey:BOTTOM_WEBVIEW_HIDDEN].length == 0){
            secondWebView.frame = CGRectMake(0, 50, WIDTH_FRAME, HEIGHT_FRAME - 150);
            buttonView.frame = CGRectMake(0, HEIGHT_FRAME - 100, WIDTH_FRAME, 50);
            webviewBottomView.frame = CGRectMake(0, HEIGHT_FRAME - 50, WIDTH_FRAME, 50);
            webviewBottomView.hidden = NO;
        }else{
            secondWebView.frame = CGRectMake(0, 50, WIDTH_FRAME, HEIGHT_FRAME - 100);
            buttonView.frame = CGRectMake(0, HEIGHT_FRAME - 50, WIDTH_FRAME, 50);
            webviewBottomView.hidden = YES;
        }
    }else{
        buttonView.hidden = YES;
        if([[defaults stringForKey:BOTTOM_WEBVIEW_HIDDEN] isEqualToString:@"NO"] || [defaults stringForKey:BOTTOM_WEBVIEW_HIDDEN].length == 0){
            secondWebView.frame = CGRectMake(0, 50, WIDTH_FRAME, HEIGHT_FRAME - 100);
            webviewBottomView.frame = CGRectMake(0, HEIGHT_FRAME - 50, WIDTH_FRAME, 50);
            webviewBottomView.hidden = NO;
        }else{
            secondWebView.frame = CGRectMake(0, 50, WIDTH_FRAME, HEIGHT_FRAME - 50);
            webviewBottomView.hidden = YES;
        }
    }
}

- (void)viewBottomButtonBgInit{
    NSString *bgColor = [defaults stringForKey:BOTTOM_BUTTON_COLOR];
    if([bgColor isEqualToString:@"default"] || bgColor.length == 0){
        buttonView.backgroundColor = [UIColor whiteColor];
    }else{
        bgColor = [bgColor stringByReplacingOccurrencesOfString:@"#" withString:@""];
        buttonView.backgroundColor = [self colorWithHexString:bgColor];
    }
}

- (void)viewBottomWebviewBgInit{
    NSString *bgColor = [defaults stringForKey:BOTTOM_WEBVIEW_COLOR];
    if([bgColor isEqualToString:@"default"] || bgColor.length == 0){
        webviewBottomView.backgroundColor = [UIColor whiteColor];
    }else{
        bgColor = [bgColor stringByReplacingOccurrencesOfString:@"#" withString:@""];
        webviewBottomView.backgroundColor = [self colorWithHexString:bgColor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        // 앱 화면이동 숨기기
        if([fURL hasPrefix:@"js2ios://SETEXIT_TYPE1?"]){
            [defaults setObject:@"TRUE" forKey:SLIDE_MOVE];
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
            
        }
    }
}

// 웹뷰가 컨텐츠를 모두 읽은 후에 실행된다.
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"end");
    
    if([TOKEN_CHECK2 isEqualToString:@"0"]){
        TOKEN_CHECK2 = @"1";
        NSString *jsValue = [NSString stringWithFormat:@"javascript:hybrid_init('%@','%@')", [defaults stringForKey:TOKEN_KEY], @"true"];
        [secondWebView stringByEvaluatingJavaScriptFromString:jsValue];
    }
}

// 컨텐츠를 읽는 도중 오류가 발생할 경우 실행된다.
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"ERROR : %@", error);
}


#pragma mark -
#pragma mark Button Action

- (IBAction)menuButton:(id)sender {
    [self.rootNav drawerToggle];
}

- (IBAction)topButton:(id)sender {
    NSURL *url = [NSURL URLWithString:buttonUrlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [secondWebView loadRequest:request];
}

- (IBAction)backButton:(id)sender {
    //[self dismissViewControllerAnimated:NO completion:nil];
    [self.rootNav popViewControllerAnimated:NO];
}

- (void)rightAction:(UIButton*)sender{
    
}

#pragma mark -
#pragma mark Button View

- (void)button1Action:(UIButton*)sender{
    NSURL *url = [NSURL URLWithString:@"http://www.naver.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [secondWebView loadRequest:request];
}

- (void)button2Action:(UIButton*)sender{
    NSURL *url = [NSURL URLWithString:@"http://www.daum.net"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [secondWebView loadRequest:request];
}

- (void)button3Action:(UIButton*)sender{
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [secondWebView loadRequest:request];
}

- (void)button4Action:(UIButton*)sender{
    NSURL *url = [NSURL URLWithString:@"http://www.yahoo.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [secondWebView loadRequest:request];
}

- (void)button5Action:(UIButton*)sender{
    NSURL *url = [NSURL URLWithString:@"http://www.11st.co.kr"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [secondWebView loadRequest:request];
}

#pragma mark -
#pragma mark WebView Button Action

- (void)prevButton:(UIButton*)sender {
    [secondWebView goBack];
}

- (void)fowardButton:(UIButton*)sender {
    [secondWebView goForward];
}

- (void)homeButton:(UIButton*)sender {
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [secondWebView loadRequest:request];
}

- (void)reloadButton:(UIButton*)sender {
    [secondWebView reload];
}

- (void)shareButton:(UIButton*)sender {
    NSArray *actionItems = @[secondWebView.request.URL];
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:actionItems applicationActivities:nil];
    
    [self presentViewController:avc animated:YES completion:nil];
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
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
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

@end
