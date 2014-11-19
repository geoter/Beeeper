//
//  SuggestBeeepVC.m
//  Beeeper
//
//  Created by User on 3/27/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "SuggestBeeepVC.h"
#import "BPSuggestions.h"


@interface SuggestBeeepVC ()
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *blurredImg = [[DTO sharedDTO]convertViewToBlurredImage:self.superviewToBlur withRadius:2];
    self.blurredImageV.image = blurredImg;
    
    self.blurContainerV.alpha = 0;
    
    [self adjustFonts];
    
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
}

-(void)getFollowers{
    
    static int failsCount = 0;
    
    [[BPUser sharedBP]getFollowersForUser:[[BPUser sharedBP].user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
        
        if (completed) {
            
            if ([objs isKindOfClass:[NSArray class]]) {
               
                @try {
                    people = [NSMutableArray arrayWithArray:objs];
                    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name"  ascending:YES];
                    people = [NSMutableArray arrayWithArray:[people sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]];
                    filteredPeople = people;
                   
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.tableV reloadData];
                    
                        self.noBeeepersFoundLbl.text = @"No Followers found";
                        
                        if (objs.count == 0) {
                            self.noBeeepersFoundLbl.hidden = NO;
                        }
                        else{
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
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"getFollowersForUser not Completed" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];

                 });
            }
        }
    }];
}

-(void)adjustFonts{
    UILabel *lbl = (id)[self.containerV viewWithTag:1];
    lbl.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];

    lbl = (id)[self.containerV viewWithTag:2];
    lbl.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
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

- (IBAction)sendPressed:(id)sender {
    
    @try {
        NSMutableArray *users_ids = [NSMutableArray array];
        
        for (NSDictionary *user in selectedPeople) {
            [users_ids addObject:[user objectForKey:@"id"]];
        }
        
        [[BPSuggestions sharedBP]suggestEvent:self.fingerprint toUsers:users_ids withCompletionBlock:^(BOOL completed,NSArray *objs){
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
        
        [UIView animateWithDuration:0.3f
                         animations:^
         {
             self.blurContainerV.alpha = 0;
         }
                         completion:^(BOOL finished)
         {
             
             [UIView animateWithDuration:0.7f
                              animations:^
              {
                  self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
                  self.containerV.frame = CGRectMake(0, self.view.frame.size.height+self.containerV.frame.size.height, self.containerV.frame.size.width+30, self.containerV.frame.size.height);
              }
                              completion:^(BOOL finished)
              {
                  [self removeFromParentViewController];
                  [self.view removeFromSuperview];
              }
              ];
             
         }];
    }
    else{
        [UIView animateWithDuration:0.7f
                         animations:^
         {
             self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
             self.containerV.frame = CGRectMake(0, self.view.frame.size.height+self.containerV.frame.size.height, self.containerV.frame.size.width+30, self.containerV.frame.size.height);
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
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIImageView *userImage = (id)[cell viewWithTag:1];
    UILabel *nameLbl = (id)[cell viewWithTag:2];
    UIImageView *tickedV = (id)[cell viewWithTag:3];
    
    NSDictionary *user = [filteredPeople objectAtIndex:indexPath.row];
    
    nameLbl.text = [[NSString stringWithFormat:@"%@ %@",[user objectForKey:@"name"],[user objectForKey:@"lastname"]] capitalizedString];
    

    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *imagePath = [user objectForKey:@"image_path"];
   
    @try {
    
        [userImage sd_setImageWithURL:[NSURL URLWithString:[[DTO sharedDTO] fixLink:imagePath]]
                     placeholderImage:[UIImage imageNamed:@"user_icon_180x180"]];
    
    }
    @catch (NSException *exception) {
    
    }
    @finally {
    
    }
    //NSString *extension = [[imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
    
    
    if ([self isSelected:user]) {
        [tickedV setImage:[UIImage imageNamed:@"suggest_selected"]];
    }
    else{
        [tickedV setImage:[UIImage imageNamed:@"suggest_unselected"]];
    }

    
    return cell;
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

@end
