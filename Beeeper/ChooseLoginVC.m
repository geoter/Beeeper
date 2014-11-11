//
//  ChooseLoginVC.m
//  Beeeper
//
//  Created by User on 3/7/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "ChooseLoginVC.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import <Social/Social.h>
#import "MONActivityIndicatorView.h"
#import "WebBrowserVC.h"

@interface ChooseLoginVC ()<UITextFieldDelegate,MONActivityIndicatorViewDelegate,UIActionSheetDelegate>
{
    UITapGestureRecognizer *tapG;
    NSArray *accounts;
    NSArray *usernames;
}
@end

@implementation ChooseLoginVC

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
    
	[self adjustFonts];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if (!IS_IPHONE_5) {
        self.scrollV.frame = CGRectMake(0, 0, 320, self.scrollV.frame.size.height);
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

}

-(void)hideKeyboard:(UITapGestureRecognizer *)g{
    for (UIView *v in self.scrollV.subviews) {
        if ([v isKindOfClass:[UITextField class]]) {
            UITextField *txtF = (id)v;
            [txtF resignFirstResponder];
        }
    }
   [self.scrollV setContentOffset:CGPointZero animated:YES];
}


-(void)adjustFonts{
    
    UILabel *lbl1 = (id)[self.scrollV viewWithTag:1];
    lbl1.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
	
    UILabel *lbl2 = (id)[self.scrollV viewWithTag:2];
    lbl2.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];

    UILabel *lbl3 = (id)[self.scrollV viewWithTag:3];
    lbl3.font = [UIFont fontWithName:@"HelveticaNeue" size:15];

    UILabel *lbl4 = (id)[self.scrollV viewWithTag:4];
    lbl4.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextfield

-(void)textFieldDidBeginEditing:(UITextField *)textField{

    tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard:)];
    [self.scrollV addGestureRecognizer:tapG];
    [self.scrollV setContentOffset:CGPointMake(0, IS_IPHONE_5?50:90) animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    

    
    
    if (textField.tag == 5) {
        UITextField *txtF = (id)[self.scrollV viewWithTag:6];
        [txtF becomeFirstResponder];
    }
    else{
        [self.scrollV removeGestureRecognizer:tapG];
        [textField resignFirstResponder];
        [self.scrollV setContentOffset:CGPointZero animated:YES];
        
        [self showLoading];
        
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        
        NetworkStatus status = [reachability currentReachabilityStatus];
        
        if(status == NotReachable)
        {
            [self hideLoadingWithTitle:@"No Internet connection" ErrorMessage:@"Please enable Wifi or Cellular data."];
            return YES;
        }
        
        UITextField *username = (id)[self.scrollV viewWithTag:5];
        UITextField *password = (id)[self.view viewWithTag:6];
        
        
        [[BPUser sharedBP]loginUser:username.text password:password.text completionBlock:^(BOOL completed,NSString *user){
            if (completed) {
                NSLog(@"%@",user);
                [self setSelectedLoginMethod:[NSDictionary dictionaryWithObjects:@[username.text,password.text] forKeys:@[@"username",@"password"]]];
                [self performSelector:@selector(loginPressed:) withObject:nil afterDelay:0.5];
                
                [self hideLoading];
                password.text = @"";
            }
            else{
                [self hideLoadingWithTitle:@"Failed to login" ErrorMessage:@"Make sure your username and password are correct."];
            }
        }];

    }
    
    return YES;
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

-(IBAction)back:(UIStoryboardSegue *)segue{
    
}

-(IBAction)logout:(UIStoryboardSegue *)segue{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"log_method"]];
    NSError *error;
    
    [[NSFileManager defaultManager]removeItemAtPath:filePath error:&error];

    NSString *crFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"cr"]];
    [[NSFileManager defaultManager]removeItemAtPath:crFilePath error:NULL];
}

