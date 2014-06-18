//
//  BeeepEventVC.m
//  Beeeper
//
//  Created by User on 2/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "BeeepEventVC.h"

@interface BeeepEventVC ()

@end

@implementation BeeepEventVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollV setContentSize:CGSizeMake(320, 837)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)beeepIt:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Beeeped" object:self];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
