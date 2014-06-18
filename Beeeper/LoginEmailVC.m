//
//  LoginEmailVC.m
//  Beeeper
//
//  Created by User on 2/18/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "LoginEmailVC.h"

@interface LoginEmailVC ()

@end

@implementation LoginEmailVC

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginPressed:(id)sender {
    
    UITextField *username = (id)[self.view viewWithTag:1];
    UITextField *password = (id)[self.view viewWithTag:2];
    
    [[BPUser sharedBP]loginUser:username.text password:password.text completionBlock:^(BOOL completed,NSString *user){
        if (completed) {
            NSLog(@"%@",user);
             [self performSegueWithIdentifier:@"home" sender:self];
        }
    }];
   
}

- (IBAction)forgotPassword:(id)sender {

}

#pragma mark - UITextField delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.tag == 1) {
       UITextField *txtF = (id)[self.view viewWithTag:2];
        [txtF becomeFirstResponder];
    }
    else{
        [textField resignFirstResponder];
    }
    return YES;
}

@end