- (IBAction)forgotPassPressed:(id)sender {
    
    WebBrowserVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"WebBrowser"];
    viewController.url = [NSURL URLWithString:@"https://www.beeeper.com/forgot_password"];
    viewController.title = @"Forgot Password";
    [self.navigationController pushViewController:viewController animated:YES];

    
  //  UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ForgotPassVC"];
  //  [self.navigationController pushViewController:vc animated:YES];
}

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
        ACAccountStore *accountStore = [[ACAccountStore alloc] init]; // you have to retain ACAccountStore
        
        ACAccountType *fbAcc = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"253616411483666", ACFacebookAppIdKey,
                                 [NSArray arrayWithObjects:@"email",@"user_events",@"user_friends",nil], ACFacebookPermissionsKey,
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
    
       /*
        if (FBSession.activeSession.state == FBSessionStateOpen
            || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
            
            [self loginFBuser];
            
            // Close the session and remove the access token from the cache
            // The session state handler (in the app delegate) will be called automatically
            // [FBSession.activeSession closeAndClearTokenInformation];
            
            //AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
            // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
            //[appDelegate sessionStateChanged:FBSession.activeSession state:FBSession.activeSession.state error:NULL];
            
            // If the session state is not any of the two "open" states when the button is clicked
        }
        
        
        else {
            // Open a session showing the user the login UI
            // You must ALWAYS ask for basic_info permissions when opening a session
            [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"user_friends",@"user_events"]
                                               allowLoginUI:YES
                                          completionHandler:
             ^(FBSession *session, FBSessionState state, NSError *error) {
                 
                 // Retrieve the app delegate
                 AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
                 // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
                 [appDelegate sessionStateChanged:session state:state error:error];
                 
                 if (FBSessionStateOpen == state) {
                     [self loginFBuser];
                 }
                 else{
                     [self hideLoading];
                 }
                 
             }];
        }
*/
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
        ACAccountStore *accountStore = [[ACAccountStore alloc] init]; // you have to retain ACAccountStore
        
        ACAccountType *twitterAcc = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:twitterAcc options:nil completion:^(BOOL granted, NSError *error)
         {
             if (granted)
             {
                 accounts = [NSArray arrayWithArray:[accountStore accountsWithAccountType:twitterAcc]];
                 usernames = [NSArray arrayWithArray:[accounts valueForKey:@"username"]];
                 
                 if (usernames.count > 1) {
                     
                     UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                     popup.tag = 77;
                     
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

-(void)attemptTwitterLogin:(ACAccount *)account{
    
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
                        if ([user isKindOfClass:[NSString class]]) {
                            [self hideLoadingWithTitle:@"Twitter login failed" ErrorMessage:user];
                        }
                        else{
                            [self hideLoadingWithTitle:@"Twitter login failed" ErrorMessage:@"Please try again or contact us."];
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

-(void)attemptFBLogin:(ACAccount *)account{
    
    [self showLoading];
    
    static int number_of_attempts = 0;
    
    id fbID = [account valueForKeyPath:@"properties.uid"];
    NSLog(@"Facebook ID: %@, FullName: %@", fbID, account.userFullName);
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:fbID forKey:@"id"];
    
    NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", fbID];
    [dict setObject:userImageURL forKey:@"image"];

    
    [[BPUser sharedBP]loginFacebookUser:dict completionBlock:^(BOOL completed,NSString *user){
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
                    
                    [self hideLoadingWithTitle:@"Facebook login failed." ErrorMessage:@"Please try again."];
                }
            }
        }
        
    }];
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==alertView.cancelButtonIndex) {
        [self hideLoading];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    if (actionSheet.tag == 77) { // twitter
        
        ACAccount *twitterAccount = [accounts objectAtIndex:buttonIndex];
        NSLog(@"Twitter UserName: %@, FullName: %@", twitterAccount.username, twitterAccount.userFullName);
        NSString *user_id = [[twitterAccount valueForKey:@"properties"] valueForKey:@"user_id"];
        
        [self attemptTwitterLogin:twitterAccount];

    }
    else{
        
        ACAccount *fbAccount = [accounts objectAtIndex:buttonIndex];
      
        [self attemptFBLogin:fbAccount];
    }
    
}

-(void)setSelectedLoginMethod:(id)value{
   
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


#pragma mark -
#pragma mark - MONActivityIndicatorViewDelegate Methods

- (UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index {
    CGFloat red   = 166/255.0;
    CGFloat green = 166/255.0;
    CGFloat blue  = 166/255.0;
    CGFloat alpha = 1.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}



@end
