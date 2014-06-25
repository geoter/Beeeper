//
//  BeeepTimeVC.m
//  Beeeper
//
//  Created by User on 3/21/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "BeeepTimeVC.h"

@interface BeeepTimeVC ()

@end

@implementation BeeepTimeVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollV.contentSize = CGSizeMake(320, 568);
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)close:(id)sender {
    
    [UIView animateWithDuration:0.5f
                     animations:^
     {
         self.view.frame = CGRectMake(0, self.view.frame.size.height,self.view.frame.size.width , self.view.frame.size.height);
     }
                     completion:^(BOOL finished)
     {
         [self removeFromParentViewController];
         [self.view removeFromSuperview];
         
     }];
}

- (IBAction)buttonClicked:(UIButton *)sender {
    self.checkMark.frame = CGRectMake(270, sender.frame.origin.y+8, 25, 24);
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[sender titleForState:UIControlStateNormal],@"Beeep Time",[NSString stringWithFormat:@"%d",(int)sender.tag],@"Seconds",nil];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Beeep Time Selected" object:nil userInfo:dict];
    [self close:nil];
}

@end
