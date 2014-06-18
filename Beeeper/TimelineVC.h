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
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;

@property (nonatomic,assign) BOOL showBackButton;
@property (nonatomic,assign) int mode;
@property (nonatomic,strong) NSDictionary *user; //for others' profile

- (IBAction)backPressed:(id)sender;
- (IBAction)beeepItPressed:(id)sender;
- (IBAction)showFollowers:(id)sender;
- (IBAction)showFollowing:(id)sender;
- (IBAction)showLikes:(id)sender;
- (IBAction)showComments:(id)sender;
- (IBAction)showBeeepers:(id)sender;
- (IBAction)followButtonPressed:(id)sender;//- (IBAction)leftButtonPressed:(id)sender;
- (IBAction)editProfilePressed:(id)sender;


- (IBAction)showSuggestions:(id)sender;
- (IBAction)showActivity:(id)sender;
@end
