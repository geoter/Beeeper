//
//  ChooseDatePopupVC.h
//  Beeeper
//
//  Created by GreekMinds on 10/28/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TKRoundedView.h"

@protocol ChooseDatePopupVCDelegate <NSObject>
-(void)datePopupIndexOptionSelected:(int)index;
@end

@interface ChooseDatePopupVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *popupVContainer;
@property (weak, nonatomic) IBOutlet UIView *popupBGV;
@property (weak, nonatomic) IBOutlet UIImageView *tickIcon;
@property (weak, nonatomic) IBOutlet UILabel *optionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowIcon;
@property (weak, nonatomic) IBOutlet TKRoundedView *optionsV;
@property (weak, nonatomic) IBOutlet TKRoundedView *expandableV;
@property (nonatomic,strong) NSDate *selectedDate;

@property (weak, nonatomic) IBOutlet UIImageView *blurredImageV;
@property (nonatomic,strong) UIView *superviewToBlur;

@property (nonatomic,assign) int option;
@property (nonatomic,weak) id<ChooseDatePopupVCDelegate>delegate;
- (IBAction)selection:(id)sender;

@end
