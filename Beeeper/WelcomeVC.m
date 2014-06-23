//
//  WelcomeVC.m
//  Beeeper
//
//  Created by User on 3/7/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "WelcomeVC.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import <Social/Social.h>
#import "TabbarVC.h"

@interface WelcomeVC ()
{
    NSMutableArray *animatedBGImages;
    BOOL cancelAllAnimations;
    BOOL firstTime;
}
@end

@implementation WelcomeVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self showSplashScreen];
    
    [self autoLoginIfAvailable];
    
    [[UINavigationBar appearance] setBarTintColor: [UIColor colorWithRed:250/255.0 green:217/255.0 blue:0 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    //Swipe to go back enable
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

-(void)viewDidDisappear:(BOOL)animated{
    [self hideSplashScreen];
}

-(void)autoLoginIfAvailable{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"log_method"]];
    NSString *method =  [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];

    if ([method isEqualToString:@"FB"]) {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) // check Facebook is configured in Settings or not
        {
            @try {
                
                ACAccountStore *accountStore = [[ACAccountStore alloc] init]; // you have to retain ACAccountStore
                
                ACAccountType *fbAcc = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
                
                NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                         @"253616411483666", ACFacebookAppIdKey,
                                         [NSArray arrayWithObject:@"email"], ACFacebookPermissionsKey,
                                         nil];
                
                
                ACAccount *fbAccount = [[accountStore accountsWithAccountType:fbAcc] lastObject];
                
                if (fbAccount != nil) {
                    
                    id email = [fbAccount valueForKeyPath:@"properties.uid"];
                    NSLog(@"Facebook ID: %@, FullName: %@", email, fbAccount.userFullName);
                    
                    [[BPUser sharedBP]loginFacebookUser:email completionBlock:^(BOOL completed,NSString *user){
                        if (completed) {
                            [self performSelector:@selector(loginPressed:) withObject:@"FB" afterDelay:0.0];
                        }
                        else{
                            [self performSelector:@selector(hideSplashScreen) withObject:nil afterDelay:1.0];
                        }
                    }];
                    
                }
                else{
                    [self performSelector:@selector(hideSplashScreen) withObject:nil afterDelay:1.0];
                }
                
            }
            @catch (NSException *exception) {
                [self performSelector:@selector(hideSplashScreen) withObject:nil afterDelay:1.0];
            }
            @finally {
                
            }
        }
        else
        {
            NSLog(@"Not Configured in Settings......"); // show user an alert view that Facebook is not configured in settings.
            
            if (FBSession.activeSession.state == FBSessionStateOpen
                || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
                
                [self loginFBuser];
            }
            else {
               [self performSelector:@selector(hideSplashScreen) withObject:nil afterDelay:1.0];
            }
            
        }

    }
    else if ([method isEqualToString:@"TW"]){
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) // check Twitter is configured in Settings or not
        {
            ACAccountStore *accountStore = [[ACAccountStore alloc] init]; // you have to retain ACAccountStore
            
            ACAccountType *twitterAcc = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            
            ACAccount *twitterAccount = [[accountStore accountsWithAccountType:twitterAcc] firstObject];
            
            if (twitterAccount != nil) {
                
                ACAccount *twitterAccount = [[accountStore accountsWithAccountType:twitterAcc] firstObject];
                NSLog(@"Twitter UserName: %@, FullName: %@", twitterAccount.username, twitterAccount.userFullName);
                NSString *user_id = [[twitterAccount valueForKey:@"properties"] valueForKey:@"user_id"];
                
                [[BPUser sharedBP]loginTwitterUser:user_id completionBlock:^(BOOL completed,NSString *user){
                    if (completed) {
                        [self performSelector:@selector(loginPressed:) withObject:@"TW" afterDelay:0.0];
                    }
                    else{
                        [self hideSplashScreen];
                    }
                }];
                
            }
            else{
                [self performSelector:@selector(hideSplashScreen) withObject:nil afterDelay:1.0];
            }
            
        }
        else
        {
            
            [self performSelector:@selector(hideSplashScreen) withObject:nil afterDelay:1.0];
        }

    }
    else if ([method isEqualToString:@"EMAIL"]){
        
        NSString *crFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"cr"]];
        NSDictionary *dictFromFile = [NSDictionary dictionaryWithContentsOfFile:crFilePath];
        
        [[BPUser sharedBP]loginUser:[dictFromFile objectForKey:@"username"] password:[dictFromFile objectForKey:@"password"] completionBlock:^(BOOL completed,NSString *user){
            if (completed) {
                NSLog(@"%@",user);
                [self performSelector:@selector(loginPressed:) withObject:@"EMAIL" afterDelay:0.5];
            }
            else{
                 [self hideSplashScreen];
            }
        }];

    }
    else{
        [self performSelector:@selector(hideSplashScreen) withObject:nil afterDelay:1.0];
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
                    [self performSelector:@selector(loginPressed:) withObject:@"FB" afterDelay:0.0];
                }
                else{
                    [self performSelector:@selector(hideSplashScreen) withObject:nil afterDelay:0.0];
                }
            }];
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
           [self performSelector:@selector(hideSplashScreen) withObject:nil afterDelay:1.0];
        }
    }];
    
}

