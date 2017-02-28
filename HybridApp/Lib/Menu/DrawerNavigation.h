//
//  DrawerNavigation.h
//  TheDayBefore
//
//  Created by Joseph on 2015. 4. 3..
//  Copyright (c) 2015년 Joseph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawerView.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface DrawerNavigation : UINavigationController<DrawerDelegate, MFMailComposeViewControllerDelegate>{
  
}

@property (nonatomic, strong) UIPanGestureRecognizer *pan_gr;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (void)drawerToggle;

@end
