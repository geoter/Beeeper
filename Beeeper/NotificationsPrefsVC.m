//
//  NotificationsPrefsVC.m
//  Beeeper
//
//  Created by User on 2/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "NotificationsPrefsVC.h"

@interface NotificationsPrefsVC ()

@end

@implementation NotificationsPrefsVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideTabbar" object:self];
    
    [self adjustFonts];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
}

-(void)goBack{
     [[NSNotificationCenter defaultCenter]postNotificationName:@"ShowTabbar" object:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)adjustFonts{
    
    for(UIView *v in [self.scrollV allSubViews])
    {
        if([v isKindOfClass:[UILabel class]])
        {
            ((UILabel*)v).font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
            
        }
        else if ([v isKindOfClass:[UIButton class]]){
            ((UIButton*)v).titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        }
    }
    
}

- (IBAction)togglePressed:(UISwitch *)sender {

    
}

@end
