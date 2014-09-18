//
//  TimelineVC.m
//  Beeeper
//
//  Created by User on 3/27/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "TimelineVC.h"
#import "EventVC.h"
#import "BeeepItVC.h"
#import "FollowListVC.h"
#import "Timeline_Object.h"
#import "CommentsVC.h"
#import <QuartzCore/QuartzCore.h>
#import "GTSegmentedControl.h"
#import <FacebookSDK/FacebookSDK.h>
#import "GHContextMenuView.h"
#import "SuggestBeeepVC.h"
#import "EventWS.h"
#import "Event_Show_Object.h"
#import "BPSuggestions.h"
#import "Reachability.h"

@interface UILabel (Resize)
- (void)sizeToFitHeight;
@end

//  UILabel+Resize.m
@implementation UILabel (Resize)
- (void)sizeToFitHeight {
    CGSize size = [self sizeThatFits:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)];
    CGRect frame = self.frame;
    frame.size.height = size.height;
    self.frame = frame;
}
@end

@interface TimelineVC ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,GTSegmentedControlDelegate,MONActivityIndicatorViewDelegate,GHContextOverlayViewDataSource,GHContextOverlayViewDelegate>
{
    NSMutableArray *beeeps;
    NSMutableDictionary *pendingImagesDict;
    int followers;
    int following;
    BOOL isFollowing;
    int segmentIndex;
    BOOL loading;
    BOOL loadNextPage;
  //  NSMutableArray *sections;
  //  NSMutableDictionary *suggestionsPerSection;
        NSMutableArray *rowsToReload;
}
@end

@implementation TimelineVC
@synthesize mode,user;

-(void)nextPage{
    
    if (!loadNextPage) {
        return;
    }
    
    loadNextPage = NO;
    
    [[BPTimeline sharedBP]nextPageTimelineForUserID:[self.user objectForKey:@"id"] option:segmentIndex WithCompletionBlock:^(BOOL completed,NSArray *objs){
        
        UIRefreshControl *refreshControl = (id)[self.tableV viewWithTag:234];
        [refreshControl endRefreshing];
        
        if (completed) {
            
            if (objs.count != 0) {
                [beeeps addObjectsFromArray:objs];

                if (objs.count == 10) {
                    loadNextPage = YES;
                }

                [self.tableV reloadData];
//                [self groupBeeepsByMonth];
            }
        }
    }];
}

