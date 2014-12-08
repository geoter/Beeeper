//
//  TimelineVC.m
//  Beeeper
//
//  Created by User on 3/27/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "TimelineVC.h"
#import "EventVC.h"
#import "FollowListVC.h"
#import "Timeline_Object.h"
#import "CommentsVC.h"
#import <QuartzCore/QuartzCore.h>
#import "GTSegmentedControl.h"
#import <FacebookSDK/FacebookSDK.h>
#import "GHContextMenuView.h"
#import "EventWS.h"
#import "Event_Show_Object.h"
#import "BPSuggestions.h"
#import "Reachability.h"
#import "GTPushButton.h"
#import "BPCreate.h"
#import "CalendarView.h"
#import "ChooseDatePopupVC.h"

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

@interface TimelineVC ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,GTSegmentedControlDelegate,MONActivityIndicatorViewDelegate,GHContextOverlayViewDataSource,GHContextOverlayViewDelegate,UIGestureRecognizerDelegate,ChooseDatePopupVCDelegate,CalendarViewDelegate>
{
    NSMutableArray *beeeps;
    NSMutableDictionary *pendingImagesDict;
    int followers;
    int following;
    BOOL isFollowing;
    int segmentIndex;
    BOOL loading;
    BOOL loadNextPage;
    CGPoint initialCellCenter;
  //  NSMutableArray *sections;
  //  NSMutableDictionary *suggestionsPerSection;
    NSMutableArray *rowsToReload;
    UIView *calendarBGV;
    UIView *calendarContainer;
    
    UIView *headerVMovingView;
    UILabel *headerTextLabel;
    BOOL headerVMovingViewShowing;
    ChooseDatePopupVC *chooseDatePopupVC;
    int chooseDaySelectedIndex;
}
@property (nonatomic,strong) NSDate *selectedDate;

@end

@implementation TimelineVC
@synthesize mode=_mode,user,selectedDate;

-(void)setMode:(int)mode{
    _mode = mode;
}

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
                loading = NO;
//                [self groupBeeepsByMonth];
            }
        }
        
        [self.tableV reloadData];
    }];
}

-(void)getTimeline:(NSString *)userID option:(int)option{
    
    if (userID == nil) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"User error" message:@"User is empty" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    @try {
        
        NSLog(@"Mpike");
        
        [self setUserInfo];
        
        loadNextPage = NO;
        
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
                        self.mode = Timeline_Not_Following;
                    }
                    else{
                        isFollowing = YES;
                        self.mode = Timeline_Following;
                    }
                    
                    [self createMenuButtons:YES];
                }
            }];
            

        }
        

        @try {
            
            if (userID == nil) {
                NSLog(@"userID in timeline is nil");
            }
            
            [[BPTimeline sharedBP]getTimelineForUserID:userID option:option timeStamp:selectedDate.timeIntervalSince1970 WithCompletionBlock:^(BOOL completed,NSArray *objs){
                
                
                UIRefreshControl *refreshControl = (id)[self.tableV viewWithTag:234];
                [refreshControl endRefreshing];
                
                if (completed) {
                    
                    loading = NO;
                    
                    if (objs) {
                        beeeps = [NSMutableArray arrayWithArray:objs];
                    }
                    
                    if (beeeps.count == 10) {
                        loadNextPage = YES;
                    }
                    else{
                        loadNextPage = NO;
                    }
                    
                    [self.tableV reloadData];
                    [self.tableV setContentOffset:CGPointZero animated:YES];
                  //  suggestionsPerSection = [NSMutableDictionary dictionary];
                   // sections = [NSMutableArray array];
                 //   [self groupBeeepsByMonth];
                }
                else{
                    if ([objs isKindOfClass:[NSString class]]) {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"getTimeline Not Completed" message:(NSString *)objs delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                        [alert show];
                        
                    }
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
                UIButton *followersBtn = self.followersButton;
                if (followersBtn != nil) {
                   
                    followersBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
                    
                    NSString *mtext = [NSString stringWithFormat:@"%d\nFollowers",followers];
                   
                    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:mtext];
                    [attText addAttribute:NSFontAttributeName
                                    value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]
                                    range:[mtext rangeOfString:[NSString stringWithFormat:@"%d",followers]]];
                    
                    [followersBtn setAttributedTitle:attText forState: UIControlStateNormal];
                }
            }
        }];
        
        [[BPUser sharedBP]getFollowingForUser:[self.user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
            
            if (completed) {
                following = objs.count;
                UIButton *followingBtn = self.followingButton;
                if (followingBtn != nil) {
                   
                    followingBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
                    
                    NSString *mtext = [NSString stringWithFormat:@"%d\nFollowing",following];
                    
                    NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:mtext];
                    [attText addAttribute:NSFontAttributeName
                                    value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]
                                    range:[mtext rangeOfString:[NSString stringWithFormat:@"%d",following]]];
                    
                    [followingBtn setAttributedTitle:attText forState: UIControlStateNormal];
                }
                
            }
        }];

    }
    @catch (NSException *exception) {
        NSLog(@"ELAKI!:%@",exception.description);
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
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(getTimeline:option:) forControlEvents:UIControlEventValueChanged];
    [refreshView addSubview:refreshControl];

    [self.tableV addSubview:refreshControl];
    self.tableV.alwaysBounceVertical = YES;
    
   
    [self getTimeline:[self.user objectForKey:@"id"] option:Upcoming];
    // self.tableV.decelerationRate = 0.6;
    
    pendingImagesDict = [NSMutableDictionary dictionary];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];

    CALayer * l = [self.profileImageBorderV layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:1.5];
    
    l = [self.profileImage layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:1.5];
    
    [self createMenuButtons:NO];

    self.userCityLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    self.usernameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20];
    
    @try {
        
        
        [[BPTimeline sharedBP]getLocalTimelineUserID:[self.user objectForKey:@"id"] option:Upcoming WithCompletionBlock:^(BOOL completed,NSArray *objs){
            if (completed) {
                beeeps = [NSMutableArray arrayWithArray:objs];
                
                if (beeeps.count > 0) {
                    loading = NO;
                    [self.tableV reloadData];
                }
                
                // suggestionsPerSection = [NSMutableDictionary dictionary];
                // sections = [NSMutableArray array];
                
                //                [self groupBeeepsByMonth];
                
            }
        }];
        
        [[BPUser sharedBP]getLocalFollowersForUser:[self.user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
            
            if (completed) {
                followers = objs.count;
                UIButton *followersBtn = self.followersButton;
                if (followersBtn != nil) {
                    dispatch_async (dispatch_get_main_queue(), ^{
                        
                        followersBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
                        
                        NSString *mtext = [NSString stringWithFormat:@"%d\nFollowers",followers];
                        
                        NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:mtext];
                        [attText addAttribute:NSFontAttributeName
                                        value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]
                                        range:[mtext rangeOfString:[NSString stringWithFormat:@"%d",followers]]];
                        
                        [followersBtn setAttributedTitle:attText forState: UIControlStateNormal];
                    });
                }
                
            }
        }];
        
        [[BPUser sharedBP]getLocalFollowingForUser:[self.user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
            
            if (completed) {
                following = objs.count;
                UIButton *followingBtn = self.followingButton;
                if (followingBtn != nil) {
                    dispatch_async (dispatch_get_main_queue(), ^{
                        
                        followingBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
                        
                        NSString *mtext = [NSString stringWithFormat:@"%d\nFollowing",following];
                        
                        NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:mtext];
                        [attText addAttribute:NSFontAttributeName
                                        value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]
                                        range:[mtext rangeOfString:[NSString stringWithFormat:@"%d",following]]];
                        
                        [followingBtn setAttributedTitle:attText forState: UIControlStateNormal];
                        
                    });
                }
                
            }
        }];
        
        //Follow + /Following button
        if (self.mode != Timeline_My) {
           
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
        
    }
    @catch (NSException *exception) {
        NSLog(@"ELA!");
    }
    @finally {
        
    }
}

