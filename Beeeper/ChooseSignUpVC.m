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

@interface ChooseSignUpVC ()<LocationManagerDelegate,UIActionSheetDelegate>
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
    BOOL hasName;
    BOOL hasSex;
    
    NSString *signupMethod;
    
    NSMutableDictionary *missingInfo;
    NSArray *accounts;
    NSArray *usernames;
    
    int fbSelectedAccountIndex;
    int twSelectedAccountIndex;
}
@property (nonatomic,strong) ACAccountStore *accountStore;
@end

@implementation ChooseSignUpVC
@synthesize accountStore;

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
    
    locManager = [LocationManager sharedLM];
    
	[self adjustFonts];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [locManager startTracking];
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
    
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:240/255.0 green:208/255.0 blue:0 alpha:1] range:range];
    [self.emailSignupButton setAttributedTitle:string forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)back:(UIStoryboardSegue *)segue{
    
}

-(void)showLoading{
    
    if ([self.view viewWithTag:-434]) {
        return;
    }
    
    dispatch_async (dispatch_get_main_queue(), ^{
        
        UIView *loadingBGV = [[UIView alloc]initWithFrame:self.view.bounds];
        loadingBGV.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        
        MONActivityIndicatorView *indicatorView = [[MONActivityIndicatorView alloc] init];
        indicatorView.delegate = self;
        indicatorView.numberOfCircles = 3;
        indicatorView.radius = 8;
        indicatorView.internalSpacing = 1;
        indicatorView.center = self.view.center;
        indicatorView.tag = -565;
        
        loadingBGV.alpha = 0;
        [loadingBGV addSubview:indicatorView];
        loadingBGV.tag = -434;
        [self.view addSubview:loadingBGV];
        [self.view bringSubviewToFront:loadingBGV];
        
        [UIView animateWithDuration:0.3f
                         animations:^
         {
             loadingBGV.alpha = 1;
         }
                         completion:^(BOOL finished)
         {
             [indicatorView startAnimating];
         }
         ];
        
    });
    
}


-(void)hideLoading{
    
    
    dispatch_async (dispatch_get_main_queue(), ^{
        
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
    });
}

-(void)hideLoadingWithTitle:(NSString *)title ErrorMessage:(NSString *)message{
    
    dispatch_async (dispatch_get_main_queue(), ^{
        
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
             
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
         }
         ];
        
    });
}

#pragma mark - Signup

- (IBAction)fbSignupPressed:(id)sender {
    
    [locManager startTracking];
    
    signupMethod = @"FB";
    
    [self fbSignupwithAccount:fbSelectedAccountIndex];

}

- (IBAction)twitterSignupPressed:(id)sender {
    
    [locManager startTracking];
     signupMethod = @"TW";
    
    [self twSignupwithAccount:twSelectedAccountIndex];
}



-(void)twSignupwithAccount:(int)row{

    [self showLoading];
    
    ACAccount *twitterAccount = [accounts objectAtIndex:row];
    
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
            
            NSString *profileImageUrl = [[twitterData objectForKey:@"profile_image_url"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            hasUsername = (twitterAccount.username != nil);
            hasFirstName = ([name isKindOfClass:[NSString class]] && name.length > 0);
            hasLastName = ([surname isKindOfClass:[NSString class]] && surname.length > 0);
            hasName = NO;
            hasEmail = NO;
            
            if (hasUsername) {
                [dict setObject:twitterAccount.username forKey:@"username"];
                [dict setObject:profileImageUrl forKey:@"image_path"];
            }
            
            NSMutableString *nameStr = [[NSMutableString alloc]init];
            
            if (hasFirstName) {
                hasName = YES;
                [nameStr appendString:name];
            }
            
            if (hasLastName) {
                hasName = YES;
                
                if (hasFirstName) {
                    [nameStr appendFormat:@" %@",surname];
                }
                else{
                    [nameStr appendString:surname];
                }

            }
            
            if (hasName) {
                [dict setObject:[NSString stringWithString:nameStr] forKey:@"name"];
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
                
                weHaveAllInfoNeeded = (hasUsername && hasEmail && hasName && hasCity && hasState && hasCountry);
                
                if (!weHaveAllInfoNeeded) {
                    
                    if (missingInfo == nil) {
                        
                        missingInfo = [NSMutableDictionary dictionary];
                        
                        if (!hasUsername) {
                            [missingInfo setObject:@"Username" forKey:@"username"];
                        }
                        if (!hasEmail) {
                            [missingInfo setObject:@"Email" forKey:@"email"];
                        }
                        if (!hasName) {
                            [missingInfo setObject:@"First and Last name" forKey:@"name"];
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
                        [self hideLoading];
                        [self.navigationController pushViewController:mf animated:YES];
                    });
                    
                    return;
                }
                else{
                    [self signUpSocialUser:dict];
                }
                
            }
            else{
                
                [self hideLoadingWithTitle:@"Where are you?" ErrorMessage:@"Please go to Settings > Privacy > Location Services and set Beeeper to on."];
            }
            
        }
        else{
            NSLog(@"Error while downloading Twitter user data: %@", error);
        }
    }];
    
}

