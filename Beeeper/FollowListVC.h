//
//  FollowListVC.h
//  Beeeper
//
//  Created by User on 2/21/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FollowersMode 1
#define FollowingMode 2
#define LikesMode 3
#define BeeepersMode 4

@interface FollowListVC : UIViewController
@property (nonatomic,assign) int mode;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic,strong) NSArray *ids;
@property (nonatomic,strong) NSDictionary *user; //Followers,Following
@property (weak, nonatomic) IBOutlet UILabel *nousersLabel;
@property (weak, nonatomic) IBOutlet UIButton *findFriendsButton;

- (IBAction)rightButtonPressed:(id)sender;
- (IBAction)findFriendsPressed:(id)sender;

@end
