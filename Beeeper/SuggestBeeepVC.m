//
//  SuggestBeeepVC.m
//  Beeeper
//
//  Created by User on 3/27/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "SuggestBeeepVC.h"
#import "BPSuggestions.h"
#import "FindFriendsVC.h"
#import "BeeepedBy.h"

@interface SuggestBeeepVC ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *people;
    NSMutableDictionary *pendingImagesDict;
    NSArray *filteredPeople;
    NSMutableArray *rowsToReload;
}
@end

@implementation SuggestBeeepVC
@synthesize selectedPeople;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIImage *blurredImg = [[DTO sharedDTO]convertViewToBlurredImage:self.superviewToBlur withRadius:7];
    self.blurredImageV.image = blurredImg;
    
    self.blurContainerV.alpha = 0;
    
   // [self adjustFonts];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    rowsToReload = [NSMutableArray array];
    
    if(selectedPeople == nil){
        selectedPeople = [NSMutableArray array];
    }
    
    pendingImagesDict = [NSMutableDictionary dictionary];
    
    UIColor *color = [UIColor whiteColor];
    self.searchTxtF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search by name" attributes:@{NSForegroundColorAttributeName: color}];
    
    [self getFollowers];

    if (self.sendNotificationWhenFinished) {
        [self.topRightButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.topRightButton removeTarget:self action:@selector(sendPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.topRightButton addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 0, 60)];
    [self.tableV addSubview:refreshView];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    refreshControl.tag = 234;
    refreshControl.tintColor = [UIColor lightGrayColor];
    [refreshControl addTarget:self action:@selector(getFollowers) forControlEvents:UIControlEventValueChanged];
    [refreshView addSubview:refreshControl];
    
    [self.tableV addSubview:refreshControl];
    self.tableV.alwaysBounceVertical = YES;
}

-(void)getFollowers{
    
    static int failsCount = 0;
    
    [[BPUser sharedBP]getFollowersForUser:[[BPUser sharedBP].user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
        
        UIRefreshControl *refreshControl = (id)[self.tableV viewWithTag:234];
        [refreshControl endRefreshing];
        
        if (completed) {
            
            if ([objs isKindOfClass:[NSArray class]]) {
               
                @try {
                    people = [NSMutableArray arrayWithArray:objs];
                    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name"  ascending:YES];
                    people = [NSMutableArray arrayWithArray:[people sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]];
                    filteredPeople = people;
                   
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.tableV reloadData];
                    

                        self.noBeeepersFoundLbl.text = @"You have no followers yet.\nStart following friends and\ninteract with them.";
                        
                        if (objs.count == 0) {
                            self.findFriendsButton.hidden = NO;
                            self.noBeeepersFoundLbl.hidden = NO;
                        }
                        else{
                            self.findFriendsButton.hidden = YES;
                            self.noBeeepersFoundLbl.hidden = YES;
                        }
                         
                     });
                }
                @catch (NSException *exception) {
        
                }
                @finally {
        
                }
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not load Followers. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                });
            }
         
        }
        else{
            failsCount++;
            if (failsCount < 5) {
                [self getFollowers];
            }
            else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"getFollowersForUser not Completed" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                    [alert show];

                 });
            }
        }
    }];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    textField.text = ([textField.text isEqualToString:@"Search by name"])?@"":textField.text;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField.text.length == 0) {
        textField.text = @"Search by name";
    }
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString * typedStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(typedStr.length == 0){
        filteredPeople = people;
    }
    else{
        filteredPeople = [people filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@) OR (lastname CONTAINS[cd] %@)", typedStr,typedStr]];
    }
    
    
    [self.tableV reloadData];
    
    return YES;
}

- (BOOL) textFieldShouldClear:(UITextField *)textField{

    filteredPeople = people;
    [self.tableV reloadData];

    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closePressed:(id)sender {
    [self hide];
}

- (IBAction)donePressed:(id)sender {
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"Suggest Followers Selected" object:nil userInfo:[NSDictionary dictionaryWithObject:selectedPeople forKey:@"followers"]];
    [self closePressed:nil];
}

