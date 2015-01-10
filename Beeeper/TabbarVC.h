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
@property (strong, nonatomic) IBOutlet UIView *notificationsBadgeV;
@property (strong, nonatomic) IBOutlet UILabel *notificationLabel;
@property (weak, nonatomic) IBOutlet UIButton *notificationsButton;
@property (nonatomic,assign) BOOL showsSplashOnLoad;

- (void)updateNotificationsBadge;
- (void)hideBadgeIcon;

- (void)addBeeepPressed:(id)sender;
- (void)reBeeepPressed:(id)sender_tml image:(UIImage *)image controller:(UIViewController *)sender;
- (void)suggestPressed:(id)fingerprint beeepers:(NSArray *)beeepers controller:(UIViewController *)sender sendNotificationWhenFinished:(BOOL)sendWhenFinished selectedPeople:(NSMutableArray *)selectedPeople showBlur:(BOOL)showBlur;

- (IBAction)tabbarButtonTapped:(id)sender;
- (void)showAlert:(NSString *)title text:(NSString *)text;

+ (TabbarVC *)sharedTabbar;

@end
