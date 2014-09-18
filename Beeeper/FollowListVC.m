//
//  FollowListVC.m
//  Beeeper
//
//  Created by User on 2/21/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "FollowListVC.h"
#import "TimelineVC.h"
#import "MONActivityIndicatorView.h"

@interface FollowListVC ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,MONActivityIndicatorViewDelegate>
{
    NSIndexPath *actionSheetIndexPath;
    NSMutableArray *people;
    NSMutableDictionary *pendingImagesDict;
    NSMutableArray *following; //used for finding which users are followed by our user
    NSMutableArray *rowsToReload;
}
@end

@implementation FollowListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.mode == 1) {
        self.title = @"Followers";
    }
    else if (self.mode == 2){
        self.title = @"Following";
    }
    else if (self.mode == 3){
        self.title = @"Likes";
    }
    else if (self.mode == 4){
        self.title = @"Beeepers";
    }
    
    self.tableV.decelerationRate = 0.6;

    pendingImagesDict = [NSMutableDictionary dictionary];
    rowsToReload = [NSMutableArray array];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [self showLoading];
    
     if (self.mode == FollowersMode) {
         
        [[BPUser sharedBP]getFollowersForUser:[self.user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
            
            if (completed) {
                 people = [NSMutableArray arrayWithArray:objs];
                
                for (NSDictionary *user in people) {
                    NSArray *keys = user.allKeys;
                    NSString *imagePath = [user objectForKey:@"image_path"];
                    [[DTO sharedDTO]downloadImageFromURL:imagePath];
                }
                
                [self updateUsersCount];
                
                NSMutableArray *true_following = [NSMutableArray array];
                
                if (following != nil) {
                    for (NSDictionary *user in people) {
                        for (NSDictionary *following_user in following) {
                            if ([[user objectForKey:@"id"] isEqualToString:[following_user objectForKey:@"id"]]) {
                                [true_following addObject:user];
                            }
                        }
                    }
                    following = true_following;
                    [self.tableV reloadData];
                    [self hideLoading];
                }
            }
        }];
         
         //to get which of the followers is our user following
         
         [[BPUser sharedBP]getFollowingForUser:[[BPUser sharedBP].user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
             
             if (completed) {
                 following = [NSMutableArray arrayWithArray:objs];
                 
                 NSMutableArray *true_following = [NSMutableArray array];
                 
                 if (people != nil) {
                     for (NSDictionary *user in people) {
                         for (NSDictionary *following_user in following) {
                             if ([[user objectForKey:@"id"] isEqualToString:[following_user objectForKey:@"id"]]) {
                                 [true_following addObject:user];
                             }
                         }
                     }
                     
                     following = true_following;
                     
                     [self.tableV reloadData];
                     [self hideLoading];
                 }
             }
         }];
     }
     else if (self.mode == FollowingMode){
         [[BPUser sharedBP]getFollowingForUser:[self.user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
             
             if (completed) {
                 people = [NSMutableArray arrayWithArray:objs];
                 following = [NSMutableArray arrayWithArray:people];
                 
                 for (NSDictionary *user in people) {
                     [[DTO sharedDTO]downloadImageFromURL:[user objectForKey:@"image_path"]];
                 }
                 
                 [self updateUsersCount];
                 [self.tableV reloadData];
                 [self hideLoading];
             }
         }];

     }
     else{
         
         if (self.ids.count == 0) {
             [self updateUsersCount]; //No users label show
             [self hideLoading];
             return;
         }
         
         following = nil; //just to be sure
         
         [[BPUsersLookup sharedBP]usersLookup:self.ids completionBlock:^(BOOL completed,NSArray *objs){
             if (completed) {
                 people = [NSMutableArray arrayWithArray:objs];
                 
                 for (NSDictionary *user in people) {
                     [[DTO sharedDTO]downloadImageFromURL:[user objectForKey:@"image_path"]];
                 }
                 
                 [self updateUsersCount];
                 
                 NSMutableArray *true_following = [NSMutableArray array];
                 
                 if (following != nil) {
                     for (NSDictionary *user in people) {
                         for (NSDictionary *following_user in following) {
                             if ([[user objectForKey:@"id"] isEqualToString:[following_user objectForKey:@"id"]]) {
                                 [true_following addObject:user];
                             }
                         }
                     }
                     
                     following = true_following;
                     [self.tableV reloadData];
                     [self hideLoading];
                 }
             }
         }];
         
         //to get which of the people is our user following
         
         [[BPUser sharedBP]getFollowingForUser:[self.user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
             
             if (completed) {
                 following = [NSMutableArray arrayWithArray:objs];
                 
                 NSMutableArray *true_following = [NSMutableArray array];
                 
                 if (people != nil) {
                     for (NSDictionary *user in people) {
                         for (NSDictionary *following_user in following) {
                             if ([[user objectForKey:@"id"] isEqualToString:[following_user objectForKey:@"id"]]) {
                                 [true_following addObject:user];
                             }
                         }
                     }
                     
                     following = true_following;
                     [self.tableV reloadData];
                     [self hideLoading];
                 }
             }
         }];
     }

}

