//
//  WebViewVC.m
//  HybridApp
//
//  Created by Joseph_iMac on 2017. 2. 18..
//  Copyright © 2017년 Joseph_iMac. All rights reserved.
//

#import "WebViewVC.h"
#import "DrawerNavigation.h"

@interface WebViewVC ()
@property (strong, nonatomic) DrawerNavigation *rootNav;
@end

@implementation WebViewVC

@synthesize webView;
@synthesize titleText;
@synthesize topButton;
@synthesize urlString;
@synthesize titleString;
@synthesize buttonString;
@synthesize buttonUrlString;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rootNav = (DrawerNavigation *)self.navigationController;
    
    titleText.text = titleString;
    [topButton setTitle:buttonString forState:UIControlStateNormal];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [webView loadRequest:request];
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

@end
