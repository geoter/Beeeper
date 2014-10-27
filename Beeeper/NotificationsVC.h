//
//  NotificationsVC.h
//  Beeeper
//
//  Created by User on 2/21/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationsVC : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UILabel *noNotifsFound;
@property (weak, nonatomic) IBOutlet UIView *tabBar;


- (IBAction)tabbarButtonTapped:(UIButton *)sender;
- (IBAction)addNewBeeep:(id)sender;

@end
