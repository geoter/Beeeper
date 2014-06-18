//
//  SuggestionsVC.h
//  Beeeper
//
//  Created by User on 3/27/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuggestionsVC : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableV;

- (IBAction)beeepItPressed:(UIButton *)sender;

@end