-(void)fbSignupwithAccount:(int)row{
    
    [self showLoading];
    
    ACAccount *fbAccount = [accounts objectAtIndex:row];
    
    
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
        
        NSString *email = [[fbAccount valueForKey:@"properties"] objectForKey:@"ACUIDisplayUsername"];
        if (email == nil) {
            email = [fbDict objectForKey:@"email"];
        }
        
        hasEmail = ([email isKindOfClass:[NSString class]] && email.length > 0);
        
        hasFirstName = ([[fbDict objectForKey:@"first_name"]isKindOfClass:[NSString class]] && [fbDict objectForKey:@"first_name"] != nil);
        hasLastName = ([[fbDict objectForKey:@"last_name"] isKindOfClass:[NSString class]] && [fbDict objectForKey:@"last_name"] != nil);
        hasName = NO;
        
        hasSex = ([fbDict objectForKey:@"gender"] != nil);
        
        
        if (hasUsername) {
            [dict setObject:[fbDict objectForKey:@"username"] forKey:@"username"];
            
            NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [fbDict objectForKey:@"username"]];
            [dict setObject:userImageURL forKey:@"image_path"];
        }
        
        if (hasEmail) {
            [dict setObject:email forKey:@"email"];
        }
        
        NSMutableString *nameStr = [[NSMutableString alloc]init];
        
        if (hasFirstName) {
            hasName = YES;
            [nameStr appendString:[fbDict objectForKey:@"first_name"]];
        }

        if (hasLastName) {
            hasName = YES;
            
            if (hasFirstName) {
                [nameStr appendFormat:@" %@",[fbDict objectForKey:@"last_name"]];
            }
            else{
                [nameStr appendString:[fbDict objectForKey:@"last_name"]];
            }

        }
        
        if (hasName) {
            [dict setObject:[NSString stringWithString:nameStr] forKey:@"name"];
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
            
            weHaveAllInfoNeeded = (hasUsername && hasEmail && hasName && hasCity && hasState && hasCountry);
            
            if (!weHaveAllInfoNeeded) {
                
                if (missingInfo == nil) {
                    
                    missingInfo = [NSMutableDictionary dictionary];
                    
                    if (!hasUsername) {
                        [missingInfo setObject:@"Username" forKey:@"username"];
                    }
                    if (!hasEmail) {
                        [missingInfo setObject:@"Email" forKey:@"email"];
                    }
                    
                    if (!hasName) {
                        [missingInfo setObject:@"First and Last name" forKey:@"name"];
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
                    [self hideLoading];
                    [self.navigationController pushViewController:mf animated:YES];
                });
                
                return;
            }
            else{
                [self signUpSocialUser:dict];
            }
            
        }
        else{
            
            [self hideLoadingWithTitle:@"Where are you?" ErrorMessage:@"Please go to Settings > Privacy > Location Services and set Beeeper to on."];
        }
        
        
    }];
}

-(void)signUpSocialUser:(NSDictionary *)dict{
    
    [self showLoading];
    
    [[BPUser sharedBP]signUpSocialUser:dict completionBlock:^(BOOL completed,NSString *response){
        
        [self hideLoading];
        
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
    
    [self hideLoading];
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[TabbarVC class]]) {
            return;
        }
    }
    
    UIViewController *menuVC = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"TabbarVC"];
    
    [self.navigationController pushViewController:menuVC animated:YES];
    
}

#pragma mark - Autologin

