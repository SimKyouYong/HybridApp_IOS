//
//  MainVC.h
//  HybridApp
//
//  Created by Joseph_iMac on 2017. 2. 17..
//  Copyright © 2017년 Joseph_iMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupView.h"
#import <CoreLocation/CoreLocation.h>

@interface MainVC : UIViewController<CLLocationManagerDelegate, UIWebViewDelegate>{
    NSUserDefaults *defaults;
    
    NSString *fURL;
    
    UIActivityIndicatorView *activityView;
    UIView *loadingView;
    UILabel *loadingLabel;
    
    PopupView *popupView;
    
    UIWebView *mainWebView;
    
    UIView *buttonView;
    UIView *webviewBottomView;
}

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@interface UIWebView (Javascript)
- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message     initiatedByFrame:(id *)frame;
@end
