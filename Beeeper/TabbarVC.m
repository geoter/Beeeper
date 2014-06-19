//
//  TabbarVC.m
//  Beeeper
//
//  Created by User on 4/17/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "TabbarVC.h"
#import "TimelineVC.h"

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
    
    [[BPUser sharedBP]getNotificationsWithCompletionBlock:^(BOOL completed,NSArray *objcts){
    
        if (completed) {
            self.notifications = objcts.count;
        }
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 1;
    
    [self tabbarButtonTapped:btn];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideTabbar) name:@"HideTabbar" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showTabbar) name:@"ShowTabbar" object:nil];
}

-(void)updateNotificationsBadge{
    
    self.notificationLabel.text = [NSString stringWithFormat:@"%d",self.notifications];
    
    if (self.notifications <= 0) {

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
    
    [UIView animateWithDuration:0.7f
                     animations:^
     {
         self.tabBar.frame = CGRectMake(0, self.view.frame.size.height-self.tabBar.frame.size.height, self.tabBar.frame.size.width, self.tabBar.frame.size.height);
     }
                     completion:^(BOOL finished)
     {
         
         [UIView animateWithDuration:0.7f
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
    
    
    for (UIViewController *child in self.childViewControllers) {
        [child removeFromParentViewController];
        [child.view removeFromSuperview];
    }
    
    [self addChildViewController:navVC];
    [self.containerVC addSubview:navVC.view];
}

@end