- (IBAction)fbLoginPressed:(id)sender {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
    {
        [self hideLoadingWithTitle:@"No Internet connection" ErrorMessage:@"Please enable Wifi or Cellular data."];
        return;
    }
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) // check Facebook is configured in Settings or not
    {
        accountStore = [[ACAccountStore alloc] init]; // you have to retain ACAccountStore
        
        ACAccountType *fbAcc = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"222125061288499", ACFacebookAppIdKey,
                                 [NSArray arrayWithObjects:@"email",@"user_friends",nil], ACFacebookPermissionsKey,
                                 nil];
        
        [accountStore requestAccessToAccountsWithType:fbAcc options:options completion:^(BOOL granted, NSError *error)
         {
             if (granted)
             {
                 accounts = [NSArray arrayWithArray:[accountStore accountsWithAccountType:fbAcc]];
                 usernames = [NSArray arrayWithArray:[accounts valueForKey:@"username"]];
                 
                 if (usernames.count > 1) {
                     
                     [self hideLoading];
                     
                     UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
                     popup.tag = 79;

                     for (NSString *name in usernames) {
                         [popup addButtonWithTitle:name];
                     }
                     
                     [popup addButtonWithTitle:@"Cancel"];
                     
                     popup.cancelButtonIndex = popup.numberOfButtons -1;
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [popup showInView:self.view];
                     });
                     
                     
                 }
                 else if(usernames.count == 1){
                     
                     fbSelectedAccountIndex = 0;
                     
                     ACAccount *fbAccount = [[accountStore accountsWithAccountType:fbAcc] firstObject];
                     
                     [self attemptFBLogin:fbAccount];
                     
                 }
                 else{
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         [self hideLoading];
                         
                         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No accounts found" message:@"Please go to Settings> Facebook and sign in with your Facebook account.." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                     });
                     
                 }
             }
             else
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:NO];
                     
                     if (error == nil) {
                         NSLog(@"User Has disabled your app from settings...");
                         [self hideLoadingWithTitle:@"Beeeper Disabled" ErrorMessage:@"Please go to Settings > Facebook and set Beeeper to on."];
                     }
                     else
                     {
                         NSLog(@"Error in Login: %@", error);
                         
                         [self hideLoadingWithTitle:@"Error" ErrorMessage:@"Something went wrong.Please try again."];
                         
                     }
                     
                 });
             }
         }];
    }
    else
    {
        
        [self hideLoadingWithTitle:@"No Facebook account found" ErrorMessage: @"Please go to Settings > Facebook and sign in with your Facebook account."];
        
        NSLog(@"Not Configured in Settings......"); // show user an alert view that Twitter is not configured in settings.
        
        
    }
    
    
}

- (IBAction)twitterLoginPressed:(id)sender {
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
    {
        [self hideLoadingWithTitle:@"No Internet connection" ErrorMessage:@"Please enable Wifi or Cellular data."];
        return;
    }
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) // check Twitter is configured in Settings or not
    {
        accountStore = [[ACAccountStore alloc] init]; // you have to retain ACAccountStore
        
        ACAccountType *twitterAcc = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:twitterAcc options:nil completion:^(BOOL granted, NSError *error)
         {
             if (granted)
             {
                 accounts = [NSArray arrayWithArray:[accountStore accountsWithAccountType:twitterAcc]];
                 usernames = [NSArray arrayWithArray:[accounts valueForKey:@"username"]];
                 
                 if (usernames.count > 1) {
                     
                     UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                     popup.tag = 80;
                     
                     for (NSString *name in usernames) {
                         [popup addButtonWithTitle:[NSString stringWithFormat:@"@%@",name]];
                     }
                     
                     [popup addButtonWithTitle:@"Cancel"];
                     
                     popup.cancelButtonIndex = popup.numberOfButtons -1;
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [popup showInView:self.view];
                     });
                     
                 }
                 else if(usernames.count == 1){
                     
                     ACAccount *twitterAccount = [[accountStore accountsWithAccountType:twitterAcc] firstObject];
                     NSLog(@"Twitter UserName: %@, FullName: %@", twitterAccount.username, twitterAccount.userFullName);
                     twSelectedAccountIndex = 0;
                     [self attemptTwitterLogin:twitterAccount];
                 }
                 else{
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         [self hideLoading];
                         
                         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No accounts found" message:@"Please go to Settings > Twitter and sign in with your Twitter account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                     });
                     
                 }
             }
             else
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:NO];
                     
                     if (error == nil) {
                         NSLog(@"User Has disabled your app from settings...");
                         [self hideLoadingWithTitle:@"Beeeper Disabled" ErrorMessage:@"Please go to Settings > Twitter and set Beeeper to on."];
                     }
                     else
                     {
                         NSLog(@"Error in Login: %@", error);
                         
                         [self hideLoadingWithTitle:@"Error" ErrorMessage:@"Something went wrong.Please try again."];
                         
                     }
                     
                 });
                 
             }
         }];
    }
    else
    {
        
        [self hideLoadingWithTitle:@"No Twitter account found" ErrorMessage: @"Please go to Settings > Twitter and sign in with your Twitter account."];
        
    }
}

