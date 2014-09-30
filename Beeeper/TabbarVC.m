//
//  TabbarVC.m
//  Beeeper
//
//  Created by User on 4/17/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "TabbarVC.h"
#import "TimelineVC.h"
#import "JSBadgeView.h"
#import <QuartzCore/QuartzCore.h>


@interface TabbarVC ()
{

}
@end

@implementation TabbarVC
@synthesize notifications =_notifications;

-(void)setNotifications:(int)notifications{
    _notifications = notifications;
    [self updateNotificationsBadge];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.showsSplashOnLoad) {
        [self showSplashScreen];
        [self performSelector:@selector(hideSplashScreen) withObject:nil afterDelay:1.0];
    }
    
    [[BPUser sharedBP]sendDeviceToken];
    [[BPUser sharedBP]sendDemoPush:5];
    
    [self updateNotificationsBadge];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 1;
    
    [self tabbarButtonTapped:btn];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidAppear:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateNotificationsBadge) name:@"readNotifications" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideTabbar) name:@"HideTabbar" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showTabbar) name:@"ShowTabbar" object:nil];
    
    //for timeline Follow + / Following Delay
    
    [[BPUser sharedBP]getFollowingForUser:[[BPUser sharedBP].user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){}];

}

-(void)updateNotificationsBadge{
    
    
    [[BPUser sharedBP]getNewNotificationsWithCompletionBlock:^(BOOL completed,NSArray *objcts){
        
        if (completed) {
            
            _notifications = (int)objcts.count;
            
            
            if (_notifications <= 0) {
                
                [UIView animateWithDuration:0.2f
                                 animations:^
                 {
                     self.notificationsBadgeV.alpha = 0;
                 }
                                 completion:^(BOOL finished)
                 {
                     
                 }
                 ];
            }
            else{
                
                JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:self.notificationsBadgeV alignment:JSBadgeViewAlignmentTopRight];
                badgeView.badgeText = [NSString stringWithFormat:@"%d",self.notifications];
                
                [UIView animateWithDuration:0.2f
                                 animations:^
                 {
                     self.notificationsBadgeV.alpha = 1;
                 }
                                 completion:^(BOOL finished)
                 {
                     
                 }
                 ];
            }
            
            [self performSelector:@selector(updateNotificationsBadge) withObject:nil afterDelay:30];

        }
    }];
    
   }

-(void)hideTabbar{

    self.containerVC.frame = self.view.bounds;
    
    [UIView animateWithDuration:0.7f
                     animations:^
     {
         
         self.tabBar.frame = CGRectMake(0, self.view.frame.size.height+20, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
     }
                     completion:^(BOOL finished)
     {
         
     }
     ];
  }

-(void)showTabbar{
    
    [UIView animateWithDuration:0.4f
                     animations:^
     {
         self.tabBar.frame = CGRectMake(0, self.view.frame.size.height-self.tabBar.frame.size.height, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
     }
                     completion:^(BOOL finished)
     {
         
         [UIView animateWithDuration:0.4f
                          animations:^
          {
                    self.containerVC.frame = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height-self.tabBar.frame.size.height);
          }
                          completion:^(BOOL finished)
          {}];
     }
     ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
   
    [self performSelector:@selector(showPushBeeep) withObject:nil afterDelay:2.0];
}

-(void)showPushBeeep{
    
    NSString *beeepID = [[DTO sharedDTO]getNotificationBeeepID];
    
    if (beeepID != nil) {
        
        
        EventVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"EventVC"];
        viewController.tml = beeepID;
        
        NSLog(@"%@",self.navigationController.viewControllers);
        
        [self.navigationController pushViewController:viewController animated:YES];
        
        [[DTO sharedDTO]setNotificationBeeepID:nil];
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)addBeeepPressed:(id)sender {
   
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"BeeepVC"];
    
    [viewController.view setFrame:CGRectMake(0, self.view.frame.size.height, 320, viewController.view.frame.size.height)];
    [self.parentViewController.view addSubview:viewController.view];
    [self.parentViewController addChildViewController:viewController];
    
    [UIView animateWithDuration:0.4f
                     animations:^
     {
         viewController.view.frame = CGRectMake(0, 0, 320, viewController.view.frame.size.height);
     }
                     completion:^(BOOL finished)
     {
         
     }
     ];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (IBAction)tabbarButtonTapped:(UIButton *)sender {
    
    
    for (UIButton *btn in self.tabBar.subviews) {
        
        if (![btn isKindOfClass:[UIButton class]]) {
            continue;
        }
        
        if (btn.tag != sender.tag) {
            btn.selected = NO;
        }
        else{
            btn.selected = YES;
        }
    }
    
    UIViewController *vC;
    
    switch (sender.tag) {
        case 1:
            vC = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"HomeFeedVC"];
            break;
        case 2:
            vC = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"SearchVC"];
            break;
        case 3:{
                TimelineVC *timelineVC = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"TimelineVC"];
                timelineVC.mode = Timeline_My;
                vC = timelineVC;
            }
            break;
        case 4:
            vC = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"NotificationsVC"];
            break;
        default:
            
            break;
    }
    

    
    UINavigationController *navVC = [[UINavigationController alloc]initWithRootViewController:vC];
    navVC.navigationBar.translucent = NO;
    navVC.view.frame = self.containerVC.frame;
    
    for (UIView *view in [[[navVC.navigationBar subviews] objectAtIndex:0] subviews]) {
        if ([view isKindOfClass:[UIImageView class]]) view.hidden = YES;
    }

    
    for (UIViewController *child in self.childViewControllers) {
        [child removeFromParentViewController];
        [child.view removeFromSuperview];
    }
    
    [self addChildViewController:navVC];
    [self.containerVC addSubview:navVC.view];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}


-(void)showSplashScreen{
    
    UIView *backV = [[UIView alloc]initWithFrame:self.view.bounds];
    backV.backgroundColor = [UIColor colorWithRed:240/255.0 green:208/255.0 blue:0 alpha:1];
    UIImageView *imgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"beeeper-logo-Splash"]];
    imgV.tag = 454;
    imgV.center = CGPointMake(backV.center.x, backV.center.y-22);
    [backV addSubview:imgV];
    backV.tag = 323;
    [self.view addSubview:backV];
    [self.view bringSubviewToFront:backV];
}

-(void)hideSplashScreen{
    
    UIView *backV = (id)[self.view viewWithTag:323];
    UIImageView *imgV = (id)[backV viewWithTag:454];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGAffineTransform transform = imgV.transform;
                         imgV.transform = CGAffineTransformScale(transform, 1.5 , 1.5);
                         backV.alpha = 0;
                         
                     } completion:^(BOOL finished){
                         [backV removeFromSuperview];
                     }];
    
}

@end
