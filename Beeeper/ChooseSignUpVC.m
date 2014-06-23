//
//  ChooseSignUpVC.m
//  Beeeper
//
//  Created by User on 3/7/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "ChooseSignUpVC.h"
#import "LocationManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import <Social/Social.h>
#import "MissingFields.h"

@interface ChooseSignUpVC ()<LocationManagerDelegate>
{
    LocationManager *locManager;
    
    BOOL weHaveAllInfoNeeded;
    BOOL hasCity;
    BOOL hasState;
    BOOL hasCountry;
    BOOL hasUsername;
    BOOL hasEmail;
    BOOL hasFirstName;
    BOOL hasLastName;
    BOOL hasSex;
    
    NSMutableDictionary *missingInfo;
}
@end

@implementation ChooseSignUpVC

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
    
    weHaveAllInfoNeeded = YES;
    
    locManager = [[LocationManager alloc]init];
    
    [locManager startTracking];
    
	[self adjustFonts];
}

-(void)adjustFonts{
    
    UILabel *lbl1 = (id)[self.view viewWithTag:1];
    lbl1.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:26];
	
    UILabel *lbl2 = (id)[self.view viewWithTag:2];
    lbl2.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];

    NSString *btnTitle = [self.emailSignupButton titleForState:UIControlStateNormal];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:btnTitle];
    NSRange range=[btnTitle rangeOfString:@"email"];
    
    [string addAttribute:NSFontAttributeName
                  value:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]
                  range:[btnTitle rangeOfString:btnTitle]];
    
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:250/255.0 green:217/255.0 blue:0 alpha:1] range:range];
    [self.emailSignupButton setAttributedTitle:string forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)back:(UIStoryboardSegue *)segue{
    
}