- (IBAction)sendPressed:(UIButton *)sender {
    
    if (selectedPeople.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Beeepers selected" message:@"Please select at least on Beeeper user." delegate:selectedPeople cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    @try {
        NSMutableArray *users_ids = [NSMutableArray array];
        
        for (NSDictionary *user in selectedPeople) {
            [users_ids addObject:[user objectForKey:@"id"]];
        }
        
        [sender setUserInteractionEnabled:NO];

        UIActivityIndicatorView *activityInd = [[UIActivityIndicatorView alloc]initWithFrame:sender.bounds];
        activityInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [sender setTitle:@"" forState:UIControlStateNormal];
        [sender addSubview:activityInd];
        [activityInd startAnimating];
        
        [[BPSuggestions sharedBP]suggestEvent:self.fingerprint toUsers:users_ids withCompletionBlock:^(BOOL completed,NSArray *objs){
            
            [activityInd removeFromSuperview];
            [sender setTitle:@"Send" forState:UIControlStateNormal];
            [sender setUserInteractionEnabled:YES];
            
            if (completed) {
                [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                [SVProgressHUD showSuccessWithStatus:@"Suggested!"];
                [self closePressed:nil];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Suggestion failed. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            }
        }];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Exception Error" message:@"Suggestion failed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    @finally {
        
    }
}

- (IBAction)findFriendsPressed:(id)sender {
    
    [self hideWithFindFriends];
    
}

-(void)showInView:(UIView *)v{
    
    self.view.frame = v.bounds;
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.containerV.frame = CGRectMake(0, self.view.frame.size.height+self.containerV.frame.size.height, self.containerV.frame.size.width-30, self.containerV.frame.size.height);
    
    [v addSubview:self.view];
    
    [UIView animateWithDuration:0.7f
                     animations:^
     {
         self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
         self.containerV.frame = CGRectMake(0, self.view.frame.size.height-self.containerV.frame.size.height, self.containerV.frame.size.width+30, self.containerV.frame.size.height);
     }
                     completion:^(BOOL finished)
     {

     }
     ];
}

-(void)hide{
    
    [[UIApplication sharedApplication] setStatusBarHidden:!self.showBlur withAnimation:UIStatusBarAnimationFade];
    
    if (self.showBlur) {
        
        [UIView animateWithDuration:0.6f
                         animations:^
         {
             self.blurContainerV.alpha = 0;
             self.containerV.frame = CGRectMake(self.containerV.frame.origin.x, self.view.frame.size.height+self.containerV.frame.size.height, self.containerV.frame.size.width+30, self.containerV.frame.size.height);
             self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
         }
                         completion:^(BOOL finished)
         {
             
             [self removeFromParentViewController];
             [self.view removeFromSuperview];
             
         }];
    }
    else{
        [UIView animateWithDuration:0.7f
                         animations:^
         {
             self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
             self.containerV.frame = CGRectMake(self.containerV.frame.origin.x, self.view.frame.size.height+self.containerV.frame.size.height, self.containerV.frame.size.width+30, self.containerV.frame.size.height);
         }
                         completion:^(BOOL finished)
         {
             [self removeFromParentViewController];
             [self.view removeFromSuperview];
         }
         ];
    }
    
   // [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)hideWithFindFriends{
    
    [[UIApplication sharedApplication] setStatusBarHidden:!self.showBlur withAnimation:UIStatusBarAnimationFade];
    
    if (self.showBlur) {
        
        [UIView animateWithDuration:0.6f
                         animations:^
         {
             self.blurContainerV.alpha = 0;
             self.containerV.frame = CGRectMake(self.containerV.frame.origin.x, self.view.frame.size.height+self.containerV.frame.size.height, self.containerV.frame.size.width+30, self.containerV.frame.size.height);
             self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
         }
                         completion:^(BOOL finished)
         {
             FindFriendsVC *viewController = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"FindFriendsVC"];
             [self.navigationController pushViewController:viewController animated:YES];
             
             [self removeFromParentViewController];
             [self.view removeFromSuperview];
             
         }];
    }
    else{
        [UIView animateWithDuration:0.7f
                         animations:^
         {
             self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
             self.containerV.frame = CGRectMake(self.containerV.frame.origin.x, self.view.frame.size.height+self.containerV.frame.size.height, self.containerV.frame.size.width+30, self.containerV.frame.size.height);
         }
                         completion:^(BOOL finished)
         {
             
             FindFriendsVC *viewController = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"FindFriendsVC"];
             viewController.hideNavigationBarOnClose = YES;
             [self.navigationController pushViewController:viewController animated:YES];
             
             [self removeFromParentViewController];
             [self.view removeFromSuperview];
             
         }
         ];
    }
    
    // [self dismissViewControllerAnimated:YES completion:NULL];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return filteredPeople.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *user = [filteredPeople objectAtIndex:indexPath.row];
    
    NSString *CellIdentifier;
    
    if ([self isBeeeper:user]) {
        CellIdentifier = @"CellBeeeped";
    }
    else{
        CellIdentifier = @"Cell";
    }
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UIImageView *userImage = (id)[cell viewWithTag:1];
    UILabel *nameLbl = (id)[cell viewWithTag:2];
    UIImageView *tickedV = (id)[cell viewWithTag:3];

    
    if ([self isBeeeper:user]) {
        cell.contentView.alpha = 0.5;
        cell.userInteractionEnabled = NO;
    }
    else{
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha = 1;
    }
    
    nameLbl.text = [[NSString stringWithFormat:@"%@ %@",[user objectForKey:@"name"],[user objectForKey:@"lastname"]] capitalizedString];
    

    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *imagePath = [user objectForKey:@"image_path"];
   
    [userImage setImage:[UIImage imageNamed:@"user_icon_180x180"]];
    
    @try {
    
        [userImage sd_setImageWithURL:[NSURL URLWithString:[[DTO sharedDTO] fixLink:imagePath]]
                     placeholderImage:[UIImage imageNamed:@"user_icon_180x180"]];
    
    }
    @catch (NSException *exception) {
    
    }
    @finally {
    
    }
    //NSString *extension = [[imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
    
    if ([self isBeeeper:user]) {
            [tickedV setImage:[UIImage imageNamed:@"suggest_selected_gray"]];
    }
    else{
        if ([self isSelected:user]) {
            [tickedV setImage:[UIImage imageNamed:@"suggest_selected"]];
        }
        else{
            [tickedV setImage:[UIImage imageNamed:@"suggest_unselected"]];
        }
    }

    
    return cell;
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 40;
}

