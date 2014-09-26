//
//  EventVC.h
//  Beeeper
//
//  Created by User on 3/21/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Timeline_Object.h"
#import "Friendsfeed_Object.h"
#import "Suggestion_Object.h"

@interface EventVC : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *hourLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@property (weak, nonatomic) IBOutlet UITextView *tagsField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollV;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UILabel *likesLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *beeepsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *eventImageV;
@property (strong, nonatomic) IBOutlet UIButton *likesButton;
@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UIButton *beeepsButton;
@property (weak, nonatomic) IBOutlet UIImageView *venueIcon;
@property (weak, nonatomic) IBOutlet UIButton *beeepItButton;
@property (weak, nonatomic) IBOutlet UIImageView *passedIcon;

@property (nonatomic,strong) NSMutableDictionary *values;
@property (nonatomic,strong) id tml;

- (IBAction)ShowWebsite:(id)sender;
- (IBAction)beeepItPressed:(id)sender;
- (IBAction)showLikes:(id)sender;
- (IBAction)showComments:(id)sender;
- (IBAction)showBeeeps:(id)sender;
- (IBAction)tagSelected:(id)sender;

@end