-(void)getTimeline:(NSString *)userID option:(int)option{
    
    
    
    @try {
        
        NSLog(@"Mpike");
        
        [self setUserInfo];
        
        loadNextPage = YES;
        
        if (option != 0 && option != 1) {
            option = segmentIndex;
        }
        
        if (![userID isKindOfClass:[NSString class]]) {
            userID = [self.user objectForKey:@"id"];
        }
        
        NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
        if ([userID isEqualToString:my_id]) {
            self.mode = Timeline_My;
        }
        else{
            
            [[BPUser sharedBP]checkIfFollowing:userID WithCompletionBlock:^(BOOL completed,NSString *following){
                
                if (completed) {
                    if ([[following lowercaseString]rangeOfString:@"false"].location != NSNotFound) {
                        isFollowing = NO;
                        mode = Timeline_Not_Following;
                    }
                    else{
                        isFollowing = YES;
                        mode = Timeline_Following;
                    }
                    
                    [self createMenuButtons:YES];
                }
            }];
            

        }
        

        @try {
            
            [[BPTimeline sharedBP]getTimelineForUserID:userID option:option WithCompletionBlock:^(BOOL completed,NSArray *objs){
                
                UIRefreshControl *refreshControl = (id)[self.tableV viewWithTag:234];
                [refreshControl endRefreshing];
                
                if (completed) {
                    
                    loading = NO;
                    
                    beeeps = [NSMutableArray arrayWithArray:objs];
                    
                    if (beeeps.count == 10) {
                        loadNextPage = YES;
                    }
                    else{
                        loadNextPage = NO;
                    }
                    
                  //  suggestionsPerSection = [NSMutableDictionary dictionary];
                   // sections = [NSMutableArray array];
         
                    [self.tableV reloadData];
                 //   [self groupBeeepsByMonth];
                }
            }];
            
        }
        @catch (NSException *exception) {
            NSLog(@"ELA!");
        }
        @finally {
            
        }
            
        
        [[BPUser sharedBP]getFollowersForUser:[self.user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
            
            if (completed) {
                followers = objs.count;
                UILabel *followersLbl = (id)[self.followersButton viewWithTag:45];
                if (followersLbl != nil) {
                    NSString *mtext = [NSString stringWithFormat:@"%d Followers",followers];
                    followersLbl.text = mtext;
                }
            }
        }];
        
        [[BPUser sharedBP]getFollowingForUser:[self.user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
            
            if (completed) {
                following = objs.count;
                UILabel *followingLbl = (id)[self.followingButton viewWithTag:45];
                if (followingLbl != nil) {
                    NSString *mtext = [NSString stringWithFormat:@"%d Following",following];
                    followingLbl.text = mtext;
                }
                
            }
        }];

    }
    @catch (NSException *exception) {
        NSLog(@"ELAKI!");
    }
    @finally {
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    GHContextMenuView* overlay = [[GHContextMenuView alloc] init];
    overlay.dataSource = self;
    overlay.delegate = self;
    
	// Do any additional setup after loading the view.
    //    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    UILongPressGestureRecognizer* _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:overlay action:@selector(longPressDetected:)];
    [self.tableV addGestureRecognizer:_longPressRecognizer];
    
    loading = YES;
    
    if (user == nil) {
         user = [BPUser sharedBP].user;
    }
    
    rowsToReload = [NSMutableArray array];

    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 0, 60)];
    [self.tableV addSubview:refreshView];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    refreshControl.tag = 234;
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(getTimeline:option:) forControlEvents:UIControlEventValueChanged];
    [refreshView addSubview:refreshControl];

    [self.tableV addSubview:refreshControl];
    self.tableV.alwaysBounceVertical = YES;
    
    @try {
        
        
        [[BPTimeline sharedBP]getLocalTimelineUserID:[self.user objectForKey:@"id"] option:Upcoming WithCompletionBlock:^(BOOL completed,NSArray *objs){
            if (completed) {
                beeeps = [NSMutableArray arrayWithArray:objs];
                
                if (beeeps.count > 0) {
                    loading = NO;
                }
                
               // suggestionsPerSection = [NSMutableDictionary dictionary];
               // sections = [NSMutableArray array];
                
                [self.tableV reloadData];
                
//                [self groupBeeepsByMonth];
                
            }
        }];
        
        [[BPUser sharedBP]getLocalFollowersForUser:[self.user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
        
            if (completed) {
                followers = objs.count;
                UILabel *followersLbl = (id)[self.followersButton viewWithTag:45];
                if (followersLbl != nil) {
                    NSString *mtext = [NSString stringWithFormat:@"%d Followers",followers];
                    followersLbl.text = mtext;
                }
            }
        }];
        
        [[BPUser sharedBP]getLocalFollowingForUser:[self.user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
            
            if (completed) {
                following = objs.count;
                UILabel *followingLbl = (id)[self.followingButton viewWithTag:45];
                if (followingLbl != nil) {
                    NSString *mtext = [NSString stringWithFormat:@"%d Following",following];
                    followingLbl.text = mtext;
                }
                
            }
        }];
        
        //Follow + /Following button
        
        [[BPUser sharedBP]getLocalFollowingForUser:[[BPUser sharedBP].user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
            
            if (completed) {
                for (NSDictionary *user in objs) {
                    if ([[user objectForKey:@"id"] isEqualToString:[self.user objectForKey:@"id"]]) {
                        self.mode = Timeline_Following;
                    }
                }
            }
        }];
        
    }
    @catch (NSException *exception) {
        NSLog(@"ELA!");
    }
    @finally {
        
    }
    
    [self getTimeline:[self.user objectForKey:@"id"] option:Upcoming];
    
    self.tableV.decelerationRate = 0.6;
    
    pendingImagesDict = [NSMutableDictionary dictionary];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    
    if (self.mode != Timeline_My || self.showBackButton) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
        self.navigationItem.leftBarButtonItem = leftItem;
        
        self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
        [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
        self.backBtn.hidden = NO;
    }
    else{
        self.settingsIcon.hidden = NO;
//        self.importIcon.hidden = NO;
    }
    
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleBordered target:self action:@selector(showMenu)];
//    self.navigationItem.leftBarButtonItem = leftItem;
//    
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    self.navigationItem.hidesBackButton = YES;
//    self.navigationController.navigationBar.backItem.title = @"";
//    
//    UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beeeper_logo"]];
//    [self.navigationItem setTitleView:titleView];
//    
//    
//    UIView *commentsIconV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 44, 28)];
//    UIButton *commentsIcon = [UIButton buttonWithType:UIButtonTypeCustom];
//    commentsIcon.frame = commentsIconV.bounds;
//    [commentsIcon addTarget:self action:@selector(showNotifications) forControlEvents:UIControlEventTouchUpInside];
//    [commentsIcon setImage:[UIImage imageNamed:@"notifications_icon"] forState:UIControlStateNormal];
//    [commentsIconV addSubview:commentsIcon];
//    
//    commentsIcon.center = CGPointMake(commentsIconV.center.x+10, commentsIconV.center.y);
//    
//    UIView *badgeV = [[UIView alloc]initWithFrame:CGRectMake(commentsIcon.center.x, commentsIcon.frame.origin.y-5, 15, 15)];
//    badgeV.backgroundColor = [UIColor redColor];
//    // [commentsIconV addSubview:badgeV];
//    
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:commentsIconV];
//    self.navigationItem.rightBarButtonItem = rightItem;

    CALayer * l = [self.profileImageBorderV layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:1.5];
    
    l = [self.profileImage layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:1.5];
    
    [self createMenuButtons:NO];

    self.userCityLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    self.usernameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20];
}

