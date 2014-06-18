//
//  SuggestBeeepVC.h
//  Beeeper
//
//  Created by User on 3/27/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SuggestBeeepVC : UIViewController
@property (weak, nonatomic) IBOutlet UIView *containerV;
@property (weak, nonatomic) IBOutlet UITextField *searchTxtF;
@property (weak, nonatomic) IBOutlet UITableView *tableV;


- (IBAction)closePressed:(id)sender;

-(void)showInView:(UIView *)v;
-(void)hide;
@end
