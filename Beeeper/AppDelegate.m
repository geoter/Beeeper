//
//  AppDelegate.m
//  Beeeper
//
//  Created by User on 2/18/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import <FacebookSDK/FacebookSDK.h>

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

   // [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x4B678B)];
    
   // [self clearDocumentsFolder];
    
   //  [[DTO sharedDTO]addBugLog:@"test what" where:@"BPCreate/test what" json:nil];
    
    [self application:application didReceiveRemoteNotification:nil];
    
    [self createEditableCopyOfPlistIfNeeded];
    
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"homefeed-y"];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

    [FBSettings setDefaultAppID: @"222125061288499"];

    [GMSServices provideAPIKey:@"AIzaSyDw_2s-d_HFlsMnFyz-30czOPBckYdrtE8"];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    if (launchOptions != nil)
    {
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (userInfo != nil)
        {
            @try {
                if (userInfo) {
                    
                    NSString *w = [userInfo objectForKey:@"w"];
                    
                    if (w != nil) {
                        [[DTO sharedDTO]setWeightForPush:w caseStr:@"w"];
                    }
                    
                    NSString *l = [userInfo objectForKey:@"l"];
                    
                    if (l != nil) {
                        [[DTO sharedDTO]setWeightForPush:l caseStr:@"l"];
                    }
                    
                    
                    NSString *c = [userInfo objectForKey:@"c"];
                    
                    if (c != nil) {
                        [[DTO sharedDTO]setWeightForPush:c caseStr:@"c"];
                    }
                    
                    
                    NSString *s = [userInfo objectForKey:@"s"];
                    
                    if (s != nil) {
                        [[DTO sharedDTO]setFingerprintForPush:s caseStr:@"s"];
                    }
                    
                    NSString *u = [userInfo objectForKey:@"u"];
                    
                    if (u != nil) {
                        [[DTO sharedDTO]setUserIDforPush:u];
                    }
                }
            }
            @catch (NSException *exception) {
                NSLog(@"Catch");
            }
            @finally {
                
            }

        }
    }
    else{
        [[DTO sharedDTO]setWeightForPush:nil caseStr:nil];
        [[DTO sharedDTO]setFingerprintForPush:nil caseStr:nil];
        [[DTO sharedDTO]setUserIDforPush:nil];
    }
    
    
//    UINavigationController *navVC = (id)self.window.rootViewController;
//    
//    loginVC = (LoginVC*)  navVC.topViewController;
//    
//    
//    
//    // Whenever a person opens the app, check for a cached session
//    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
//        NSLog(@"Found a cached session");
//        // If there's one, just open the session silently, without showing the user the login UI
//        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"]
//                                           allowLoginUI:NO
//                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
//                                          // Handler for session state changes
//                                          // This method will be called EACH time the session state changes,
//                                          // also for intermediate states and NOT just when the session open
//                                          [self sessionStateChanged:session state:state error:error];
//                                      }];
//        
//        // If there's no cached session, we will show a login button
//    } else { //check for Twitter
//        
//        ACAccountStore *account = [[ACAccountStore alloc] init];
//        ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:
//                                      ACAccountTypeIdentifierTwitter];
//        
//        if (accountType.accessGranted) {
//            // Get account and communicate with Twitter API
//            NSArray *arrayOfAccounts = [account
//                                        accountsWithAccountType:accountType];
//            
//            if ([arrayOfAccounts count] > 0)
//            {
//                ACAccount *twitterAccount = [arrayOfAccounts lastObject];
//                [loginVC performSegueWithIdentifier:@"home" sender:loginVC];
//            }
//
//        }
//        
//    }


    
    return YES;
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}
#endif
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"foreground");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

// Show the user the logged-out UI
- (void)userLoggedOut
{
    // Set the button title as "Log in with Facebook"
//    UIButton *loginButton = [self.customLoginViewController loginButton];
//    [loginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
//    
//    // Confirm logout message
//    [self showMessage:@"You're now logged out" withTitle:@""];
}

// Show the user the logged-in UI
- (void)userLoggedIn
{
    [loginVC fbLoginPressed:nil];
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}

// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
// Override application:openURL:sourceApplication:annotation to call the FBsession object that handles the incoming URL
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
   
    @try {
        
        if ([url.absoluteString rangeOfString:@"beeeper://"].location != NSNotFound) {
            [[DTO sharedDTO]setDeeepLinkEventFingerprint:[[url.absoluteString componentsSeparatedByString:@"event/"] lastObject]];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"DEEPLINK" object:nil];
            return YES;
        }
        else{
        
            if ([url.absoluteString rangeOfString:@"fb222125061288499"].location != NSNotFound) {
                
                BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                            sourceApplication:sourceApplication
                                              fallbackHandler:^(FBAppCall *call) {
                                                  // incoming link processing goes here
                                                  NSLog(@"%@",call);
                                              }];
                return urlWasHandled;

            }
       
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    
    [FBAppCall handleDidBecomeActive];
    
    [FBAppEvents activateApp];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[BPUser sharedBP]setDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    if ( application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground  )
    {
        @try {
            if (userInfo) {
                
                NSString *w = [userInfo objectForKey:@"w"];
                
                if (w != nil) {
                    [[DTO sharedDTO]setWeightForPush:w caseStr:@"w"];
                }
                
                NSString *l = [userInfo objectForKey:@"l"];
                
                if (l != nil) {
                    [[DTO sharedDTO]setWeightForPush:l caseStr:@"l"];
                }
                
                
                NSString *c = [userInfo objectForKey:@"c"];
                
                if (c != nil) {
                    [[DTO sharedDTO]setWeightForPush:c caseStr:@"c"];
                }
                
                
                NSString *s = [userInfo objectForKey:@"s"];
                
                if (s != nil) {
                    [[DTO sharedDTO]setFingerprintForPush:s caseStr:@"s"];
                }
                
                NSString *u = [userInfo objectForKey:@"u"];
                
                if (u != nil) {
                    [[DTO sharedDTO]setUserIDforPush:u];
                }
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"PUSH" object:nil userInfo:userInfo];
                
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[UIApplication sharedApplication].applicationIconBadgeNumber-1];
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Catch");
        }
        @finally {
            
        }
    }
    
    
}

-(void)getCorrectTypeOrDie:(NSString *)type dict:(NSDictionary *)userInfo{
   
    NSArray *types = [NSArray arrayWithObjects:@"w",@"u",@"l",@"c", nil];
    
    @try {
        [userInfo objectForKey:type];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
  
    
    @try {
        
        NSDictionary *apsInfo = notification.userInfo;
        
        [[DTO sharedDTO]setWeightForPush:[apsInfo objectForKey:@"w"] caseStr:@"w"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"PUSH" object:nil];
   
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    
}

-(void)clearDocumentsFolder{
    
    NSFileManager *fileMgr = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *files = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    while (files.count > 0) {
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSArray *directoryContents = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error];
        if (error == nil) {
            for (NSString *path in directoryContents) {
                NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
                BOOL removeSuccess = [fileMgr removeItemAtPath:fullPath error:&error];
                files = [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:nil];
                if (!removeSuccess) {
                    // Error
                }
            }
        } else {
            // Error
        }
    }
}

- (void)createEditableCopyOfPlistIfNeeded
{
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"Settings.plist"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    
    if (success) return;
    
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Settings.plist"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    
    NSLog(@"Egrapsa to pList");
    
    if (!success)
    {
        NSAssert1(0, @"Failed to create writable Plist file with message '%@'.", [error localizedDescription]);
    }
}


@end
