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
#import "HomeFeedVC.h"
#import "SearchVC.h"
#import "EAIntroPage.h"
#import "EAIntroView.h"

@interface TabbarVC ()<UINavigationControllerDelegate,UIAlertViewDelegate>
{
    NSMutableArray *viewControllers;
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
    
    viewControllers = [NSMutableArray array];
    
    [[DTO sharedDTO]getSuggestions];
    
    //[[DTO sharedDTO]setApplicationBadge:0];//reset
    
    thisWebServices = self;
    
    if (self.showsSplashOnLoad) {
        [self showSplashScreen];
        [self performSelector:@selector(hideSplashScreen) withObject:nil afterDelay:1.0];
    }
    
    [[BPUser sharedBP]sendDeviceToken];
    //[[BPUser sharedBP]sendDemoPush:50];
    
    [self pushReceived:nil];
    
    [self updateNotificationsBadge];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 3;
    
    [self tabbarButtonTapped:btn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushReceived:) name:@"PUSH" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDeeepLinkEvent) name:@"DEEPLINK" object:nil];
    
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

-(void)showWalkthrough{
    NSMutableArray *pages = [NSMutableArray array];
    
    for (int i = 0; i <= 7; i++) {
        EAIntroPage *page = [EAIntroPage page];
        if (IS_IPHONE_4_OR_LESS) {
            page.bgImage = [UIImage imageNamed:[NSString stringWithFormat:@"%d.App_Tour_4.jpg",i]];
        }
        else if (IS_IPHONE_5){
            page.bgImage = [UIImage imageNamed:[NSString stringWithFormat:@"%d.App_Tour_5.jpg",i]];
        }
        else if(IS_IPHONE_6){
            page.bgImage = [UIImage imageNamed:[NSString stringWithFormat:@"%d.App_Tour_6.jpg",i]];
        }
        else if(IS_IPHONE_6P){
            page.bgImage = [UIImage imageNamed:[NSString stringWithFormat:@"%d.App_Tour_6+.jpg",i]];
        }
        
        [pages addObject:page];
    }
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:CGRectMake(0, 0, [TabbarVC sharedTabbar].view.frame.size.width, [TabbarVC sharedTabbar].view.frame.size.height) andPages:pages];
    intro.pageControl.hidden = YES;
    //    intro.pageControlY = 250.0f;
    //
    //    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    [btn setFrame:CGRectMake((320-230)/2, [UIScreen mainScreen].bounds.size.height - 60, 230, 40)];
    //    [btn setTitle:@"SKIP NOW" forState:UIControlStateNormal];
    //    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    btn.layer.borderWidth = 2.0f;
    //    btn.layer.cornerRadius = 10;
    //    btn.layer.borderColor = [[UIColor whiteColor] CGColor];
    //    intro.skipButton = btn;
    
    //[intro setDelegate:self];
    [intro showInView:[TabbarVC sharedTabbar].view animateDuration:0.3];
    [intro setShowSkipButtonOnlyOnLastPage:YES];
    
    [DTO sharedDTO].hasShownWalkthrough = YES;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    if (![[DTO sharedDTO] hasShownWalkthrough]) {
        [self performSelector:@selector(showWalkthrough) withObject:nil afterDelay:1.0];
    }
}

-(void)pushReceived:(NSNotification *)notif{
   
    @try {
       
        NSDictionary *userInfo = [notif userInfo];
        
        if (userInfo != nil) {
            
//            NSString *alertText = [[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"];
//            
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Notification Received" message:alertText delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"View", nil];
//            alert.tag = 33;
//            [alert show];
            
            [self performSelector:@selector(showPushBeeep) withObject:nil afterDelay:1.0];
            [self performSelector:@selector(showPushEvent) withObject:nil afterDelay:1.0];
            [self performSelector:@selector(showPushUser) withObject:nil afterDelay:1.0];
            [self performSelector:@selector(showDeeepLinkEvent) withObject:nil afterDelay:1.0];

        }
        else{
            [self performSelector:@selector(showPushBeeep) withObject:nil afterDelay:2.0];
            [self performSelector:@selector(showPushEvent) withObject:nil afterDelay:2.0];
            [self performSelector:@selector(showPushUser) withObject:nil afterDelay:2.0];
            [self performSelector:@selector(showDeeepLinkEvent) withObject:nil afterDelay:1.0];
        }

    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex != alertView.cancelButtonIndex && alertView.tag == 33) {
        [self showPushBeeep];
        [self showPushEvent];
        [self showPushUser];
    }
}

-(void)showPushBeeep{
    
    NSDictionary *beeepDict = [[DTO sharedDTO]getWeightAndCaseForPush];
    
    NSString *beeepID = [beeepDict objectForKey:@"WeightPush"];
    
    if (beeepID != nil) {
        
        EventVC *viewController = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"EventVC"];
        viewController.tml = [NSString stringWithString:beeepID];
        
        BOOL commentsShow = [[beeepDict objectForKey:@"WeightPushCase"]isEqualToString:@"c"];
        BOOL likesShow = [[beeepDict objectForKey:@"WeightPushCase"]isEqualToString:@"l"];
        
        viewController.redirectToComments = commentsShow;
        viewController.redirectToLikes = likesShow;
        
        [self.navigationController pushViewController:viewController animated:YES];
        
        [[DTO sharedDTO]setWeightForPush:nil caseStr:nil];
    }

}

-(void)showPushEvent{
    
    NSDictionary *eventDict = [[DTO sharedDTO]getFingerprintAndCaseForPush];
    
    NSString *eventID = [eventDict objectForKey:@"FingerprintPush"];
    
    if (eventID != nil) {
        
        EventVC *viewController = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"EventVC"];
        viewController.deepLinkFingerprint = [NSString stringWithString:eventID];
        
        [self.navigationController pushViewController:viewController animated:YES];
        
        [[DTO sharedDTO]setFingerprintForPush:nil caseStr:nil];
    }
    
}

