//
//  HomeVC.m
//  Beeeper
//
//  Created by User on 2/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "HomeVC.h"


@interface HomeVC ()

@end

@implementation HomeVC

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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(beeepPosted) name:@"Beeeped" object:nil];
}

-(void)beeepPosted{
    [TSMessage setDefaultViewController:self.navigationController.viewControllers[0]];
    [TSMessage showNotificationWithTitle:@"Successfully Beeeped" type:TSMessageNotificationTypeSuccess duration:3];
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
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)showMenu:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Menu-Show" object:nil];
}

- (IBAction)showComments:(UIButton *)sender {
    CGPoint location = [sender.superview convertPoint:sender.center toView:self.tableV];
    NSIndexPath *indexPath = [self.tableV indexPathForRowAtPoint:location];
    
    [self performSegueWithIdentifier:@"comments" sender:self];
}


@end
