//
//  BeeepTimeVC.m
//  Beeeper
//
//  Created by User on 3/21/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "BeeepTimeVC.h"

@interface HighButton : UIButton

@end

@implementation HighButton


- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithRed:240/255.0 green:208/255.0 blue:0 alpha:1];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
}


@end

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
    
    for (UIButton *b in self.scrollV.subviews) {
        if ([b isKindOfClass:[UIButton class]]) {
            [b setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        }
    }
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
    
    if (self.closeExits) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"CloseBeeepItVC" object:nil];
    }
    else{
        
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
    
}

- (IBAction)buttonClicked:(UIButton *)sender {
    
    //self.checkMark.frame = CGRectMake(270, sender.frame.origin.y+8, 25, 24);
    
    self.closeExits = NO;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[sender titleForState:UIControlStateNormal],@"Beeep Time",[NSString stringWithFormat:@"%d",(int)sender.tag],@"Seconds",nil];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Beeep Time Selected" object:nil userInfo:dict];
    [self performSelector:@selector(close:) withObject:nil afterDelay:0.3];
}

@end
