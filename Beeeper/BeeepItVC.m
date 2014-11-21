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
#import "Activity_Object.h"
#import "Event_Search.h"
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>
#import "BPActivity.h"
#import "BPSuggestions.h"

@interface BeeepItVC ()
{
    NSString *beeepTime;
    int beepTimeSeconds;
    NSMutableString *shareText;
    NSString *imageURL;
    NSString *website;
    NSString *beeepTitle;
    NSString *beeepDate;
    NSString *tinyURL;
    NSString *fingerprint;
    NSMutableArray *followers;
    
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
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    UIImage *blurredImg = [[DTO sharedDTO]convertViewToBlurredImage:self.superviewToBlur withRadius:2];
    self.blurredImageV.image = blurredImg;
    
    self.blurContainerV.alpha = 0;
    
//    self.suggestButton.layer.borderColor = [UIColor colorWithRed:164/255.0 green:168/255.0 blue:174/255.0 alpha:1].CGColor;
//    self.suggestButton.layer.borderWidth = 1;
//    self.suggestButton.layer.cornerRadius = 5;

    TKRoundedView *beeepTimeBGV = (TKRoundedView *)[self.view viewWithTag:1111];
    beeepTimeBGV.roundedCorners = TKRoundedCornerTopLeft | TKRoundedCornerTopRight;
    beeepTimeBGV.borderColor = [UIColor colorWithRed:164/255.0 green:168/255.0 blue:174/255.0 alpha:0.8];
    beeepTimeBGV.borderWidth = 1.0f;
    beeepTimeBGV.cornerRadius = 6;
    beeepTimeBGV.drawnBordersSides = TKDrawnBorderSidesLeft | TKDrawnBorderSidesRight | TKDrawnBorderSidesTop;
    
    TKRoundedView *suggestBGV = (TKRoundedView *)[self.view viewWithTag:1112];
    suggestBGV.roundedCorners = TKRoundedCornerBottomLeft | TKRoundedCornerBottomRight;
    suggestBGV.borderColor = [UIColor colorWithRed:164/255.0 green:168/255.0 blue:174/255.0 alpha:0.8];
    suggestBGV.borderWidth = 1.0f;
    suggestBGV.cornerRadius = 6;
    
//    self.beeepTimeButton.layer.borderColor = [UIColor colorWithRed:164/255.0 green:168/255.0 blue:174/255.0 alpha:1].CGColor;
//    self.beeepTimeButton.layer.borderWidth = 1;
//    self.beeepTimeButton.layer.cornerRadius = 5;
    
    self.fbShareV.roundedCorners = TKRoundedCornerTopLeft | TKRoundedCornerTopRight;
    self.fbShareV.borderColor = [UIColor colorWithRed:164/255.0 green:168/255.0 blue:174/255.0 alpha:0.8];
    self.fbShareV.borderWidth = 1.0f;
    self.fbShareV.cornerRadius = 6;
    self.fbShareV.drawnBordersSides = TKDrawnBorderSidesLeft | TKDrawnBorderSidesRight | TKDrawnBorderSidesTop;

    self.twitterV.roundedCorners =  TKRoundedCornerBottomLeft | TKRoundedCornerBottomRight;
    self.twitterV.borderColor = [UIColor colorWithRed:164/255.0 green:168/255.0 blue:174/255.0 alpha:0.8];
    self.twitterV.borderWidth = 1.0f;
    self.twitterV.cornerRadius = 6;
    self.twitterV.drawnBordersSides = TKDrawnBorderSidesLeft | TKDrawnBorderSidesRight | TKDrawnBorderSidesTop;
    
    [self adjustFonts];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setBeeepTime:) name:@"Beeep Time Selected" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(close:) name:@"CloseBeeepItVC" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(followersSelected:) name:@"Suggest Followers Selected" object:nil];
    
    BeeepTimeVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"BeeepTimeVC"];
    
    [viewController.view setFrame:CGRectMake(0, 0, viewController.view.frame.size.width, viewController.view.frame.size.height)];
    viewController.closeExits = YES;
    
    [self.view addSubview:viewController.view];
    [self addChildViewController:viewController];

    [self setBeeep];
}

