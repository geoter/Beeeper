//
//  SignUpVC.m
//  Beeeper
//
//  Created by User on 2/18/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "SignUpVC.h"

@interface SignUpVC ()<UITextFieldDelegate,UIAlertViewDelegate>
{
    NSMutableDictionary *values;
}
@end

@implementation SignUpVC

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
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollV setContentSize:CGSizeMake(self.view.frame.size.width, 750)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerPressed:(id)sender {
    for (UIView *sub in [self.scrollV.subviews.firstObject subviews]) {
        if ([sub isKindOfClass:[UITextField class]]) {
            switch (sub.tag) {
                case 1:
                    [values setObject:[(UITextField *)sub text] forKey:@"name"];
                    break;
                case 2:
                    [values setObject:[(UITextField *)sub text] forKey:@"surname"];
                    break;
                case 3:
                    [values setObject:[(UITextField *)sub text] forKey:@"username"];
                    break;
                case 4:
                    [values setObject:[(UITextField *)sub text] forKey:@"password"];
                    break;
                case 5:
                    [values setObject:[(UITextField *)sub text] forKey:@"e-mail"];
                    break;
                case 6:
                    [values setObject:[(UITextField *)sub text] forKey:@"location"];
                    break;
                default:
                    break;
            }
        }
    }
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Sign Up" message:@"Thank you for registering.\nPlease check your e- mail to activate your account" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
    [alert show];
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (textField.tag == 6) {
        //show Location Popup
        [self.scrollV endEditing:YES];
        [self.scrollV setContentOffset:CGPointMake(0, self.scrollV.contentSize.height-self.scrollV.frame.size.height) animated:YES];
        [self performSegueWithIdentifier:@"chooseCity" sender:self];
        return NO;
    }
    
    [self.scrollV setContentOffset:CGPointMake(0, textField.frame.origin.y - 120) animated:YES];

    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    int nextTag = textField.tag +1;
    UITextField *txtF = (id)[self.scrollV viewWithTag:nextTag];
    
    if (txtF.tag == 6) {
        [self.scrollV setContentOffset:CGPointMake(0, self.scrollV.contentSize.height-self.scrollV.frame.size.height) animated:YES];

    }
    else{
        
        if (txtF) {
            [txtF becomeFirstResponder];
        }
        else{
            [textField resignFirstResponder];
            [self.scrollV setContentOffset:CGPointZero animated:YES];
        }
    }
 
    
    return YES;
}

@end
