//
//  BeeepVC.h
//  Beeeper
//
//  Created by User on 3/19/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BorderTextField.h"

@interface BeeepVC : UIViewController

@property (weak, nonatomic) IBOutlet UIPageControl *imagesPageControl;
@property (weak, nonatomic) IBOutlet BorderTextField *titleTxtF;
@property (weak, nonatomic) IBOutlet BorderTextField *dateTxtF;
@property (weak, nonatomic) IBOutlet BorderTextField *venueTxtF;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollV;
@property (weak, nonatomic) IBOutlet UIScrollView *containerScrollV;
@property (weak, nonatomic) IBOutlet UIView *tagsV;
- (IBAction)releaseKeyborad:(id)sender;

- (IBAction)close:(id)sender;
- (IBAction)nextPressed:(id)sender;
- (IBAction)imageSelected:(id)sender;
- (IBAction)addPhotoPressed:(id)sender;

@end