-(void)setBeeep{
    
    shareText = [[NSMutableString alloc]init];
    
    @try {
        
        if (tml == nil && self.values != nil) { //Coming from Create event screen
            Friendsfeed_Object *ff = [[Friendsfeed_Object alloc]init];
            ff.eventFfo.eventDetailsFfo.title = [values objectForKey:@"title"];
            ff.eventFfo.eventDetailsFfo.timestamp = [[values objectForKey:@"timestamp"]doubleValue];
            
            //{"venue_station":"Save Mart Center","longitude":"36.7468422","latitude":"-119.7725868","address":"Fresno, CA, United States","city":"Fresno","state":" CA","country":"","utcoffset":"-420"}
            NSMutableString *locationObjc = [[NSMutableString alloc]initWithFormat:@"{\"venue_station\":\"%@\",\"longitude\":\"%@\",\"latitude\":\"%@\",\"address\":\"%@\",\"city\":\"%@\",\"state\":\"%@\",\"country\":\"%@\",\"utcoffset\":\"%@\"}",[values objectForKey:@"station"],[values objectForKey:@"longitude"],[values objectForKey:@"latitude"],[values objectForKey:@"address"],[values objectForKey:@"city"],[values objectForKey:@"state"],[values objectForKey:@"country"],[values objectForKey:@"utcoffset"]];
            
            ff.eventFfo.eventDetailsFfo.location = locationObjc;
            ff.eventFfo.eventDetailsFfo.fingerprint = [values objectForKey:@"fingerprint"];
            fingerprint = [values objectForKey:@"fingerprint"];
            tml = ff;
        }
        
        
        NSString *title;
        
        if ([tml isKindOfClass:[Friendsfeed_Object class]]) {
            Friendsfeed_Object *ffo = tml;
            title = [ffo.eventFfo.eventDetailsFfo.title capitalizedString];
            fingerprint = ffo.eventFfo.eventDetailsFfo.fingerprint;
        }
        else if ([tml isKindOfClass:[Event_Show_Object class]]){
            Event_Show_Object *activity = tml;
            title = [activity.eventInfo.title capitalizedString];
            fingerprint = activity.eventInfo.fingerprint;
        }
        else if ([tml isKindOfClass:[Suggestion_Object class]]){
            Suggestion_Object *sgo = tml;
            title = [sgo.what.title capitalizedString];
            fingerprint = sgo.what.fingerprint;
        }
        else if ([tml isKindOfClass:[Timeline_Object class]]){
            Timeline_Object *tmlO = tml;
            title = [tmlO.event.title capitalizedString];
            fingerprint = tmlO.event.fingerprint;
        }
        else if ([tml isKindOfClass:[Activity_Object class]]){
            Activity_Object *activity = tml;
            
            if(activity.beeepInfoActivity.eventActivity.count >0){
                
                EventActivity *event = [activity.beeepInfoActivity.eventActivity firstObject];
                title = [event.title capitalizedString];
                fingerprint = event.fingerprint;
            }
            else if(activity.eventActivity.count > 0){
                
                EventActivity *event = [activity.eventActivity firstObject];
                NSString *event_title = [event.title capitalizedString];
                title = [event_title capitalizedString];
                fingerprint = event.fingerprint;
            }
            
        }
        else if ([tml isKindOfClass:[Event_Search class]]){
            Event_Search *eventS = tml;
            title = [eventS.title capitalizedString];
            fingerprint = eventS.fingerprint;
        }
        
        website = [NSString stringWithFormat:@"https://www.beeeper.com/event/%@",fingerprint];
        
        if (website == nil) {
            website = @"http://www.beeeper.com";
        }
        
        [[BPActivity sharedBP]getEventFromFingerprint:fingerprint WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
            if (completed) {
                tinyURL = [NSString stringWithFormat:@"http://beeep.it/%@",event.tinyUrl];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Event not found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
        
        
        beeepTitle = title;
        //[shareText appendString:title];
        
        
        NSDate *date;
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE, MMM dd, yyyy HH:mm"];
        
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
        else if ([tml isKindOfClass:[Event_Search class]]){
            Event_Search *eventS = tml;
            date = [NSDate dateWithTimeIntervalSince1970:eventS.timestamp];
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
        
        
        dayNumberLbl.text = daynumber;
        monthLbl.text = [month uppercaseString];
        
        [shareText appendFormat:@"When: %@ %@",daynumber,[month uppercaseString]];
        
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
        else if ([tml isKindOfClass:[Event_Search class]]){
            Event_Search *eventS = tml;
            jsonString = eventS.location;
        }
        else{
            jsonString = ffo.eventFfo.eventDetailsFfo.location;
        }
        
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        if (data != nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
            venue = [loc.venueStation uppercaseString];
            [shareText appendFormat:@"\nWhere: %@",venue];
        }
        
        
        self.titleLabel.text = (title)?title:@"n/a";
        [self.titleLabel sizeToFit];
        self.titleLabel.center = CGPointMake(self.scrollV.frame.size.width/2, self.titleLabel.center.y);
        self.venueLabel.text = (venue)?venue:@"n/a";
       // self.titleLabel.backgroundColor = [UIColor yellowColor];
        
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              self.venueLabel.font, NSFontAttributeName,
                                              nil];
        
        CGRect frame = [self.venueLabel.text boundingRectWithSize:CGSizeMake(self.venueLabel.frame.size.width, 2000.0)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:attributesDictionary
                                                context:nil];
        CGSize sizeOfText= frame.size;
        
       // self.venueLabel.backgroundColor = [UIColor redColor];
        self.venueLabel.frame = CGRectMake(self.venueLabel.frame.origin.x, self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height, sizeOfText.width, sizeOfText.height);
        self.venueLabel.center = CGPointMake(self.titleLabel.center.x+3,self.venueLabel.center.y);//any y
        
        self.venueIcon.frame = CGRectMake(self.venueLabel.frame.origin.x-self.venueIcon.frame.size.width-3, self.venueLabel.frame.origin.y+2, self.venueIcon.frame.size.width, self.venueIcon.frame.size.height);
        
        NSString *imageUrl;
        if ([tml isKindOfClass:[Timeline_Object class]]) {
            imageUrl = t.event.imageUrl;
        }
        else if ([tml isKindOfClass:[Event_Show_Object class]]){
            Event_Show_Object *activity = tml;
            imageUrl = activity.eventInfo.imageUrl;;
            
        }
        else if([tml isKindOfClass:[Suggestion_Object class]]){
            imageUrl = sgo.what.imageUrl;
        }
        else if ([tml isKindOfClass:[Event_Search class]]){
            Event_Search *eventS = tml;
            imageUrl = eventS.imageUrl;
        }
        
        else{
            imageUrl = ffo.eventFfo.eventDetailsFfo.imageUrl;
        }
        
        
        imageURL = [[DTO sharedDTO]fixLink:imageUrl];
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    @finally {
        
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

-(void)setBeeepTime:(NSNotification *)notif{
    beeepTime = [notif.userInfo objectForKey:@"Beeep Time"];
    beepTimeSeconds = [[notif.userInfo objectForKey:@"Seconds"]intValue];
    
    self.selectTimeLabel.text = beeepTime;
    self.selectTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
    self.selectTimeLabel.textColor = [UIColor colorWithRed:240/255.0 green:208/255.0 blue:0 alpha:1];
    
}

-(void)followersSelected:(NSNotification *)notif{
   followers = [NSMutableArray arrayWithArray:[notif.userInfo objectForKey:@"followers"]];
   
    self.suggestedLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
    self.suggestedLabel.textColor = [UIColor colorWithRed:240/255.0 green:208/255.0 blue:0 alpha:1];
    self.suggestedLabel.text = @"";
    
    for (NSDictionary *beeeper in followers) {
        NSString *name = [beeeper objectForKey:@"name"];
//        NSString *surname = [beeeper objectForKey:@"lastname"];
        
        if ([name isKindOfClass:[NSString class]] && name.length > 0) {
            self.suggestedLabel.text = [self.suggestedLabel.text stringByAppendingString:[name capitalizedString]];
        }

       /* if ([surname isKindOfClass:[NSString class]] && surname.length > 0) {
            self.suggestedLabel.text = [self.suggestedLabel.text stringByAppendingFormat:@" %@",[surname capitalizedString]];
        }*/
        
        if ([followers indexOfObject:beeeper] != followers.count-1) {
            self.suggestedLabel.text = [self.suggestedLabel.text stringByAppendingString:@", "];
        }
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)adjustFonts{
    
    UILabel *fbLbl = (id)[self.fbShareV viewWithTag:2];
    fbLbl.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
  
    UILabel *twitterLbl = (id)[self.twitterV viewWithTag:2];
    twitterLbl.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    
    UILabel *hideFromFollowers = (id)[self.scrollV viewWithTag:10];
    hideFromFollowers.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
}

- (IBAction)close:(id)sender {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.3f
                     animations:^
     {
         self.blurContainerV.alpha = 0;
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.5f
                          animations:^
          {
              self.view.frame = CGRectMake(0, self.view.frame.size.height,self.view.frame.size.width , self.view.frame.size.height);
          }
                          completion:^(BOOL finished)
          {
              [self removeFromParentViewController];
              [self.view removeFromSuperview];
              [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
              
              if (sender == nil) {
                  [[NSNotificationCenter defaultCenter]postNotificationName:@"BeeepIt" object:nil];
                  [SVProgressHUD showSuccessWithStatus:@"Successfully \nBeeeped!"];
              }
          }
          ];

    }];
    
}

- (IBAction)fbShare:(UISwitch *)sender {
    [self switchValueChanged:sender];
}

-(void)switchValueChanged:(UISwitch *)switchV{
   
    if (switchV == self.fbSwitch) {
        UIView *superV = switchV.superview;
        
        if (switchV.on) {
            [self sendFacebook];
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
    else{
        
        UIView *superV = switchV.superview;
        
        if (switchV.on) {
            [self sendTwitter];
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
}

- (IBAction)twitterShare:(UISwitch *)sender {
    [self switchValueChanged:sender];
}

-(void)sendFacebookOld{
    
    
    SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
 //   NSString *extension = [[imageURL.lastPathComponent componentsSeparatedByString:@"."] lastObject];

    if(imageURL == nil){
       NSString *base64Image = [self.values objectForKey:@"base64_image"];
        NSData *base64Data = [self base64DataFromString:base64Image];
        
        if (base64Data != nil) {
            UIImage *img = [UIImage imageWithData:base64Data];
            [composeController addImage:img];

        }
    }
    else{
        NSString *imageName = [NSString stringWithFormat:@"%@",[imageURL MD5]];

        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

        NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
        
        if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
            
            UIImage *img = [UIImage imageWithContentsOfFile:localPath];
            [composeController addImage:img];
        }
    }
    
    [composeController setInitialText:shareText];

    [composeController addURL: [NSURL URLWithString:(website != nil)?website:@"http://www.beeeper.com"]];
    
    [self presentViewController:composeController animated:YES completion:nil];
    
    
    SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
        if (result == SLComposeViewControllerResultCancelled) {
            
            UIImageView *icon = (id)[self.fbSwitch.superview viewWithTag:1];
            [icon setImage:[UIImage imageNamed:@"twitter_icon_gray"]];
            UILabel *lbl = (id)[self.fbSwitch.superview viewWithTag:2];
            lbl.textColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1];
            self.fbSwitch.on = NO;
            
        } else
            
        {
            [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1]];
            [SVProgressHUD showSuccessWithStatus:@"Posted on Facebook!"];
        }
        
        //    [composeController dismissViewControllerAnimated:YES completion:Nil];
    };
    composeController.completionHandler =myBlock;
    
    
}

-(void)sendFacebook2{
    
    [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                      defaultAudience:FBSessionDefaultAudienceOnlyMe
                                         allowLoginUI:YES
                                    completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {                                      if (error) {
                                          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                              message:error.localizedDescription
                                                                                             delegate:nil
                                                                                    cancelButtonTitle:@"OK"
                                                                                    otherButtonTitles:nil];
                                          [alertView show];
                                          
                                      }
                                      else if (session.isOpen) {
                                          


                                              // instantiate a Facebook Open Graph object
                                              NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
                                              
                                              // specify that this Open Graph object will be posted to Facebook
                                              object.provisionedForPost = YES;
                                              
                                              // for og:title
                                              object[@"title"] = beeepTitle;
                                              
                                              // for og:type, this corresponds to the Namespace you've set for your app and the object type name
                                              object[@"type"] = @"beeeperappios:Beeep";
                                              
                                              // for og:description
                                              object[@"description"] = shareText;
                                              
                                              // for og:url, we cover how this is used in the "Deep Linking" section below
                                              object[@"url"] = website;
                                              
                                              // for og:image we assign the image that we just staged, using the uri we got as a response
                                              // the image has to be packed in a dictionary like this:
                                              object[@"image"] = @[@{@"url": imageURL, @"user_generated" : @"false"}];
                                              
                                              
                                              // Post custom object
                                              [FBRequestConnection startForPostOpenGraphObject:object completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                  if(!error) {
                                                      // get the object ID for the Open Graph object that is now stored in the Object API
                                                      NSString *objectId = [result objectForKey:@"id"];
                                                      
                                                      // Further code to post the OG story goes here 
                                                      
                                                  } else {
                                                      // An error occurred
                                                      NSLog(@"Error posting the Open Graph object to the Object API: %@", error);
                                                  }
                                              }];
                                              
                                              
                                          
                                          }
                                          
                                          //run your user info request here
                                      }
     ];

  
}

-(void)sendFacebook{


    [FBSession openActiveSessionWithReadPermissions:@[@"publish_actions"]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState state,
                                                      NSError *error) {
          if (error) {
              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:error.localizedDescription
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles:nil];
              [alertView show];
              self.fbSwitch.on = NO;
              [self switchValueChanged:self.fbSwitch];
              
              [self sendFacebookNoApp];
              
          } else if (session.isOpen) {
              
            
//            UIImage *img;
//            
//            if(imageURL == nil){
//                NSString *base64Image = [self.values objectForKey:@"base64_image"];
//                NSData *base64Data = [self base64DataFromString:base64Image];
//                
//                if (base64Data != nil) {
//                    img = [UIImage imageWithData:base64Data];
//                }
//            }
//            else{
//                NSString *imageName = [NSString stringWithFormat:@"%@",[imageURL MD5]];
//                
//                NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//                
//                NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
//                
//                if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
//                    
//                    img = [UIImage imageWithContentsOfFile:localPath];
//                }
//            }

            
              // Check if the Facebook app is installed and we can present the share dialog
              FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
              params.link = [NSURL URLWithString:website];
              NSURL *url = [NSURL URLWithString:imageURL];
              params.picture = url;
              params.name = beeepTitle;
              params.linkDescription = self.venueLabel.text;
              
              // If the Facebook app is installed and we can present the share dialog
              if ([FBDialogs canPresentShareDialogWithParams:params]) {
                  // Present share dialog
                  
                  [FBDialogs presentShareDialogWithParams:params clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                    if(error) {
                                                        // An error occurred, we need to handle the error
                                                        // See: https://developers.facebook.com/docs/ios/errors
                                                        
                                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                            message:error.localizedDescription
                                                                                                           delegate:nil
                                                                                                  cancelButtonTitle:@"OK"
                                                                                                  otherButtonTitles:nil];
                                                        [alertView show];
                                                        
                                                        NSLog(@"Error publishing story: %@", error.description);
                                                        self.fbSwitch.on = NO;
                                                        
                                                        [self switchValueChanged:self.fbSwitch];
                                                        
                                                        [self sendFacebookNoApp];
                                                        
                                                    } else {
                                                        // Success
                                                        NSLog(@"result %@", results);
                                                        @try {
                                                           
                                                            NSString *action = [results objectForKey:@"completionGesture"];
                                                            
                                                            if ([action isEqualToString:@"cancel"]) {
                                                                
                                                                self.fbSwitch.on = NO;
                                                                
                                                                [self switchValueChanged:self.fbSwitch];
                                                            }
                                                            
                                                        }
                                                        @catch (NSException *exception) {
                                                            
                                                        }
                                                        @finally {
                                                            

                                                        }
                                                        
                                                        
                                                    }
                                                }];
              } else {
                  // Present the feed dialog
                  [self sendFacebookNoApp];
              }

    
          //run your user info request here
      }
  }];
}

