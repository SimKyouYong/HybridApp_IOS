//
//  Drawer.h
//  CCKFNavDrawer
//
//  Created by calvin on 2/2/14.
//  Copyright (c) 2014年 com.calvin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DrawerDelegate <NSObject>
@required
- (void)DrawerSelection:(NSInteger)selectionIndex;
@end

@interface DrawerView : UIView<UIScrollViewDelegate>{
    UIActivityIndicatorView *activityView;
    UIView *loadingView;
}

@property (weak, nonatomic)id<DrawerDelegate> delegate;

- (IBAction)firstButton:(id)sender;
- (IBAction)secondButton:(id)sender;
- (IBAction)thirdButton:(id)sender;
- (IBAction)fourButton:(id)sender;
- (IBAction)fiveButton:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *firstImage;
@property (weak, nonatomic) IBOutlet UIImageView *secondImage;
@property (weak, nonatomic) IBOutlet UIImageView *thirdImage;
@property (weak, nonatomic) IBOutlet UIImageView *fourImage;
@property (weak, nonatomic) IBOutlet UIImageView *fiveImage;

- (void)reloadMenuImage;

@end
