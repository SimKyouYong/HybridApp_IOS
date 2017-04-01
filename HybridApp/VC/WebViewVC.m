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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rootNav = (DrawerNavigation *)self.navigationController;
    
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
    webView = [[UIWebView alloc] init];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    webView.frame = CGRectMake(0, 50, WIDTH_FRAME, HEIGHT_FRAME - 150);
    [self.view addSubview:webView];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
    // 버튼 뷰
    buttonView = [[UIView alloc] init];
    buttonView.backgroundColor = [UIColor whiteColor];
    buttonView.frame = CGRectMake(0, HEIGHT_FRAME - 100, WIDTH_FRAME, 50);
    [self.view addSubview:buttonView];
    
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
    
    // 웹뷰 하단 버튼 뷰
    webviewBottomView = [[UIView alloc] init];
    webviewBottomView.backgroundColor = [UIColor whiteColor];
    webviewBottomView.frame = CGRectMake(0, HEIGHT_FRAME - 50, WIDTH_FRAME, 50);
    [self.view addSubview:webviewBottomView];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)menuButton:(id)sender {
    [self.rootNav drawerToggle];
}

- (IBAction)topButton:(id)sender {
    NSURL *url = [NSURL URLWithString:buttonUrlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [webView loadRequest:request];
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
    [webView loadRequest:request];
}

- (void)button2Action:(UIButton*)sender{
    NSURL *url = [NSURL URLWithString:@"http://www.daum.net"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

- (void)button3Action:(UIButton*)sender{
    NSURL *url = [NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

- (void)button4Action:(UIButton*)sender{
    NSURL *url = [NSURL URLWithString:@"http://www.yahoo.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

- (void)button5Action:(UIButton*)sender{
    NSURL *url = [NSURL URLWithString:@"http://www.11st.co.kr"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

#pragma mark -
#pragma mark WebView Button Action

- (void)prevButton:(UIButton*)sender {
    [webView goBack];
}

- (void)fowardButton:(UIButton*)sender {
    [webView goForward];
}

- (void)homeButton:(UIButton*)sender {
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

- (void)reloadButton:(UIButton*)sender {
    [webView reload];
}

- (void)shareButton:(UIButton*)sender {
    NSArray *actionItems = @[webView.request.URL];
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:actionItems applicationActivities:nil];
    
    [self presentViewController:avc animated:YES completion:nil];
}

@end
