//
//  SignUp_Email_VC.m
//  Beeeper
//
//  Created by User on 3/7/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "SignUp_Email_VC.h"

@interface SignUp_Email_VC ()
{
    NSMutableDictionary *values;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerPressed:(id)sender {
   
    for (UIView *sub in [self.scrollV subviews]) {
        if ([sub isKindOfClass:[UITextField class]]) {
            switch (sub.tag) {
                case 1:
                {
                    NSArray *components = [[(UITextField *)sub text] componentsSeparatedByString:@" "];
                    if (components.count == 1) {
                        [values setObject:[components firstObject] forKey:@"name"];
                    }
                    else{
                        NSRange nameRange = [[(UITextField *)sub text]rangeOfString:[components firstObject]];
                        [values setObject:[components firstObject] forKey:@"name"];

                        NSString *lastName = [[(UITextField *)sub text]substringFromIndex:nameRange.location+nameRange.length+1];
                        [values setObject:[components lastObject] forKey:@"lastname"];
                    }
                    break;
                }
                case 2:
                    [values setObject:[(UITextField *)sub text] forKey:@"password"];
                    break;
                case 3:
                    [values setObject:[(UITextField *)sub text] forKey:@"email"];
                    break;
                    default:
                    break;
            }
        }
    }

    NSInteger minutesFromGMT = [[NSTimeZone localTimeZone] secondsFromGMT]/60;
    [values setObject:[NSString stringWithFormat:@"%d",minutesFromGMT] forKey:@"timezone"];
    
    CLPlacemark *userPlace = [DTO sharedDTO].userPlace;
    
    if (userPlace != nil) {
        [values setObject:userPlace.locality forKey:@"city"];
        [values setObject:userPlace.administrativeArea forKey:@"state"];
        [values setObject:userPlace.country forKey:@"country"];
    }
    
    [[BPUser sharedBP]signUpUser:values completionBlock:^(BOOL completed,NSString *user){
        if (completed) {
            NSLog(@"%@",user);
        }
    }];

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
    }
    else{
        [sender setImage:[UIImage imageNamed:@"checkbox_empty"] forState:UIControlStateNormal];
        sender.tag = 0;
    }
}

#pragma mark - UITextfield

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.scrollV setContentOffset:CGPointMake(0, IS_IPHONE_5?0:30) animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.tag != 3) {
        UITextField *txtF = (id)[self.scrollV viewWithTag:textField.tag+1];
        [txtF becomeFirstResponder];
    }
    else{
        [textField resignFirstResponder];
        [self.scrollV setContentOffset:CGPointZero animated:YES];
    }
    
    return YES;
}
@end
