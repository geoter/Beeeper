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
#import "Suggestion_Object.h"
#import "Event_Show_Object.h"
#import "SuggestBeeepVC.h"
#import "Activity_Object.h"

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

    [self adjustFonts];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setBeeepTime:) name:@"Beeep Time Selected" object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    @try {
        
        if (tml == nil && self.values != nil) { //Coming from Create event screen
            Friendsfeed_Object *ff = [[Friendsfeed_Object alloc]init];
            ff.eventFfo.eventDetailsFfo.title = [values objectForKey:@"title"];
            ff.eventFfo.eventDetailsFfo.timestamp = [[values objectForKey:@"timestamp"]doubleValue];
            
            //{"venue_station":"Save Mart Center","longitude":"36.7468422","latitude":"-119.7725868","address":"Fresno, CA, United States","city":"Fresno","state":" CA","country":"","utcoffset":"-420"}
            NSMutableString *locationObjc = [[NSMutableString alloc]initWithFormat:@"{\"venue_station\":\"%@\",\"longitude\":\"%@\",\"latitude\":\"%@\",\"address\":\"%@\",\"city\":\"%@\",\"state\":\"%@\",\"country\":\"%@\",\"utcoffset\":\"%@\"}",[values objectForKey:@"station"],[values objectForKey:@"longitude"],[values objectForKey:@"latitude"],[values objectForKey:@"address"],[values objectForKey:@"city"],[values objectForKey:@"state"],[values objectForKey:@"country"],[values objectForKey:@"utcoffset"]];
            
            ff.eventFfo.eventDetailsFfo.location = locationObjc;
            ff.eventFfo.eventDetailsFfo.fingerprint = [values objectForKey:@"fingerprint"];
            tml = ff;
        }
        
        
        
        NSString *title;
        
        if ([tml isKindOfClass:[Friendsfeed_Object class]]) {
            Friendsfeed_Object *ffo = tml;
            title = [ffo.eventFfo.eventDetailsFfo.title capitalizedString];
            
        }
        else if ([tml isKindOfClass:[Event_Show_Object class]]){
            Event_Show_Object *activity = tml;
            
            title = [activity.eventInfo.title capitalizedString];
            
        }
        else if ([tml isKindOfClass:[Suggestion_Object class]]){
            Suggestion_Object *sgo = tml;
            title = [sgo.what.title capitalizedString];
        }
        else if ([tml isKindOfClass:[Timeline_Object class]]){
            Timeline_Object *tmlO = tml;
            title = [tmlO.event.title capitalizedString];
        }
        else if ([tml isKindOfClass:[Activity_Object class]]){
            Activity_Object *activity = tml;
            
            if(activity.beeepInfoActivity.eventActivity.count >0){
                
                EventActivity *event = [activity.beeepInfoActivity.eventActivity firstObject];
                title = event.title;
            }
            else if(activity.eventActivity.count > 0){
                
                EventActivity *event = [activity.eventActivity firstObject];
                NSString *event_title = [event.title capitalizedString];
                title = [event_title capitalizedString];
            }

        }
        
        NSDate *date;
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE, MMM dd, yyyy hh:mm"];
        
        Timeline_Object *t = tml; //one of those two will be used
        Friendsfeed_Object *ffo = tml;
        Suggestion_Object *sgo = tml;
        
        if ([tml isKindOfClass:[Timeline_Object class]]) {
            date = [NSDate dateWithTimeIntervalSince1970:t.event.timestamp];
        }
        else if ([tml isKindOfClass:[Event_Show_Object class]]){
            Event_Show_Object *activity = tml;
            
            date = [NSDate dateWithTimeIntervalSince1970:activity.eventInfo.timestamp];
            
        }
        else if ([tml isKindOfClass:[Suggestion_Object class]]){
            date = [NSDate dateWithTimeIntervalSince1970:sgo.what.timestamp];
        }
        else if ([tml isKindOfClass:[Activity_Object class]]){
            Activity_Object *activity = tml;
            
            if(activity.beeepInfoActivity.eventActivity.count >0){
                
                EventActivity *event = [activity.beeepInfoActivity.eventActivity firstObject];
                
            }
            else if(activity.eventActivity.count > 0){
                
                EventActivity *event = [activity.eventActivity firstObject];

                
            }
            
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
        
        monthLbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
        dayNumberLbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24];
        
        dayNumberLbl.text = daynumber;
        monthLbl.text = [month uppercaseString];
        
        NSString *venue;
        NSString *jsonString;
        
        if ([tml isKindOfClass:[Timeline_Object class]]) {
            jsonString = t.event.location;
        }
        else if ([tml isKindOfClass:[Event_Show_Object class]]){
            Event_Show_Object *activity = tml;
            
            jsonString = activity.eventInfo.location;
            
        }
        else if ([tml isKindOfClass:[Suggestion_Object class]]){
            jsonString = sgo.what.location;
        }
        else if ([tml isKindOfClass:[Activity_Object class]]){
            Activity_Object *activity = tml;
            
            if(activity.beeepInfoActivity.eventActivity.count >0){
                
                EventActivity *event = [activity.beeepInfoActivity.eventActivity firstObject];
                
            }
            else if(activity.eventActivity.count > 0){
                
                EventActivity *event = [activity.eventActivity firstObject];

            }
            
        }

        else{
            jsonString = ffo.eventFfo.eventDetailsFfo.location;
        }
        
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        if (data != nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
            venue = loc.venueStation;
        }
        
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
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    @finally {
        
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
                    txtV.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24];
                }
                    break;
                case 2:
                case 3:
                {
                    txtV.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
                }
                    break;
                default:
                    break;
            }
        }
        else if ([v isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton *)v;
            btn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        }
    }
    
    UILabel *fbLbl = (id)[self.fbShareV viewWithTag:2];
    fbLbl.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
  
    UILabel *twitterLbl = (id)[self.twitterV viewWithTag:2];
    twitterLbl.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    
    UILabel *hideFromFollowers = (id)[self.scrollV viewWithTag:10];
    hideFromFollowers.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
}

