//
//  ProfilePrefsVC.m
//  Beeeper
//
//  Created by User on 2/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "ProfilePrefsVC.h"

@interface ProfilePrefsVC ()<UITextFieldDelegate,UITextViewDelegate>

@end

@implementation ProfilePrefsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideTabbar" object:self];
    [self adjustFonts];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)adjustFonts{
    
    for(UIView *v in [self.scrollV allSubViews])
    {
        if([v isKindOfClass:[UILabel class]])
        {
            ((UILabel*)v).font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
            
        }
        else if ([v isKindOfClass:[UIButton class]]){
            ((UIButton*)v).titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (textField.tag == 3) {
        //show Location Popup
        [self.scrollV endEditing:YES];
        [self performSegueWithIdentifier:@"chooseCity" sender:self];
        return NO;
    }
    
    [self.scrollV setContentOffset:CGPointMake(0, textField.frame.origin.y - 140) animated:YES];
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    int nextTag = textField.tag +1;
    UITextField *txtF = (id)[self.scrollV viewWithTag:nextTag];

//    if (textField.tag >= 4) {
//          [self.scrollV setContentOffset:CGPointMake(0, self.scrollV.contentSize.height - self.scrollV.frame.size.height) animated:YES];
//    }
//    else{
//        [self.scrollV setContentOffset:CGPointZero animated:YES];
//    }
    
    return YES;
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    
    return YES;
}


-(void)textViewDidBeginEditing:(UITextView *)textView{
    
    if ([textView.text isEqualToString:@"Enter description"]) {
        textView.text = @"";
    }
    [self.scrollV setContentOffset:CGPointMake(0, textView.frame.origin.y - 100) animated:YES];
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.text.length == 0) {
        textView.text = @"Enter description";
    }
}


@end
