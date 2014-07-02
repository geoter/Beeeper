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
    
    NSString *signupMethod;
    
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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

    [locManager startTracking];
    
    signupMethod = @"FB";
    
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
                     CLLocation *userloc = [DTO sharedDTO].userLocation;
                     
                     if (userPlace != nil && userloc != nil) {
                         
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
                         
                         NSString *lat = [[NSString alloc] initWithFormat:@"%g", userloc.coordinate.latitude];
                         
                         NSString *lon = [[NSString alloc] initWithFormat:@"%g", userloc.coordinate.longitude];
                         
                         [dict setObject:lat forKey:@"long"];
                         [dict setObject:lon forKey:@"lat"];
                         
                     
                     
                         weHaveAllInfoNeeded = (hasUsername && hasEmail && hasFirstName &&hasLastName && hasCity && hasState && hasCountry);
                         
                         if (!weHaveAllInfoNeeded) {
                             
                             if (missingInfo == nil) {
                                 
                                 missingInfo = [NSMutableDictionary dictionary];
                                 
                                 if (!hasUsername) {
                                     [missingInfo setObject:@"Username" forKey:@"username"];
                                 }
                                 if (!hasEmail) {
                                     [missingInfo setObject:@"Email" forKey:@"email"];
                                 }
                                 if (!hasFirstName) {
                                     [missingInfo setObject:@"First Name" forKey:@"first_name"];
                                 }
                                 if (!hasLastName) {
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
                             
                         }
                         
                         
                         
                         if (missingInfo.allKeys.count != 0) {
                             
                             MissingFields *mf = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"MissingFields"];
                             mf.fields = [NSMutableDictionary dictionaryWithDictionary:dict];
                             mf.misssingfields = [NSMutableDictionary dictionaryWithDictionary:missingInfo];
                             mf.delegate = self;

                             missingInfo = nil;
                             
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self.navigationController pushViewController:mf animated:YES];
                             });
                             
                             return;
                         }
                         else{
                             [self signUpSocialUser:dict];
                         }

                     }
                     else{
                         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Where are you?" message:@"Please make sure that Beeeper is enabled in Location Settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                     }
                     
                     
                 }];
                 
             }
             else
             {
                 if (error == nil) {
                     NSLog(@"User Has disabled your app from settings...");
                     
                     UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Beeeper disabled" message:@"Please enable Beeeper in your Settings->Facebook." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
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
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Facebook account" message:@"There are no Facebook accounts configured.You can add or create a Facebook account in Settings." delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
        [alert show];
    }

}

