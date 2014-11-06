//
//  BeeepTimeVC.h
//  Beeeper
//
//  Created by User on 3/21/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKRoundedView.h"

@interface BeeepTimeVC : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollV;
@property (weak, nonatomic) IBOutlet UIImageView *checkMark;
@property (nonatomic,assign) BOOL closeExits;
@property (weak, nonatomic) IBOutlet TKRoundedView *corneredBGV;

- (IBAction)close:(id)sender;
- (IBAction)buttonClicked:(id)sender;

@end