- (IBAction)fbLoginPressed:(id)sender {

    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) // check Facebook is configured in Settings or not
    {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init]; // you have to retain ACAccountStore
        
        ACAccountType *fbAcc = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"253616411483666", ACFacebookAppIdKey,
                                 [NSArray arrayWithObject:@"email"], ACFacebookPermissionsKey,
                                 nil];
        
        [accountStore requestAccessToAccountsWithType:fbAcc options:options completion:^(BOOL granted, NSError *error)
         {
             if (granted)
             {
                 ACAccount *fbAccount = [[accountStore accountsWithAccountType:fbAcc] lastObject];
                 
                 
                 NSURL* URL = [NSURL URLWithString:@"https://graph.facebook.com/me"];
                 
                 SLRequest* request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                                         requestMethod:SLRequestMethodGET
                                                                   URL:URL
                                                            parameters:nil];
                 
                 [request setAccount:fbAccount]; // Authentication - Requires user context
                 
                 [request performRequestWithHandler:^(NSData* responseData, NSHTTPURLResponse* urlResponse, NSError* error) {
                    
                     NSDictionary *fbDict = [NSJSONSerialization
                                                  JSONObjectWithData:responseData
                                                  options:kNilOptions 
                                                  error:&error];
                     
                     NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                     
                     hasUsername = ([fbDict objectForKey:@"username"] != nil);
                     hasEmail = ([fbDict objectForKey:@"email"] != nil);
                     hasFirstName = ([fbDict objectForKey:@"first_name"] != nil);
                     hasLastName = ([fbDict objectForKey:@"last_name"] != nil);
                     hasSex = ([fbDict objectForKey:@"gender"] != nil);
                     
                     
                     if (hasUsername) {
                        [dict setObject:[fbDict objectForKey:@"username"] forKey:@"username"];
                         
                         NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [fbDict objectForKey:@"username"]];
                         [dict setObject:userImageURL forKey:@"image_path"];
                     }
                     
                     if (hasEmail) {
                         [dict setObject:[fbDict objectForKey:@"email"] forKey:@"email"];
                     }
                     
                     if (hasFirstName) {
                         [dict setObject:[fbDict objectForKey:@"first_name"] forKey:@"name"];
                     }
                     
                     if (hasLastName) {
                          [dict setObject:[fbDict objectForKey:@"last_name"] forKey:@"lastname"];
                     }
                     
                     if (hasSex) {
                         [dict setObject:[fbDict objectForKey:@"gender"] forKey:@"sex"];
                     }
                    
                     [dict setObject:[fbDict objectForKey:@"id"] forKey:@"fbid"];

                     float timezoneoffset = ([[NSTimeZone systemTimeZone] secondsFromGMT])/60;
                     
                     [dict setObject:[NSString stringWithFormat:@"%.1f",timezoneoffset] forKey:@"timezone"];
                     [dict setObject:@"" forKey:@"password"];
                     [dict setObject:@"0" forKey:@"locked"];
                     
                     
                     CLPlacemark *userPlace = [DTO sharedDTO].userPlace;
                     
                     if (userPlace != nil) {
                         
                         NSString *city = userPlace.locality;
                         NSString *state = userPlace.administrativeArea;
                         NSString *country = userPlace.country;
                         
                         hasCity = (city != nil);
                         hasState = (state != nil);
                         hasCountry = (country != nil);
                         
                         if (hasCity) {
                             [dict setObject:city forKey:@"city"];
                         }
                         if (hasState) {
                             [dict setObject:state forKey:@"state"];
                         }
                         if (hasCountry) {
                             [dict setObject:country forKey:@"country"];
                         }
                         
                     }
                     
                     weHaveAllInfoNeeded = (hasUsername && hasEmail && hasFirstName && hasCity && hasState && hasCountry);
                     
                     if (!weHaveAllInfoNeeded) {
                         
                         missingInfo = [NSMutableDictionary dictionary];
                         
                         if (!hasUsername) {
                             [missingInfo setObject:@"Username" forKey:@"username"];
                         }
                         if (hasEmail) {
                             [missingInfo setObject:@"Email" forKey:@"email"];
                         }
                         if (hasFirstName) {
                             [missingInfo setObject:@"First Name" forKey:@"first_name"];
                         }
                         if (hasLastName) {
                             [missingInfo setObject:@"Last Name" forKey:@"last_name"];
                         }
                         
                         if (!hasCity) {
                             [missingInfo setObject:@"City" forKey:@"city"];
                         }
                         if (!hasState) {
                             [missingInfo setObject:@"State" forKey:@"state"];
                         }
                         if (!hasCountry) {
                             [missingInfo setObject:@"Country" forKey:@"country"];
                         }
                         
                     }
                     
                     
                     CLLocation *userloc = [DTO sharedDTO].userLocation;
                     
                     if (userloc != nil) {
                         NSString *lat = [[NSString alloc] initWithFormat:@"%g", userloc.coordinate.latitude];
                         
                         NSString *lon = [[NSString alloc] initWithFormat:@"%g", userloc.coordinate.longitude];

                         [dict setObject:lat forKey:@"long"];
                         [dict setObject:lon forKey:@"lat"];
                     }
                     else{
                         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Where are you?" message:@"Please make sure that Beeeper is enabled in Location Settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                         return ;
                     }
                     
                     if (missingInfo.allKeys.count != 0) {
                         MissingFields *mf = [[MissingFields alloc]init];
                         mf.fields = missingInfo;
                         [self presentViewController:mf animated:YES completion:NULL];
                         return;
                     }
                     
                     [[BPUser sharedBP]signUpFacebookUser:dict completionBlock:^(BOOL completed,NSString *following){
                         
                         if (completed) {
                             
                         }
                     }];

                 }];
                 
             }
             else
             {
                 if (error == nil) {
                     NSLog(@"User Has disabled your app from settings...");
                 }
                 else
                 {
                     NSLog(@"Error in Login: %@", error);
                 }
             }
         }];
    }
    else
    {
        NSLog(@"Not Configured in Settings......"); // show user an alert view that Fcebook is not configured in settings.
        
        if (FBSession.activeSession.state == FBSessionStateOpen
            || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
            
            //[self loginFBuser];
            
            // Close the session and remove the access token from the cache
            // The session state handler (in the app delegate) will be called automatically
            // [FBSession.activeSession closeAndClearTokenInformation];
            
            //AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
            // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
            //[appDelegate sessionStateChanged:FBSession.activeSession state:FBSession.activeSession.state error:NULL];
            
            // If the session state is not any of the two "open" states when the button is clicked
        } else {
            // Open a session showing the user the login UI
            // You must ALWAYS ask for basic_info permissions when opening a session
            [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"user_friends"]
                                               allowLoginUI:YES
                                          completionHandler:
             ^(FBSession *session, FBSessionState state, NSError *error) {
                 
                 // Retrieve the app delegate
                 AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
                 // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
                 [appDelegate sessionStateChanged:session state:state error:error];
                 
                 if (FBSessionStateOpen == state) {
                 //    [self loginFBuser];
                 }
             }];
        }
        
    }

}

- (IBAction)twitterLoginPressed:(id)sender {
    
}


@end