- (void)attemptTwitterLogin:(ACAccount *)account{
    
    [self showLoading];
    
    static int number_of_attempts = 0;
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"];
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    NSString *user_id = [[account valueForKey:@"properties"] valueForKey:@"user_id"];
    
    [params setObject:user_id forKey:@"user_id"];
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
    //  Attach an account to the request
    [request setAccount:account]; // this can be any Twitter account obtained from the Account store
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        if (responseData) {
            
            NSDictionary *twitterData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:NULL];
            NSLog(@"received Twitter data: %@", twitterData);
            
            // to do something useful with this data:
            
            NSString *profileImageUrl = [[twitterData objectForKey:@"profile_image_url"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            [dict setObject:profileImageUrl forKey:@"image"];
            [dict setObject:user_id forKey:@"id"];
            
            [[BPUser sharedBP]loginTwitterUser:dict completionBlock:^(BOOL completed,NSString *user){
                if (completed) {
                    [self setSelectedLoginMethod:[NSString stringWithFormat:@"TW-%@",user_id]];
                    [self performSelector:@selector(loginPressed:) withObject:nil afterDelay:0.0];
                }
                else{
                    if (user_id != nil && number_of_attempts < 3) {
                        [self attemptTwitterLogin:account];
                        number_of_attempts ++;
                    }
                    else{
                        number_of_attempts = 0;
                        
                        Reachability *reachability = [Reachability reachabilityForInternetConnection];
                        [reachability startNotifier];
                        
                        NetworkStatus status = [reachability currentReachabilityStatus];
                        
                        if(status == NotReachable)
                        {
                            [self hideLoadingWithTitle:@"Facebook login failed." ErrorMessage:@"Make sure you are connected to the Internet and try again."];
                        }
                        else{
                            
                            [self twitterSignupPressed:nil];
                        }
                    }
                }
            }];
            
            
        }
        else{
            [self hideLoadingWithTitle:@"Twitter login failed" ErrorMessage:@"Error getting Twitter account information"];
        }
    }];
    
}

- (void)attemptFBLogin:(ACAccount *)account{
    
    [self showLoading];
    
    static int number_of_attempts = 0;
    
    id fbID = [account valueForKeyPath:@"properties.uid"];
    NSLog(@"Facebook ID: %@, FullName: %@", fbID, account.userFullName);
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:fbID forKey:@"id"];
    
    NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", fbID];
    [dict setObject:userImageURL forKey:@"image"];
    
    
    [[BPUser sharedBP]loginFacebookUser:dict completionBlock:^(BOOL completed,NSString *responseString){
        if (completed) {
            [self setSelectedLoginMethod:[NSString stringWithFormat:@"FB-%@",fbID]];
            [self performSelector:@selector(loginPressed:) withObject:nil afterDelay:0.0];
        }
        else{
            if (fbID != nil && number_of_attempts < 3) {
                [self attemptFBLogin:account];
                number_of_attempts ++;
            }
            else{
                number_of_attempts = 0;
                
                Reachability *reachability = [Reachability reachabilityForInternetConnection];
                [reachability startNotifier];
                
                NetworkStatus status = [reachability currentReachabilityStatus];
                
                if(status == NotReachable)
                {
                    [self hideLoadingWithTitle:@"Facebook login failed." ErrorMessage:@"Make sure you are connected to the Internet and try again."];
                }
                else{
                    if ([responseString rangeOfString:@"fb user login failure"].location != NSNotFound) {
                        
                        [self fbSignupPressed:nil];
                    }
                    else{
                        [self hideLoadingWithTitle:@"Facebook login failed." ErrorMessage:@"Please try again."];
                    }
                }
            }
        }
        
    }];
}

- (void)setSelectedLoginMethod:(id)value{
    
    NSString *method = value;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    
    if ([value isKindOfClass:[NSString class]]) {
        
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"log_method"]];
        NSError *error;
        
        BOOL succeed = [method writeToFile:filePath
                                atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
    }
    else if([value isKindOfClass:[NSDictionary class]]){
        NSDictionary *cr = (id)value;
        NSString *username= [cr objectForKey:@"username"];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"cr"]];
        [value writeToFile:filePath atomically:YES];
        
        NSString *methodfilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"log_method"]];
        NSError *error;
        NSString *method = @"EMAIL";
        BOOL succeed = [method writeToFile:methodfilePath
                                atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.cancelButtonIndex == buttonIndex) {
        return;
    }
    
    if(actionSheet.tag == 79){
        fbSelectedAccountIndex = buttonIndex;
        [self attemptFBLogin:[accounts objectAtIndex:fbSelectedAccountIndex]];
    }
    else if (actionSheet.tag == 80) { // twitter
        twSelectedAccountIndex = buttonIndex;
        [self attemptTwitterLogin:[accounts objectAtIndex:twSelectedAccountIndex]];
    }
    
}

@end
