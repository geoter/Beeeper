//
//  BeeepItVC.m
//  Beeeper
//
//  Created by User on 3/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "BeeepItVC.h"
#import "BeeepTimeVC.h"
#import "Timeline_Object.h"
#import "Friendsfeed_Object.h"
#import "BPCreate.h"

@interface BeeepItVC ()
{
    NSString *beepTime;
    int beepTimeSeconds;
}
@end

@implementation BeeepItVC
@synthesize tml,values;

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
    
    self.fbShareV.layer.borderColor = [UIColor colorWithRed:223/255.0 green:227/255.0 blue:230/255.0 alpha:1].CGColor;
    self.fbShareV.layer.borderWidth = 1;
    self.fbShareV.layer.masksToBounds = YES;
    self.fbShareV.layer.cornerRadius = 2;
    
    self.twitterV.layer.borderColor = [UIColor colorWithRed:223/255.0 green:227/255.0 blue:230/255.0 alpha:1].CGColor;
    self.twitterV.layer.borderWidth = 1;
    self.twitterV.layer.masksToBounds = YES;
    self.twitterV.layer.cornerRadius = 2;
    
    if (tml == nil && self.values != nil) { //Coming from Create event screen
        Friendsfeed_Object *ff = [[Friendsfeed_Object alloc]init];
        ff.eventFfo.eventDetailsFfo.title = [values objectForKey:@"title"];
        ff.eventFfo.eventDetailsFfo.timestamp = [[values objectForKey:@"timestamp"]doubleValue];
        
        //{"venue_station":"Save Mart Center","longitude":"36.7468422","latitude":"-119.7725868","address":"Fresno, CA, United States","city":"Fresno","state":" CA","country":"","utcoffset":"-420"}
        NSMutableString *locationObjc = [[NSMutableString alloc]initWithFormat:@"{\"venue_station\":\"%@\"}",[values objectForKey:@"station"]];
        
        ff.eventFfo.eventDetailsFfo.location = locationObjc;
        ff.eventFfo.eventDetailsFfo.fingerprint = [values objectForKey:@"fingerprint"];
        tml = ff;
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setBeeepTime:) name:@"Beeep Time Selected" object:nil];
    
    [self adjustFonts];
    
    NSString *title;

    if ([tml isKindOfClass:[Friendsfeed_Object class]]) {
        Friendsfeed_Object *ffo = tml;
        title = [ffo.eventFfo.eventDetailsFfo.title capitalizedString];
        
    }
    
    NSDate *date;
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMM dd, yyyy hh:mm"];

    Timeline_Object *t = tml; //one of those two will be used
    Friendsfeed_Object *ffo = tml;
    
    if ([tml isKindOfClass:[Timeline_Object class]]) {
        date = [NSDate dateWithTimeIntervalSince1970:t.event.timestamp];
    }
    else{
        date = [NSDate dateWithTimeIntervalSince1970:ffo.eventFfo.eventDetailsFfo.timestamp];
    }
    
    NSString *dateStr = [formatter stringFromDate:date];
    NSArray *components = [dateStr componentsSeparatedByString:@","];
    NSArray *day_month= [[components objectAtIndex:1]componentsSeparatedByString:@" "];
    
    NSString *month = [day_month objectAtIndex:1];
    NSString *daynumber = [day_month objectAtIndex:2];
    
    UILabel *dayNumberLbl = (id)[self.scrollV viewWithTag:-2];
    UILabel *monthLbl = (id)[self.scrollV viewWithTag:-1];
    
    monthLbl.font = [UIFont fontWithName:@"Roboto-Medium" size:18];
    dayNumberLbl.font = [UIFont fontWithName:@"Roboto-Bold" size:24];

    dayNumberLbl.text = daynumber;
    monthLbl.text = [month uppercaseString];
    
    NSString *venue;
    NSString *jsonString;
    
    if ([tml isKindOfClass:[Timeline_Object class]]) {
        jsonString = t.event.location;
    }
    else{
        jsonString = ffo.eventFfo.eventDetailsFfo.location;
    }
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
    venue = loc.venueStation;

    
    for (UIView *v in self.scrollV.subviews) {
        if ([v isKindOfClass:[UITextView class]]) {
            UITextView *txtV = (UITextView *)v;
            
            switch (txtV.tag) {
                case 1:
                {
                    txtV.text = (title)?title:@"n/a";
                }
                    break;
                case 3:
                {
                    txtV.text = (venue)?venue:@"n/a";;
                }
                    break;
                default:
                    break;
            }
        }
    }
}

