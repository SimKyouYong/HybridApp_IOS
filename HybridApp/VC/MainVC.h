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
    
    PopupView *popupView;
    UIView *popupViewWhite;
    
    UIWebView *mainWebView;
    
    UIView *buttonView;
    UIView *webviewBottomView;
    
    NSString *urlValue;
    
    UIImageView *backImage;
    UIImageView *fowardImage;
    UIImageView *homeImage;
    UIImageView *reloadImage;
    UIImageView *shareImage;
}

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@interface UIWebView (Javascript)
- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message     initiatedByFrame:(id *)frame;
@end
