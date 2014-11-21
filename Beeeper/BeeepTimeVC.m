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
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
   
    self.corneredBGV.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    self.corneredBGV.layer.shadowOpacity = 0.7;
    self.corneredBGV.layer.shadowOffset = CGSizeMake(0, 0.0);
    self.corneredBGV.layer.shadowRadius = 0.8;
    [self.corneredBGV.layer setShadowPath:[[UIBezierPath
                                        bezierPathWithRect:self.corneredBGV.bounds] CGPath]];

    
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.corneredBGV.bounds byRoundingCorners:UIRectCornerAllCorners                                                         cornerRadii:CGSizeMake(10.0, 10.0)];
//    // Create the shape layer and set its path
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.frame = self.corneredBGV.bounds;
//    maskLayer.path = maskPath.CGPath;
//    // Set the newly created shape layer as the mask for the image view's layer
//    self.corneredBGV.layer.mask = maskLayer;
//    self.corneredBGV.layer.shadowColor = [UIColor colorWithRed:152/255.0 green:157/255.0 blue:164/255.0 alpha:1].CGColor;
    
    for (UIButton *b in self.corneredBGV.subviews) {
        if ([b isKindOfClass:[UIButton class]] && b.tag != 77) {
            [b addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
            [b addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchDragExit];
            [b setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        }
    }
}

- (IBAction)touchDown:(id)sender
{
    UIButton *b = (UIButton*)sender;

    b.backgroundColor = [UIColor colorWithRed:152/255.0 green:157/255.0 blue:164/255.0 alpha:1];
    [b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [b setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [b setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
}

- (IBAction)touchCancel:(id)sender
{
    UIButton *b = (UIButton*)sender;
    
    b.backgroundColor = [UIColor whiteColor];
    [b setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
    
    self.view.userInteractionEnabled = NO;
    
    self.closeExits = NO;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[sender titleForState:UIControlStateNormal],@"Beeep Time",[NSString stringWithFormat:@"%d",(int)sender.tag],@"Seconds",nil];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Beeep Time Selected" object:nil userInfo:dict];
    [self performSelector:@selector(close:) withObject:nil afterDelay:0.3];
}

@end