-(void)sendFacebookNoApp{
    
    if (self.facebookDialogEventImage) {
    
        SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [composeController setInitialText:shareText];
        
        [composeController addImage:self.facebookDialogEventImage];
        [composeController addURL: [NSURL URLWithString:(website != nil)?website:@"http://www.beeeper.com"]];
        
        [self presentViewController:composeController animated:YES completion:nil];
        
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultDone) {
                [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:85/255.0 green:172/255.0 blue:238/255.0 alpha:1]];
                [SVProgressHUD showSuccessWithStatus:@"Posted on Facebook!"];
                
                self.fbSwitch.on = YES;
                [self switchValueChanged:self.fbSwitch];
            }
            else if (result == SLComposeViewControllerResultCancelled) {
                self.fbSwitch.on = NO;
                [self switchValueChanged:self.fbSwitch];
            }
            
            //    [composeController dismissViewControllerAnimated:YES completion:Nil];
        };
        composeController.completionHandler =myBlock;
    }
    else{
        
        [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:imageURL]
                                                            options:0
                                                           progress:^(NSInteger receivedSize, NSInteger expectedSize)
         {
             // progression tracking code
         }
                                                          completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
         {
             if (image && finished)
             {
                 
                 SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                 
                 [composeController setInitialText:shareText];
                 
                 [composeController addImage:image];
                 
                 NSURL *url = [NSURL URLWithString:(tinyURL != nil)?tinyURL:@"http://www.beeeper.com"];
                 [composeController addURL: url];
                 
                 
                 [self presentViewController:composeController
                                    animated:YES completion:nil];
                 
                 SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
                     if (result == SLComposeViewControllerResultCancelled) {
                         self.twitterSwitch.on = NO;
                         [self switchValueChanged:self.twitterSwitch];
                         
                     } else
                         
                     {
                         [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:85/255.0 green:172/255.0 blue:238/255.0 alpha:1]];
                         [SVProgressHUD showSuccessWithStatus:@"Posted on Facebook!"];
                     }
                     
                     //   [composeController dismissViewControllerAnimated:YES completion:Nil];
                 };
                 composeController.completionHandler =myBlock;
                 
                 
                 
             }
         }];
        
    }
}


