//
//  MainVC.h
//  HybridApp
//
//  Created by Joseph_iMac on 2017. 2. 17..
//  Copyright © 2017년 Joseph_iMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupView.h"

@interface MainVC : UIViewController{
    NSUserDefaults *defaults;
    
    NSString *fURL;
    
    UIActivityIndicatorView *activityView;
    UIView *loadingView;
    UILabel *loadingLabel;
    
    PopupView *popupView;
}

@property (weak, nonatomic) IBOutlet UIWebView *mainWebView;

- (IBAction)backButton:(id)sender;
- (IBAction)fowardButton:(id)sender;
- (IBAction)homeButton:(id)sender;
- (IBAction)refreshButton:(id)sender;
- (IBAction)dropButton:(id)sender;

@end

@interface UIWebView (Javascript)
- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message     initiatedByFrame:(id *)frame;
@end
