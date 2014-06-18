//
//  SideBarVC.m
//  Beeeper
//
//  Created by User on 2/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "SideBarVC.h"
#import "TimelineVC.h"

@interface SideBarVC ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
{
    NSArray *options;
    NSArray *images;
}
@end

@implementation SideBarVC

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
    
	options = [NSArray arrayWithObjects:@"Homefeed",@"Suggestions",@"Activity",@"Find Friends",@"Walkthrough",@"Settings", nil];
	images = [NSArray arrayWithObjects:@"Home_feed_icon2",@"friends_suggestions_icon",@"Activity_icon",@"find_friends_icon",@"walkthrough_icon",@"settings_icon", nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    CALayer * l = [self.profileImageBorderV layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:1.5];
   
    l = [self.profileImage layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:1.5];
    
    self.nameLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:14];
    self.showTimelineButton.titleLabel.font = [UIFont fontWithName:@"Roboto-Regular" size:10];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Tableview

-(int)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 6;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UILabel *lbl = (id)[cell viewWithTag:2];
    UIImageView *imageV = (id)[cell viewWithTag:1];
    
    [lbl setFont:[UIFont fontWithName:@"Roboto-Light" size:20]];
    [lbl setText:[options objectAtIndex:indexPath.row]];
    imageV.image = [UIImage imageNamed:[images objectAtIndex:indexPath.row]];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vC;
    
    switch (indexPath.row) {
        case 0:
            vC = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"HomeFeedVC"];          
            break;
        case 1:
            vC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SuggestionsVC"];
            break;
        case 2:
            vC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ActivityVC"];
            break;
        case 3:
            vC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FindFriendsVC"];
            break;
        case 5:
            vC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsVC"];
            break;
        default:
        
            break;
    }
    
    if (vC == nil) {
        return;
    }
    
    [self.sideMenuController changeContentViewController:vC closeMenu:YES];
    
    
    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}


#pragma mark - Search

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    NSLog(@"%@",searchString);
    return YES;
}

-(void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView{
    
    
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
    return YES;
}

- (IBAction)showTimeline:(id)sender {
    
    UINavigationController *vC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"TimelineVCNav"];
    TimelineVC *timelineVC = vC.viewControllers.firstObject;
    timelineVC.mode = Timeline_My;
    
    [self.sideMenuController changeContentViewController:vC closeMenu:YES];
}

@end
