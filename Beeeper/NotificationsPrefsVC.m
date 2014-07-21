//
//  NotificationsPrefsVC.m
//  Beeeper
//
//  Created by User on 2/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "NotificationsPrefsVC.h"

@interface NotificationsPrefsVC ()<MONActivityIndicatorViewDelegate>
{
    NSMutableDictionary *downloadedSettings;
    NSMutableDictionary *settings;
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
    
    self.scrollV.contentSize = CGSizeMake(self.scrollV.frame.size.width, self.scrollV.frame.size.height+1);
    
    [self showLoading];
    
    settings = [NSMutableDictionary dictionary];
    
    [[BPUser sharedBP]getEmailSettingsWithCompletionBlock:^(BOOL completed,NSDictionary *objs){
        if (completed) {
            [self hideLoading];
            downloadedSettings = [NSMutableDictionary dictionaryWithDictionary:objs];
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
    
    NSString *beeep = [downloadedSettings objectForKey:@"beeep"];
    NSString *like = [downloadedSettings objectForKey:@"like"];
    NSString *follow = [downloadedSettings objectForKey:@"follow"];
    NSString *suggest = [downloadedSettings objectForKey:@"suggest"];
    NSString *comment = [downloadedSettings objectForKey:@"comment"];
    
    toggleLikes.on = like.boolValue;
    toggleRebeeeps.on = beeep.boolValue;
    toggleFollows.on = follow.boolValue;
    toggleSuggestions.on = suggest.boolValue;
    toggleComments.on = comment.boolValue;
}

-(void)goBack{
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

    switch (sender.tag) {
        case 12:
        {
            [downloadedSettings setObject:[NSString stringWithFormat:@"%d",sender.isOn] forKey:@"like"];
            
        }
        break;
        case 15:
        {
            [downloadedSettings setObject:[NSString stringWithFormat:@"%d",sender.isOn] forKey:@"beeep"];
        }
            break;
        case 18:
        {
            [downloadedSettings setObject:[NSString stringWithFormat:@"%d",sender.isOn] forKey:@"follow"];
        }
            break;
        case 21:
        {
           [downloadedSettings setObject:[NSString stringWithFormat:@"%d",sender.isOn] forKey:@"comment"];

        }
            break;
        case 24:
        {
            
        }
            break;
        case 27:
        {
             [downloadedSettings setObject:[NSString stringWithFormat:@"%d",sender.isOn] forKey:@"suggest"];
        }
            break;

    
        default:
            break;
    }
    
    [settings setObject:[downloadedSettings objectForKey:@"like"] forKey:@"likes"];
    [settings setObject:[downloadedSettings objectForKey:@"beeep"] forKey:@"beeep"];
    [settings setObject:[downloadedSettings objectForKey:@"follow"] forKey:@"setfollows"];
    [settings setObject:[downloadedSettings objectForKey:@"comment"] forKey:@"setcomments"];
    [settings setObject:[downloadedSettings objectForKey:@"suggest"] forKey:@"suggestions"];
    
    
    [[BPUser sharedBP]setEmailSettings:settings WithCompletionBlock:^(BOOL completed,NSDictionary *objs){
        if (completed) {
            downloadedSettings = [NSMutableDictionary dictionaryWithDictionary:objs];
            [self performSelectorOnMainThread:@selector(updateSettings) withObject:nil waitUntilDone:NO];
            }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was a problem getting your Notification preferences. Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
    }];

    
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
