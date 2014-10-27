//
//  TimelineVC.h
//  Beeeper
//
//  Created by User on 3/27/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Timeline_My 1
#define Timeline_Following 2
#define Timeline_Not_Following 3

@interface TimelineVC : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *profileImageBorderV;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

@property (weak, nonatomic) IBOutlet UIButton *followersButton;
@property (weak, nonatomic) IBOutlet UIButton *followingButton;

@property (weak, nonatomic) IBOutlet UIView *topV;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *userCityLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pinIcon;
@property (weak, nonatomic) IBOutlet UIButton *suggestionsButton;

@property (weak, nonatomic) IBOutlet UIButton *settingsIcon;
@property (weak, nonatomic) IBOutlet UIButton *importIcon;

@property (weak, nonatomic) IBOutlet UIButton *addFriendIcon;
@property (nonatomic,assign) BOOL showBackButton;
@property (nonatomic,assign) int mode;
@property (nonatomic,strong) NSDictionary *user; //for others' profile
@property (weak, nonatomic) IBOutlet UIView *myTimelineMenuV;
@property (weak, nonatomic) IBOutlet UIView *othersTimelineMenuV;
@property (weak, nonatomic) IBOutlet UIView *topBGV;
@property (weak, nonatomic) IBOutlet UIView *tabBar;

- (IBAction)calendarPressed:(id)sender;
- (IBAction)addFriend:(id)sender;

- (IBAction)backPressed:(id)sender;
- (IBAction)beeepItPressed:(id)sender;
- (IBAction)showFollowers:(id)sender;
- (IBAction)showFollowing:(id)sender;
- (IBAction)showLikes:(id)sender;
- (IBAction)showComments:(id)sender;
- (IBAction)showBeeepers:(id)sender;
- (IBAction)followButtonPressed:(id)sender;//- (IBAction)leftButtonPressed:(id)sender;
- (IBAction)editProfilePressed:(id)sender;
- (IBAction)settingsPressed:(id)sender;
- (IBAction)importPressed:(id)sender;
- (IBAction)handleTopBarPan:(UIPanGestureRecognizer *)recognizer;

- (IBAction)showSuggestions:(id)sender;
- (IBAction)showActivity:(id)sender;

- (IBAction)tabbarButtonTapped:(UIButton *)sender;
- (IBAction)addNewBeeep:(id)sender;

@end
