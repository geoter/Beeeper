//
//  ProfilePrefsVC.h
//  Beeeper
//
//  Created by User on 2/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfilePrefsVC : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollV;

- (IBAction)changeProfilePicture:(id)sender;

@end