-(void)setUserInfo{
    
    if (user == nil && self.mode == Timeline_My) {
        user = [BPUser sharedBP].user;
    }
    
    [self downloadUserImageIfNecessery];
    
    BOOL mpike = NO;
    
    if ([user objectForKey:@"name"] == nil || [user objectForKey:@"lastname"] == nil) {
        
         mpike = YES;
        
        
        if (user == nil) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error getting user" message:@"Something went wrong.Please go back and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            return;
        }
        
        [[BPUsersLookup sharedBP]usersLookup:@[[user objectForKey:@"id"]] completionBlock:^(BOOL completed,NSArray *objs){
            
            if (completed && objs.count >0) {
                NSDictionary *userDict = [objs firstObject];
                self.user = userDict;
                [self setUserInfo];
            }
            else{
                
                Reachability *reachability = [Reachability reachabilityForInternetConnection];
                [reachability startNotifier];
                
                NetworkStatus status = [reachability currentReachabilityStatus];
                
                if(status == NotReachable)
                {
                  [self hideLoadingWithTitle:@"No Internet connection" ErrorMessage:@"Please enable Wifi or Cellular data."];
                }
                else{
                    [self hideLoading];
                }
               
            }
        }];
        

    }
    
    else{
        
        [self hideLoading];
        self.usernameLabel.text = [[NSString stringWithFormat:@"%@ %@",[user objectForKey:@"name"],[user objectForKey:@"lastname"]] capitalizedString];
        
        UIButton *totalBeeepsBtn;
        if (self.mode == Timeline_My) {
            totalBeeepsBtn = (UIButton *)[self.myTimelineMenuV viewWithTag:32];
        }
        else{
            totalBeeepsBtn = (UIButton *)[self.othersTimelineMenuV viewWithTag:32];
        }
        
        totalBeeepsBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        id beeeps = [user objectForKey:@"beeep_count"];
        
        NSString *mtext = [NSString stringWithFormat:@"%@\nTotal Beeeps",(beeeps != nil)?beeeps:@"0"];
        
        NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:mtext];
        [attText addAttribute:NSFontAttributeName
                        value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]
                        range:[mtext rangeOfString:[NSString stringWithFormat:@"%@",(beeeps != nil)?beeeps:@"0"]]];
        
        [totalBeeepsBtn setAttributedTitle:attText forState: UIControlStateNormal];
        
        NSString *city = [[user objectForKey:@"city"] capitalizedString];
        
        if (city != nil && city.length > 0) {
            
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
            
            
            self.userCityLabel.hidden = NO;
            self.pinIcon.hidden = NO;
            
            self.userCityLabel.text = city;
            [self.userCityLabel sizeToFit];
            self.userCityLabel.center = CGPointMake(self.userCityLabel.superview.center.x, self.userCityLabel.center.y);
            self.pinIcon.frame = CGRectMake(self.userCityLabel.frame.origin.x - 13, self.pinIcon.frame.origin.y, self.pinIcon.frame.size.width, self.pinIcon.frame.size.height);

        }
        else{
            
            mpike = YES;
            
            [[BPUsersLookup sharedBP]usersLookup:@[[user objectForKey:@"id"]] completionBlock:^(BOOL completed,NSArray *objs){
                
                if (completed && objs.count >0) {
                    NSDictionary *userDict = [objs firstObject];
                    self.user = userDict;
                    [self setUserInfo];
                }
            }];

            
            [UIView animateWithDuration:0.3f
                             animations:^
             {
                 self.userCityLabel.alpha = 0;
                 self.pinIcon.alpha = 0;
             }
                             completion:^(BOOL finished)
             {
                 
             }
             ];
        }
    }
    
    if (!mpike) {
        
        [[BPUsersLookup sharedBP]usersLookup:@[[user objectForKey:@"id"]] completionBlock:^(BOOL completed,NSArray *objs){
            
          
            if (completed && objs.count >0) {
                NSDictionary *userDict = [objs firstObject];
                self.user = userDict;
                [self setUserInfo];
            }
            else{
                  [self hideLoading];
            }
        }];
    }
}

-(void)hideLoadingWithTitle:(NSString *)title ErrorMessage:(NSString *)message{
    
    if ([self.view viewWithTag:-434] == nil) {
        return;
    }
    
    dispatch_async (dispatch_get_main_queue(), ^{
        
        UIView *loadingBGV = (id)[self.view viewWithTag:-434];
        MONActivityIndicatorView *indicatorView = (id)[loadingBGV viewWithTag:-565];
        [indicatorView stopAnimating];
        
        [UIView animateWithDuration:0.3f
                         animations:^
         {
             loadingBGV.alpha = 0;
         }
                         completion:^(BOOL finished)
         {
             [loadingBGV removeFromSuperview];
             
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
         }
         ];
        
    });
}