-(void)setUserInfo{
    
    
    [self downloadUserImageIfNecessery];
    
    BOOL mpike;
    
    if ([user objectForKey:@"name"] == nil || [user objectForKey:@"lastname"] == nil) {
        
         mpike = YES;
        
         [self showLoading];
        
        [[BPUsersLookup sharedBP]usersLookup:@[[user objectForKey:@"id"]] completionBlock:^(BOOL completed,NSArray *objs){
            
            [self hideLoading];
            if (completed && objs.count >0) {
                NSDictionary *userDict = [objs firstObject];
                self.user = userDict;
                [self setUserInfo];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No user found" message:@"Something went wrong.Please go back and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            }
        }];
        

    }
    else{
        [self hideLoading];
        self.usernameLabel.text = [[NSString stringWithFormat:@"%@ %@",[user objectForKey:@"name"],[user objectForKey:@"lastname"]] capitalizedString];
        
        if ([user objectForKey:@"city"] == nil) {
          
             mpike = YES;
            
            [[BPUsersLookup sharedBP]usersLookup:@[[user objectForKey:@"id"]] completionBlock:^(BOOL completed,NSArray *objs){
                
                [self hideLoading];
                if (completed && objs.count >0) {
                    NSDictionary *userDict = [objs firstObject];
                    self.user = userDict;
                    [self setUserInfo];
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No user found" message:@"Something went wrong.Please go back and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                }
            }];
        }
        else{
            
            [UIView animateWithDuration:0.3f
                     animations:^
             {
                 self.userCityLabel.alpha = 1;
                 self.pinIcon.alpha = 1;
             }
                     completion:^(BOOL finished)
             {
             }
             ];
            
            self.userCityLabel.text = [user objectForKey:@"city"];
            [self.userCityLabel sizeToFit];
            self.userCityLabel.center = CGPointMake(self.userCityLabel.superview.center.x, self.userCityLabel.center.y);
            self.pinIcon.frame = CGRectMake(self.userCityLabel.frame.origin.x - 13, self.pinIcon.frame.origin.y, self.pinIcon.frame.size.width, self.pinIcon.frame.size.height);
        }
    }
    
    if (!mpike) {
        
        [[BPUsersLookup sharedBP]usersLookup:@[[user objectForKey:@"id"]] completionBlock:^(BOOL completed,NSArray *objs){
            
            [self hideLoading];
            if (completed && objs.count >0) {
                NSDictionary *userDict = [objs firstObject];
                self.user = userDict;
                [self setUserInfo];
            }
        }];
    }
}

-(void)downloadUserImageIfNecessery{

    @try {
        
        NSString *imagePath = [user objectForKey:@"image_path"];
        
       // NSString *extension = [[imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        
        NSString *imageName = [NSString stringWithFormat:@"%@",[imagePath MD5]];
        
        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
//        
//        if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
//            UIImage *img = [UIImage imageWithContentsOfFile:localPath];
//            self.profileImage.image = img;
//        }
//        else{
//
        
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        
        NetworkStatus status = [reachability currentReachabilityStatus];
        
        if(status == NotReachable)
        {
            //No internet
        }
        else if (status == ReachableViaWiFi)
        {
            dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(q, ^{
                /* Fetch the image from the server... */
                NSString *imagePath = [user objectForKey:@"image_path"];
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[DTO sharedDTO]fixLink:imagePath]]];
                UIImage *img = [[UIImage alloc] initWithData:data];
                
                [self saveImage:img withFileName:imageName inDirectory:localPath];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    /* This is the main thread again, where we set the tableView's image to
                     be what we just fetched. */
                    self.profileImage.image = img;
                });
            });
        }
        else if (status == ReachableViaWWAN) 
        {
            //3G
        }
        
       // }
    
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self setUserInfo];
    
    if (self.mode == Timeline_My && !self.showBackButton) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ShowTabbar" object:nil];
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"HideTabbar" object:nil];
    }
    