-(BOOL)isSelected:(NSDictionary *)dict{
    
    NSString *user_id = [dict objectForKey:@"id"];
    NSArray *ids = [selectedPeople valueForKey:@"id"];
    
    for (NSString *u_id in ids) {
        if ([u_id isEqualToString:user_id]) {
            return YES;
        }
    }
    
    return NO;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *tickedV = (id)[cell viewWithTag:3];

    NSDictionary *user = [filteredPeople objectAtIndex:indexPath.row];
    
    if (![self isSelected:user]) {
        [selectedPeople addObject:user];
        tickedV.alpha = 0;
        tickedV.hidden = NO;
 
        [UIView animateWithDuration:0.0f
                     animations:^
     {
         tickedV.alpha = 0;
     }
                     completion:^(BOOL finished)
     {
         [tickedV setImage:[UIImage imageNamed:@"suggest_selected"]];
         
         [UIView animateWithDuration:0.0f
                          animations:^
          {
              tickedV.alpha = 1;
          }
                          completion:^(BOOL finished)
          {
          }
          ];
     }
     ];
        
    }
    else{
        [selectedPeople removeObject:user];
        
        [UIView animateWithDuration:0.0f
                         animations:^
         {
             tickedV.alpha = 0;
         }
                         completion:^(BOOL finished)
         {
             [tickedV setImage:[UIImage imageNamed:@"suggest_unselected"]];
            
             [UIView animateWithDuration:0.0f
                              animations:^
              {
                  tickedV.alpha = 1;
              }
                              completion:^(BOOL finished)
              {
                  
              }
              ];

         }
         ];

    }
}

-(void)manageUser:(NSDictionary *)dict{
    
}

-(BOOL)isBeeeper:(NSDictionary *)user{
    
    for (id userO in self.beeepers) {
        
        if ([userO isKindOfClass:[NSDictionary class]]) {
            
            if ([[user objectForKey:@"id"] isEqualToString:[userO objectForKey:@"id"]]) {
                return YES;
            }
        }
        else if ([userO isKindOfClass:[BeeepedBy class]]){
            if ([[user objectForKey:@"id"] isEqualToString:[(BeeepedBy *)userO beeepedByIdentifier]]) {
                return YES;
            }
        }
        else{ //nsstring
            
            NSString *userStr = (NSString *)userO;
            
            if ([userStr isEqualToString:[user objectForKey:@"id"]]) {
                return YES;
            }
        }
        
        
    }
    
    return NO;
}

@end