-(void)sendTwitter {
    
    if (self.facebookDialogEventImage) {
        
        SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [composeController setInitialText:shareText];
        
        [composeController addImage:self.facebookDialogEventImage];
        
        NSURL *url = [NSURL URLWithString:(tinyURL != nil)?tinyURL:@"http://www.beeeper.com"];
        [composeController addURL: url];
        
        
        [self presentViewController:composeController
                           animated:YES completion:nil];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            if (result == SLComposeViewControllerResultCancelled) {
                self.twitterSwitch.on = NO;
                [self switchValueChanged:self.twitterSwitch];
                
            } else
                
            {
                [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:85/255.0 green:172/255.0 blue:238/255.0 alpha:1]];
                [SVProgressHUD showSuccessWithStatus:@"Posted on Twitter!"];
            }
            
            //   [composeController dismissViewControllerAnimated:YES completion:Nil];
        };
        composeController.completionHandler =myBlock;

    }
    else{
    
        [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:imageURL]
                                                            options:0
                                                           progress:^(NSInteger receivedSize, NSInteger expectedSize)
         {
             // progression tracking code
         }
                                                          completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
         {
             if (image && finished)
             {
        
                 SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                 
                 [composeController setInitialText:shareText];
                 
                 [composeController addImage:image];
                 
                 NSURL *url = [NSURL URLWithString:(tinyURL != nil)?tinyURL:@"http://www.beeeper.com"];
                 [composeController addURL: url];
                 
                 
                 [self presentViewController:composeController
                                    animated:YES completion:nil];
                 
                 SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
                     if (result == SLComposeViewControllerResultCancelled) {
                         self.twitterSwitch.on = NO;
                         [self switchValueChanged:self.twitterSwitch];
                         
                     } else
                         
                     {
                         [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:85/255.0 green:172/255.0 blue:238/255.0 alpha:1]];
                         [SVProgressHUD showSuccessWithStatus:@"Posted on Twitter!"];
                     }
                     
                     //   [composeController dismissViewControllerAnimated:YES completion:Nil];
                 };
                 composeController.completionHandler =myBlock;

        
        
             }
         }];
    
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
    else if ([tml isKindOfClass:[Event_Search class]]){
        Event_Search *eventS = tml;
        fingerPrint = eventS.fingerprint;
        timestamp = eventS.timestamp;
    }

    else{
        fingerPrint = ffo.eventFfo.eventDetailsFfo.fingerprint;
        timestamp = ffo.eventFfo.eventDetailsFfo.timestamp;
    }
    
    
    int beep_time = timestamp-beepTimeSeconds;
    NSString *beepTime= [NSString stringWithFormat:@"%d",beep_time];
    //Edw exei provlima,otan pas na kaneis kenurgio beep,mallon to fingerprint ine keno
    if (timestamp > 0 && fingerPrint != nil) { //Create beeep
        [[BPCreate sharedBP]beeepCreate:fingerPrint beeep_time:beepTime completionBlock:^(BOOL completed,NSDictionary *objs){
            if (completed) {
                
                if ([objs isKindOfClass:[NSDictionary class]]) {
                    
                    @try {
                        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                        localNotification.fireDate = [NSDate dateWithTimeIntervalSince1970:beep_time];
                        NSString *alertBody = [NSString stringWithFormat:@"%@\n(%@)",[beeepTitle uppercaseString],[beeepTime stringByReplacingOccurrencesOfString:@"before" withString:@"left"]];
                        localNotification.alertBody = alertBody;
                        localNotification.timeZone = [NSTimeZone defaultTimeZone];
                        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
                        localNotification.userInfo = [NSDictionary dictionaryWithDictionary:objs];
                        
                        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                    }
                    @catch (NSException *exception) {
    
                    }
                    @finally {
    
                    }
                    
                    
                    @try {
                        NSMutableArray *users_ids = [NSMutableArray array];
                        
                        for (NSDictionary *user in followers) {
                            [users_ids addObject:[user objectForKey:@"id"]];
                        }
                        
                        if(users_ids.count > 0){
                            
                            [[BPSuggestions sharedBP]suggestEvent:fingerprint toUsers:users_ids withCompletionBlock:^(BOOL completed,NSArray *objs){
                                if (completed) {
                                    NSLog(@"Suggestion send");
                                }
                                else{
                                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Beeep was created but suggestions failed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                                }
                            }];
                        }
                    }
                    @catch (NSException *exception) {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Exception Error" message:@"Beeep was created but suggestions failed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                    @finally {
                        
                    }

                }
                
                [self close:nil];
            }
            else{
                
                if ([objs isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *error  = (NSDictionary *)objs;
                    NSString *message = [error objectForKey:@"message"];
                    NSString *info = [error objectForKey:@"info"];
                  
                    
                    @try {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:(message.length>0)?message:@"Error" message:(info.length > 0)?info:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                    }
                    @catch (NSException *exception) {
                       
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Beeep was not created.Please try again. We are sorry for the inconvenience" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                    }
                    @finally {
                        
                    }
                   

                }
                else{
                
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Beeep was not created.Please try again. We are sorry for the inconvenience" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                }
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
    
    NSString  *fingerPrintLocal;
    
    Timeline_Object *t = tml; //one of those two will be used
    Friendsfeed_Object *ffo = tml;
    Suggestion_Object *sgo = tml;
    
    if ([tml isKindOfClass:[Timeline_Object class]]) {
        fingerPrintLocal = t.beeep.beeepInfo.fingerprint;
    }
    else if ([tml isKindOfClass:[Event_Show_Object class]]){
        Event_Show_Object *activity = tml;
        
        fingerPrintLocal = activity.eventInfo.fingerprint;
        
    }
    else if([tml isKindOfClass:[Suggestion_Object class]]){
        fingerPrintLocal = sgo.what.fingerprint;
    }
    else if ([tml isKindOfClass:[Event_Search class]]){
        Event_Search *eventS = tml;
        fingerPrintLocal = eventS.fingerprint;
    }
    
    else{
        fingerPrintLocal = ffo.eventFfo.eventDetailsFfo.fingerprint;
    }
    
    
    if (fingerPrintLocal != nil) {
        
        NSMutableArray *selectedPeople;
        
        if (followers != nil && followers.count != 0) {
            selectedPeople = [NSMutableArray arrayWithArray:followers];
        }
        
        [[TabbarVC sharedTabbar]suggestPressed:fingerPrintLocal controller:self sendNotificationWhenFinished:YES selectedPeople:selectedPeople showBlur:NO];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was a problem with this Beeep. Please refresh and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }


}

- (NSData *)base64DataFromString: (NSString *)string
{
    unsigned long ixtext, lentext;
    unsigned char ch, inbuf[4], outbuf[3];
    short i, ixinbuf;
    Boolean flignore, flendtext = false;
    const unsigned char *tempcstring;
    NSMutableData *theData;
    
    if (string == nil)
    {
        return [NSData data];
    }
    
    ixtext = 0;
    
    tempcstring = (const unsigned char *)[string UTF8String];
    
    lentext = [string length];
    
    theData = [NSMutableData dataWithCapacity: lentext];
    
    ixinbuf = 0;
    
    while (true)
    {
        if (ixtext >= lentext)
        {
            break;
        }
        
        ch = tempcstring [ixtext++];
        
        flignore = false;
        
        if ((ch >= 'A') && (ch <= 'Z'))
        {
            ch = ch - 'A';
        }
        else if ((ch >= 'a') && (ch <= 'z'))
        {
            ch = ch - 'a' + 26;
        }
        else if ((ch >= '0') && (ch <= '9'))
        {
            ch = ch - '0' + 52;
        }
        else if (ch == '+')
        {
            ch = 62;
        }
        else if (ch == '=')
        {
            flendtext = true;
        }
        else if (ch == '/')
        {
            ch = 63;
        }
        else
        {
            flignore = true;
        }
        
        if (!flignore)
        {
            short ctcharsinbuf = 3;
            Boolean flbreak = false;
            
            if (flendtext)
            {
                if (ixinbuf == 0)
                {
                    break;
                }
                
                if ((ixinbuf == 1) || (ixinbuf == 2))
                {
                    ctcharsinbuf = 1;
                }
                else
                {
                    ctcharsinbuf = 2;
                }
                
                ixinbuf = 3;
                
                flbreak = true;
            }
            
            inbuf [ixinbuf++] = ch;
            
            if (ixinbuf == 4)
            {
                ixinbuf = 0;
                
                outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
                
                for (i = 0; i < ctcharsinbuf; i++)
                {
                    [theData appendBytes: &outbuf[i] length: 1];
                }
            }
            
            if (flbreak)
            {
                break;
            }
        }
    }
    
    return theData;
}

@end
