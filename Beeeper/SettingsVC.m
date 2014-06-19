//
//  SettingsVC.m
//  Beeeper
//
//  Created by User on 2/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "SettingsVC.h"

@interface SettingsVC ()

@end

@implementation SettingsVC


- (void)viewDidLoad
{
    [super viewDidLoad];

    [self adjustFonts];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideTabbar" object:self];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    for (UIView *view in [[[self.navigationController.navigationBar subviews] objectAtIndex:0] subviews]) {
        if ([view isKindOfClass:[UIImageView class]]) view.hidden = YES;
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)adjustFonts{
    
    for(UIView *v in [self.scrollV allSubViews])
    {
        if([v isKindOfClass:[UILabel class]])
        {
   
               ((UILabel*)v).font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
    
            
        }
        else if ([v isKindOfClass:[UIButton class]]){
                ((UIButton*)v).titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        }
        else if ([v isKindOfClass:[UIView class]]){
            
            UIButton *btn = (UIButton *)[v viewWithTag:1];
            btn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        }
    }
    
    for(UIView *v in [self.view allSubViews])
    {
        if([v isKindOfClass:[UILabel class]] && v.tag == 4)
        {
            ((UILabel*)v).font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
        }
    }
    
}

- (IBAction)showAbout:(id)sender {
   UIViewController *vC = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"AboutVC"];
    [self.navigationController pushViewController:vC animated:YES];
}

- (IBAction)showTerms:(id)sender {
    UIViewController *vC = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"TermsVC"];
    [self.navigationController pushViewController:vC animated:YES];
}
@end
