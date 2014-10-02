//
//  TabbarVC.h
//  Beeeper
//
//  Created by User on 4/17/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabbarVC : UIViewController
@property (weak, nonatomic) IBOutlet UIView *containerVC;
@property (weak, nonatomic) IBOutlet UIView *tabBar;
@property (strong, nonatomic) IBOutlet UIView *notificationsBadgeV;
@property (strong, nonatomic) IBOutlet UILabel *notificationLabel;
@property (nonatomic,assign)  int notifications;
@property (nonatomic,assign) BOOL showsSplashOnLoad;
@property (weak, nonatomic) IBOutlet UIButton *notificationsButton;

-(void)hideBadgeIcon;
- (IBAction)addBeeepPressed:(id)sender;
- (IBAction)tabbarButtonTapped:(id)sender;

- (id)init;
+ (TabbarVC *)sharedTabbar;

@end