-(void)showPushUser{
   
    NSString *userID = [[DTO sharedDTO]getUserIDForPush];
    
    if (userID != nil) {
      
        TimelineVC *timelineVC = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"TimelineVC"];
        timelineVC.mode = Timeline_Following;
        timelineVC.showBackButton = YES; //in case of My_Timeline
        
        timelineVC.following = YES;
        timelineVC.user = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithObject:userID forKey:@"id"]];
        
        [self.navigationController pushViewController:timelineVC animated:YES];
    
        [[DTO sharedDTO]setUserIDforPush:nil];
    }
}

-(void)showDeeepLinkEvent{
    
    NSString *fingerprint = [[DTO sharedDTO]getDeeepLinkEventFingerprint];
    
    if (fingerprint != nil) {
        
        EventVC *viewController = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"EventVC"];
        viewController.deepLinkFingerprint = [NSString stringWithString:fingerprint];
        
        [self.navigationController pushViewController:viewController animated:YES];
        
        [[DTO sharedDTO]setDeeepLinkEventFingerprint:nil];
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
    
    BeeepVC *viewController = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"BeeepVC"];
    viewController.superviewToBlur = sender.navigationController.view;
   
    [self.parentViewController.view addSubview:viewController.view];
    [self.parentViewController addChildViewController:viewController];
    
    [viewController.containerScrollV setFrame:CGRectMake(viewController.containerScrollV.frame.origin.x, viewController.view.frame.size.height,viewController.containerScrollV.frame.size.width, viewController.containerScrollV.frame.size.height)];
    
    [UIView animateWithDuration:0.4f
                     animations:^
     {
         viewController.containerScrollV.center = viewController.view.center;
         viewController.blurContainerV.alpha = 1;
     }
                     completion:^(BOOL finished)
     {

     }
     ];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)reBeeepPressed:(id)sender_tml image:(UIImage *)image controller:(UIViewController *)sender{
    
    BeeepItVC *viewController = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"BeeepItVC"];
    viewController.superviewToBlur = sender.navigationController.view;
    viewController.facebookDialogEventImage = image;
    
    if ([sender isKindOfClass:[HomeFeedVC class]] || [sender isKindOfClass:[SearchVC class]]) {
        viewController.notificationName = @"Rebeeep";
    }
    
    if ([sender isKindOfClass:[BeeepVC class]]) {
        viewController.hideBackgroundblur = YES;
    }
    
    if ([sender_tml isKindOfClass:[NSDictionary class]]) {
        viewController.values = sender_tml;
    }
    else{
        viewController.tml = sender_tml;
    }
    

    [self.parentViewController.view addSubview:viewController.view];
    [self.parentViewController addChildViewController:viewController];
    
    [viewController.scrollV setFrame:CGRectMake(viewController.scrollV.frame.origin.x, viewController.view.frame.size.height,  viewController.scrollV.frame.size.width,   viewController.scrollV.frame.size.height)];
    
    [UIView animateWithDuration:0.4f
                     animations:^
     {
         viewController.scrollV.center = viewController.view.center;
         viewController.blurContainerV.alpha = !viewController.hideBackgroundblur;
     }
                     completion:^(BOOL finished)
     {
     }
     ];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)suggestPressed:(id)fingerprint beeepers:(NSArray *)beeepers controller:(UIViewController *)sender sendNotificationWhenFinished:(BOOL)sendWhenFinished selectedPeople:(NSMutableArray *)selectedPeople showBlur:(BOOL)showBlur{
    

    SuggestBeeepVC *viewController = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"SuggestBeeepVC"];
    viewController.fingerprint = fingerprint;
    viewController.superviewToBlur = sender.navigationController.view;
    viewController.selectedPeople = selectedPeople;
    viewController.sendNotificationWhenFinished = sendWhenFinished;
    viewController.showBlur = showBlur;
    viewController.beeepers = [NSMutableArray arrayWithArray:beeepers];

    [self.parentViewController.view addSubview:viewController.view];
    [self.parentViewController addChildViewController:viewController];
    
    [viewController.containerV setFrame:CGRectMake(viewController.containerV.frame.origin.x, self.parentViewController.view.frame.size.height,viewController.containerV.frame.size.width,   viewController.containerV.frame.size.height)];
    
    [UIView animateWithDuration:0.4f
                     animations:^
     {
         
         if (IS_IPHONE_4_OR_LESS) {
             viewController.containerV.center = CGPointMake(viewController.view.center.x, viewController.view.center.y+ 20);
         }
         else{
             viewController.containerV.center = viewController.view.center;
         }

         if (showBlur) {
             viewController.blurContainerV.alpha = 1;
         }

     }
                     completion:^(BOOL finished)
     {
    
     }
     ];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (IBAction)tabbarButtonTapped:(UIButton *)sender {
    
    
    UIViewController *vC;
    
    switch (sender.tag) {
        case 1:
            vC = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"HomeFeedVC"];
            break;
        case 2:
            vC = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"SearchVC"];
            break;
        case 3:{
                TimelineVC *timelineVC = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"TimelineVC"];
                timelineVC.mode = Timeline_My;
                vC = timelineVC;
            }
            break;
        case 4:
            vC = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"NotificationsVC"];
            break;
        default:
            
            break;
    }
    
//    BOOL mpike;
//    
//    for (UIViewController *viewcontroller in viewControllers) {
//        if ([viewcontroller isKindOfClass:[vC class]]) {
//            vC = viewcontroller;
//            mpike = YES;
//        }
//    }
//    
//    if (!mpike) {
//        [viewControllers addObject:vC];
//    }
    
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
