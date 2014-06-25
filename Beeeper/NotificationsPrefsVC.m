//
//  NotificationsPrefsVC.m
//  Beeeper
//
//  Created by User on 2/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "NotificationsPrefsVC.h"

@interface NotificationsPrefsVC ()
{
    NSDictionary *settings;
}
@end

@implementation NotificationsPrefsVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideTabbar" object:self];
    
    [self adjustFonts];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self showLoading];
    
    [[BPUser sharedBP]getEmailSettingsWithCompletionBlock:^(BOOL completed,NSDictionary *objs){
        if (completed) {
            [self hideLoading];
            settings = objs;
            [self updateSettings];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was a problem getting your Notification preferences. Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
    }];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
}

-(void)updateSettings{
    UISwitch *toggleLikes = (id)[[self.scrollV viewWithTag:10]viewWithTag:12];
    UISwitch *toggleRebeeeps = (id)[[self.scrollV viewWithTag:13]viewWithTag:15];
    UISwitch *toggleFollows = (id)[[self.scrollV viewWithTag:16]viewWithTag:18];
    UISwitch *toggleComments = (id)[[self.scrollV viewWithTag:19]viewWithTag:21];
    UISwitch *toggleFriendsJoined = (id)[[self.scrollV viewWithTag:22]viewWithTag:24];
    UISwitch *toggleSuggestions = (id)[[self.scrollV viewWithTag:25]viewWithTag:27];
    
    toggleLikes.on = (BOOL)[settings objectForKey:@"like"];
    toggleRebeeeps.on = (BOOL)[settings objectForKey:@"beeep"];
    toggleFollows.on = (BOOL)[settings objectForKey:@"follow"];
    toggleSuggestions.on = (BOOL)[settings objectForKey:@"suggest"];
}

-(void)goBack{
     [[NSNotificationCenter defaultCenter]postNotificationName:@"ShowTabbar" object:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)adjustFonts{
    
    for(UIView *v in [self.scrollV allSubViews])
    {
        if([v isKindOfClass:[UILabel class]])
        {
            ((UILabel*)v).font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
            
        }
        else if ([v isKindOfClass:[UIButton class]]){
            ((UIButton*)v).titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        }
    }
    
}

- (IBAction)togglePressed:(UISwitch *)sender {

    
}

#pragma mark - MONActivityIndicatorView

-(void)showLoading{
    
    UIView *loadingBGV = [[UIView alloc]initWithFrame:self.view.bounds];
    loadingBGV.backgroundColor = self.view.backgroundColor;
    
    MONActivityIndicatorView *indicatorView = [[MONActivityIndicatorView alloc] init];
    indicatorView.delegate = self;
    indicatorView.numberOfCircles = 3;
    indicatorView.radius = 8;
    indicatorView.internalSpacing = 1;
    indicatorView.center = self.view.center;
    indicatorView.tag = -565;
    
    [loadingBGV addSubview:indicatorView];
    loadingBGV.tag = -434;
    [self.view addSubview:loadingBGV];
    [self.view bringSubviewToFront:loadingBGV];
    
    [indicatorView startAnimating];
    
}

-(void)hideLoading{
    
    UIView *loadingBGV = (id)[self.view viewWithTag:-434];
    MONActivityIndicatorView *indicatorView = (id)[loadingBGV viewWithTag:-565];
    [indicatorView stopAnimating];
    
    [UIView animateWithDuration:0.3f
                     animations:^
     {
         loadingBGV.alpha = 0;
     }
                     completion:^(BOOL finished)
     {
         [loadingBGV removeFromSuperview];
         
     }
     ];
}


@end
