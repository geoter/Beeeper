//
//  ProfileVC.m
//  Beeeper
//
//  Created by User on 2/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "ProfileVC.h"
#import "FollowListVC.h"

@interface ProfileVC ()
{
    int mode; //1 followers, 2 following
}
@end

@implementation ProfileVC

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)followers:(id)sender {
    mode = 1;
    [self performSegueWithIdentifier:@"followList" sender:self];
}

- (IBAction)following:(id)sender {
    mode = 2;
    [self performSegueWithIdentifier:@"followList" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    FollowListVC *list = segue.destinationViewController;
    list.mode = mode;
}

@end
