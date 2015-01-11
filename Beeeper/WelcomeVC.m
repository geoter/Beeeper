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
#import "LocationManager.h"

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
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
      
        [[NSFileManager defaultManager]removeItemAtPath:filePath error:&error];
        
        NSString *crFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"cr"]];
        [[NSFileManager defaultManager]removeItemAtPath:crFilePath error:NULL];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[LocationManager sharedLM] startTracking];
    
    [self showSplashScreen];
    
    [self autoLoginIfAvailable];
    
    [[UINavigationBar appearance] setBarTintColor: [UIColor colorWithRed:240/255.0 green:208/255.0 blue:0 alpha:1]];
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
    
    if (method == nil) {
        [self hideSplashScreen];
        return;
    }

    if ([method rangeOfString:@"FB"].location != NSNotFound) {
        
        [self fbLogin];

    }
    else if ([method rangeOfString:@"TW"].location != NSNotFound){
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) // check Twitter is configured in Settings or not
        {
            ACAccountStore *accountStore = [[ACAccountStore alloc] init]; // you have to retain ACAccountStore
            
            ACAccountType *twitterAcc = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            
            NSArray *accounts = [accountStore accountsWithAccountType:twitterAcc];
            
            ACAccount *twitterAccount;
            
            for (ACAccount *acc in accounts) {
                NSString *user_id = [[acc valueForKey:@"properties"] valueForKey:@"user_id"];
                
                if ([method rangeOfString:user_id].location != NSNotFound) {
                    twitterAccount = acc;
                }
            }
            
            if (twitterAccount != nil) {

                [self attemptTwitterLogin:twitterAccount];
                
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

-(void)attemptTwitterLogin:(ACAccount *)account{
    
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
                dispatch_async (dispatch_get_main_queue(), ^{
                    
                    if (completed) {
                        [self loginPressed:@"TW"];
                    }
                    else{
                        [self hideSplashScreen];
                    }
                });
            }];

            
            
        }
        else{
            [self hideSplashScreen];
        }
    }];
    
}

-(void)attemptFBLogin:(ACAccount *)account{
    
    [self fbLogin];
}

- (void)fbLogin
{
    
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        [self loginFBuser];
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        //[FBSession.activeSession closeAndClearTokenInformation];
        
        //AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
        //[appDelegate sessionStateChanged:FBSession.activeSession state:FBSession.activeSession.state error:NULL];
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for basic_info permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             
             
             if (FBSessionStateOpen == state) {
                 [self loginFBuser];
             }
             else{
                 [self hideSplashScreen];
             }
         }];
    }
}

-(void)loginFBuser{
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Success! Include your code to handle the results here
            NSLog(@"user info: %@", result);
            
            NSMutableDictionary *dict  = [NSMutableDictionary dictionaryWithDictionary:result];
            
            NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [result objectForKey:@"id"]];
            [dict setObject:userImageURL forKey:@"image"];
            
            [[BPUser sharedBP]loginFacebookUser:dict completionBlock:^(BOOL completed,NSString *user){
                if (completed) {
                    [self loginPressed:@"FB"];
                }
                
            }];
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
        }
    }];
    
}

- (IBAction)loginPressed:(id)sender {
    
    if (sender != nil) {
        TabbarVC *viewController = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"TabbarVC"];
        
        viewController.showsSplashOnLoad = (sender != nil);
        [self.navigationController pushViewController:viewController animated:NO];
    }
    else{
        UIViewController *viewController = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"ChooseLoginVC"];
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
        for (int i = 0; i <= 3; i++) { //100 is just a big number
            
            NSString *photoName;
            
            if (IS_IPHONE_6) {
                photoName = [NSString stringWithFormat:@"welcome_screen_%d_6",i];
            }
            else{
                photoName = [NSString stringWithFormat:@"welcome_screen_%d",i];
            }
            
            NSString *path = [[NSBundle mainBundle] pathForResource:photoName ofType:@"png"];
            
            if ([UIImage imageWithContentsOfFile:path] != nil) {
                UIImage *image = [UIImage imageWithContentsOfFile:path];
                
                if (i == 0) {
                    [self.bgImage setImage:image];
                    [self.view sendSubviewToBack:self.bgImage];
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
    UIViewController *viewController = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"ChooseLoginVC"];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)showSplashScreen{

    UIView *backV = [[UIView alloc]initWithFrame:self.view.bounds];
    backV.backgroundColor = [UIColor colorWithRed:240/255.0 green:208/255.0 blue:0 alpha:1];
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
