//
//  SuggestBeeepVC.h
//  Beeeper
//
//  Created by User on 3/27/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuggestBeeepVC : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerV;
@property (weak, nonatomic) IBOutlet UITextField *searchTxtF;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic,strong) NSString *fingerprint;
@property (weak, nonatomic) IBOutlet UILabel *noBeeepersFoundLbl;

- (IBAction)closePressed:(id)sender;
- (IBAction)donePressed:(id)sender;

-(void)showInView:(UIView *)v;
-(void)hide;
@end