-(void)downloadUserImageIfNecessery{

    @try {
        
        NSString *imagePath =  [[DTO sharedDTO]fixLink:[user objectForKey:@"image_path"]];
        
       // NSString *extension = [[imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        
        NSString *imageName = [NSString stringWithFormat:@"%@",[imagePath MD5]];
        
        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
        
        if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
            
        //    UIImage *img = [UIImage animatedImageWithAnimatedGIFData:[NSData dataWithContentsOfFile:localPath]];
            UIImage *img = [UIImage imageWithContentsOfFile:localPath];
            self.profileImage.image = img;
        }
  
        Reachability *reachability = [Reachability reachabilityForInternetConnection];
        [reachability startNotifier];
        
        NetworkStatus status = [reachability currentReachabilityStatus];
        
        if(status == NotReachable)
        {
            //No internet
        }
        else if (status == ReachableViaWiFi)
        {
            
            [self.profileImage sd_setImageWithURL:[NSURL URLWithString:[[DTO sharedDTO] fixLink:[user objectForKey:@"image_path"]]]
                    placeholderImage:[UIImage imageNamed:@"user_icon_180x180"]];
           
        }
        else if (status == ReachableViaWWAN) 
        {
            //3G
            [self.profileImage sd_setImageWithURL:[NSURL URLWithString:[[DTO sharedDTO] fixLink:[user objectForKey:@"image_path"]]]
                                 placeholderImage:[UIImage imageNamed:@"user_icon_180x180"]];
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
    
    if (self.mode == Timeline_My) {
        [self showSuggestionsBadge];
    }
    
    if (self.mode != Timeline_My || self.showBackButton) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
        self.navigationItem.leftBarButtonItem = leftItem;
        
        self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
        [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
        self.backBtn.hidden = NO;
        
        self.tabBar.hidden = YES;
        self.tableV.frame = CGRectMake(self.tableV.frame.origin.x, self.tableV.frame.origin.y, self.tableV.frame.size.width, self.view.frame.size.height-self.tableV.frame.origin.y);
    }
    else{
        [self showBadgeIcon];
        self.settingsIcon.hidden = NO;
        self.addFriendIcon.hidden = NO;
    }
    
    [self setUserInfo];
    
    [self.tableV reloadData];
    
    for (UIButton *btn in self.tabBar.subviews) {
        
        if (![btn isKindOfClass:[UIButton class]]) {
            continue;
        }
        
        if (btn.tag != 3) {
            btn.selected = NO;
        }
        else{
            btn.selected = YES;
        }
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.topV.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    self.topV.layer.shadowOpacity = 0.7;
    self.topV.layer.shadowOffset = CGSizeMake(0, 0.1);
    self.topV.layer.shadowRadius = 0.8;
    self.topV.layer.masksToBounds = NO;
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Internet connection" message:@"Please enable Wifi or Cellular data." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO ];
        
    }
    
}


-(void)createMenuButtons:(BOOL)animated{
    
    self.othersTimelineMenuV.hidden = (self.mode == Timeline_My);
    self.myTimelineMenuV.hidden = !(self.mode == Timeline_My);
    
    
    if (self.mode == Timeline_My) {
        self.followersButton = (UIButton *)[self.myTimelineMenuV viewWithTag:33];
        self.followingButton = (UIButton *)[self.myTimelineMenuV viewWithTag:34];
    }
    else{
        self.followersButton = (UIButton *)[self.othersTimelineMenuV viewWithTag:33];
        self.followingButton = (UIButton *)[self.othersTimelineMenuV viewWithTag:34];
    }
    
    for (UIView *v in self.followButton.subviews) {
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
    
    if (self.mode == Timeline_Following || self.following == YES){
        
        lbl.userInteractionEnabled = NO;
        lbl.numberOfLines = 0;
        lbl.text = @"Following";
        lbl.backgroundColor = [UIColor clearColor]; //[UIColor colorWithRed:234/255.0 green:176/255.0 blue:17/255.0 alpha:1];
        lbl.textColor = [UIColor colorWithRed:240/255.0 green:208/255.0 blue:0/255.0 alpha:1];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        lbl.layer.cornerRadius = 2;
        
        self.followButton.layer.cornerRadius = 2;
        [self.followButton addSubview:lbl];
        self.followButton.hidden = NO;
        
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:CGRectMake(lbl.center.x+32, lbl.center.y-5, 14, 10)];
        imgV.image = [UIImage imageNamed:@"tick_following"];
        [self.followButton addSubview:imgV];
       
    }
    else if (self.mode == Timeline_Not_Following){
        
        lbl.userInteractionEnabled = NO;
        lbl.numberOfLines = 0;
        lbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
        
        NSMutableAttributedString *txt = [[NSMutableAttributedString alloc] initWithString:@"Follow +"];
        NSRange r = [txt.string rangeOfString:@"+"];
      
        [txt addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]
                      range:r];
        lbl.attributedText = txt;
        
        lbl.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:234/255.0 green:176/255.0 blue:17/255.0 alpha:1];
        lbl.textColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:1];
        lbl.textAlignment = NSTextAlignmentCenter;

        
        [self.followButton addSubview:lbl];
        
        self.followButton.hidden = NO;
       // [self.followButton setBackgroundColor:[]
       // [self.followButton setBackgroundImage:[[DTO sharedDTO] imageWithColor:[UIColor colorWithRed:240/255.0 green:208/255.0 blue:0/255.0 alpha:1.0]] forState:UIControlStateNormal];
       // [self.followButton setBackgroundImage:[[DTO sharedDTO] imageWithColor:[UIColor colorWithRed:232/255.0 green:209/255.0 blue:3/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
    }
    else{
        self.followButton.hidden = YES;
    }
 

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
    
    return (loadNextPage)?beeeps.count+1:beeeps.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    UITableViewCell *cell;
    
    if (loadNextPage && indexPath.row == beeeps.count) {
        
        CellIdentifier = @"LoadMoreCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UIActivityIndicatorView *indicator = (id)[cell viewWithTag:55];
        [indicator startAnimating];
        
        [self nextPage];
        
        return cell;
        
    }
    
    
    CellIdentifier =  @"Cell";
    
    if (indexPath.row == 0) {
        CellIdentifier = @"CellTopBorder";
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
    if (initialCellCenter.x == 0 && initialCellCenter.y == 0) {
        initialCellCenter = [cell viewWithTag:66].center;
    }
    
    if (cell.gestureRecognizers.count == 0) {
      /*  UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(handleCellPan:)];
        pgr.delegate = self;
        [[cell viewWithTag:66] addGestureRecognizer:pgr];*/
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    UILabel *mLbl = (id)[cell viewWithTag:1];
  //  mLbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    
    UILabel *dLbl = (id)[cell viewWithTag:2];
    //dLbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:25];
    
    UILabel *titleLbl = (id)[cell viewWithTag:4];
   // titleLbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];

    UILabel *reminderLabel = (id)[cell viewWithTag:-6];
    
    //    [cell viewWithTag:66].layer.masksToBounds = NO;
    //    [cell viewWithTag:66].layer.borderColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:0.3].CGColor;
    //    [cell viewWithTag:66].layer.borderWidth = 0.5;
    
    UILabel *timeLabel = (id)[cell viewWithTag:55];
    
    UIImageView *reminderIcon = (id)[cell viewWithTag:-7];
    UIButton *beepItbutton = (id)[cell viewWithTag:-8];
    
    Timeline_Object *b = [beeeps objectAtIndex:indexPath.row];
    
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
    
    timeLabel.text = hour;
    
    UILabel *dayLbl = (id)[cell viewWithTag:2];
    UILabel *monthLbl = (id)[cell viewWithTag:1];
    
    dayLbl.text = daynumber;
   // dayLbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:23];
    monthLbl.text = [month uppercaseString];
   // monthLbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    
    NSString *alert_time = [self dailyLanguageFutureDate:b.beeep.beeepInfo.eventTime.intValue pastDate:b.beeep.beeepInfo.timestamp.intValue];
    
    reminderLabel.text = alert_time;
    [reminderLabel sizeToFit];
    reminderLabel.frame = CGRectMake(cell.frame.size.width-reminderLabel.frame.size.width-9, reminderLabel.frame.origin.y, reminderLabel.frame.size.width, reminderLabel.frame.size.height);
    reminderIcon.frame = CGRectMake(reminderLabel.frame.origin.x-reminderIcon.frame.size.width-3, reminderIcon.frame.origin.y, reminderIcon.frame.size.width, reminderIcon.frame.size.height);
    
    //Venue
    
    UILabel *venueLbl = (id)[cell viewWithTag:5];

    NSString *jsonString = b.event.location;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
    venueLbl.text = [loc.venueStation capitalizedString];
    
    UIImageView* areaIcon = (id)[cell viewWithTag:-1];
    areaIcon.center = CGPointMake(areaIcon.center.x, venueLbl.center.y);
    
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
    
    NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
   
    beepItbutton.hidden = ([b.beeepersIds indexOfObject:my_id] != NSNotFound);
    
    //Image
    
    UIImageView *imgV = (id)[cell viewWithTag:3];
    
    [imgV sd_setImageWithURL:[NSURL URLWithString:[[DTO sharedDTO]fixLink:b.event.imageUrl]]
              placeholderImage:[UIImage imageNamed:@"event_image"]];
    
    
    if (b.event.timestamp < [[NSDate date]timeIntervalSince1970]) { //PAST
      
        UILabel *passedLbl = (UILabel *)[[cell viewWithTag:34] viewWithTag:35];
        UIFont *font =[UIFont fontWithName:@"Mohave" size:9];
        
        for (NSString *family in [UIFont familyNames]) {
            NSLog(@"%@", [UIFont fontNamesForFamilyName:family]);
        }
        
        //[passedLbl setFont:font];
        [cell viewWithTag:34].hidden = NO;
        reminderIcon.hidden = YES;
        reminderLabel.hidden = YES;
    }
    else{
        [cell viewWithTag:34].hidden = YES;
        reminderIcon.hidden = NO;
        reminderLabel.hidden = NO;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == beeeps.count+1 && loadNextPage){
        return 51;
    }
    else if (indexPath.row == 0){
        return 86;
    }
    else{
        return 81;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    EventVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"EventVC"];
    
    viewController.tml = [beeeps objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 36;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableV.frame.size.width, 36)];
    headerV.backgroundColor = [UIColor colorWithRed:212/255.0 green:216/255.0 blue:217/255.0 alpha:1];
    
    UIView *buttonV = [[UIView alloc]initWithFrame:CGRectMake(0, 1, headerV.frame.size.width, headerV.frame.size.height-4)];
    [buttonV setBackgroundColor:[UIColor whiteColor]];
    [headerV addSubview:buttonV];
    
//    UIButton *upcomingbtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, buttonV.frame.size.width/3, buttonV.frame.size.height)];
//    upcomingbtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
//    [upcomingbtn setTitle:@"Upcoming" forState:UIControlStateNormal];
//    [upcomingbtn setBackgroundColor:[UIColor whiteColor]];
//    [upcomingbtn setTitleColor:[UIColor colorWithRed:240/255.0 green:208/255.0 blue:0 alpha:1] forState:UIControlStateNormal];
//    
//    [buttonV addSubview:upcomingbtn];
//
//    UIButton *pastbtn = [[UIButton alloc]initWithFrame:CGRectMake(upcomingbtn.frame.size.width, 0, buttonV.frame.size.width/3, buttonV.frame.size.height)];
//    pastbtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
//    [pastbtn setTitle:@"Past" forState:UIControlStateNormal];
//    [pastbtn setBackgroundColor:[UIColor whiteColor]];
//    [pastbtn setTitleColor:[UIColor colorWithRed:218/255.0 green:223/255.0 blue:226/255.0 alpha:1] forState:UIControlStateNormal];
//    
//    [buttonV addSubview:pastbtn];
//
//    UIButton *calendarbtn = [[UIButton alloc]initWithFrame:CGRectMake(pastbtn.frame.origin.x + pastbtn.frame.size.width,0, buttonV.frame.size.width/3, buttonV.frame.size.height)];
//    calendarbtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
//    [calendarbtn setTitle:@"Choose Date" forState:UIControlStateNormal];
//    [calendarbtn setBackgroundColor:[UIColor whiteColor]];
//    [calendarbtn setTitleColor:[UIColor colorWithRed:218/255.0 green:223/255.0 blue:226/255.0 alpha:1] forState:UIControlStateNormal];
//    
//    [buttonV addSubview:calendarbtn];
    
    
    UIView *bgV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, headerV.frame.size.width, headerV.frame.size.height)];
    [bgV setBackgroundColor:[UIColor whiteColor]];
    [headerV addSubview:bgV];
    
    headerVMovingView = bgV;
    
    bgV.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    bgV.layer.shadowOpacity = 0.7;
    bgV.layer.shadowOffset = CGSizeMake(0, 0.1);
    bgV.layer.shadowRadius = 0.8;
    [bgV.layer setShadowPath:[[UIBezierPath
                                bezierPathWithRect:bgV.bounds] CGPath]];
    
    UILabel *textLbl = [[UILabel alloc]initWithFrame:CGRectMake((self.tableV.frame.size.width/2)-13, 0, 133, bgV.frame.size.height)];
    textLbl.textAlignment = NSTextAlignmentLeft;
    textLbl.textColor = [UIColor colorWithRed:132/255.0 green:139/255.0 blue:145/255.0 alpha:1];

    
    switch (chooseDaySelectedIndex) {
        case 0:
            textLbl.text = @"Upcoming";
            break;
        case 1:
            textLbl.text = @"Past";
            break;
        case 2:{
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [dateFormatter setDateFormat:@"MMM YYYY"];
            NSString *dateStr = [dateFormatter stringFromDate:selectedDate];
            
            if([dateStr isKindOfClass:[NSString class]] && dateStr.length > 0){
                textLbl.text =  dateStr;
            }
            else{
                textLbl.text = @"Choose Date";
            }
            
            break;
        }
        default:
            break;
    }
    
    
    textLbl.tag = 1;
    textLbl.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    [textLbl sizeToFit];
    textLbl.center = bgV.center;
    [bgV addSubview:textLbl];
    
    headerTextLabel = textLbl;
    
    UIImageView *arrow = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"calendar-arrow.png"]];
    arrow.center = textLbl.center;
    arrow.frame = CGRectMake(textLbl.frame.origin.x+textLbl.frame.size.width+3, arrow.frame.origin.y, arrow.frame.size.width, arrow.frame.size.height);
    arrow.tag = 2;
    [bgV addSubview:arrow];
    
