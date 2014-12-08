//
//  SignUp_Email_VC.m
//  Beeeper
//
//  Created by User on 3/7/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "SignUp_Email_VC.h"
#import "MissingFields.h"
#import "LocationManager.h"
#import "TKRoundedView.h"
#import "WebBrowserVC.h"

@interface SignUp_Email_VC ()
{
    LocationManager *locManager;
    NSMutableDictionary *values;
    NSMutableDictionary *missingInfo;
    BOOL weHaveAllInfoNeeded;
    BOOL hasCity;
    BOOL hasState;
    BOOL hasCountry;
    BOOL hasUsername;
    BOOL hasEmail;
    BOOL hasName;
    BOOL hasSex;
    BOOL hasPassword;
   UITapGestureRecognizer *tapG;
    BOOL agreeTerms;
}
@end

@implementation SignUp_Email_VC

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
    
 	values = [NSMutableDictionary dictionary];
    
    [self adjustFonts];
    
    locManager = [[LocationManager alloc]init];
    
    [locManager startTracking];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)hideKeyboard:(UITapGestureRecognizer *)g{
    for (UIView *subSuper in [self.scrollV subviews]) {
        
        for (UIView *sub in subSuper.subviews) {
            
            if ([sub isKindOfClass:[UITextField class]]) {
                [(UITextField *)sub resignFirstResponder];
            }
        }
    }
    
    [self.scrollV setContentOffset:CGPointZero animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerPressed:(id)sender {
   
    if (!agreeTerms) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Terms of Use" message:@"To create account,please agree with our Terms of Use and Privacy Policy." delegate:nil cancelButtonTitle:@"Done" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    UITextField *nameTxtF;
    UITextField *emailTxtF;
    UITextField *passwordTxtF;
    UITextField *usernameTxtF;
    
    for (UIView *subSuper in [self.scrollV subviews]) {
      
        if (![subSuper isKindOfClass:[TKRoundedView class]]) {
            continue;
        }
        
        ((TKRoundedView *)subSuper).roundedCorners = TKRoundedCornerNone;
        ((TKRoundedView *)subSuper).borderColor = [UIColor colorWithRed:164/255.0 green:168/255.0 blue:174/255.0 alpha:1];
        ((TKRoundedView *)subSuper).borderWidth = 1.0f;
        ((TKRoundedView *)subSuper).cornerRadius = 0;
        ((TKRoundedView *)subSuper).drawnBordersSides = TKDrawnBorderSidesAll;
        
        for (UIView *sub in subSuper.subviews) {
            
            if ([sub isKindOfClass:[UITextField class]]) {
                switch (sub.tag) {
                    case 1:{
                        nameTxtF = (UITextField *)sub;
                        if ([(UITextField *)sub text].length > 0) {
                            [values setObject:[(UITextField *)sub text] forKey:@"name"];
                        }
                        break;
                    }
                    case 3:{
                        emailTxtF = (UITextField *)sub;
                        if ([(UITextField *)sub text].length > 0) {
                            [values setObject:[(UITextField *)sub text] forKey:@"email"];
                        }
                        break;
                    }
                    case 4:{
                        passwordTxtF = (UITextField *)sub;
                        if ([(UITextField *)sub text].length > 0) {
                            [values setObject:[(UITextField *)sub text] forKey:@"password"];
                        }
                        break;
                    }
                    case 5:{
                        passwordTxtF = (UITextField *)sub;
                        if ([(UITextField *)sub text].length > 0) {
                            [values setObject:[(UITextField *)sub text] forKey:@"username"];
                        }
                        break;
                    }
                    default:
                        break;
                }
            }
        }
    }
    
    hasUsername = ([values objectForKey:@"username"] != nil);
    hasEmail = ([values objectForKey:@"email"] != nil);
    hasName = ([values objectForKey:@"name"] != nil);
    hasSex = ([values objectForKey:@"gender"] != nil);
    hasPassword = ([values objectForKey:@"password"] != nil);

    if (hasName) {
        [self validTextfield:nameTxtF];
    }
    else{
        [self invalidTextfield:nameTxtF];
    }
    
    if (hasEmail) {
        [self validTextfield:emailTxtF];
    }
    else{
        [self invalidTextfield:emailTxtF];
    }
    
    if (hasPassword) {
        [self validTextfield:passwordTxtF];
    }
    else{
        [self invalidTextfield:passwordTxtF];
    }
    
    if (hasUsername) {
        [self validTextfield:usernameTxtF];
    }
    else{
        [self invalidTextfield:usernameTxtF];
    }
    
    if (!hasName || !hasEmail || !hasPassword || !hasUsername) {
       
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Missing information" message:@"Please make sure you entered all required information." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    NSInteger minutesFromGMT = [[NSTimeZone localTimeZone] secondsFromGMT]/60;
    [values setObject:[NSString stringWithFormat:@"%d",minutesFromGMT] forKey:@"timezone"];
    
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
            [values setObject:city forKey:@"city"];
        }
        if (hasState) {
            [values setObject:state forKey:@"state"];
        }
        if (hasCountry) {
            [values setObject:country forKey:@"country"];
        }
        
        NSString *lat = [[NSString alloc] initWithFormat:@"%g", userloc.coordinate.latitude];
        
        NSString *lon = [[NSString alloc] initWithFormat:@"%g", userloc.coordinate.longitude];
        
        [values setObject:lat forKey:@"long"];
        [values setObject:lon forKey:@"lat"];
        
        
        weHaveAllInfoNeeded = (hasUsername && hasEmail && hasName && hasCity && hasState && hasCountry && hasPassword);
        
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
                    [missingInfo setObject:@"First and Last Name" forKey:@"name"];
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
                if (!hasPassword) {
                    [missingInfo setObject:@"Password" forKey:@"password"];
                }
                
//                if (!hasSex) {
//                    [missingInfo setObject:@"Gender" forKey:@"gender"];
//                }
                
            }
            
        }
        
        
        if (missingInfo.allKeys.count != 0) {
            
            MissingFields *mf = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"MissingFields"];
            mf.fields = [NSMutableDictionary dictionaryWithDictionary:values];
            mf.misssingfields = [NSMutableDictionary dictionaryWithDictionary:missingInfo];
            mf.delegate = self;
            
            missingInfo = nil;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:mf animated:YES];
            });
            
            return;
        }
        else{
            
            [[BPUser sharedBP]signUpUser:values completionBlock:^(BOOL completed,NSString *response){
                
                if (completed) {
                    [self performSelector:@selector(loginPressed:) withObject:nil afterDelay:0.0];
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Registration Failed" message:response delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                }
            }];
            
        }
        

    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Where are you?" message:@"Please go to Settings > Privacy > Location Services and set Beeeper to on." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];

        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        
        [locManager startTracking];
    }

}



