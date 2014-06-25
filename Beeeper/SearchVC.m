//
//  SearchVC.m
//  Beeeper
//
//  Created by User on 4/2/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "SearchVC.h"
#import "EventWS.h"

@interface SearchVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    NSArray *filteredResults;
    NSArray *suggestionValues;
}
@end

@implementation SearchVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self resetSearch];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)resetSearch{
    
    suggestionValues = [NSArray arrayWithObjects:@"popular",@"sports",@"cinema",@"music",@"TV",@"nightlife",@"radio",@"deals", nil];
    
    filteredResults = suggestionValues;
    
    UIView *numberOfCommentsV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableV.frame.size.width, 41)];
    numberOfCommentsV.backgroundColor = [UIColor clearColor];
    
    UILabel *numberOfComments = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, self.tableV.frame.size.width, 40)];
    numberOfComments.text = [NSString stringWithFormat:@"SUGGESTIONS"];
    numberOfComments.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    numberOfComments.textAlignment = NSTextAlignmentLeft;
    [numberOfCommentsV addSubview:numberOfComments];
    
    self.tableV.tableHeaderView = numberOfCommentsV;

    [self.tableV reloadData];
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
    
    if ([[filteredResults firstObject]isEqualToString:@"No results found"]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        searchResultLabel.text = [filteredResults firstObject];
    }
    else{
         searchResultLabel.text = [NSString stringWithFormat:@"#%@",[filteredResults objectAtIndex:indexPath.row]];
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    [self resetSearch];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * searchStr = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if (searchStr.length < 2) {
        if (searchStr.length == 0) {
            [self resetSearch];
        }
        return YES;
    }
    
    [[EventWS sharedBP]searchKeyword:searchStr WithCompletionBlock:^(BOOL completed,NSArray *keywords){
        if (completed) {
        
            UIView *numberOfCommentsV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableV.frame.size.width, 41)];
            numberOfCommentsV.backgroundColor = [UIColor clearColor];
            
            UILabel *numberOfComments = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, self.tableV.frame.size.width, 40)];
            numberOfComments.text = [NSString stringWithFormat:@"SEARCH"];
            numberOfComments.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
            numberOfComments.textAlignment = NSTextAlignmentLeft;
            [numberOfCommentsV addSubview:numberOfComments];
            
            self.tableV.tableHeaderView = numberOfCommentsV;
            
            filteredResults = keywords;

        }
        else{
            filteredResults = [NSArray array];
        }
        
        if (filteredResults.count == 0) {
            self.tapG.enabled = YES;
            filteredResults = [NSArray arrayWithObject:@"No results found"];
        }
        else{
            self.tapG.enabled = NO;
        }

         [self.tableV reloadData];
    
    }];
    
//    NSPredicate *predicate =
//    [NSPredicate predicateWithFormat:@"self CONTAINS[cd] %@", searchStr];
//    filteredResults  = [searchResults filteredArrayUsingPredicate:predicate];
//    
    
    return YES;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *tag = [filteredResults objectAtIndex:indexPath.row];
    [[EventWS sharedBP]searchEvent:tag WithCompletionBlock:^(BOOL completed,NSArray *events){
        if (completed) {
            NSLog(@"EVENTS");
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No events found" message:@"Please search for another keyword." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
    }];
}


- (IBAction)releaseSearch:(id)sender {
    [self.searchTextField resignFirstResponder];
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
