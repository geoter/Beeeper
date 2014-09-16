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
    NSMutableArray *selectedPeople;
    NSArray *filteredPeople;
    NSMutableArray *rowsToReload;
}
@end

@implementation SuggestBeeepVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self adjustFonts];
    
    rowsToReload = [NSMutableArray array];
    selectedPeople = [NSMutableArray array];
    pendingImagesDict = [NSMutableDictionary dictionary];
    
    UIColor *color = [UIColor lightTextColor];
    self.searchTxtF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search by name" attributes:@{NSForegroundColorAttributeName: color}];
    
    [self getFollowers];

}

-(void)getFollowers{
    
    static int failsCount = 0;
    
    [[BPUser sharedBP]getFollowersForUser:[[BPUser sharedBP].user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
        
        if (objs == 0) {
            self.noBeeepersFoundLbl.hidden = NO;
        }
        else{
            self.noBeeepersFoundLbl.hidden = YES;
        }
        if (completed) {
            people = [NSMutableArray arrayWithArray:objs];
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"name"  ascending:YES];
            people = [NSMutableArray arrayWithArray:[people sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]];
            filteredPeople = people;
            [self.tableV reloadData];
        }
        else{
            failsCount++;
            if (failsCount < 5) {
                [self getFollowers];
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
    
    /*[UIView animateWithDuration:0.7f
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
     ];*/
    [self dismissViewControllerAnimated:YES completion:NULL];
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
    
    //NSString *extension = [[imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
    
    NSString *imageName = [NSString stringWithFormat:@"%@",[imagePath MD5]];
    
    NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
        userImage.backgroundColor = [UIColor clearColor];
        userImage.image = nil;
        UIImage *img = [UIImage imageWithContentsOfFile:localPath];
        userImage.image = img;
    }
    else{
        userImage.image = nil;
        [pendingImagesDict setObject:indexPath forKey:imageName];
        
      //  NSString *extension = [[imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        
        NSString *imageName = [NSString stringWithFormat:@"%@",[imagePath MD5]];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(imageDownloadFinished:) name:imageName object:nil];
    }
    
    if ([selectedPeople indexOfObject:user] != NSNotFound) {
        [tickedV setImage:[UIImage imageNamed:@"suggest_selected"]];
    }
    else{
        [tickedV setImage:[UIImage imageNamed:@"suggest_unselected"]];
    }

    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *tickedV = (id)[cell viewWithTag:3];

    NSDictionary *user = [filteredPeople objectAtIndex:indexPath.row];

    if ([selectedPeople indexOfObject:user] == NSNotFound) {
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

-(void)imageDownloadFinished:(NSNotification *)notif{
    
    NSString *imageName  = [notif.userInfo objectForKey:@"imageName"];
    
    NSArray* rows = [NSArray arrayWithObjects:[pendingImagesDict objectForKey:imageName], nil];
    
    [rowsToReload addObjectsFromArray:rows];
    [pendingImagesDict removeObjectForKey:imageName];
    
    if (rowsToReload.count == 5  || pendingImagesDict.count < 5) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            @try {
                [self.tableV reloadData];
                [rowsToReload removeAllObjects];
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        });
        
    }
    
    
}


@end