-(void)updateUsersCount{
    
    if (people.count == 0) {
        self.nousersLabel.hidden= NO;
    }
    else{
        self.nousersLabel.hidden = YES;
    }
    
    UILabel *numberLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    numberLbl.textAlignment = NSTextAlignmentRight;
    numberLbl.text = [NSString stringWithFormat:@"%d",people.count];
    numberLbl.textColor = [UIColor whiteColor];
    numberLbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:numberLbl];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideTabbar" object:self];
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
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
    return (people)?people.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    ((UILabel *)[cell viewWithTag:2]).font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    
    UIButton *btn = (id)[cell viewWithTag:3];
    UILabel *nameLbl = (id)[cell viewWithTag:2];
    UIImageView *userImage = (id)[cell viewWithTag:1];
    userImage.layer.cornerRadius = 1;
    userImage.layer.masksToBounds = YES;

    NSDictionary *user = [people objectAtIndex:indexPath.row];
    
    nameLbl.text = [[NSString stringWithFormat:@"%@ %@",[user objectForKey:@"name"],[user objectForKey:@"lastname"]] capitalizedString];
    
    
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *imagePath = [user objectForKey:@"image_path"];
    
   // NSString *extension = [[imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
    @try {
       
        NSString *imageName = [NSString stringWithFormat:@"%@",[imagePath MD5]];
        
        NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
        
        if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
            userImage.backgroundColor = [UIColor clearColor];
            userImage.image = nil;
            UIImage *img = [UIImage imageWithContentsOfFile:localPath];
            userImage.image = img;
        }
        else{
            userImage.image = [UIImage imageNamed:@"user_icon_180x180"];
            [pendingImagesDict setObject:indexPath forKey:imageName];
            
            //NSString *extension = [[imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
            
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(imageDownloadFinished:) name:imageName object:nil];
            
            
        }
    
    }
    @catch (NSException *exception) {
       
        userImage.image = [UIImage imageNamed:@"user_icon_180x180"];
        
        //NSString *extension = [[imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];

    }
    @finally {
        
    }
    if ([[user objectForKey:@"id"]isEqualToString:[[BPUser sharedBP].user objectForKey:@"id"]]) {
        btn.hidden = YES;
    }
    else{
    
        btn.hidden = NO;
        
        if ([following indexOfObject:user] != NSNotFound) {
            [btn setImage:[UIImage imageNamed:@"following-icon.png"] forState:UIControlStateNormal] ;
        }
        else{
            [btn setImage:[UIImage imageNamed:@"not-following-icon.png"] forState:UIControlStateNormal] ;
        }

    }
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TimelineVC *timelineVC = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"TimelineVC"];
    timelineVC.mode = Timeline_Not_Following;
    timelineVC.showBackButton = YES; //in case of My_Timeline
    NSDictionary *user = [people objectAtIndex:indexPath.row];
    timelineVC.user = user;
    
    [self.navigationController pushViewController:timelineVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}


