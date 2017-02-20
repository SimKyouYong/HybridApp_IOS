//
//  WebViewVC.h
//  HybridApp
//
//  Created by Joseph_iMac on 2017. 2. 18..
//  Copyright © 2017년 Joseph_iMac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewVC : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic) NSString *urlString;

- (IBAction)backButton:(id)sender;

@end
