//
//  TabbarVC.m
//  Beeeper
//
//  Created by User on 4/17/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "TabbarVC.h"
#import "TimelineVC.h"
#import <QuartzCore/QuartzCore.h>
#import "BeeepVC.h"
#import "BeeepItVC.h"
#import "SuggestBeeepVC.h"

@interface TabbarVC ()<UINavigationControllerDelegate>
{

}
@end

@implementation TabbarVC

static TabbarVC *thisWebServices = nil;

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
    
    [[DTO sharedDTO]getSuggestions];
    
    thisWebServices = self;
    
    if (self.showsSplashOnLoad) {
        [self showSplashScreen];
        [self performSelector:@selector(hideSplashScreen) withObject:nil afterDelay:1.0];
    }
    
    [[BPUser sharedBP]sendDeviceToken];
    //[[BPUser sharedBP]sendDemoPush:50];
    
    [self pushReceived];
    
    [self updateNotificationsBadge];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 1;
    
    [self tabbarButtonTapped:btn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushReceived) name:@"PUSH" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateNotificationsBadge) name:@"readNotifications" object:nil];

    //for timeline Follow + / Following Delay
    
    [[BPUser sharedBP]getFollowingForUser:[[BPUser sharedBP].user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){}];

}

+ (TabbarVC *)sharedTabbar{
    
    if (thisWebServices != nil) {
        return thisWebServices;
    }

    return nil;
}


-(void)updateNotificationsBadge{
    
    [[BPUser sharedBP]newNotificationsWithCompletionBlock:^(BOOL completed,NSArray *objcts){
        
        [self performSelector:@selector(updateNotificationsBadge) withObject:nil afterDelay:60];
    }];
    
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

}

-(void)pushReceived{
    [self performSelector:@selector(showPushBeeep) withObject:nil afterDelay:2.0];
}

-(void)showPushBeeep{
    
    NSString *beeepID = [[DTO sharedDTO]getNotificationBeeepID];
    
    if (beeepID != nil) {
        
        EventVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"EventVC"];
        viewController.tml = [NSString stringWithString:beeepID];
        
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

- (void)addBeeepPressed:(UIViewController *)sender {
    
    BeeepVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"BeeepVC"];
    viewController.superviewToBlur = sender.navigationController.view;
    
    [viewController.view setFrame:CGRectMake(0, self.parentViewController.view.frame.size.height,  self.parentViewController.view.frame.size.width,   self.parentViewController.view.frame.size.height)];
    [self.parentViewController.view addSubview:viewController.view];
    [self.parentViewController addChildViewController:viewController];
    
    [UIView animateWithDuration:0.4f
                     animations:^
     {
         viewController.view.frame = CGRectMake(0, 0, 320, viewController.view.frame.size.height);
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.4f
                          animations:^
          {
              viewController.blurContainerV.alpha = 1;
          }
                          completion:^(BOOL finished)
          {
              
          }
          ];

     }
     ];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)reBeeepPressed:(id)sender_tml image:(UIImage *)image controller:(UIViewController *)sender{
    
    BeeepItVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"BeeepItVC"];
    viewController.superviewToBlur = sender.navigationController.view;
    viewController.facebookDialogEventImage = image;
    
    if ([sender_tml isKindOfClass:[NSDictionary class]]) {
        viewController.values = sender_tml;
    }
    else{
        viewController.tml = sender_tml;
    }
    
    [viewController.view setFrame:CGRectMake(0, self.parentViewController.view.frame.size.height,  self.parentViewController.view.frame.size.width,   self.parentViewController.view.frame.size.height)];
    [self.parentViewController.view addSubview:viewController.view];
    [self.parentViewController addChildViewController:viewController];
    
    [UIView animateWithDuration:0.4f
                     animations:^
     {
         viewController.view.frame = CGRectMake(0, 0, 320, viewController.view.frame.size.height);
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.4f
                          animations:^
          {
              viewController.blurContainerV.alpha = 1;
          }
                          completion:^(BOOL finished)
          {
              
          }
          ];
         
     }
     ];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)suggestPressed:(id)fingerprint controller:(UIViewController *)sender sendNotificationWhenFinished:(BOOL)sendWhenFinished selectedPeople:(NSMutableArray *)selectedPeople showBlur:(BOOL)showBlur{
    
    SuggestBeeepVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"SuggestBeeepVC"];
    viewController.fingerprint = fingerprint;
    viewController.superviewToBlur = sender.navigationController.view;
    viewController.selectedPeople = selectedPeople;
    viewController.sendNotificationWhenFinished = sendWhenFinished;
    viewController.showBlur = showBlur;
    
    [viewController.view setFrame:CGRectMake(0, self.parentViewController.view.frame.size.height,  self.parentViewController.view.frame.size.width,   self.parentViewController.view.frame.size.height)];
    [self.parentViewController.view addSubview:viewController.view];
    [self.parentViewController addChildViewController:viewController];
    
    [UIView animateWithDuration:0.4f
                     animations:^
     {
         viewController.view.frame = CGRectMake(0, 0, 320, viewController.view.frame.size.height);
     }
                     completion:^(BOOL finished)
     {
         if (showBlur) {
             
             [UIView animateWithDuration:0.4f
                              animations:^
              {
                  viewController.blurContainerV.alpha = 1;
              }
                              completion:^(BOOL finished)
              {
                  
              }
              ];
         }
     }
     ];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (IBAction)tabbarButtonTapped:(UIButton *)sender {
    
    
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
    navVC.delegate = self;
   
//    for (UIView *view in [[[navVC.navigationBar subviews] objectAtIndex:0] subviews]) {
//        if ([view isKindOfClass:[UIImageView class]]) view.hidden = YES;
//    }

    
    for (UIViewController *child in self.childViewControllers) {
        [child.view removeFromSuperview];
        [child removeFromParentViewController];
    }
    
    [self addChildViewController:navVC];
    [self.containerVC addSubview:navVC.view];
    [self.containerVC bringSubviewToFront:navVC.view];
    
    
    
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

- (void)showAlert:(NSString *)title text:(NSString *)text{
  
    dispatch_async (dispatch_get_main_queue(), ^{
           
       UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
       [alert show];
    });

}

@end