//    [[BPSuggestions sharedBP]nextSuggestionsWithCompletionBlock:^(BOOL completed,NSArray *objcts){
//        
//        if (completed) {
//            if (objcts>0) {
//               
//            }
//        }
//    }];

    
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)createMenuButtons:(BOOL)animated{
    
    for (UIView *v in self.followButton.subviews) {
        [v removeFromSuperview];
    }
    
    for (UIView *v in self.followersButton.subviews) {
        [v removeFromSuperview];
    }
    
    for (UIView *v in self.followingButton.subviews) {
        [v removeFromSuperview];
    }
    
    UILabel *lbl = [[UILabel alloc]initWithFrame:self.followButton.bounds];
    
    if (self.mode != Timeline_My) {
        for (UIView *v in self.topV.subviews) {
            if (v.tag > 0) {
                v.hidden = YES;
            }
        }
    }
    
    if (self.mode == Timeline_Following){
        
        lbl.userInteractionEnabled = NO;
        lbl.numberOfLines = 0;
        lbl.text = @"Following";
        lbl.backgroundColor =  [UIColor colorWithRed:234/255.0 green:176/255.0 blue:17/255.0 alpha:1];
        lbl.textColor = [UIColor whiteColor];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        lbl.layer.cornerRadius = 2;
        
        self.followButton.layer.cornerRadius = 2;
        [self.followButton addSubview:lbl];
        self.followButton.hidden = NO;
        
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(lbl.center.x+38, lbl.center.y-5, 14, 10)];
        imgV.image = [UIImage imageNamed:@"tick_following"];
        [self.followButton addSubview:imgV];
       
    }
    else if (self.mode == Timeline_Not_Following){
        
        lbl.userInteractionEnabled = NO;
        lbl.numberOfLines = 0;
        lbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        
        NSMutableAttributedString *txt = [[NSMutableAttributedString alloc] initWithString:@"Follow +"];
        NSRange r = [txt.string rangeOfString:@"+"];
      
        [txt addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:20]
                      range:r];
        lbl.attributedText = txt;
        
        lbl.backgroundColor = [UIColor whiteColor];
        lbl.textColor = [UIColor colorWithRed:240/255.0 green:208/255.0 blue:0/255.0 alpha:1];
        lbl.textAlignment = NSTextAlignmentCenter;

        
        [self.followButton addSubview:lbl];
        
        self.followButton.hidden = NO;
        
        [self.followButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:240/255.0 green:208/255.0 blue:0/255.0 alpha:1.0]] forState:UIControlStateNormal];
        [self.followButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:232/255.0 green:209/255.0 blue:3/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
    }
    else{
        self.followButton.hidden = YES;
    }
 
        
        //CENTER
        
        lbl = [[UILabel alloc]initWithFrame:self.followersButton.bounds];
        lbl.textColor = [UIColor whiteColor];
        lbl.numberOfLines = 0;
        lbl.userInteractionEnabled = NO;
        lbl.tag = 45;
        
        NSString *mtext = [NSString stringWithFormat:@"%d Followers",followers];
        lbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        lbl.text = mtext;
        lbl.textAlignment = NSTextAlignmentCenter;
        
        lbl.layer.borderColor = [UIColor whiteColor].CGColor;
        lbl.layer.borderWidth = 1.5f;
        lbl.layer.cornerRadius = 2;
        
        [self.followersButton addSubview:lbl];
        [self.followersButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:198/255.0 green:202/255.0 blue:205/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
        
        //RIGHT
        
        lbl = [[UILabel alloc]initWithFrame:self.followingButton.bounds];
        lbl.numberOfLines = 0;
        lbl.userInteractionEnabled = NO;
        lbl.textColor = [UIColor whiteColor];
        lbl.tag = 45;
        
        NSString *text = [NSString stringWithFormat:@"%d Following",following];
        
        lbl.text = text;
        lbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        lbl.layer.borderColor = [UIColor whiteColor].CGColor;
        lbl.layer.borderWidth = 1.5f;
        lbl.layer.cornerRadius = 2;
        
        lbl.textAlignment = NSTextAlignmentCenter;
        [self.followingButton addSubview:lbl];
        
        [self.followingButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:198/255.0 green:202/255.0 blue:205/255.0 alpha:1.0]] forState:UIControlStateHighlighted];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

