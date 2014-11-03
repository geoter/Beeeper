//
//  FindFriendsVC.h
//  Beeeper
//
//  Created by User on 3/12/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^completed)(BOOL,id);

@interface FindFriendsVC : UIViewController
@property (weak, nonatomic) UIView *headerV;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic,copy) completed search_completed;
@property (nonatomic,assign) int pageLimit;
@property (weak, nonatomic) IBOutlet UILabel *noUsersFoundLabel;

- (IBAction)rightButtonPressed:(id)sender;
- (IBAction)selectFBFriendPressed:(id)sender;

@end
