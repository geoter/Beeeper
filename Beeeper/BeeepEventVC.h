//
//  BeeepEventVC.h
//  Beeeper
//
//  Created by User on 2/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeeepEventVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *bottomV;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollV;

- (IBAction)beeepIt:(id)sender;

@end