-(void)setBeeepTime:(NSNotification *)notif{
    beepTime = [notif.userInfo objectForKey:@"Beeep Time"];
    beepTimeSeconds = [[notif.userInfo objectForKey:@"Seconds"]intValue];
    
    [self.beeepTimeButton setTitle:beepTime forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)adjustFonts{
    for (UIView *v in self.scrollV.subviews) {
        if ([v isKindOfClass:[UITextView class]]) {
            UITextView *txtV = (UITextView *)v;
            
            switch (txtV.tag) {
                case 1:
                {
                    txtV.font = [UIFont fontWithName:@"Roboto-Light" size:24];
                }
                    break;
                case 2:
                case 3:
                {
                    txtV.font = [UIFont fontWithName:@"Roboto-Regular" size:13];
                }
                    break;
                default:
                    break;
            }
        }
        else if ([v isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton *)v;
            btn.titleLabel.font = [UIFont fontWithName:@"Roboto-Light" size:16];
        }
    }
    
    UILabel *fbLbl = (id)[self.fbShareV viewWithTag:2];
    fbLbl.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
  
    UILabel *twitterLbl = (id)[self.twitterV viewWithTag:2];
    twitterLbl.font = [UIFont fontWithName:@"Roboto-Regular" size:15];
    
    UILabel *hideFromFollowers = (id)[self.scrollV viewWithTag:10];
    hideFromFollowers.font = [UIFont fontWithName:@"Roboto-Light" size:13];
}

- (IBAction)close:(id)sender {
    
//    BOOL showNav = [[[NSUserDefaults standardUserDefaults] objectForKey:@"dontShowNavOnClose"] boolValue];
//    
//    if (!showNav) {
//        [self.parentViewController.navigationController setNavigationBarHidden:NO animated:YES];
//    }
    
    if (sender == nil) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"BeeepIt" object:nil];
    }
    
    [UIView animateWithDuration:0.5f
                     animations:^
     {
         self.view.frame = CGRectMake(0, self.view.frame.size.height,self.view.frame.size.width , self.view.frame.size.height);
     }
                     completion:^(BOOL finished)
     {
         [self removeFromParentViewController];
         [self.view removeFromSuperview];
         
         if (sender == nil) { //Beep It pressed
//             NSDictionary *options = @{
//                                       kCRToastTextKey : @"Successfully Beeeped!",
//                                       kCRToastNotificationTypeKey  : @(CRToastTypeNavigationBar),
//                                       kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
//                                       kCRToastBackgroundColorKey : [UIColor colorWithRed:62/255.0 green:187/255.0 blue:45/255.0 alpha:1],
//                                       kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
//                                       kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
//                                       kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
//                                       kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
//                                       };
//             [CRToastManager showNotificationWithOptions:options
//                                         completionBlock:^{
//                                             
//                                         }];
             [SVProgressHUD showSuccessWithStatus:@"Successfully \nBeeeped!"];
         
         }
         }
         
     ];
}

- (IBAction)fbShare:(UISwitch *)sender {
    UIView *superV = sender.superview;
    
    if (sender.on) {
        UIImageView *icon = (id)[superV viewWithTag:1];
        [icon setImage:[UIImage imageNamed:@"facebook_icon"]];
        UILabel *lbl = (id)[superV viewWithTag:2];
        lbl.textColor = [UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1];
    }
    else{
        UIImageView *icon = (id)[superV viewWithTag:1];
        [icon setImage:[UIImage imageNamed:@"facebook_icon_gray"]];
        UILabel *lbl = (id)[superV viewWithTag:2];
        lbl.textColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1];
    }

}

- (IBAction)twitterShare:(UISwitch *)sender {
    UIView *superV = sender.superview;
    
    if (sender.on) {
        UIImageView *icon = (id)[superV viewWithTag:1];
        [icon setImage:[UIImage imageNamed:@"twitter_icon"]];
        UILabel *lbl = (id)[superV viewWithTag:2];
        lbl.textColor = [UIColor colorWithRed:70/255.0 green:154/255.0 blue:233/255.0 alpha:1];
    }
    else{
        UIImageView *icon = (id)[superV viewWithTag:1];
        [icon setImage:[UIImage imageNamed:@"twitter_icon_gray"]];
        UILabel *lbl = (id)[superV viewWithTag:2];
        lbl.textColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1];
    }
}

- (IBAction)hideFromFollowersPressed:(UIButton *)sender {
    
    if (sender.tag == 0) {
        [sender setImage:[UIImage imageNamed:@"checkbox_check"] forState:UIControlStateNormal];
        sender.tag = 1;
    }
    else{
        [sender setImage:[UIImage imageNamed:@"checkbox_empty"] forState:UIControlStateNormal];
        sender.tag = 0;
    }

}

- (IBAction)beeepIt:(id)sender {
    
    Timeline_Object *t = tml; //one of those two will be used
    Friendsfeed_Object *ffo = tml;
    
    NSString  *fingerPrint;
    int timestamp;
    
    if ([tml isKindOfClass:[Timeline_Object class]]) {
        fingerPrint = t.beeep.beeepInfo.fingerprint;
    }
    else{
        fingerPrint = ffo.eventFfo.eventDetailsFfo.fingerprint;
        timestamp = ffo.eventFfo.eventDetailsFfo.timestamp;
    }
    
    
    int beep_time = timestamp-beepTimeSeconds;
    NSString *beepTime= [NSString stringWithFormat:@"%d",beep_time];
    //Edw exei provlima,otan pas na kaneis kenurgio beep,mallon to fingerprint ine keno
    if (timestamp > 0 && fingerPrint != nil) { //Create beeep
        [[BPCreate sharedBP]beeepCreate:fingerPrint beeep_time:beepTime completionBlock:^(BOOL completed,NSArray *objs){
            if (completed) {
                [self close:nil];
            }
        }];
    }
    else{
        NSLog(@"WRONG!");
    }
    

}

- (IBAction)beeepTimeSelected:(id)sender {
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"BeeepTimeVC"];
    
    [viewController.view setFrame:CGRectMake(0, self.view.frame.size.height, 320, viewController.view.frame.size.height)];
    [self.view.superview addSubview:viewController.view];
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

}

@end