- (IBAction)twitterLoginPressed:(id)sender {
    [locManager startTracking];
     signupMethod = @"TW";
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) // check Facebook is configured in Settings or not
    {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init]; // you have to retain ACAccountStore
        
        ACAccountType *twitterAcc = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:twitterAcc options:nil completion:^(BOOL granted, NSError *error)
         {
             if (granted)
             {
                 ACAccount *twitterAccount = [[accountStore accountsWithAccountType:twitterAcc] firstObject];
                 NSString *user_id = [[twitterAccount valueForKey:@"properties"] valueForKey:@"user_id"];
                 
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
                 NSMutableDictionary *params = [NSMutableDictionary new];
                 [params setObject:user_id forKey:@"user_id"];
                 
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
                 //  Attach an account to the request
                 [request setAccount:twitterAccount]; // this can be any Twitter account obtained from the Account store
                 
                 [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    
                     if (responseData) {
                         NSDictionary *twitterData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:NULL];
                         NSLog(@"received Twitter data: %@", twitterData);
                         
                         // to do something useful with this data:
                         NSString *name_fullName = [twitterData objectForKey:@"name"]; // the screen name you were after
                         NSArray *name_components = [name_fullName componentsSeparatedByString:@" "];
                         NSString *name = [name_components firstObject];
                         NSString *surname = [name_components lastObject];
                         
                         NSString *profileImageUrl = [twitterData objectForKey:@"profile_image_url"];
                         
                         NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                         
                         hasUsername = (twitterAccount.username != nil);
                         hasFirstName = (name.length > 0);
                         hasLastName = (surname.length > 0);
                         
                         if (hasUsername) {
                             [dict setObject:twitterAccount.username forKey:@"username"];
                             [dict setObject:profileImageUrl forKey:@"image_path"];
                         }
                         
                         if (hasFirstName) {
                             [dict setObject:name forKey:@"name"];
                         }
                         
                         if (hasLastName) {
                             [dict setObject:surname forKey:@"lastname"];
                         }
                         
                         
                         [dict setObject:[twitterData objectForKey:@"id_str"] forKey:@"twid"];
                         
                         float timezoneoffset = ([[NSTimeZone systemTimeZone] secondsFromGMT])/60;
                         
                         [dict setObject:[NSString stringWithFormat:@"%.1f",timezoneoffset] forKey:@"timezone"];
                         [dict setObject:@"" forKey:@"password"];
                         [dict setObject:@"0" forKey:@"locked"];
                         
                         
                         CLPlacemark *userPlace = [DTO sharedDTO].userPlace;
                         CLLocation *userloc = [DTO sharedDTO].userLocation;
                         
                         if (userPlace != nil && userloc != nil) {
                             
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
                             
                             NSString *lat = [[NSString alloc] initWithFormat:@"%g", userloc.coordinate.latitude];
                             
                             NSString *lon = [[NSString alloc] initWithFormat:@"%g", userloc.coordinate.longitude];
                             
                             [dict setObject:lat forKey:@"long"];
                             [dict setObject:lon forKey:@"lat"];
                             
                             
                             
                             weHaveAllInfoNeeded = (hasUsername && hasEmail && hasFirstName &&hasLastName && hasCity && hasState && hasCountry);
                             
                             if (!weHaveAllInfoNeeded) {
                                 
                                 if (missingInfo == nil) {
                                     
                                     missingInfo = [NSMutableDictionary dictionary];
                                     
                                     if (!hasUsername) {
                                         [missingInfo setObject:@"Username" forKey:@"username"];
                                     }
                                     if (!hasEmail) {
                                         [missingInfo setObject:@"Email" forKey:@"email"];
                                     }
                                     if (!hasFirstName) {
                                         [missingInfo setObject:@"First Name" forKey:@"first_name"];
                                     }
                                     if (!hasLastName) {
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
                                 
                             }
                             
                             
                             if (missingInfo.allKeys.count != 0) {
                                 
                                 MissingFields *mf = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"MissingFields"];
                                 mf.fields = [NSMutableDictionary dictionaryWithDictionary:dict];
                                 mf.misssingfields = [NSMutableDictionary dictionaryWithDictionary:missingInfo];
                                 mf.delegate = self;
                                 
                                 missingInfo = nil;
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [self.navigationController pushViewController:mf animated:YES];
                                 });
                                 
                                 return;
                             }
                             else{
                                 [self signUpSocialUser:dict];
                            }
                             
                         }
                         else{
                             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Where are you?" message:@"Please make sure that Beeeper is enabled in Location Settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                             [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                         }
                         
                     }
                     else{
                         NSLog(@"Error while downloading Twitter user data: %@", error);
                     }
                 }];
                              }
             else
             {
                 if (error == nil) {
                     NSLog(@"User Has disabled your app from settings...");
                     
                     UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Beeeper disabled" message:@"Please make sure Beeeper is allowed to use your Twitter accounts." delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
                     [alert show];
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
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Twitter account" message:@"There are no Twitter accounts configured.You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
        [alert show];
    }
    

}

-(void)signUpSocialUser:(NSDictionary *)dict{
    
    [[BPUser sharedBP]signUpSocialUser:dict completionBlock:^(BOOL completed,NSString *response){
        
        if (completed) {
            [self performSelector:@selector(loginPressed:) withObject:nil afterDelay:0.0];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Failed" message:response delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
    }];

}

- (IBAction)loginPressed:(id)sender {
  
  UIViewController *menuVC = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"TabbarVC"];
  
  [self.navigationController pushViewController:menuVC animated:YES];
  
}


@end
