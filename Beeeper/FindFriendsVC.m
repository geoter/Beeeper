//
//  FindFriendsVC.m
//  Beeeper
//
//  Created by User on 3/12/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "FindFriendsVC.h"

#define BeeeperButton 0
#define FacebookButton 1
#define TwitterButton 2
#define MailButton 3

@interface FindFriendsVC ()<UISearchBarDelegate,UISearchDisplayDelegate>
{
    int selectedOption;
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
    UIView *headerView;
}
@end

@implementation FindFriendsVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];

    
    self.tableView.decelerationRate = 0.6;
    
    //search
    
//    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//    /*the search bar widht must be > 1, the height must be at least 44
//     (the real size of the search bar)*/
//    searchBar.barTintColor = [UIColor whiteColor];
//    searchBar.delegate = self;
//    
//    searchBar.layer.borderWidth = 1;
//    searchBar.layer.borderColor = [[UIColor colorWithRed:218/255.0 green:223/255.0 blue:226/255.0 alpha:1.0] CGColor];
//    
//    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
//    /*contents controller is the UITableViewController, this let you to reuse
//     the same TableViewController Delegate method used for the main table.*/
//    
//    searchDisplayController.delegate = self;
//    searchDisplayController.searchResultsDataSource = self;
//    searchDisplayController.searchResultsDelegate = self;
//    //set the delegate = self. Previously declared in ViewController.h
//    
//    //on the top of tableView
//    
//    self.tableView.tableHeaderView = searchBar;
}

-(void)goBack{
     [[NSNotificationCenter defaultCenter]postNotificationName:@"ShowTabbar" object:self];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)optionSelectedFromHeader:(UIButton *)btn{
    
    
    [UIView transitionWithView:self.tableView
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [btn setSelected:YES];
                    } completion:nil];
    
    selectedOption = (int)btn.tag;
    
    for (UIButton *btn in [headerView subviews]) {
        if (btn.tag != selectedOption) {
            
            [UIView transitionWithView:self.view
                              duration:0.2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [btn setSelected:NO];
                            } completion:nil];
        }
    }
    
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.backItem.title = @"";
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    ((UITextField *)[cell viewWithTag:1]).font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    
    UIImage *optionIcon;
    
    switch (selectedOption) {
        case BeeeperButton:
        {
            optionIcon = [UIImage imageNamed:@"Beeeper_logo_small"];
        }
        break;
        case FacebookButton:
        {
            optionIcon = [UIImage imageNamed:@"facebook_logo_small"];
        }
            break;
        case TwitterButton:
        {
            optionIcon = [UIImage imageNamed:@"twitter_icon_small"];
        }
            break;
        case MailButton:
        {
            optionIcon = [UIImage imageNamed:@"mail_icon_small"];
        }
            break;
            
        default:
            break;
    }
    
    ((UIImageView *)[cell viewWithTag:2]).image = optionIcon;
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
   
    if (tableView == searchDisplayController.searchResultsTableView) {
        return 0;
    }
    
    return 81;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 61;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
   
    if (tableView == searchDisplayController.searchResultsTableView) {
        return nil;
    }
    
    if (headerView != nil) {
        return headerView;
    }
    
    UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 81)];
    headerV.backgroundColor = [UIColor colorWithRed:218/255.0 green:223/255.0 blue:226/255.0 alpha:1.0];
    
    //Buttons
    
    for (int i = 0; i <= 3; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(i*81, 0, 80, 80)];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"option_%d_gray",i]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"option_%d",i]] forState:UIControlStateSelected];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"option_%d",i]] forState:UIControlStateHighlighted];
        [btn setBackgroundColor:[UIColor whiteColor]];
        btn.tag = i;
        [btn addTarget:self action:@selector(optionSelectedFromHeader:) forControlEvents:UIControlEventTouchUpInside];
        [headerV addSubview:btn];
        
        if (i == 0) {
            [btn setSelected:YES];
        }
    }
    
    headerView = headerV;
    
    return headerV;
}

@end
