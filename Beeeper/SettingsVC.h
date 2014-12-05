//
//  SettingsVC.h
//  Beeeper
//
//  Created by User on 2/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsVC : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollV;

- (IBAction)showTerms:(id)sender;
- (IBAction)sendBugsReport:(id)sender;
- (IBAction)showPrivacy:(id)sender;

@end
