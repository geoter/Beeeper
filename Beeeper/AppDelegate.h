//
//  AppDelegate.h
//  Beeeper
//
//  Created by User on 2/18/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "LoginVC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    LoginVC *loginVC;
}
@property (strong, nonatomic) UIWindow *window;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
- (void)userLoggedIn;
- (void)userLoggedOut;



@end
