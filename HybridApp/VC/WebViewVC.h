//
//  WebViewVC.h
//  HybridApp
//
//  Created by Joseph_iMac on 2017. 2. 18..
//  Copyright © 2017년 Joseph_iMac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewVC : UIViewController<UIWebViewDelegate>{
    NSUserDefaults *defaults;
    
    UIWebView *webView;
    
    UIView *buttonView;
    UIView *webviewBottomView;
}

@property (nonatomic) NSString *urlString;
@property (nonatomic) NSString *titleString;
@property (nonatomic) NSString *buttonString;
@property (nonatomic) NSString *buttonUrlString;
@property (nonatomic) NSString *viewNum;

@property (weak, nonatomic) IBOutlet UILabel *titleText;

- (IBAction)menuButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
- (IBAction)backButton:(id)sender;

@end
