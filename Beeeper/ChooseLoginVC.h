//
//  ChooseLoginVC.h
//  Beeeper
//
//  Created by User on 3/7/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"

@interface ChooseLoginVC : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollV;

- (IBAction)loginPressed:(id)sender;
- (IBAction)forgotPassPressed:(id)sender;
- (IBAction)fbLoginPressed:(id)sender;
- (IBAction)twitterLoginPressed:(id)sender;
- (void)hideLoading;
@end
