//
//  ChooseSignUpVC.h
//  Beeeper
//
//  Created by User on 3/7/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseSignUpVC : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *emailSignupButton;

- (IBAction)fbLoginPressed:(id)sender;
- (IBAction)twitterLoginPressed:(id)sender;

@end
