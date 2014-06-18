//
//  LoginVC.m
//  Beeeper
//
//  Created by User on 2/18/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "LoginVC.h"
#import "AppDelegate.h"

@interface LoginVC ()

@end

@implementation LoginVC

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

    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)fbLoginPressed:(id)sender
{
    // If the session state is any of the two "open" states when the button is clicked
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
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for basic_info permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
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
         }];
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
                    [self performSegueWithIdentifier:@"home" sender:self];
                }
            }];
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
        }
    }];

}

- (IBAction)twitterLoginPressed:(id)sender {

    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:
                                  ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType options:nil
                                  completion:^(BOOL granted, NSError *error)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (granted == YES)
            {
                // Get account and communicate with Twitter API
                NSArray *arrayOfAccounts = [account
                                            accountsWithAccountType:accountType];
                
                if ([arrayOfAccounts count] > 0)
                {
                    ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                    
                    
                    [self performSegueWithIdentifier:@"home" sender:self];
                }
                
            }
        });
        
    }];

}


@end
