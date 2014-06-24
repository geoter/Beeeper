//
//  FindFriendsVC.h
//  Beeeper
//
//  Created by User on 3/12/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^completed)(BOOL,id);

@interface FindFriendsVC : UITableViewController
@property (weak, nonatomic) IBOutlet UIView *headerV;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic,copy) completed search_completed;

- (IBAction)rightButtonPressed:(id)sender;

@end