- (IBAction)close:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (sender == nil) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"BeeepIt" object:nil];
            [SVProgressHUD showSuccessWithStatus:@"Successfully \nBeeeped!"];
        }
    }];
    
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
    Suggestion_Object *sgo = tml;
    
    NSString  *fingerPrint;
    int timestamp;
    
    if ([tml isKindOfClass:[Timeline_Object class]]) {
        fingerPrint = t.beeep.beeepInfo.fingerprint;
        timestamp = t.beeep.beeepInfo.timestamp.doubleValue;
    }
    else if ([tml isKindOfClass:[Event_Show_Object class]]){
        Event_Show_Object *activity = tml;
        
        fingerPrint = activity.eventInfo.fingerprint;
        timestamp = activity.eventInfo.timestamp;
        
    }
    else if([tml isKindOfClass:[Suggestion_Object class]]){
        fingerPrint = sgo.what.fingerprint;
        timestamp = sgo.what.timestamp;
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
            else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Beeep was not created.Please try again. We are sorry for the inconvenience" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            }
        }];
    }
    else{
        NSLog(@"WRONG!");
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Beeep was not created.Make sure you haven't already Beeeped this event." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    

}

- (IBAction)beeepTimeSelected:(id)sender {
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"BeeepTimeVC"];
    
    [viewController.view setFrame:CGRectMake(0, self.view.frame.size.height, 320, viewController.view.frame.size.height)];
    [self.view addSubview:viewController.view];
    [self addChildViewController:viewController];
    
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

- (IBAction)suggestItPressed:(id)sender {
    SuggestBeeepVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"SuggestBeeepVC"];
    [self presentViewController:viewController animated:YES completion:NULL];

}

@end
