//
//  SearchVC.m
//  Beeeper
//
//  Created by User on 4/2/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "SearchVC.h"

@interface SearchVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    NSMutableArray *searchResults;
    NSArray *filteredResults;
}
@end

@implementation SearchVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    searchResults = [NSMutableArray arrayWithObjects:@"Basketball",@"U2 Concert",@"NBA All star game",@"Madonna",@"Shakira Live", nil];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
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
    return filteredResults.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell" forIndexPath:indexPath];
    UILabel *searchResultLabel = (UILabel *)[cell viewWithTag:1];
    searchResultLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:23];
    searchResultLabel.text = [filteredResults objectAtIndex:indexPath.row];
    
    if ([[filteredResults firstObject]isEqualToString:@"No results found"]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * searchStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"self CONTAINS[cd] %@", searchStr];
    filteredResults  = [searchResults filteredArrayUsingPredicate:predicate];
    
    if (filteredResults.count == 0) {
        self.tapG.enabled = YES;
        filteredResults = [NSArray arrayWithObject:@"No results found"];
    }
    else{
        self.tapG.enabled = NO;
    }
    
    [self.tableV reloadData];
    
    return YES;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *numberOfCommentsV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableV.frame.size.width, 41)];
    numberOfCommentsV.backgroundColor = [UIColor clearColor];
    
    UILabel *numberOfComments = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, self.tableV.frame.size.width, 40)];
    numberOfComments.text = [NSString stringWithFormat:@"SEARCH FOR"];
    numberOfComments.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    numberOfComments.textAlignment = NSTextAlignmentLeft;
    [numberOfCommentsV addSubview:numberOfComments];
    
    return numberOfCommentsV;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return (filteredResults.count > 0)?41:0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)cancelPressed:(id)sender {
    
   // [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.searchTextField resignFirstResponder];
    self.searchTextField.text = @"";
    
//    [UIView animateWithDuration:0.7f
//                     animations:^
//     {
//         self.topV.frame = CGRectMake(0, -self.topV.frame.size.height, self.topV.frame.size.width, self.topV.frame.size.height);
//         self.tableV.alpha = 0.0;
//     }
//                     completion:^(BOOL finished)
//     {
//         [self.parentViewController.navigationController setNavigationBarHidden:NO animated:YES];
//         [self removeFromParentViewController];
//         [self.view removeFromSuperview];
//     }
//     ];
}

- (IBAction)releaseSearch:(id)sender {
    [self cancelPressed:nil];
}

+(void)showInVC:(UIViewController *)vc{
    
    SearchVC *sVC = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"SearchVC"];
    [vc.view addSubview:sVC.view];
    [vc addChildViewController:sVC];
    
    sVC.topV.frame = CGRectMake(0, -sVC.topV.frame.size.height, 320, sVC.topV.frame.size.height);
    sVC.tableV.alpha = 0;

    [vc.navigationController setNavigationBarHidden:YES animated:YES];
    
    [UIView animateWithDuration:0.7f
                     animations:^
     {
         sVC.topV.frame = CGRectMake(0, 0, sVC.topV.frame.size.width, sVC.topV.frame.size.height);
          sVC.tableV.alpha = 1;
     }
                     completion:^(BOOL finished)
     {
         [sVC.searchTextField becomeFirstResponder];
     }
     ];
}

@end