-(void)imageDownloadFinished:(NSNotification *)notif{
    
    NSString *imageName  = [notif.userInfo objectForKey:@"imageName"];
    
    NSArray* rows = [NSArray arrayWithObjects:[pendingImagesDict objectForKey:imageName], nil];
    
    [rowsToReload addObjectsFromArray:rows];
    
    [pendingImagesDict removeObjectForKey:imageName];
    
    if (rowsToReload.count == 4 || pendingImagesDict.count < 4) {
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

- (IBAction)rightButtonPressed:(UIButton *)sender {
   
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview.superview;
    NSIndexPath *path = [self.tableV indexPathForCell:cell];
    
    NSDictionary *user = [people objectAtIndex:path.row];

    if ([following indexOfObject:user] != NSNotFound) {
        
        NSString *username = [[NSString stringWithFormat:@"%@ %@",[user objectForKey:@"name"],[user objectForKey:@"lastname"]] capitalizedString];
        
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:username delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Unfollow" otherButtonTitles:nil];
        [popup showInView:self.view];
        actionSheetIndexPath = path;
    }
    else{
        
      //follow user
        [[BPUser sharedBP]follow:[user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
            if (completed) {
                
                [following addObject:user];
                
                NSArray* rowsToReload = [NSArray arrayWithObjects:path, nil];
                
                [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
                
                [self updateUsersCount];
            }
        }];

    }
}



-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
   
    if (buttonIndex != actionSheet.cancelButtonIndex) {

       
         NSDictionary *user = [people objectAtIndex:actionSheetIndexPath.row];
        
        [[BPUser sharedBP]unfollow:[user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
            if (completed) {
                
                [following removeObject:user];
                
                NSArray* rowsToReload = [NSArray arrayWithObjects:actionSheetIndexPath, nil];
                
                [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
                
                [self updateUsersCount];
            }
            
            actionSheetIndexPath = nil;
        }];
    
    }
}

#pragma mark - MONActivityIndicatorView

-(void)showLoading{
    
    self.tableV.alpha = 0;

    UIView *loadingBGV = [[UIView alloc]initWithFrame:self.view.bounds];
    loadingBGV.backgroundColor = self.view.backgroundColor;
    
    MONActivityIndicatorView *indicatorView = [[MONActivityIndicatorView alloc] init];
    indicatorView.delegate = self;
    indicatorView.numberOfCircles = 3;
    indicatorView.radius = 8;
    indicatorView.internalSpacing = 1;
    indicatorView.center = self.view.center;
    indicatorView.tag = -565;
    
    [loadingBGV addSubview:indicatorView];
    loadingBGV.tag = -434;
    [self.view addSubview:loadingBGV];
    [self.view bringSubviewToFront:loadingBGV];
    
    [indicatorView startAnimating];

}

-(void)hideLoading{
    dispatch_async(dispatch_get_main_queue(), ^{
       
   
        UIView *loadingBGV = (id)[self.view viewWithTag:-434];
        MONActivityIndicatorView *indicatorView = (id)[loadingBGV viewWithTag:-565];
        [indicatorView stopAnimating];
        
        [UIView animateWithDuration:0.3f
                         animations:^
         {
             loadingBGV.alpha = 0;
             self.tableV.alpha = 1;
         }
                         completion:^(BOOL finished)
         {
             [loadingBGV removeFromSuperview];
            
         }
         ];
        
        });
}


#pragma mark - MONActivityIndicatorViewDelegate Methods

- (UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index {
    
    CGFloat red   = 250/255.0;
    CGFloat green = 217/255.0;
    CGFloat blue  = 0/255.0;
    CGFloat alpha = 1.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end