-(void)adjustFonts{
    
    for(UIView *v in [self.view allSubViews])
    {
        if([v isKindOfClass:[UILabel class]])
        {
            if (v.tag == 1) {
                ((UILabel*)v).font = [UIFont fontWithName:@"HelveticaNeue-Light" size:26];
            }
            else{
                ((UILabel*)v).font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
                
                NSString *lblStr = [(UILabel *)v text];
                
                NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:lblStr];
                NSRange range=[lblStr rangeOfString:@"Terms of Use Agreement"];
                
                [string addAttribute:NSFontAttributeName
                               value:[UIFont fontWithName:@"HelveticaNeue" size:12]
                               range:range];
                
                NSRange range2 =[lblStr rangeOfString:@"Privacy Policy"];
                
                [string addAttribute:NSFontAttributeName
                               value:[UIFont fontWithName:@"HelveticaNeue" size:12]
                               range:range2];
                
                ((UILabel *)v).attributedText = string;

            }
        }
        else if ([v isKindOfClass:[UIButton class]]){
            if (v.tag == 4) {
                ((UIButton*)v).titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
            }
        }
        else if ([v isKindOfClass:[UITextField class]]){
            UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
            ((UITextField*)v).leftView = paddingView;
            ((UITextField*)v).leftViewMode = UITextFieldViewModeAlways;
            ((UITextField*)v).font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        }
    }
    
    
}

- (IBAction)agreeButtonPressed:(UIButton *)sender {
  
    if (sender.tag == 0) {
        [sender setImage:[UIImage imageNamed:@"checkbox_check"] forState:UIControlStateNormal];
        sender.tag = 1;
        agreeTerms = YES;
    }
    else{
        [sender setImage:[UIImage imageNamed:@"checkbox_empty"] forState:UIControlStateNormal];
        sender.tag = 0;
        agreeTerms = NO;
    }
}

- (IBAction)showTerms:(id)sender {
  
    WebBrowserVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"WebBrowser"];
    viewController.url = [NSURL URLWithString:@"https://www.beeeper.com/terms"];
    viewController.title = @"Terms of Use";
    [self.navigationController pushViewController:viewController animated:YES];

}

- (IBAction)showPrivacy:(id)sender {
    
    WebBrowserVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"WebBrowser"];
    viewController.url = [NSURL URLWithString:@"https://www.beeeper.com/privacy"];
    viewController.title = @"Privacy Policy";
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)invalidTextfield:(UITextField *)txtF{
    
    TKRoundedView *backV = (id)txtF.superview;
    
    [UIView animateWithDuration:0.3f
                     animations:^
     {    backV.borderColor = [UIColor redColor];
     }
                     completion:^(BOOL finished)
     {
     }
     ];
}

-(void)validTextfield:(UITextField *)txtF{
    
    TKRoundedView *backV = (id)txtF.superview;
    
    [UIView animateWithDuration:0.3f
                     animations:^
     {
         backV.borderColor = [UIColor clearColor];
     }
                     completion:^(BOOL finished)
     {
     }
     ];
    
}

#pragma mark - UITextfield

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard:)];
    [self.scrollV addGestureRecognizer:tapG];
    
    [self.scrollV setContentOffset:CGPointMake(0, IS_IPHONE_5?20:50) animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
   
    if (textField.tag != 5) {
        UITextField *txtF = (id)[self.scrollV viewWithTag:textField.tag+1];
        [txtF becomeFirstResponder];
    }
    else{
        [self.scrollV removeGestureRecognizer:tapG];
        [textField resignFirstResponder];
        [self.scrollV setContentOffset:CGPointZero animated:YES];
    }
    
    return YES;
}
@end
