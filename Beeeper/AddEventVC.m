//
//  AddEventVC.m
//  Beeeper
//
//  Created by User on 2/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "AddEventVC.h"
#import "RMDateSelectionViewController.h"

@interface AddEventVC ()<UITextFieldDelegate,UITextViewDelegate>

@end

@implementation AddEventVC

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
    [self.scrollV setContentSize:CGSizeMake(320, 730)];
    [self.imagesScrollV setContentSize:CGSizeMake(410, 77)];
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

- (IBAction)imageSelected:(id)sender {
  
    self.imagesPageControl.currentPage = [sender tag]-1;
    
    switch ([sender tag]) {
        case 1:
            
            break;
        case 2:
            
            break;
        case 3:
            
            break;
        case 4:
            
            break;
            
        default:
            break;
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (textField.tag == 2) {
        //show Location Popup
        [self.scrollV endEditing:YES];
        [self.scrollV setContentOffset:CGPointMake(0, 0) animated:YES];
        [self showDatePicker:textField];
        return NO;
    }
    
    [self.scrollV setContentOffset:CGPointMake(0, textField.frame.origin.y - 120) animated:YES];
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    int nextTag = textField.tag +1;
    UITextField *txtF = (id)[self.scrollV viewWithTag:nextTag];
    
    if (txtF) {
        [txtF becomeFirstResponder];
    }
    else{
        [textField resignFirstResponder];
        [self.scrollV setContentOffset:CGPointZero animated:YES];
    }
    
    return YES;
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }

    [self.scrollV setContentOffset:CGPointMake(0, self.scrollV.contentSize.height - self.scrollV.frame.size.height) animated:YES];
    
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

-(void)showDatePicker:(UITextField *)txtF{
    
    RMDateSelectionViewController *dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
    
    //You can enable or disable bouncing and motion effects
    //dateSelectionVC.disableBouncingWhenShowing = YES;
    //dateSelectionVC.disableMotionEffects = YES;
    [dateSelectionVC showWithSelectionHandler:^(RMDateSelectionViewController *vc, NSDate *aDate) {
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        //        [format setDateFormat:@"MMMM dd, yyyy HH:mm"];
        [format setDateStyle:NSDateFormatterMediumStyle];
        NSString *nsstr = [format stringFromDate:aDate];
        txtF.text = nsstr;
        
    } andCancelHandler:^(RMDateSelectionViewController *vc) {
        NSLog(@"Date selection was canceled (with block)");
    }];

}
@end
