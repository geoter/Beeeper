//
//  ForgotPassVC.m
//  Beeeper
//
//  Created by User on 3/21/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "ForgotPassVC.h"

@interface ForgotPassVC ()<UITextFieldDelegate>

@end

@implementation ForgotPassVC

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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)sendEmail:(id)sender {
}

-(void)adjustFonts{
    
    for(UIView *v in [self.view allSubViews])
    {
        if([v isKindOfClass:[UILabel class]])
        {
            if (v.tag == 1) {
                ((UILabel*)v).font = [UIFont fontWithName:@"HelveticaNeue-Light" size:26];
            }
            else{ //2
                ((UILabel*)v).font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
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
            ((UITextField*)v).font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        }
    }
    
    
}



@end
