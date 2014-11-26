//
//  SignUp_Email_VC.h
//  Beeeper
//
//  Created by User on 3/7/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUp_Email_VC : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollV;

- (IBAction)registerPressed:(id)sender;
- (IBAction)agreeButtonPressed:(id)sender;
- (IBAction)showTerms:(id)sender;
- (IBAction)showPrivacy:(id)sender;

@end
