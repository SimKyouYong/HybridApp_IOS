//
//  Drawer.m
//  CCKFNavDrawer
//
//  Created by calvin on 2/2/14.
//  Copyright (c) 2014年 com.calvin. All rights reserved.
//

#import "DrawerView.h"
#import "GlobalHeader.h"

@implementation DrawerView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
        
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 40 + self.frame.origin.x, self.frame.size.height/2 - 40 + self.frame.origin.y, 80, 80)];
    loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    loadingView.clipsToBounds = YES;
    loadingView.layer.cornerRadius = 10.0;
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(24, 22, activityView.bounds.size.width, activityView.bounds.size.height);
    [loadingView addSubview:activityView];
    [self addSubview:loadingView];
    loadingView.hidden = YES;
}

#pragma mark -
#pragma mark Button Action

- (IBAction)firstButton:(id)sender {
    [delegate DrawerSelection:0];
}

- (IBAction)secondButton:(id)sender {
    [delegate DrawerSelection:1];
}

- (IBAction)thirdButton:(id)sender {
    [delegate DrawerSelection:2];
}

- (IBAction)fourButton:(id)sender {
    [delegate DrawerSelection:3];
}

- (IBAction)fiveButton:(id)sender {
    [delegate DrawerSelection:4];
}

@end