//    UIImageView *imgV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"calendar_btn.png"]];
//    imgV.center = textLbl.center;
//    imgV.frame = CGRectMake(16, imgV.frame.origin.y, imgV.frame.size.width, imgV.frame.size.height);
//    imgV.tag = 3;
//    [bgV addSubview:imgV];
    
    GTPushButton *btn = [GTPushButton buttonWithType:UIButtonTypeCustom];
    btn.selectionColor = [UIColor colorWithRed:225/255.0 green:226/255.0 blue:226/255.0 alpha:0.4];
    btn.frame = headerV.bounds;
    btn.backgroundColor = [UIColor clearColor];
    btn.tag = 4;
    [btn addTarget:self action:@selector(calendarPressed:) forControlEvents:UIControlEventTouchUpInside];
    [headerV addSubview:btn];
    
    return headerV;
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
    
    UIView *footer=[[UIView alloc] initWithFrame:CGRectMake(0,0,self.tableV.frame.size.width,50.0)];
    footer.backgroundColor =[UIColor clearColor];
    UILabel *lbl = [[UILabel alloc]initWithFrame:footer.bounds];
    lbl.text = (loading)?@"Loading...":@"There are no beeeps available.";
    lbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    lbl.textColor = [UIColor colorWithRed:111/255.0 green:113/255.0 blue:121/255.0 alpha:1];
    lbl.textAlignment = NSTextAlignmentCenter;
    [footer addSubview:lbl];
    
    return footer;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (self.mode == Timeline_My) {
         return YES;
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
        ; // Delete.
    
    Timeline_Object *b = [beeeps objectAtIndex:indexPath.row];
    [[BPCreate sharedBP]beeepDelete:b.event.fingerprint timestamp:b.beeep.beeepInfo.timestamp weight:b.beeep.beeepInfo.weight completionBlock:^(BOOL completed,id objct){
        if (completed) {
            dispatch_async (dispatch_get_main_queue(), ^{
                
                [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                [SVProgressHUD showSuccessWithStatus:@"Deleted!"];
                
                [beeeps removeObject:b];
                [self.tableV reloadData];
    

            });
        }
        else{
            UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Couldn't delete beeep.Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertV performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
    }];
}

- (IBAction)handleCellPan:(UIPanGestureRecognizer *)recognizer {
    
    static CGPoint lastKnownVelocity;
    
    UIView *cellV = (UITableViewCell *)recognizer.view;
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        if (lastKnownVelocity.x < 0) {
            
            recognizer.enabled = NO;
            
            [UIView animateWithDuration:0.5f
                             animations:^
             {
                 cellV.center = CGPointMake(cellV.center.x,cellV.center.y);
             }
                             completion:^(BOOL finished)
             {
                 recognizer.enabled = YES;
             }
             ];
        }
        else if(cellV.center.y < - 90){
            
            [UIView animateWithDuration:0.5f
                             animations:^
             {
                 cellV.center = CGPointMake(cellV.center.x,cellV.center.y);

             }
                             completion:^(BOOL finished)
             {
                 
             }
             ];
        }
        else{
            [UIView animateWithDuration:0.5f
                             animations:^
             {
                 cellV.center = CGPointMake(cellV.center.x,cellV.center.y);
                 
             }
                             completion:^(BOOL finished)
             {
                 
             }
             ];
            
        }
    }
    else{
        
        lastKnownVelocity = [recognizer velocityInView:cellV];
        
        if (lastKnownVelocity.y == 0)
        {
            // user dragged towards the right
            CGPoint translation = [recognizer translationInView:cellV];
            
            CGPoint newCenter = CGPointMake(recognizer.view.center.x + translation.x,
                                            recognizer.view.center.y);
            if(newCenter.x > 79 && newCenter.x < 160){
                cellV.center = newCenter;
            }
            
            [recognizer setTranslation:CGPointMake(0, 0) inView:cellV];
        
        }
    }
    
    NSLog(@"%@",NSStringFromCGPoint(cellV.center));
}

#pragma mark - UIPangesture Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer {
    
    if (self.mode == Timeline_My) {
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES; //otherGestureRecognizer is your custom pan gesture
}

#pragma mark - Actions


- (IBAction)addFriend:(id)sender {
    
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"FindFriendsVC"];
    [self.navigationController pushViewController:viewController animated:YES];
}


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
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Passed Event" message:@"You can’t  Beeep a passed event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    
    UITableViewCell *cell = (UITableViewCell *)view;

    NSIndexPath *path = [self.tableV indexPathForCell:cell];
    
    Timeline_Object *b = [beeeps objectAtIndex:path.row-1];
   
    NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
    
    if ([b.beeepersIds indexOfObject:my_id] != NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Already Beeeped" message:@"You have already Beeeeped this event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    UIImageView *imgV = (id)[cell viewWithTag:3];
    
    [[TabbarVC sharedTabbar]reBeeepPressed:b image:imgV.image controller:self];

}

