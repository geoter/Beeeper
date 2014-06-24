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

@interface ChooseLoginVC ()<UITextFieldDelegate,MONActivityIndicatorViewDelegate>
{
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
    
    if (!IS_IPHONE_5) {
        self.scrollV.frame = CGRectMake(0, 0, 320, self.scrollV.frame.size.height);
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

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
    [self.scrollV setContentOffset:CGPointMake(0, IS_IPHONE_5?50:90) animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.tag == 5) {
        UITextField *txtF = (id)[self.scrollV viewWithTag:6];
        [txtF becomeFirstResponder];
    }
    else{
        [textField resignFirstResponder];
        [self.scrollV setContentOffset:CGPointZero animated:YES];
        
        [self showLoading];
        
        UITextField *username = (id)[self.scrollV viewWithTag:5];
        UITextField *password = (id)[self.view viewWithTag:6];
        
        
        [[BPUser sharedBP]loginUser:username.text password:password.text completionBlock:^(BOOL completed,NSString *user){
            if (completed) {
                NSLog(@"%@",user);
                [self setSelectedLoginMethod:[NSDictionary dictionaryWithObjects:@[username.text,password.text] forKeys:@[@"username",@"password"]]];
                [self performSelector:@selector(loginPressed:) withObject:nil afterDelay:0.5];
            }
            else{
                [self hideLoading];
            }
        }];

    }
    
    return YES;
}

- (IBAction)loginPressed:(id)sender {
    
    [self hideLoading];
    
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
      UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ForgotPassVC"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)fbLoginPressed:(id)sender {
   
    [self showLoading];
    
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
                 ACAccount *fbAccount = [[accountStore accountsWithAccountType:fbAcc] lastObject];
                 id email = [fbAccount valueForKeyPath:@"properties.uid"];
                 NSLog(@"Facebook ID: %@, FullName: %@", email, fbAccount.userFullName);
                 
                 [[BPUser sharedBP]loginFacebookUser:email completionBlock:^(BOOL completed,NSString *user){
                     if (completed) {
                         [self setSelectedLoginMethod:@"FB"];
                         [self performSelector:@selector(loginPressed:) withObject:nil afterDelay:0.0];
                     }
                     else{
                         [self hideLoading];
                     }
                     
                 }];
             }
             else
             {
                 [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:NO];
                 
                 if (error == nil) {
                     NSLog(@"User Has disabled your app from settings...");
                     UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Beeeper Disabled" message:@"Please enable Beeeper in your Settings->Facebook" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                 }
                 else
                 {
                     NSLog(@"Error in Login: %@", error);
                     UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Something went wrong.Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];

                 }
             }
         }];
    }
    else
    {
        NSLog(@"Not Configured in Settings......"); // show user an alert view that Twitter is not configured in settings.
        
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

    }

    
}

- (IBAction)twitterLoginPressed:(id)sender {
    
    [self showLoading];

    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) // check Twitter is configured in Settings or not
    {
        ACAccountStore *accountStore = [[ACAccountStore alloc] init]; // you have to retain ACAccountStore
        
        ACAccountType *twitterAcc = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:twitterAcc options:nil completion:^(BOOL granted, NSError *error)
         {
             if (granted)
             {
                 ACAccount *twitterAccount = [[accountStore accountsWithAccountType:twitterAcc] firstObject];
                 NSLog(@"Twitter UserName: %@, FullName: %@", twitterAccount.username, twitterAccount.userFullName);
                 NSString *user_id = [[twitterAccount valueForKey:@"properties"] valueForKey:@"user_id"];
                 
                 [[BPUser sharedBP]loginTwitterUser:user_id completionBlock:^(BOOL completed,NSString *user){
                     if (completed) {
                         [self setSelectedLoginMethod:@"TW"];
                         [self performSelector:@selector(loginPressed:) withObject:nil afterDelay:0.0];
                     }
                     else{
                         [self hideLoading];
                     }
                 }];
             }
             else
             {
                 [self hideLoading];
                 
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
        
        UIAlertView *alertViewTwitter = [[UIAlertView alloc]
                                          initWithTitle:@"No Twitter Accounts"
                                          message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings."
                                          delegate:self
                                          cancelButtonTitle:@"Close"
                                          otherButtonTitles:nil];
        
        [alertViewTwitter show];
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex==alertView.cancelButtonIndex) {
        [self hideLoading];
    }
}

-(void)loginFBuser{
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Success! Include your code to handle the results here
            NSLog(@"user info: %@", result);
            [[BPUser sharedBP]loginFacebookUser:[result objectForKey:@"id"] completionBlock:^(BOOL completed,NSString *user){
                if (completed) {
                    NSLog(@"%@",user);
                    
                    [self setSelectedLoginMethod:@"FB"];
                    [self performSelectorOnMainThread:@selector(loginPressed:) withObject:nil waitUntilDone:NO];
                }
                else{
                    [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:NO];
                }
            }];
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
            [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:NO];
        }
    }];
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
