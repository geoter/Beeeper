//
//  BeeepVC.h
//  Beeeper
//
//  Created by User on 3/19/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BorderTextField.h"
#import "TKRoundedView.h"

@interface BeeepVC : UIViewController

@property (weak, nonatomic) IBOutlet UIPageControl *imagesPageControl;
@property (weak, nonatomic) IBOutlet UITextField *titleTxtF;
@property (weak, nonatomic) IBOutlet UITextField *dateTxtF;
@property (weak, nonatomic) IBOutlet UITextField *venueTxtF;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollV;
@property (weak, nonatomic) IBOutlet UIScrollView *containerScrollV;
@property (weak, nonatomic) IBOutlet UIView *tagsV;
@property (weak, nonatomic) IBOutlet TKRoundedView *titleBGV;
@property (weak, nonatomic) IBOutlet TKRoundedView *whereBGV;
@property (weak, nonatomic) IBOutlet TKRoundedView *whenBGV;
@property (weak, nonatomic) IBOutlet TKRoundedView *addPhotoBGV;
@property (weak, nonatomic) IBOutlet TKRoundedView *tagsBGV;
@property (weak, nonatomic) IBOutlet UIView *blurContainerV;

@property (weak, nonatomic) IBOutlet UIImageView *blurredImageV;
@property (nonatomic,strong) UIView *superviewToBlur;

- (IBAction)releaseKeyborad:(id)sender;

- (IBAction)close:(id)sender;
- (IBAction)nextPressed:(id)sender;
- (IBAction)addPhotoPressed:(id)sender;
- (IBAction)tagSelected:(id)sender;

@end