- (IBAction)showLikes:(UIButton *)sender {
    
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    
    UITableViewCell *cell = (UITableViewCell *)view;

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
   
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    
    UITableViewCell *cell = (UITableViewCell *)view;

    NSIndexPath *path = [self.tableV indexPathForCell:cell];
    
    Timeline_Object *b = [beeeps objectAtIndex:path.row-1];
   
    CommentsVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentsVC"];
    viewController.event_beeep_object = b;
    viewController.comments = [NSMutableArray arrayWithArray: b.beeep.beeepInfo.comments];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showBeeepers:(UIButton *)sender {
   
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    
    UITableViewCell *cell = (UITableViewCell *)view;

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
                
                NSMutableDictionary *userMutable = [NSMutableDictionary dictionaryWithDictionary:user];
                [userMutable setObject:@"1" forKey:@"following"];
                user = [NSDictionary dictionaryWithDictionary:userMutable];
                
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
    
    if ([self.view viewWithTag:-434]) {
        return;
    }
    
    dispatch_async (dispatch_get_main_queue(), ^{
        
        CGFloat height = self.view.frame.size.height-((self.mode != Timeline_My || self.showBackButton)?0:self.tabBar.frame.size.height);
        
        UIView *loadingBGV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableV.frame.size.width, height)];
        loadingBGV.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        
        MONActivityIndicatorView *indicatorView = [[MONActivityIndicatorView alloc] init];
        indicatorView.delegate = self;
        indicatorView.numberOfCircles = 3;
        indicatorView.radius = 8;
        indicatorView.internalSpacing = 1;
        indicatorView.center = loadingBGV.center;
        indicatorView.tag = -565;
        
        loadingBGV.alpha = 0;
        [loadingBGV addSubview:indicatorView];
        loadingBGV.tag = -434;
        [self.view addSubview:loadingBGV];
        [self.view bringSubviewToFront:loadingBGV];
        
        [UIView animateWithDuration:0.3f
                         animations:^
         {
             loadingBGV.alpha = 1;
         }
                         completion:^(BOOL finished)
         {
             [indicatorView startAnimating];
         }
         ];
        
    });
    
}