- (IBAction)loginPressed:(id)sender {
    
    if (sender != nil) {
        TabbarVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"TabbarVC"];
        
        viewController.showsSplashOnLoad = (sender != nil);
        [self.navigationController pushViewController:viewController animated:NO];
    }
    else{
        UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"ChooseLoginVC"];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated{

    firstTime = YES;
    
    cancelAllAnimations = NO;

    [self adjustFonts];
    
    
    [self loadGalleryAnimatedImages];
    
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    cancelAllAnimations = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super viewWillDisappear:animated];
}

-(void)adjustFonts{
    
    for(UIView *v in [self.view allSubViews])
    {
        if([v isKindOfClass:[UIButton class]])
        {
            ((UIButton*)v).titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
        }
    }

    
}

-(void)loadGalleryAnimatedImages{
    
    animatedBGImages = [NSMutableArray array];
    
    @try {
        for (int i = 0; i <= 2; i++) { //100 is just a big number
            NSString *photoName = [NSString stringWithFormat:@"welcome_screen_%d",i];
            
            NSString *path = [[NSBundle mainBundle] pathForResource:photoName ofType:@"png"];
            
            if ([UIImage imageWithContentsOfFile:path] != nil) {
                UIImage *image = [UIImage imageWithContentsOfFile:path];
                
                if (i == 0) {
                    [self.bgImage setImage:image];
                }
                
                
                [animatedBGImages addObject:image];
            }
        }
        
        
        
        if (animatedBGImages.count > 0) {
            [self performSelector:@selector(animateNextGalleryImage) withObject:nil afterDelay:(firstTime)?1:2.0];
            firstTime = NO;
        }
        
    }
    @catch (NSException *exception) {
        [self loadGalleryAnimatedImages];
    }
    @finally {
        
    }
}

-(void)animateNextGalleryImage{
    
    if (cancelAllAnimations) {
        return;
    }
    
    static int i = 0;
    
    UIImageView *galleryButton = self.bgImage;
    
    
    if (i == animatedBGImages.count) {
        i=0;
    }
    
    UIImage *trans_img;
    
    @try {
        trans_img = [animatedBGImages objectAtIndex:i];
    }
    @catch (NSException *exception) {
        i = 0;
        trans_img = [animatedBGImages objectAtIndex:i];
        NSLog(@"ESKASE");
    }
    @finally {
        
    }
    
    CATransition *transition = [CATransition animation];
    transition.duration = 2.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [galleryButton.layer addAnimation:transition forKey:nil];
    [galleryButton setImage:trans_img ];
    
    ++i;
    [self performSelector:@selector(animateNextGalleryImage) withObject:nil afterDelay:4.0];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)back:(UIStoryboardSegue *)segue{
    
}


- (IBAction)login:(id)sender {
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"ChooseLoginVC"];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)showSplashScreen{

    UIView *backV = [[UIView alloc]initWithFrame:self.view.bounds];
    backV.backgroundColor = [UIColor colorWithRed:250/255.0 green:217/255.0 blue:0 alpha:1];
    UIImageView *imgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"beeeper-logo-Splash"]];
    imgV.tag = 454;
    imgV.center = CGPointMake(backV.center.x, backV.center.y-22);
    [backV addSubview:imgV];
    backV.tag = 323;
    [self.view addSubview:backV];
    [self.view bringSubviewToFront:backV];
}

-(void)hideSplashScreen{
    
    UIView *backV = (id)[self.view viewWithTag:323];
    UIImageView *imgV = (id)[backV viewWithTag:454];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGAffineTransform transform = imgV.transform;
                         imgV.transform = CGAffineTransformScale(transform, 1.5 , 1.5);
                         backV.alpha = 0;
                         
                     } completion:^(BOOL finished){
                               [backV removeFromSuperview];
                     }];

}

@end
