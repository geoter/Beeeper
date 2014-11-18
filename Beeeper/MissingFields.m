//
//  MissingFields.m
//  Beeeper
//
//  Created by George on 6/22/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "MissingFields.h"

@interface MissingFields ()<UITextFieldDelegate>
{
    NSMutableDictionary *dict;
}
@end

@implementation MissingFields

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
    
    dict = [NSMutableDictionary dictionary];
    
   }

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)save{
    
    for (UIView *v in self.scrollV.subviews) {
        if([v isKindOfClass:[UITextField class]]){
            [(UITextField *)v resignFirstResponder];
        }
    }
    if (dict.allKeys.count == self.misssingfields.allKeys.count) {
        
        [self showLoading];
        
        [self.fields addEntriesFromDictionary:dict];
        
        [[BPUser sharedBP]signUpSocialUser:self.fields completionBlock:^(BOOL completed,NSString *response){

            [self hideLoading];
            
            if (completed) {
                [self performSelector:@selector(loginPressed:) withObject:nil afterDelay:0.0];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Registration Failed" message:response delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            }
        }];

    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Empty Fields" message:@"Please make sure you have filled in all required fields." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


- (IBAction)loginPressed:(id)sender {
    
    UIViewController *menuVC = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"TabbarVC"];
    
    [self.navigationController pushViewController:menuVC animated:YES];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    int i = 0;
    
    for (NSString *fieldName in self.misssingfields) {
        NSString *fieldPlaceHolder = [self.misssingfields objectForKey:fieldName];
        UITextField *textF = [[UITextField alloc]initWithFrame:CGRectMake(28, 50*i+((IS_IPHONE_5)?50:30), 264, 40)];
        textF.textColor = [UIColor blackColor];
        [textF.UserInfo setObject:fieldName forKey:@"key"];
        textF.tag = i;
        textF.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        textF.delegate = self;
        textF.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0);
        textF.returnKeyType = (i != self.misssingfields.count-1)?UIReturnKeyNext:UIReturnKeyDone;
        UIColor *color = [UIColor colorWithRed:210/255.0 green:210/255.0 blue:214/255.0 alpha:1];
        textF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:fieldPlaceHolder attributes:@{NSForegroundColorAttributeName: color}];
        textF.backgroundColor = [UIColor whiteColor];
       
        [self.scrollV addSubview:textF];
        self.scrollV.contentSize = CGSizeMake(320, textF.frame.origin.y+textF.frame.size.height + 10);
        i++;
    }
    
    self.joinButton.frame = CGRectMake(28, self.scrollV.contentSize.height +7, self.joinButton.frame.size.width, self.joinButton.frame.size.height);
    
    self.scrollV.contentSize = CGSizeMake(320, self.joinButton.frame.origin.y+self.joinButton.frame.size.height + 30);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    UIView *v = [self.scrollV viewWithTag:100+textField.tag];
    v.backgroundColor = textField.textColor;
    
    if (textField.frame.origin.y > ((IS_IPHONE_5)?200:100)) {
        [self.scrollV setContentOffset:CGPointMake(0, textField.frame.origin.y - ((IS_IPHONE_5)?200:100)) animated:YES];
    }
    else{
        [self.scrollV setContentOffset:CGPointZero animated:YES];
    }
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    UIView *v = [self.scrollV viewWithTag:100+textField.tag];
    v.backgroundColor = textField.textColor;

}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{

    UIView *v = [self.scrollV viewWithTag:100+textField.tag];
    v.backgroundColor = textField.textColor;
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField.returnKeyType == UIReturnKeyNext) {
       UITextField *nextTextF = (id)[self.scrollV viewWithTag:textField.tag+1];
       [nextTextF becomeFirstResponder];
    }
    else{
        [self.scrollV setContentOffset:(self.scrollV.contentSize.height < self.scrollV.frame.size.height)?CGPointZero:CGPointMake(0, self.scrollV.contentSize.height - self.scrollV.frame.size.height) animated:YES];
    }
    
    [textField resignFirstResponder];
    NSString *key = [textField.UserInfo objectForKey:@"key"];
    
    [dict setObject:textField.text forKey:key];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *key = [textField.UserInfo objectForKey:@"key"];
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    [dict setObject:newString forKey:key];
    return YES;
}

-(void)showLoading{
    
    if ([self.view viewWithTag:-434]) {
        return;
    }
    
    dispatch_async (dispatch_get_main_queue(), ^{
        
        UIView *loadingBGV = [[UIView alloc]initWithFrame:self.view.bounds];
        loadingBGV.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        
        MONActivityIndicatorView *indicatorView = [[MONActivityIndicatorView alloc] init];
        indicatorView.delegate = self;
        indicatorView.numberOfCircles = 3;
        indicatorView.radius = 8;
        indicatorView.internalSpacing = 1;
        indicatorView.center = self.view.center;
        indicatorView.tag = -565;
        
        loadingBGV.alpha = 0;
        [loadingBGV addSubview:indicatorView];
        loadingBGV.tag = -434;
        [self.view addSubview:loadingBGV];
        [self.view bringSubviewToFront:loadingBGV];
        
        [UIView animateWithDuration:0.3f
                         animations:^
         {
             loadingBGV.alpha = 1;
         }
                         completion:^(BOOL finished)
         {
             [indicatorView startAnimating];
         }
         ];
        
    });
    
}

-(void)hideLoading{
    dispatch_async (dispatch_get_main_queue(), ^{
        
        UIView *loadingBGV = (id)[self.view viewWithTag:-434];
        MONActivityIndicatorView *indicatorView = (id)[loadingBGV viewWithTag:-565];
        [indicatorView stopAnimating];
        
        [UIView animateWithDuration:0.3f
                         animations:^
         {
             loadingBGV.alpha = 0;
         }
                         completion:^(BOOL finished)
         {
             [loadingBGV removeFromSuperview];
         }
         ];
    });
}


#pragma mark -
#pragma mark - MONActivityIndicatorViewDelegate Methods

- (UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index {
    CGFloat red   = 240/255.0;
    CGFloat green = 208/255.0;
    CGFloat blue  = 0/255.0;
    CGFloat alpha = 1.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}


- (IBAction)backpressed:(id)sender {
    [self goBack];
}

- (IBAction)joinPressed:(id)sender {
    [self save];
}
@end