-(void)hideLoading{
    

    dispatch_async (dispatch_get_main_queue(), ^{
        
        UIView *loadingBGV = (id)[self.view viewWithTag:-434];
        
        MONActivityIndicatorView *indicatorView = (id)[loadingBGV viewWithTag:-565];
        [indicatorView stopAnimating];
        
        [UIView animateWithDuration:0.3f
                         animations:^
         {
             loadingBGV.alpha = 0;
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


-(NSString*)dailyLanguageFutureDate:(NSTimeInterval )futureInterval pastDate:(NSTimeInterval) pastInterval{
    
    if (pastInterval<0)
        pastInterval*=-1;
    
    int timeDiff = futureInterval-pastInterval;
    
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Create the NSDates
    NSDate *pastDate = [[NSDate alloc] initWithTimeIntervalSince1970:pastInterval];
    NSDate *futureDate = [[NSDate alloc] initWithTimeIntervalSince1970:futureInterval];

    
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    
    NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:pastDate  toDate:futureDate  options:0];
    
    NSLog(@"Conversion: %dmin %dhours %ddays %dmoths",[conversionInfo minute], [conversionInfo hour], [conversionInfo day], [conversionInfo month]);
    
    NSInteger minutes = [conversionInfo minute];
    NSInteger hours   = [conversionInfo hour];
    NSInteger days    = [conversionInfo day];
    NSInteger months  = [conversionInfo month];
    NSInteger years   = [conversionInfo year];
    
    NSString* overdueMessage;
    
    if (years>0){
        overdueMessage = [NSString stringWithFormat:@"%d %@ before", (years),(years == 1)?@"year":@"years"];
    }else if (months>0){
        overdueMessage = [NSString stringWithFormat:@"%d %@ before", (months),(months == 1)?@"month":@"months"];
    }else if (days>0){
        overdueMessage = [NSString stringWithFormat:@"%d %@ before", (days),(days == 1)?@"day":@"days"];
    }else if (hours>0){
        overdueMessage = [NSString stringWithFormat:@"%d %@ before", (hours),(hours == 1)?@"hour":@"hours"];
    }else if (minutes>0){
        overdueMessage = [NSString stringWithFormat:@"%d %@ before", (minutes),(minutes == 1)?@"minute":@"minutes"];
    }else if (timeDiff<60){
        overdueMessage = [NSString stringWithFormat:@"On Event Time"];
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
    return (self.mode == Timeline_My)?3:4;
}

-(UIImage*) imageForItemAtIndex:(NSInteger)index
{
    NSString* imageName = nil;
   
    if (self.mode == Timeline_My) {
        switch (index) {
            case 0:
                imageName = @"Like_popup_unpressed";
                break;
            case 1:
                imageName = @"Suggest_popup_unpressed";
                break;
            case 2:
                imageName = @"Comment_popup_unpressed";
                break;
                
            default:
                break;
        }
    }
    else{
    
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
    }
    
    return [UIImage imageNamed:imageName];
}

- (void) didSelectItemAtIndex:(NSInteger)selectedIndex forMenuAtPoint:(CGPoint)point
{
    NSIndexPath* indexPath = [self.tableV indexPathForRowAtPoint:point];
    
    Timeline_Object *b = [beeeps objectAtIndex:indexPath.row];
    
    if (self.mode == Timeline_My) {
       
        switch (selectedIndex) {
            case 0:
                [self likeEventAtIndexPath:indexPath];
                break;
            case 1:
                [self suggestEventAtIndexPath:indexPath];
                break;
            case 2:
                [self commentEventAtIndexPath:indexPath];
                break;
                
            default:
                break;
        }
    }
    else{
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
}

-(void)beeepEventAtIndexPath:(NSIndexPath *)indexpath{
    
    if (segmentIndex != 0) { //Passed
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Passed Event" message:@"You can’t  Beeep a passed event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    Timeline_Object *b = [beeeps objectAtIndex:indexpath.row];
    
    NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
    
    if ([b.beeepersIds indexOfObject:my_id] != NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Already Beeeped" message:@"You have already Beeeped this event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    UITableViewCell *cell = [self.tableV cellForRowAtIndexPath:indexpath];
    UIImageView *imgV = (id)[cell viewWithTag:3];
    
    [[TabbarVC sharedTabbar]reBeeepPressed:b image:imgV.image controller:self];
    
}

-(void)likeEventAtIndexPath:(NSIndexPath *)indexpath{
    
        
    Timeline_Object *b = [beeeps objectAtIndex:indexpath.row];
    
    NSArray *likes = b.beeep.beeepInfo.likes;
    NSMutableArray *likers = [NSMutableArray array];
    
    for (Likes *l in likes) {
        
        NSString *liker;

        if ([l isKindOfClass:[NSString class]]) {
            liker = (NSString *)l;
        }
        else{
          liker = l.likers.likersIdentifier;
        }
        [likers addObject:liker];
    }
    
    if ([likers indexOfObject:[[BPUser sharedBP].user objectForKey:@"id"]] == NSNotFound) {
        
        [[EventWS sharedBP]likeBeeep:b.beeep.beeepInfo.weight user:b.beeep.userId WithCompletionBlock:^(BOOL completed,NSDictionary *response){
            if (completed) {
                
                Likes *l = [[Likes alloc]init];
                l.likers = [[Likers alloc]init];
                l.likers.likersIdentifier = [[BPUser sharedBP].user objectForKey:@"id"];
                [likers addObject:l];
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
        
        UIAlertView *alert  = [[UIAlertView alloc]initWithTitle:@"Already liked!" message:@"You have already liked this event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        
//        [[EventWS sharedBP]unlikeBeeep:b.beeep.beeepInfo.weight user:b.beeep.userId WithCompletionBlock:^(BOOL completed,Event_Show_Object *eventShow){
//            if (completed) {
//                [likers removeObject:[[BPUser sharedBP].user objectForKey:@"id"]];
//                b.beeep.beeepInfo.likes = likers;
//                [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
//                [SVProgressHUD showSuccessWithStatus:@"Unliked"];
//                
//                [self.tableV reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationFade];
//            }
//            else{
//                [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
//                [SVProgressHUD showErrorWithStatus:@"Something went wrong"];
//            }
//        }];
    }
    
}

-(void)commentEventAtIndexPath:(NSIndexPath *)indexPath{
    
    Timeline_Object*b = [beeeps objectAtIndex:indexPath.row];
    
    CommentsVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentsVC"];
    viewController.event_beeep_object = [beeeps objectAtIndex:indexPath.row];
    viewController.comments = [NSMutableArray arrayWithArray: b.beeep.beeepInfo.comments];
    viewController.showKeyboard = YES;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)suggestEventAtIndexPath:(NSIndexPath *)indexpath{
    
    Timeline_Object*b = [beeeps objectAtIndex:indexpath.row];
    
    if (b.event.fingerprint != nil) {
        [[TabbarVC sharedTabbar]suggestPressed:b.event.fingerprint controller:self sendNotificationWhenFinished:NO selectedPeople:nil showBlur:YES];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There is a problem with this Beeep. Please refresh and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
}


- (IBAction)tabbarButtonTapped:(UIButton *)sender{
    [[TabbarVC sharedTabbar]tabbarButtonTapped:sender];
}

- (IBAction)addNewBeeep:(id)sender {
    [[TabbarVC sharedTabbar]addBeeepPressed:self];
}

-(void)showBadgeIcon{
    
    if ([BPUser sharedBP].badgeNumber <= 0) {
        [self hideBadgeIcon];
        return;
    }
    
    [self performSelector:@selector(showBadgeIcon) withObject:nil afterDelay:2];
    
    UIView *b = [[UIView alloc]initWithFrame:CGRectMake(self.notificationsBadgeV.frame.origin.x+self.notificationsBadgeV.frame.size.width-2,self.notificationsBadgeV.frame.origin.y+2,200,10)];
    b.badge.outlineWidth = 0.0;
    b.badge.badgeColor = [UIColor redColor];
    b.tag = 34567;
    b.badge.badgeValue = [BPUser sharedBP].badgeNumber;
    [self.notificationsBadgeV.superview addSubview:b];
    
    //    [UIView animateWithDuration:0.2f
    //                     animations:^
    //     {
    //         self.notificationsBadgeV.alpha = 1;
    //     }
    //                     completion:^(BOOL finished)
    //     {
    //
    //     }
    //     ];
}

-(void)hideBadgeIcon{
    
    [self performSelector:@selector(showBadgeIcon) withObject:nil afterDelay:2];
    
    [[self.notificationsBadgeV.superview viewWithTag:34567]removeFromSuperview];
    
    //    [UIView animateWithDuration:0.2f
    //                     animations:^
    //     {
    //         self.notificationsBadgeV.alpha = 0;
    //     }
    //                     completion:^(BOOL finished)
    //     {
    //
    //     }
    //     ];
}



-(void)showSuggestionsBadge{
    
    if (![DTO sharedDTO].suggestionBadgeNumberFinished) {
        [self performSelector:@selector(showSuggestionsBadge) withObject:nil afterDelay:1.0];
    }
    
    [[self.suggestionsButton.superview viewWithTag:34567] removeFromSuperview];
    
    UIView *b = [[UIView alloc]initWithFrame:CGRectMake(self.suggestionsButton.frame.origin.x+5+self.suggestionsButton.frame.size.width/2,self.suggestionsButton.frame.origin.y+13,5,5)];
    b.badge.outlineWidth = 0.0;
    b.badge.badgeColor = [UIColor redColor];
    b.tag = 34567;
    b.badge.badgeValue = [DTO sharedDTO].suggestionBadgeNumber;
    [self.suggestionsButton.superview addSubview:b];
}

#pragma mark - Choose Date Popup

-(void)closeDatePopup:(int)index{

    if(index >= 0){
       
        switch (index) {
            case 0:
                headerTextLabel.text = @"Upcoming";
                break;
            case 1:
                headerTextLabel.text = @"Past";
                break;
            case 2:
                headerTextLabel.text = @"Choose Date";
                break;
            default:
                break;
        }
        
        [headerTextLabel sizeToFit];
        headerTextLabel.center = headerTextLabel.superview.center;
        
        UIImageView *arrow = (id)[headerTextLabel.superview viewWithTag:2];
        arrow.center = headerTextLabel.center;
        arrow.frame = CGRectMake(headerTextLabel.frame.origin.x+headerTextLabel.frame.size.width+3, arrow.frame.origin.y, arrow.frame.size.width, arrow.frame.size.height);
        
        [UIView animateWithDuration:0.4f
                         animations:^
         {
             
             headerTextLabel.alpha = 1;
             
             arrow.alpha = 1;
         }
                         completion:^(BOOL finished){}];
    
    }
    
    UIImageView *arrow = (id)[headerTextLabel.superview viewWithTag:2];
    
    [UIView animateWithDuration:0.5f
                     animations:^
     {
         chooseDatePopupVC.view.alpha = 0;
         
         headerTextLabel.alpha = 1;
         
         arrow.alpha = 1;
     }
                     completion:^(BOOL finished)
     {
         [chooseDatePopupVC.view removeFromSuperview];
         [chooseDatePopupVC removeFromParentViewController];
     }
     ];

}

-(void)datePopupIndexOptionSelected:(int)index{
    
    
    if (index == 0) { //upcoming
        
        chooseDaySelectedIndex = index;
        segmentIndex = index;
        selectedDate = [NSDate date];
        
        [self closeDatePopup:index];
        [self getTimeline:[self.user objectForKey:@"id"] option:Upcoming];
    }
    else if(index == 1){ //past
       
        chooseDaySelectedIndex = index;
        selectedDate = 0;
        segmentIndex = index;
        [self closeDatePopup:index];
        [self getTimeline:[self.user objectForKey:@"id"] option:Past];
    }
    else if(index == -1){
        [self closeDatePopup:-1];
        [self getTimeline:[self.user objectForKey:@"id"] option:Past];
    }
    else if(index == -10){ //tapG
        [self closeDatePopup:-1];
    }
    else{
        chooseDaySelectedIndex = index;
        selectedDate = chooseDatePopupVC.selectedDate;
        [self closeDatePopup:-1];
        [self releaseCalendar:nil];
    }
}

- (IBAction)calendarPressed:(UIButton *)sender {
    
    CGPoint pointInView = [headerTextLabel.superview convertPoint:headerTextLabel.frame.origin toView:self.view];
    
    if (pointInView.y >= 300 && [[UIScreen mainScreen] bounds].size.height < 568) {
        
        [self.tableV setContentOffset:CGPointMake(0, 55) animated:NO];
    }
    
    chooseDatePopupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChooseDatePopupVC"];
    chooseDatePopupVC.superviewToBlur = self.navigationController.view;
    
    chooseDatePopupVC.view.frame = self.view.bounds;
    chooseDatePopupVC.delegate = self;
    
    if([headerTextLabel.text isEqualToString:@"Upcoming"]){
        chooseDatePopupVC.option = 0;
    }
    else if([headerTextLabel.text isEqualToString:@"Past"]){
        chooseDatePopupVC.option = 1;
    }
    else {
        chooseDatePopupVC.option = 2;
    }
    
    chooseDatePopupVC.view.alpha = 0;
    [self.view addSubview:chooseDatePopupVC.view];
    [self addChildViewController:chooseDatePopupVC];
    
    //define Popup Y
    

    if (pointInView.y >= 300 && [[UIScreen mainScreen] bounds].size.height < 568) {
        
        chooseDatePopupVC.popupVContainer.frame = CGRectMake(0, 300, chooseDatePopupVC.view.frame.size.width, chooseDatePopupVC.view.frame.size.height);
      
    }
    else{

        chooseDatePopupVC.popupVContainer.frame = CGRectMake(0,pointInView.y, chooseDatePopupVC.view.frame.size.width, chooseDatePopupVC.view.frame.size.height);
        
    }
    
    
    [UIView animateWithDuration:0.4f
                     animations:^
     {
         chooseDatePopupVC.view.alpha = 1;
     }
                     completion:^(BOOL finished)
     {
         headerTextLabel.alpha = 0;
         UIImageView *arrow = (id)[headerTextLabel.superview viewWithTag:2];
         arrow.alpha = 0;
     }
     ];
    
    //[self animateHeaderMovingPartHide];
    
    // [self showCalendar];
}

-(void)animateHeaderMovingPartShow{
    
    headerVMovingViewShowing = YES;
    
    dispatch_async (dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.7f
                         animations:^
         {
             //headerVMovingView.frame = CGRectMake(0, headerVMovingView.frame.origin.y, headerVMovingView.frame.size.width, headerVMovingView.frame.size.height);
             headerVMovingView.alpha = 1;
         }
                         completion:^(BOOL finished)
         {
             
         }];
        
    });
}

-(void)animateHeaderMovingPartHide{
    
    headerVMovingViewShowing = NO;
    
    dispatch_async (dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.7f
                         animations:^
         {
             //headerVMovingView.frame = CGRectMake(-headerVMovingView.frame.size.width, headerVMovingView.frame.origin.y, headerVMovingView.frame.size.width, headerVMovingView.frame.size.height);
             headerVMovingView.alpha = 0;
         }
                         completion:^(BOOL finished)
         {
         }
         ];
        
    });
    
}

-(void)showCalendar{
    
    calendarBGV = [[UIView alloc]initWithFrame:self.view.bounds];
    calendarBGV.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    calendarBGV.alpha = 0;
    
    UITapGestureRecognizer *tapg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(releaseCalendar:)];
    [calendarBGV addGestureRecognizer:tapg];
    
    CalendarView *cv = [[CalendarView alloc] initWithPosition:0.0 y:10.0];
    [cv setMode:1];
    cv.calendarDelegate = self;
    
    calendarContainer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, calendarBGV.frame.size.width, cv.frame.size.height+10)];
    [calendarContainer setBackgroundColor:[UIColor whiteColor]];
    cv.center = CGPointMake(calendarContainer.center.x+5,cv.center.y+5);
    [calendarContainer addSubview:cv];
    
    calendarContainer.frame = CGRectMake(0, calendarBGV.frame.size.height, calendarBGV.frame.size.width, calendarContainer.frame.size.height);
    
    [calendarBGV addSubview:calendarContainer];
    
    [self.view addSubview:calendarBGV];

    
    [UIView animateWithDuration:0.4f
                     animations:^
     {
         calendarBGV.alpha = 1;
         calendarContainer.frame = CGRectMake(0, calendarBGV.frame.size.height-calendarContainer.frame.size.height, calendarBGV.frame.size.width, calendarContainer.frame.size.height);
     }
                     completion:^(BOOL finished)
     {
         
     }
     ];
}

-(void)releaseCalendar:(UITapGestureRecognizer *)tapG{
   
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
//    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//    dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
//    [dateFormatter setDateFormat:@"MMM YYYY"];
//    headerTextLabel.text = [dateFormatter stringFromDate:selectedDate];
//    
//    [headerTextLabel sizeToFit];
//    headerTextLabel.center = headerTextLabel.superview.center;
//    
//    UIImageView *arrow = [headerTextLabel.superview viewWithTag:2];
//    arrow.center = headerTextLabel.center;
//    arrow.frame = CGRectMake(headerTextLabel.frame.origin.x+headerTextLabel.frame.size.width+3, arrow.frame.origin.y, arrow.frame.size.width, arrow.frame.size.height);

    [self.tableV reloadData]; //refresh choose date title to add current date
    
    if(selectedDate != nil){
    
        @try {
            
            [[BPTimeline sharedBP]getTimelineForUserID:[user objectForKey:@"id"] option:0 timeStamp:[selectedDate timeIntervalSince1970] WithCompletionBlock:^(BOOL completed,NSArray *objs){
                
                UIRefreshControl *refreshControl = (id)[self.tableV viewWithTag:234];
                [refreshControl endRefreshing];
                
                if (completed) {
                    
                    loading = NO;
                    
                    if (objs) {
                        beeeps = [NSMutableArray arrayWithArray:objs];
                    }
                    
                    if (beeeps.count == 10) {
                        loadNextPage = YES;
                    }
                    else{
                        loadNextPage = NO;
                    }
                    [self.tableV setContentOffset:CGPointZero animated:YES];
                    [self.tableV reloadData];
                    
                    //  suggestionsPerSection = [NSMutableDictionary dictionary];
                    // sections = [NSMutableArray array];
                    //   [self groupBeeepsByMonth];
                }
                else{
                    if ([objs isKindOfClass:[NSString class]]) {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"getTimeline Not Completed" message:(NSString *)objs delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                        [alert show];
                        
                    }
                }
            }];
            
        }
        @catch (NSException *exception) {
            NSLog(@"ELA!");
        }
        @finally {
            
        }
    }
    
    [UIView animateWithDuration:0.4f
                     animations:^
     {
         calendarBGV.alpha = 0;
         calendarContainer.frame = CGRectMake(0, calendarBGV.frame.size.height, calendarContainer.frame.size.width, calendarContainer.frame.size.height);
     }
                     completion:^(BOOL finished)
     {
         [calendarContainer removeFromSuperview];
         [calendarBGV removeFromSuperview];
     }
     ];
}

#pragma mark - Calendar Delegate

- (void)didChangeCalendarDate:(NSDate *)date{
    selectedDate = date;
}

- (void)didDoubleTapCalendar:(NSDate *)date withType:(NSInteger)type{

    selectedDate = date;
    
    [self releaseCalendar:nil];
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
