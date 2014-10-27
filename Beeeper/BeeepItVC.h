//
//  BeeepItVC.h
//  Beeeper
//
//  Created by User on 3/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeeepItVC : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollV;
@property (weak, nonatomic) IBOutlet UIView *fbShareV;
@property (weak, nonatomic) IBOutlet UIView *twitterV;
@property (nonatomic,strong) NSDictionary *values;
@property (weak, nonatomic) IBOutlet UIButton *beeepTimeButton;
@property (nonatomic,strong) id tml;
@property (weak, nonatomic) IBOutlet UISwitch *fbSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *twitterSwitch;
@property (weak, nonatomic) IBOutlet UIButton *suggestButton;
@property (weak, nonatomic) IBOutlet UIImageView *venueIcon;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *selectTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *suggestedLabel;
@property (weak, nonatomic) IBOutlet UITextView *venueLabel;

- (IBAction)close:(id)sender;
- (IBAction)fbShare:(id)sender;
- (IBAction)twitterShare:(id)sender;
- (IBAction)hideFromFollowersPressed:(id)sender;
- (IBAction)beeepIt:(id)sender;
- (IBAction)beeepTimeSelected:(id)sender;
- (IBAction)suggestItPressed:(id)sender;

@end