#pragma mark - Table view data source

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return (loadNextPage)?beeeps.count+2:beeeps.count+1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    UITableViewCell *cell;
    
    if (loadNextPage && indexPath.row == beeeps.count + 1) {
        
        CellIdentifier = @"LoadMoreCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UIActivityIndicatorView *indicator = (id)[cell viewWithTag:55];
        [indicator startAnimating];
        
        [self nextPage];
        
        return cell;
        
    }
    
    if (indexPath.row == 0) {
        
        CellIdentifier = @"ToggleCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableV.frame.size.width, 32)];
        
        GTSegmentedControl *segment = [GTSegmentedControl initWithOptions:[NSArray arrayWithObjects:@"Upcoming",@"Past", nil] size:CGSizeMake(310, 32) selectedIndex:segmentIndex selectionColor:[UIColor colorWithRed:241/255.0 green:181/255.0 blue:18/255.0 alpha:1]];
        
        segment.delegate = self;
        [headerView addSubview:segment];
        segment.center = CGPointMake(160, 16);
        [cell addSubview:headerView];
    }
    else{
        CellIdentifier =  @"Cell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel *mLbl = (id)[cell viewWithTag:1];
        mLbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        
        UILabel *dLbl = (id)[cell viewWithTag:2];
        dLbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:25];
        
        UILabel *titleLbl = (id)[cell viewWithTag:4];
        titleLbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
        
        //    [cell viewWithTag:66].layer.masksToBounds = NO;
        //    [cell viewWithTag:66].layer.borderColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:0.3].CGColor;
        //    [cell viewWithTag:66].layer.borderWidth = 0.5;
        
        UILabel *reminderLabel = (id)[cell viewWithTag:-6];
        UIImageView *reminderIcon = (id)[cell viewWithTag:-7];
        UIButton *beepItbutton = (id)[cell viewWithTag:-8];
        
        Timeline_Object *b = [beeeps objectAtIndex:indexPath.row-1];
        
        if (self.mode != Timeline_My) {

            beepItbutton.hidden = NO;
            
            double now_time = [[NSDate date]timeIntervalSince1970];
            double event_timestamp = b.event.timestamp;
            
            if (now_time > event_timestamp) {
                [beepItbutton setHidden:YES];
            }
            else{
                [beepItbutton setHidden:NO];
                [beepItbutton setImage:[UIImage imageNamed:@"beeep_it_icon_event"] forState:UIControlStateNormal];
            }
            
            reminderIcon.hidden = YES;
            reminderLabel.hidden = YES;
        }
        else{
            beepItbutton.hidden = YES;
            reminderIcon.hidden = NO;
            reminderLabel.hidden = NO;
        }
        
        titleLbl.text = [b.event.title capitalizedString];
        
        //EVENT DATE
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE, MMM dd, yyyy HH:mm"];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [formatter setLocale:usLocale];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:b.event.timestamp];
        NSString *dateStr = [formatter stringFromDate:date];
        NSArray *components = [dateStr componentsSeparatedByString:@","];
        NSArray *day_month= [[components objectAtIndex:1]componentsSeparatedByString:@" "];
        
        NSString *month = [day_month objectAtIndex:1];
        NSString *daynumber = [day_month objectAtIndex:2];
        NSString *year = [[[components lastObject] componentsSeparatedByString:@" "] firstObject];
        NSString *hour = [[[components lastObject] componentsSeparatedByString:@" "] lastObject];
        
        UILabel *dayLbl = (id)[cell viewWithTag:2];
        UILabel *monthLbl = (id)[cell viewWithTag:1];
        
        dayLbl.text = daynumber;
        dayLbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:23];
        monthLbl.text = [month uppercaseString];
        monthLbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        
        float timestamp =  b.beeep.beeepInfo.eventTime.floatValue-b.beeep.beeepInfo.timestamp.floatValue;
        
        NSString *alert_time = [self dailyLanguage:timestamp];
        reminderLabel.text = alert_time;
        //Venue name
        
        UILabel *venueLbl = (id)[cell viewWithTag:5];
        
        NSString *jsonString = b.event.location;
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
        venueLbl.text = [loc.venueStation uppercaseString];
        
        //Likes,Beeeps,Comments
        UILabel *beeepsLbl = (id)[cell viewWithTag:-5];
        UILabel *likesLbl = (id)[cell viewWithTag:-3];
        UILabel *commentsLbl = (id)[cell viewWithTag:-4];
        
        likesLbl.text = [NSString stringWithFormat:@"%d",b.beeep.beeepInfo.likes.count];
        commentsLbl.text = [NSString stringWithFormat:@"%d",b.beeep.beeepInfo.comments.count];
        beeepsLbl.text = [NSString stringWithFormat:@"%d",b.beeepersIds.count];
        
        likesLbl.hidden = (likesLbl.text.intValue == 0);
        commentsLbl.hidden = (commentsLbl.text.intValue == 0);
        beeepsLbl.hidden = (beeepsLbl.text.intValue == 0);
        
        //Image
        
        UIImageView *imgV = (id)[cell viewWithTag:3];
        
        //NSString *extension = [[b.event.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        
        NSString *imageName = [NSString stringWithFormat:@"%@",[b.event.imageUrl MD5]];
        
        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
        
        if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
            imgV.backgroundColor = [UIColor clearColor];
            imgV.image = nil;
            UIImage *img = [UIImage imageWithContentsOfFile:localPath];
            imgV.image = img;
        }
        else{
            imgV.backgroundColor = [UIColor lightGrayColor];
            imgV.image = nil;
            [pendingImagesDict setObject:indexPath forKey:imageName];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(imageDownloadFinished:) name:imageName object:nil];
        }
        
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return 40;
    }
    else if (indexPath.row == beeeps.count+1 && loadNextPage){
        return 51;
    }
    else{
        return 113;
    }
}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [[cell viewWithTag:55]setBackgroundColor:[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EventVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"EventVC"];
    
    viewController.tml = [beeeps objectAtIndex:indexPath.row-1];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [[cell viewWithTag:55]setBackgroundColor:[UIColor clearColor]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if(beeeps.count > 0 && !loading){
        return 0;
    }
    else{
        return 50;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *footer=[[UIView alloc] initWithFrame:CGRectMake(0,0,320.0,50.0)];
    footer.backgroundColor =[UIColor clearColor];
    UILabel *lbl = [[UILabel alloc]initWithFrame:footer.bounds];
    lbl.text = (loading)?@"Loading...":@"There are no beeeps available.";
    lbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    lbl.textColor = [UIColor colorWithRed:111/255.0 green:113/255.0 blue:121/255.0 alpha:1];
    lbl.textAlignment = NSTextAlignmentCenter;
    [footer addSubview:lbl];
    
    return footer;
    
    
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

#pragma mark - Actions

- (IBAction)backPressed:(id)sender {
    [self goBack];
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)showFollowers:(id)sender {
    FollowListVC *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowListVC"];
    viewController.mode = 1;
    viewController.user = self.user;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showFollowing:(id)sender {
    FollowListVC *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowListVC"];
    viewController.mode = 2;
    viewController.user = self.user;

    [self.navigationController pushViewController:viewController animated:YES];
}

-(IBAction)beeepItPressed:(UIButton *)sender{
    
    if(segmentIndex == 1){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Passed Event" message:@"Can not Beeep a passed event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    UITableViewCell *cell = (id)sender.superview.superview.superview.superview;
    NSIndexPath *path = [self.tableV indexPathForCell:cell];
    
    Timeline_Object *b = [beeeps objectAtIndex:path.row-1];
   
    NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
    
    if ([b.beeepersIds indexOfObject:my_id] != NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Already Beeeped" message:@"You have already Beeeeped this event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    BeeepItVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"BeeepItVC"];
    viewController.tml = b;
    viewController.view.frame = self.parentViewController.parentViewController.view.bounds;
    
    [self presentViewController:viewController animated:YES completion:nil];    

}

- (IBAction)showLikes:(UIButton *)sender {
    
    UITableViewCell *cell = (id)sender.superview.superview.superview.superview;
    NSIndexPath *path = [self.tableV indexPathForCell:cell];
    
    Timeline_Object *b = [beeeps objectAtIndex:path.row-1];


    NSArray *likes = b.beeep.beeepInfo.likes;
    NSMutableArray *likers = [NSMutableArray array];
    
    for (Likes *l in likes) {
        NSString *liker = l.likers.likersIdentifier;
        [likers addObject:liker];
    }
    
    
    FollowListVC *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowListVC"];
    viewController.mode = LikesMode;
    viewController.ids = likers;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showComments:(UIButton *)sender {
   
    UITableViewCell *cell = (id)sender.superview.superview.superview.superview;
    NSIndexPath *path = [self.tableV indexPathForCell:cell];
    
    Timeline_Object *b = [beeeps objectAtIndex:path.row-1];
   
    CommentsVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentsVC"];
    viewController.event_beeep_object = b;
    viewController.comments = [NSMutableArray arrayWithArray: b.beeep.beeepInfo.comments];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showBeeepers:(UIButton *)sender {
   
    UITableViewCell *cell = (id)sender.superview.superview.superview.superview;
    NSIndexPath *path = [self.tableV indexPathForCell:cell];

    
    Timeline_Object *b = [beeeps objectAtIndex:path.row-1];
    
    FollowListVC *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowListVC"];
    viewController.mode = BeeepersMode;
    viewController.ids = b.beeepersIds;
    [self.navigationController pushViewController:viewController animated:YES];
}


- (IBAction)followButtonPressed:(id)sender {
    
    if (self.mode == Timeline_Not_Following){
       
        //follow user
        [[BPUser sharedBP]follow:[user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
            if (completed) {
                
                self.mode = Timeline_Following;
                [self createMenuButtons:YES];
            }
        }];
    }
   else{
        
        NSString *username = [[NSString stringWithFormat:@"%@ %@",[user objectForKey:@"name"],[user objectForKey:@"lastname"]] capitalizedString];
        
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:username delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Unfollow" otherButtonTitles:nil];
        [popup showInView:self.view];
       
    }
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        
        [[BPUser sharedBP]unfollow:[user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
            if (completed) {
                self.mode = Timeline_Not_Following;
                [self createMenuButtons:YES];

            }
        }];
        
    }
}

- (IBAction)editProfilePressed:(id)sender {
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"EditProfile"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)settingsPressed:(id)sender {
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingsVC"];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)importPressed:(id)sender {
 
    [FBRequestConnection startWithGraphPath:@"/me/events"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              NSLog(@"%@",result);
                          }];
}

- (IBAction)showSuggestions:(id)sender {
    UIViewController *vC = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"SuggestionsVC"];
    [self.navigationController pushViewController:vC animated:YES];
}

- (IBAction)showActivity:(id)sender {
    UIViewController *vC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ActivityVC"];
    [self.navigationController pushViewController:vC animated:YES];
}


#pragma mark - GTSegmentedControlDelegate

-(void)selectedSegmentAtIndex:(int)index{

    segmentIndex = index;
    
    if (index == 0) { //upcoming
        [self getTimeline:[self.user objectForKey:@"id"] option:Upcoming];
    }
    else{ //past
        [self getTimeline:[self.user objectForKey:@"id"] option:Past];
    }
}


#pragma mark - MONActivityIndicatorViewDelegate Methods

-(void)showLoading{
    
    if (self.tableV.alpha == 0) {
        return;
    }
    
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



-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName inDirectory:(NSString *)directoryPath {
    
    if ([imageName rangeOfString:@"n/a"].location != NSNotFound) {
        return;
    }
    
    if ([[imageName lowercaseString] rangeOfString:@".png"].location != NSNotFound) {
        [UIImagePNGRepresentation(image) writeToFile:directoryPath options:NSAtomicWrite error:nil];
        NSLog(@"Saved Image: %@",imageName);
        
    } else {
        
        BOOL write = [UIImageJPEGRepresentation(image, 1) writeToFile:directoryPath options:NSAtomicWrite error:nil];
        NSLog(@"Saved Image: %@ - %d",directoryPath,write);
        
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:imageName object:nil userInfo:[NSDictionary dictionaryWithObject:imageName forKey:@"imageName"]];
}


-(NSString*)dailyLanguage:(NSTimeInterval) overdueTimeInterval{
    
    if (overdueTimeInterval<0)
        overdueTimeInterval*=-1;
    
    NSInteger minutes = round(overdueTimeInterval)/60;
    NSInteger hours   = minutes/60;
    NSInteger days    = hours/24;
    NSInteger months  = days/30;
    NSInteger years   = months/12;
    
    NSString* overdueMessage;
    
    if (years>0){
        overdueMessage = [NSString stringWithFormat:@"%d years before", (years)];
    }else if (months>0){
        overdueMessage = [NSString stringWithFormat:@"%d months before", (months)];
    }else if (days>0){
        overdueMessage = [NSString stringWithFormat:@"%d days before", (days)];
    }else if (hours>0){
        overdueMessage = [NSString stringWithFormat:@"%d hours before", (hours)];
    }else if (minutes>0){
        overdueMessage = [NSString stringWithFormat:@"%d minutes before", (minutes)];
    }else if (overdueTimeInterval<60){
        overdueMessage = [NSString stringWithFormat:@"On Time"];
    }
    
    return overdueMessage;
}

#pragma mark - GHMenu methods

-(BOOL) shouldShowMenuAtPoint:(CGPoint)point
{
    NSIndexPath* indexPath = [self.tableV indexPathForRowAtPoint:point];
    UITableViewCell* cell = [self.tableV cellForRowAtIndexPath:indexPath];
    
    return cell != nil;
}

- (NSInteger) numberOfMenuItems
{
    return 4;
}

-(UIImage*) imageForItemAtIndex:(NSInteger)index
{
    NSString* imageName = nil;
    switch (index) {
        case 0:
            imageName = @"Beeep_popup_unpressed";
            break;
        case 1:
            imageName = @"Like_popup_unpressed";
            break;
        case 2:
            imageName = @"Suggest_popup_unpressed";
            break;
        case 3:
            imageName = @"Comment_popup_unpressed";
            break;
            
        default:
            break;
    }
    return [UIImage imageNamed:imageName];
}

- (void) didSelectItemAtIndex:(NSInteger)selectedIndex forMenuAtPoint:(CGPoint)point
{
    NSIndexPath* indexPath = [self.tableV indexPathForRowAtPoint:point];
    
    Timeline_Object *b = [beeeps objectAtIndex:indexPath.row-1];
    
    switch (selectedIndex) {
        case 0:
            [self beeepEventAtIndexPath:indexPath];
            break;
        case 1:
            [self likeEventAtIndexPath:indexPath];
            break;
        case 2:
            [self suggestEventAtIndexPath:indexPath];
            break;
        case 3:
            [self commentEventAtIndexPath:indexPath];
            break;
            
        default:
            break;
    }
    
}

-(void)beeepEventAtIndexPath:(NSIndexPath *)indexpath{
    
    if (segmentIndex != 0) { //Passed
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Passed Event" message:@"Can not Beeep a passed event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    BeeepItVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"BeeepItVC"];
    

    Timeline_Object *b = [beeeps objectAtIndex:indexpath.row-1];
    viewController.tml = b;
    
    viewController.view.frame = self.parentViewController.parentViewController.view.bounds;
    
    [self presentViewController:viewController animated:YES completion:nil];
    
}

-(void)likeEventAtIndexPath:(NSIndexPath *)indexpath{
    
        
    Timeline_Object *b = [beeeps objectAtIndex:indexpath.row-1];
    
    NSArray *likes = b.beeep.beeepInfo.likes;
    NSMutableArray *likers = [NSMutableArray array];
    
    for (Likes *l in likes) {
        NSString *liker = l.likers.likersIdentifier;
        [likers addObject:liker];
    }
    
    if ([likers indexOfObject:[[BPUser sharedBP].user objectForKey:@"id"]] == NSNotFound) {
        
        [[EventWS sharedBP]likeBeeep:b.beeep.beeepInfo.weight user:b.beeep.userId WithCompletionBlock:^(BOOL completed,NSDictionary *response){
            if (completed) {
                
                [likers addObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                b.beeep.beeepInfo.likes = likers;
                
                [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                [SVProgressHUD showSuccessWithStatus:@"Liked!"];
                
                [self.tableV reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
            }
            else{
                
                NSArray *errorArray = [response objectForKey:@"errors"];
                NSDictionary *errorDict = [errorArray firstObject];
                
                NSString *info = [errorDict objectForKey:@"info"];
                if ([info isEqualToString:@"You have already liked this event"]) {
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@\n%@",[errorDict objectForKey:@"message"],[errorDict objectForKey:@"info"]]];
                }
            }
        }];
        
    }
    else{
        [[EventWS sharedBP]unlikeBeeep:b.beeep.beeepInfo.weight user:b.beeep.userId WithCompletionBlock:^(BOOL completed,Event_Show_Object *eventShow){
            if (completed) {
                [likers removeObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                b.beeep.beeepInfo.likes = likers;
                [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                [SVProgressHUD showSuccessWithStatus:@"Unliked"];
                
                [self.tableV reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
    }
    
}

-(void)commentEventAtIndexPath:(NSIndexPath *)indexPath{
    
    Timeline_Object*b = [beeeps objectAtIndex:indexPath.row-1];
    
    CommentsVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentsVC"];
    viewController.event_beeep_object = [beeeps objectAtIndex:indexPath.row-1];
    viewController.comments = [NSMutableArray arrayWithArray: b.beeep.beeepInfo.comments];
    viewController.showKeyboard = YES;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)suggestEventAtIndexPath:(NSIndexPath *)indexpath{
    
    Timeline_Object*b = [beeeps objectAtIndex:indexpath.row-1];
    
    
    SuggestBeeepVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"SuggestBeeepVC"];
    viewController.fingerprint = b.event.fingerprint;
    
    if (viewController.fingerprint != nil) {
        [self presentViewController:viewController animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There is a problem with this Beeep. Please refresh and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }


}


#pragma mark - Group by date

/*-(void)groupBeeepsByMonth{
    @try {

        [beeeps sortUsingComparator:^NSComparisonResult(Timeline_Object *obj1, Timeline_Object *obj2) {
            
            //1401749430
            //1401749422
            if (obj1.event.timestamp < obj2.event.timestamp) {
                return (NSComparisonResult)(segmentIndex == 0)?NSOrderedAscending:NSOrderedDescending;
            }
            
            if (obj1.event.timestamp > obj2.event.timestamp) {
                return (NSComparisonResult)(segmentIndex == 0)?NSOrderedDescending:NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        for (Timeline_Object *activity in beeeps) {
            //EVENT DATE
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEEE, MMM dd, yyyy HH:mm"];
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [formatter setLocale:usLocale];
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:activity.event.timestamp];
            NSString *dateStr = [formatter stringFromDate:date];
            NSArray *components = [dateStr componentsSeparatedByString:@","];
            NSArray *day_month= [[components objectAtIndex:1]componentsSeparatedByString:@" "];
            
            NSString *month = [day_month objectAtIndex:1];
            NSString *daynumber = [day_month objectAtIndex:2];
            NSString *year = [[[components lastObject] componentsSeparatedByString:@" "] firstObject];
            NSString *hour = [[[components lastObject] componentsSeparatedByString:@" "] lastObject];
            
            NSString *signature = [NSString stringWithFormat:@"%@#%@#%@",month,daynumber,year];
            
            if ([sections indexOfObject:signature] == NSNotFound) {
                [sections addObject:signature];
            }
        }

        [self.tableV reloadData];
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"ELAA");
    }
    @finally {
        
    }
}

-(NSMutableArray *)timelineForSection:(int)section{
    
    if ([suggestionsPerSection objectForKey:[NSString stringWithFormat:@"%d",section]]) {
        return [suggestionsPerSection objectForKey:[NSString stringWithFormat:@"%d",section]];
    }
    else{
        
        NSString *section_signature = [sections objectAtIndex:section-1];
        NSMutableArray *filtered_activities = [NSMutableArray array];
        
        for (Timeline_Object *suggestion in beeeps) {
            //EVENT DATE
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEEE, MMM dd, yyyy HH:mm"];
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [formatter setLocale:usLocale];
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:suggestion.event.timestamp];
            NSString *dateStr = [formatter stringFromDate:date];
            NSArray *components = [dateStr componentsSeparatedByString:@","];
            NSArray *day_month= [[components objectAtIndex:1]componentsSeparatedByString:@" "];
            
            NSString *month = [day_month objectAtIndex:1];
            NSString *daynumber = [day_month objectAtIndex:2];
            NSString *year = [[[components lastObject] componentsSeparatedByString:@" "] firstObject];
            NSString *hour = [[[components lastObject] componentsSeparatedByString:@" "] lastObject];
            
            NSString *signature = [NSString stringWithFormat:@"%@#%@#%@",month,daynumber,year];
            
            if ([section_signature isEqualToString:signature]) {
                [filtered_activities addObject:suggestion];
            }
        }
        
        [suggestionsPerSection setObject:filtered_activities forKey:[NSString stringWithFormat:@"%d",section]];
        return filtered_activities;
    }
}
 
 */
@end
