//
//  HomeFeedVC.m
//  Beeeper
//
//  Created by User on 3/19/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "HomeFeedVC.h"
#import "EventVC.h"
#import "FollowListVC.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "CHTCollectionViewWaterfallHeader.h"
#import "CHTCollectionViewWaterfallFooter.h"
#import "SearchVC.h"
#import "GTSegmentedControl.h"
#import "Friendsfeed_Object.h"
#import "CommentsVC.h"
#import "TimelineVC.h"
#import "GHContextMenuView.h"
#import "EventWS.h"
#import "Event_Show_Object.h"
#import "BorderTextField.h"
#import "Event_Search.h"
#import "BeeepedBy.h"
#import <QuartzCore/QuartzCore.h>

@interface HomeFeedVC ()<UICollectionViewDataSource,UICollectionViewDelegate,CHTCollectionViewDelegateWaterfallLayout,GHContextOverlayViewDataSource, GHContextOverlayViewDelegate,MONActivityIndicatorViewDelegate>
{
    NSMutableArray *textSizes;
    NSMutableArray *beeeps;
    NSMutableArray *events;
   
    GTSegmentedControl *segment;
    GHContextMenuView* overlay;
    
    int selectedIndex;
    BOOL loadNextPage;
    BOOL initiateData;
    BOOL getNextPage;
}
@end

@implementation HomeFeedVC


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)nextPage{
    
    if (!loadNextPage) {
        return;
    }
    
    if (selectedIndex == 1) {
        [self getNextFriendsFeed];
    }
    else{
        [self nextHomeFeed];
    }
    
}

-(void)refreshCollectionView{
    
    if ([self.collectionV viewWithTag:234] == nil) {
        
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
        refreshControl.tag = 234;
        refreshControl.tintColor = [UIColor whiteColor];
        [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        
        [self.collectionV addSubview:refreshControl];
    }
    
    [self.collectionV reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    initiateData = YES;
    
    selectedIndex = 1; //FriendsFeed only
    
    overlay = [[GHContextMenuView alloc] init];
    overlay.dataSource = self;
    overlay.delegate = self;
    
	// Do any additional setup after loading the view.
    //    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    UILongPressGestureRecognizer* _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:overlay action:@selector(longPressDetected:)];
    [self.collectionV addGestureRecognizer:_longPressRecognizer];

//    for (UIView *view in [[[self.navigationController.navigationBar subviews] objectAtIndex:0] subviews]) {
//        if ([view isKindOfClass:[UIImageView class]]) view.hidden = YES;
//    }
    
    self.collectionV.alwaysBounceVertical = YES;
    
    //self.collectionV.decelerationRate = 0.6;
    
    CHTCollectionViewWaterfallLayout *layout = (id)self.collectionV.collectionViewLayout;
    
    layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);
    layout.headerHeight = 0;
    layout.footerHeight = 50;
    layout.minimumColumnSpacing = 8;
    layout.minimumInteritemSpacing = 8;

//    [self.collectionV registerClass:[CHTCollectionViewWaterfallHeader class]
//        forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader
//               withReuseIdentifier:@"HeaderView"];

    [self.collectionV registerClass:[CHTCollectionViewWaterfallFooter class]
        forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter
               withReuseIdentifier:@"FooterView"];

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.backItem.title = @"";
    
    UIImageView *titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beeeper_logo"]];
    [self.navigationItem setTitleView:titleView];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add_friend_icon"] style:UIBarButtonItemStyleBordered target:self action:@selector(showFindFriends)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)refresh{
    
    if (selectedIndex == 1) {
        [self getFriendsFeed];
    }
    else{
        [self getHomefeed];
    }
}

-(void)getFriendsFeed{
    
    [self showLoading];
    
    loadNextPage = NO;
    
    [[BPHomeFeed sharedBP]getLocalFriendsFeed:^(BOOL completed,NSArray *objs){
        
        dispatch_async (dispatch_get_main_queue(), ^{
        
            if (completed) {
                
                if (objs.count > 0) {
                        
                    UIRefreshControl *refreshControl = (id)[self.collectionV viewWithTag:234];
                    [refreshControl endRefreshing];
                    
                    events = nil;
                    beeeps = [NSMutableArray arrayWithArray:objs];
                    [self refreshCollectionView];
                    
                    [self hideLoading];
                }
            }
            
         });
    }];

    
    [[BPHomeFeed sharedBP]getFriendsFeedWithCompletionBlock:^(BOOL completed,NSArray *objs){
        
        dispatch_async (dispatch_get_main_queue(), ^{
        
            UIRefreshControl *refreshControl = (id)[self.collectionV viewWithTag:234];
            [refreshControl endRefreshing];
            
            if (completed) {
                
                if ([objs isKindOfClass:[NSArray class]]) {
                   
                    loadNextPage = (objs.count == [BPHomeFeed sharedBP].pageLimit);
                    self.noBeeepsLabel.hidden = (objs.count != 0);
                    
                    events = nil;
                    beeeps = [NSMutableArray arrayWithArray:objs];
                }
                else if ([objs isKindOfClass:[NSString class]]) {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"getFriendsFeed Completed but objs is not NSArray class" message:(NSString *)objs delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                        [alert show];
                    
                }
                
                [self refreshCollectionView];
                
            }
            else{
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"getFriendsFeed NOT Completed" message:(NSString *)objs delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
            }

            
            [self hideLoading];
        });
    }];

}

-(void)getNextFriendsFeed{

    loadNextPage = NO;
    
    [[BPHomeFeed sharedBP]nextFriendsFeedWithCompletionBlock:^(BOOL completed,NSArray *objs){
        
        UIRefreshControl *refreshControl = (id)[self.collectionV viewWithTag:234];
        [refreshControl endRefreshing];
        
        if (completed && objs.count >0) {
            
            dispatch_async (dispatch_get_main_queue(), ^{
                
                events = nil;
                [beeeps addObjectsFromArray:objs];
                loadNextPage = (objs.count == [BPHomeFeed sharedBP].pageLimit);
                
                [self refreshCollectionView];
            });
        }
        
    }];
}

-(void)nextHomeFeed{
    
    loadNextPage = NO;
    
    [[EventWS sharedBP]nextAllEventsWithCompletionBlock:^(BOOL completed,NSArray *objs){
        
        UIRefreshControl *refreshControl = (id)[self.collectionV viewWithTag:234];
        [refreshControl endRefreshing];
        
        if (completed) {
          
            dispatch_async (dispatch_get_main_queue(), ^{
                
                if (objs.count != 0) {
                    
                    beeeps = nil;
                    [events addObjectsFromArray:objs];
                    
                    loadNextPage = (objs.count == [EventWS sharedBP].pageLimit);
                    
                    [self refreshCollectionView];
                }
                else{
                    if ([objs isKindOfClass:[NSString class]]) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{

                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"getHomefeed Completed but objs.count == 0" message:(NSString *)objs delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                            [alert show];
                        });
                        
                    }
                }
                
            });
            
        }
        
    }];
}

-(void)getHomefeed{
    
    [self showLoading];
    
    loadNextPage = NO;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [[EventWS sharedBP]getAllLocalEvents:^(BOOL completed,NSArray *objs){
        
        dispatch_async (dispatch_get_main_queue(), ^{
    
            if (completed) {
              
                if (objs.count != 0) {
                   
                    beeeps = nil;
                    events = [NSMutableArray arrayWithArray:objs];
                    
                    UIRefreshControl *refreshControl = (id)[self.collectionV viewWithTag:234];
                    [refreshControl endRefreshing];
                    
                    [self refreshCollectionView];
                    
                    [self hideLoading];
                }
            }
            
        });
    }];

    
    
    [[EventWS sharedBP]getAllEventsWithCompletionBlock:^(BOOL completed,NSArray *objs){
        
        if (completed) {

            dispatch_async (dispatch_get_main_queue(), ^{
            
                UIRefreshControl *refreshControl = (id)[self.collectionV viewWithTag:234];
                [refreshControl endRefreshing];
                
                if (objs.count != 0) {
                    loadNextPage = (objs.count == [EventWS sharedBP].pageLimit);
                    self.noBeeepsLabel.hidden = YES;
                }
                else{
                    
                    if ([objs isKindOfClass:[NSString class]]) {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"getAllEvents Completed but objs.count == 0" message:(NSString *)objs delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                        [alert show];
                        
                    }
                    
                    self.noBeeepsLabel.hidden = NO;
                }

                beeeps = nil;
                events = [NSMutableArray array];
                
                if (objs) {
                    [events addObjectsFromArray:objs];
                }
                
                [self refreshCollectionView];
                
            });
        }
        
        [self hideLoading];
                            
    }];
}


-(void)showFindFriends{
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"FindFriendsVC"];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];

    [self.collectionV reloadData];
    
    [self showBadgeIcon];
    
    for (UIButton *btn in self.tabBar.subviews) {
        
        if (![btn isKindOfClass:[UIButton class]]) {
            continue;
        }
        
        if (btn.tag != 1) {
            btn.selected = NO;
        }
        else{
            btn.selected = YES;
        }
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (initiateData) {
        initiateData = NO;
        //[self getHomefeed];
        [self getFriendsFeed];
    }

    [self refreshCollectionView];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ShowTabbar" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
 //   [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:nil object: nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return (selectedIndex == 1)?beeeps.count:events.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (events != nil) {
    
        UICollectionViewCell * cell = [cv dequeueReusableCellWithReuseIdentifier:@"EventCellWaterfallLite" forIndexPath:indexPath];
        
        //        cell.layer.borderWidth = 1.0;
//        cell.layer.borderColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:0.2].CGColor;

        Event_Search *event = [events objectAtIndex:indexPath.row];
        
        double now_time = [[NSDate date]timeIntervalSince1970];
        double event_timestamp = event.timestamp;
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE, MMM dd, yyyy HH:mm"];
        
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [formatter setLocale:usLocale];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:event.timestamp];
        NSString *dateStr = [formatter stringFromDate:date];
        NSArray *components = [dateStr componentsSeparatedByString:@","];
        NSArray *day_month= [[components objectAtIndex:1]componentsSeparatedByString:@" "];
        
        NSString *month = [day_month objectAtIndex:1];
        NSString *daynumber = [day_month objectAtIndex:2];
        
        UIView *containerV = [cell viewWithTag:55];

        UILabel *monthLbl = (id)[containerV viewWithTag:1];
        UILabel *dayLbl = (id)[containerV viewWithTag:2];
        UIImageView *imageV = (id)[containerV viewWithTag:3];
        UILabel *titleLbl = (id)[containerV viewWithTag:4];
        
      //  monthLbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
       // monthLbl.textColor = [UIColor colorWithRed:240/255.0 green:208/255.0 blue:0/255.0 alpha:1];
        monthLbl.text = [month uppercaseString];
        
      //  dayLbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:24];
        dayLbl.text = daynumber;
       // dayLbl.textColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:1];
        
        //imageV.image = [UIImage imageNamed:[event objectForKey:@"image"]];
        
      //  titleLbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
       // titleLbl.textColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:1];
        
        //    NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc]initWithString:[event.title capitalizedString]];
        //    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
        
        //    [paragrahStyle setAlignment:NSTextAlignmentCenter];
        //
        //    [paragrahStyle setMaximumLineHeight:18];
        //
        //    [titleStr addAttribute:NSFontAttributeName value:titleLbl.font range:NSMakeRange(0, [event.title length])];
        //    [titleStr addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [event.title length])];
        
        titleLbl.text = [event.title capitalizedString];
        [titleLbl sizeToFit];
        [titleLbl setFrame:CGRectMake(titleLbl.frame.origin.x, titleLbl.frame.origin.y, 119, titleLbl.frame.size.height)];
        
        //    CGSize size = [self frameForText:titleLbl.attributedText constrainedToSize:CGSizeMake(116, CGFLOAT_MAX)];
        
        //    titleLbl.frame = CGRectMake(titleLbl.frame.origin.x, titleLbl.frame.origin.y, 116, size.height + 5);
        
        UIView *bottomV = (id)[cell viewWithTag:5];
        
        //bottomV.frame = CGRectMake(bottomV.frame.origin.x, title.frame.origin.y + title.frame.size.height, bottomV.frame.size.width, bottomV.frame.size.height);
        
        UILabel *area = (id)[containerV viewWithTag:-2];
        area.frame = CGRectMake(37, 190, 108, 32);
        
      //  area.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
        area.textColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1];
        NSString *jsonString = event.location;
        
        if (jsonString != nil) {
            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
            area.text = [loc.venueStation capitalizedString];
            [area sizeToFit];
        }

        if (area.frame.size.width > 130  && now_time > event_timestamp) {
            [area setFrame:CGRectMake(15, area.frame.origin.y, 130, area.frame.size.height)];
        }
        
        area.center = CGPointMake(containerV.center.x, area.center.y);
        area.frame = CGRectMake(area.frame.origin.x, titleLbl.frame.origin.y+titleLbl.frame.size.height-1, area.frame.size.width, area.frame.size.height);
        
        UIImageView *areaIcon = (id)[containerV viewWithTag:-1];
        areaIcon.frame = CGRectMake(area.frame.origin.x-9, area.frame.origin.y+1.5, areaIcon.frame.size.width, areaIcon.frame.size.height);
        
        //now move are to center
        area.textAlignment = NSTextAlignmentCenter;
        
        UILabel *favorites = (id)[containerV viewWithTag:-3];
        UILabel *comments = (id)[containerV viewWithTag:-4];
        UILabel *beeeps = (id)[containerV viewWithTag:-5];
        favorites.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        comments.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        beeeps.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];

        
        beeeps.text = [NSString stringWithFormat:@"%d",(int)event.beeepedBy.count];
        favorites.text = [NSString stringWithFormat:@"%d",(int)event.likes.count];
        comments.text = [NSString stringWithFormat:@"%d",(int)event.comments.count];
        
        favorites.hidden = (favorites.text.intValue == 0);
        comments.hidden = (comments.text.intValue == 0);
        beeeps.hidden = (beeeps.text.intValue == 0);
        
        
      //  NSString *extension = [[event.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        [imageV sd_setImageWithURL:[NSURL URLWithString:[[DTO sharedDTO] fixLink:event.imageUrl]]
                placeholderImage:[UIImage imageNamed:@"event_image"]];
        
        UIView *beeepedByView = (id)[containerV viewWithTag:32];
        
        //disable Beeep button if past event
        
        UIButton *beeepBtn = (id)[containerV viewWithTag:99];
        UIView *passed =(id)[containerV viewWithTag:34];
       
        return cell;
    }
    else{
        
            UICollectionViewCell *cell;
        
            Friendsfeed_Object *event = [beeeps objectAtIndex:indexPath.row];
        
            double now_time = [[NSDate date]timeIntervalSince1970];
            double event_timestamp = event.eventFfo.eventDetailsFfo.timestamp;
            
            if (now_time > event_timestamp) {
               cell = [cv dequeueReusableCellWithReuseIdentifier:@"EventCellWaterfallDisabled" forIndexPath:indexPath];
            }
            else{
               cell = [cv dequeueReusableCellWithReuseIdentifier:@"EventCellWaterfall" forIndexPath:indexPath];
            }
        
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEEE, MMM dd, yyyy HH:mm"];
            
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [formatter setLocale:usLocale];
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:event.eventFfo.eventDetailsFfo.timestamp];
            NSString *dateStr = [formatter stringFromDate:date];
            NSArray *components = [dateStr componentsSeparatedByString:@","];
            NSArray *day_month= [[components objectAtIndex:1]componentsSeparatedByString:@" "];
            
            NSString *month = [day_month objectAtIndex:1];
            NSString *daynumber = [day_month objectAtIndex:2];
            
            UIView *containerV = [cell viewWithTag:55];
            
            UILabel *monthLbl = (id)[containerV viewWithTag:1];
            UILabel *dayLbl = (id)[containerV viewWithTag:2];
            UIImageView *imageV = (id)[containerV viewWithTag:3];
            UILabel *titleLbl = (id)[containerV viewWithTag:4];
            
            //monthLbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
            //monthLbl.textColor = [UIColor colorWithRed:240/255.0 green:208/255.0 blue:0/255.0 alpha:1];
            monthLbl.text = [month uppercaseString];
            
           // dayLbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:24];
            dayLbl.text = daynumber;
           // dayLbl.textColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:1];
            
            //imageV.image = [UIImage imageNamed:[event objectForKey:@"image"]];

           // titleLbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
          //  titleLbl.textColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:1];
            
        //    NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc]initWithString:[event.title capitalizedString]];
        //    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
            
        //    [paragrahStyle setAlignment:NSTextAlignmentCenter];
        //    
        //    [paragrahStyle setMaximumLineHeight:18];
        //    
        //    [titleStr addAttribute:NSFontAttributeName value:titleLbl.font range:NSMakeRange(0, [event.title length])];
        //    [titleStr addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [event.title length])];
           
            titleLbl.text = [event.eventFfo.eventDetailsFfo.title capitalizedString];
            [titleLbl sizeToFit];
            [titleLbl setFrame:CGRectMake(titleLbl.frame.origin.x, titleLbl.frame.origin.y, 119, titleLbl.frame.size.height)];
            
        //    CGSize size = [self frameForText:titleLbl.attributedText constrainedToSize:CGSizeMake(116, CGFLOAT_MAX)];
            
        //    titleLbl.frame = CGRectMake(titleLbl.frame.origin.x, titleLbl.frame.origin.y, 116, size.height + 5);
            
            UIView *bottomV = (id)[cell viewWithTag:5];
            
            //bottomV.frame = CGRectMake(bottomV.frame.origin.x, title.frame.origin.y + title.frame.size.height, bottomV.frame.size.width, bottomV.frame.size.height);
            
            UILabel *area = (id)[containerV viewWithTag:-2];
            area.frame = CGRectMake(37, 190, 108, 32);
            
            //area.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
            area.textColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1];
        
        
        @try {
            
            NSString *jsonString = event.eventFfo.eventDetailsFfo.location;
            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
            area.text = [loc.venueStation capitalizedString];
            [area sizeToFit];
            area.center = CGPointMake(containerV.center.x, area.center.y);
            area.frame = CGRectMake(area.frame.origin.x, titleLbl.frame.origin.y+titleLbl.frame.size.height+3, area.frame.size.width, area.frame.size.height);
            
            if (area.frame.size.width > 130  && now_time > event_timestamp) {
                [area setFrame:CGRectMake(15, area.frame.origin.y, 130, area.frame.size.height)];
            }
            
            UIImageView *areaIcon = (id)[containerV viewWithTag:-1];
            areaIcon.frame = CGRectMake(area.frame.origin.x-9, area.frame.origin.y+1.5, areaIcon.frame.size.width, areaIcon.frame.size.height);
            
            //now move are to center
            area.textAlignment = NSTextAlignmentCenter;

        }
        @catch (NSException *exception) {
            NSLog(@"ESKASEEE");
        }
        @finally {
    
        }
            
            UILabel *favorites = (id)[containerV viewWithTag:-3];
            UILabel *comments = (id)[containerV viewWithTag:-4];
            UILabel *beeeps = (id)[containerV viewWithTag:-5];
            favorites.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
            comments.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
            beeeps.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
            
            Beeeps *b = [event.beeepFfo.beeeps firstObject];
            
            favorites.text = [NSString stringWithFormat:@"%d",(int)b.likes.count];
            comments.text = [NSString stringWithFormat:@"%d",(int)b.comments.count];
            beeeps.text = [NSString stringWithFormat:@"%d",(int)event.eventFfo.beeepedBy.count];
            
            favorites.hidden = (favorites.text.intValue == 0);
            comments.hidden = (comments.text.intValue == 0);
            beeeps.hidden = (beeeps.text.intValue == 0);
        
            float centerOfPassedIcon = (favorites.frame.origin.y - area.frame.origin.y-area.frame.size.height)/2;
        
            UIImageView *passedIcon = (UIImageView *)[cell viewWithTag:67];
        
            passedIcon.center = CGPointMake(passedIcon.center.x, favorites.frame.origin.y - centerOfPassedIcon);
           // NSString *extension = [[event.eventFfo.eventDetailsFfo.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
            
            [imageV sd_setImageWithURL:[NSURL URLWithString:[[DTO sharedDTO] fixLink:event.eventFfo.eventDetailsFfo.imageUrl]]
                placeholderImage:[UIImage imageNamed:@"event_image"]];
        
            UIView *beeepedByView = (id)[containerV viewWithTag:32];
            UIImageView *beeepedByImageV =(id)[beeepedByView viewWithTag:34];
            UILabel *beeepedByLabel =(id)[beeepedByView viewWithTag:35];
            UILabel *beeepedByNameLabel =(id)[beeepedByView viewWithTag:33];
            
            beeepedByLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:9];
            beeepedByLabel.textColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1];

            beeepedByNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
            beeepedByNameLabel.textColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:1];
            
            beeepedByNameLabel.text = [event.whoFfo.name capitalizedString];
            
           // NSString *who_extension = [[event.eventFfo.eventDetailsFfo.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        
            [beeepedByImageV sd_setImageWithURL:[NSURL URLWithString:[[DTO sharedDTO] fixLink:event.whoFfo.imagePath]]
                     placeholderImage:[UIImage imageNamed:@"user_icon_180x180"]];
            //disable Beeep button if past event
        
            return cell;
    }

}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    return UIEdgeInsetsMake(0, 7, 3, 7);
//}

- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{

    UICollectionReusableView * reusableview = nil ;
    
//    if ( kind == CHTCollectionElementKindSectionHeader ) {
//        
//        UICollectionReusableView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind : CHTCollectionElementKindSectionHeader withReuseIdentifier : @ "HeaderView" forIndexPath : indexPath] ;
//
//        if (!segment) {
//            
//            segment = [GTSegmentedControl initWithOptions:[NSArray arrayWithObjects:@"All Beeeps", @"Friends' Beeeps", nil] size:CGSizeMake(303, 32) selectedIndex:selectedIndex selectionColor:[UIColor colorWithRed:240/255.0 green:208/255.0 blue:0 alpha:1]];
//            segment.delegate = self;
//            [headerView addSubview:segment];
//            segment.frame = CGRectMake(0, headerView.frame.size.height-segment.frame.size.height, segment.frame.size.width, segment.frame.size.height);
//            segment.center = CGPointMake(headerView.center.x,segment.center.y);
//        }
//        
//        reusableview = headerView;
//    }
    
    if ([kind isEqualToString:CHTCollectionElementKindSectionFooter]) {
        UICollectionReusableView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind : CHTCollectionElementKindSectionFooter withReuseIdentifier : @ "FooterView" forIndexPath : indexPath] ;
        
        UIActivityIndicatorView *actv = (id)[headerView viewWithTag:12];
        actv.hidden = YES;
        [actv removeFromSuperview];

        if (loadNextPage) {
            NSLog(@"Add loading");
            UIActivityIndicatorView *activIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, 25)];
            activIndicator.tag = 12;
            [headerView addSubview:activIndicator];
            [activIndicator startAnimating];
            getNextPage = YES;
        }

        reusableview = headerView;

    }
    
    return reusableview;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

        if (getNextPage) {
            getNextPage = NO;
            [self nextPage];
        }
}

-(void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  
    EventVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"EventVC"];
    
    if (beeeps != nil || selectedIndex == 1) {
        viewController.tml = [beeeps objectAtIndex:indexPath.row];
    }
    else{
        viewController.tml = [events objectAtIndex:indexPath.row];
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    CGSize textsize = [[textSizes objectAtIndex:indexPath.row] CGSizeValue];
//    CGSize size = CGSizeMake(148, textsize.height + 145 +144);
    return CGSizeMake(148, (selectedIndex == 1)?327:303);
}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//
//    NSDictionary *event = [events objectAtIndex:indexPath.row];
//
//    NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc]initWithString:[event objectForKey:@"title"]];
//    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
//    
//    [paragrahStyle setMaximumLineHeight:18];
//    
//    [titleStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18] range:NSMakeRange(0, [[event objectForKey:@"title"] length])];
//    [titleStr addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [[event objectForKey:@"title"] length])];
//    
//    CGSize size = [self frameForText:titleStr constrainedToSize:CGSizeMake(123, CGFLOAT_MAX)];
//    
//    return CGSizeMake(148,165 + size.height + 76);
//}


-(CGSize)frameForText:(NSAttributedString *) text constrainedToSize:(CGSize)size{
    
    CGRect frame = [text boundingRectWithSize:size
                                      options:(NSStringDrawingUsesLineFragmentOrigin) context:nil];
    
    // This contains both height and width, but we really care about height.
    return frame.size;
}


- (IBAction)eventBeeepPressed:(UIButton *)sender {
    
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UICollectionViewCell class]]) {
        view = [view superview];
    }
    
    UICollectionViewCell *cell = (UICollectionViewCell *)view;
    
    NSIndexPath *path = [self.collectionV indexPathForCell:cell];
    
    UIView *containerV = [cell viewWithTag:55];
    UIImageView *imageV = (id)[containerV viewWithTag:3];
    
    [[TabbarVC sharedTabbar]reBeeepPressed:[beeeps objectAtIndex:path.row] image:imageV.image controller:self];
    
}

- (IBAction)showUser:(UIButton *)sender {
    
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UICollectionViewCell class]]) {
        view = [view superview];
    }
    
    UICollectionViewCell *cell = (UICollectionViewCell *)view;
    NSIndexPath *path = [self.collectionV indexPathForCell:cell];
    
    Friendsfeed_Object*b = [beeeps objectAtIndex:path.row];
  
    TimelineVC *timelineVC = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"TimelineVC"];
    timelineVC.mode = Timeline_Not_Following;
    
    NSDictionary *user = [b.whoFfo dictionaryRepresentation];
    timelineVC.user = user;
    
    [self.navigationController pushViewController:timelineVC animated:YES];
}

- (IBAction)showBeeepLikes:(UIButton *)sender {
    
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UICollectionViewCell class]]) {
        view = [view superview];
    }
    
    UICollectionViewCell *cell = (UICollectionViewCell *)view;
    NSIndexPath *path = [self.collectionV indexPathForCell:cell];
    
    Friendsfeed_Object*b = [beeeps objectAtIndex:path.row];
    Beeeps *beeep = [b.beeepFfo.beeeps firstObject];
    
    FollowListVC *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowListVC"];
    viewController.mode = LikesMode;
    viewController.ids = [beeep.likes valueForKey:@"likes"];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showBeeepComments:(UIButton *)sender {
    
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UICollectionViewCell class]]) {
        view = [view superview];
    }
    
    UICollectionViewCell *cell = (UICollectionViewCell *)view;
    NSIndexPath *path = [self.collectionV indexPathForCell:cell];
    
    Friendsfeed_Object*b = [beeeps objectAtIndex:path.row];
    Beeeps *beeep = [b.beeepFfo.beeeps firstObject];
    
    CommentsVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentsVC"];
    viewController.event_beeep_object = [beeeps objectAtIndex:path.row];
    viewController.comments = beeep.comments;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showReBeeeps:(UIButton *)sender {
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UICollectionViewCell class]]) {
        view = [view superview];
    }
    
    UICollectionViewCell *cell = (UICollectionViewCell *)view;
    NSIndexPath *path = [self.collectionV indexPathForCell:cell];

    Friendsfeed_Object*b = [beeeps objectAtIndex:path.row];
    
    FollowListVC *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowListVC"];
    viewController.mode = BeeepersMode;
    viewController.ids = b.eventFfo.beeepedBy;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showEventLikes:(UIButton *)sender {
    
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UICollectionViewCell class]]) {
        view = [view superview];
    }
    
    UICollectionViewCell *cell = (UICollectionViewCell *)view;
    NSIndexPath *path = [self.collectionV indexPathForCell:cell];
    
    Event_Search* event = [events objectAtIndex:path.row];
    
    
    FollowListVC *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowListVC"];
    viewController.mode = LikesMode;
    viewController.ids = event.likes;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showEventComments:(UIButton *)sender {
    
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UICollectionViewCell class]]) {
        view = [view superview];
    }
    
    UICollectionViewCell *cell = (UICollectionViewCell *)view;
    NSIndexPath *path = [self.collectionV indexPathForCell:cell];
    
    Event_Search *event = [events objectAtIndex:path.row];
    
    CommentsVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentsVC"];
    viewController.event_beeep_object = event;
    viewController.comments = event.comments;

    [self.navigationController pushViewController:viewController animated:YES];

}

- (IBAction)showEventBeepers:(UIButton *)sender {
 
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UICollectionViewCell class]]) {
        view = [view superview];
    }
    
    UICollectionViewCell *cell = (UICollectionViewCell *)view;
    NSIndexPath *path = [self.collectionV indexPathForCell:cell];
    
    Event_Search* event = [events objectAtIndex:path.row];
    
    
    FollowListVC *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowListVC"];
    viewController.mode = BeeepersMode;
    viewController.ids = [event.beeepedBy valueForKey:@"beeepedByIdentifier"];
    
    [self.navigationController pushViewController:viewController animated:YES];

}


#pragma mark - GHMenu methods

-(BOOL) shouldShowMenuAtPoint:(CGPoint)point
{
    NSIndexPath* indexPath = [self.collectionV indexPathForItemAtPoint:point];
    UICollectionViewCell* cell = [self.collectionV cellForItemAtIndexPath:indexPath];
    
    if ([cell viewWithTag:3455465]) {
        return NO;
    }
    
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
    NSIndexPath* indexPath = [self.collectionV indexPathForItemAtPoint:point];
    
    
    NSString* msg = nil;
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
    
    
    if (beeeps != nil || selectedIndex == 1) {
        Friendsfeed_Object *ffo = [beeeps objectAtIndex:indexpath.row];
       
        NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
        
        NSArray *beeeepers = ffo.eventFfo.beeepedBy;
        
        for (NSString *beeeper in beeeepers) {
            if ([beeeper isEqualToString:my_id]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Already Beeeped" message:@"You have already Beeeped this event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
        }
    }
    else{
        Event_Search *event = [events objectAtIndex:indexpath.row];
        
        NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
        
        NSArray *beeeepers = event.beeepedBy;
        
        for (BeeepedBy *beeeper in beeeepers) {
            if ([beeeper.beeepedByIdentifier isEqualToString:my_id]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Already Beeeped" message:@"You have already Beeeped this event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
        }
    }
 
    
    UICollectionViewCell *cell= [self.collectionV cellForItemAtIndexPath:indexpath];

    UIView *containerV = [cell viewWithTag:55];
    UIImageView *imageV = (id)[containerV viewWithTag:3];
    
    if ([cell.reuseIdentifier isEqualToString:@"EventCellWaterfallDisabled"]) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Passed Event" message:@"Can not Beeep a passed event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    id tml;
    
    if (beeeps != nil || selectedIndex == 1) {
         tml = [beeeps objectAtIndex:indexpath.row];
    }
    else{
         tml = [events objectAtIndex:indexpath.row];
    }
    
    [[TabbarVC sharedTabbar]reBeeepPressed:tml image:imageV.image controller:self];

}

-(void)likeEventAtIndexPath:(NSIndexPath *)indexpath{
    
    if (beeeps != nil || selectedIndex == 1) {
        
        Friendsfeed_Object *ffo = [beeeps objectAtIndex:indexpath.row];
        
        Beeeps *bps = [ffo.beeepFfo.beeeps firstObject];
        
        NSMutableArray *likers = [NSMutableArray arrayWithArray:[bps.likes valueForKey:@"likes"]];
        
        if ([likers indexOfObject:[[BPUser sharedBP].user objectForKey:@"id"]] == NSNotFound) {
           
            [[EventWS sharedBP]likeBeeep:bps.weight user:ffo.beeepFfo.userId WithCompletionBlock:^(BOOL completed,NSDictionary *response){
                if (completed) {
                    
                    [likers addObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                    bps.likes = likers;
                    
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                    [SVProgressHUD showSuccessWithStatus:@"Liked!"];
                    
                    [self.collectionV reloadItemsAtIndexPaths:@[indexpath]];
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
            [[EventWS sharedBP]unlikeBeeep:bps.weight user:ffo.beeepFfo.userId WithCompletionBlock:^(BOOL completed,Event_Show_Object *eventShow){
                if (completed) {
                    [likers removeObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                    bps.likes = likers;
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                    [SVProgressHUD showSuccessWithStatus:@"Unliked"];
                    
                    [self.collectionV reloadItemsAtIndexPaths:@[indexpath]];
                }
            }];
        }
        
    }
    else{
        
        Event_Search *event = [events objectAtIndex:indexpath.row];
        
        NSMutableArray *likers = [NSMutableArray arrayWithArray:event.likes];
        
        if ([likers indexOfObject:[[BPUser sharedBP].user objectForKey:@"id"]] == NSNotFound) {
            
            [[EventWS sharedBP]likeEvent:event.fingerprint WithCompletionBlock:^(BOOL completed,NSDictionary *response){
                
                if (completed) {
                    
                    [likers addObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                    event.likes = likers;
                    
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                    [SVProgressHUD showSuccessWithStatus:@"Liked!"];
                    
                    [self.collectionV reloadItemsAtIndexPaths:@[indexpath]];
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
            
            [[EventWS sharedBP]unlikeEvent:event.fingerprint WithCompletionBlock:^(BOOL completed,Event_Show_Object *eventShow){
                if (completed) {
                    [likers removeObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                    event.likes = likers;
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                    [SVProgressHUD showSuccessWithStatus:@"Unliked"];

                    [self.collectionV reloadItemsAtIndexPaths:@[indexpath]];
                }
                else{
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                    [SVProgressHUD showErrorWithStatus:@"Something went wrong"];
                }
                
            }];
        }
    }
    
}

-(void)commentEventAtIndexPath:(NSIndexPath *)indexPath{
    
    if (beeeps != nil) {
        
        Friendsfeed_Object*b = [beeeps objectAtIndex:indexPath.row];
        Beeeps *beeep = [b.beeepFfo.beeeps firstObject];
        
        CommentsVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentsVC"];
        viewController.event_beeep_object = [beeeps objectAtIndex:indexPath.row];
        viewController.comments = beeep.comments;
        viewController.showKeyboard = YES;
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else{
        
        Event_Search*b = [events objectAtIndex:indexPath.row];
        
        CommentsVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentsVC"];
        viewController.event_beeep_object = b;
        viewController.comments = b.comments;
        viewController.showKeyboard = YES;
        
        [self.navigationController pushViewController:viewController animated:YES];

    }
    
}

-(void)suggestEventAtIndexPath:(NSIndexPath *)indexpath{
    
    NSString *localFingerPrint;
    
    if (beeeps != nil || selectedIndex == 1) {
            
        Friendsfeed_Object *ffo = [beeeps objectAtIndex:indexpath.row];
        
        Beeeps *bps = [ffo.beeepFfo.beeeps firstObject];
        
        localFingerPrint = ffo.eventFfo.eventDetailsFfo.fingerprint;
        
    }
    else{
        
        Event_Search *event = [events objectAtIndex:indexpath.row];
        
        localFingerPrint = event.fingerprint;
    }
    
    if (localFingerPrint) {
        
        [[TabbarVC sharedTabbar]suggestPressed:localFingerPrint controller:self sendNotificationWhenFinished:NO selectedPeople:nil showBlur:YES];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There is a problem with this Beeep. Please refresh and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }

}


#pragma mark - MONActivityIndicatorView

-(void)showLoading{
    
    if ([self.view viewWithTag:-434]) {
        return;
    }
    
    self.noBeeepsLabel.hidden = YES;
    
    UIView *loadingBGV = [[UIView alloc]initWithFrame:CGRectMake(0, self.collectionV.frame.origin.y, self.collectionV.frame.size.width, self.collectionV.frame.size.height)];
    loadingBGV.backgroundColor = self.view.backgroundColor;
    
    MONActivityIndicatorView *indicatorView = [[MONActivityIndicatorView alloc] init];
    indicatorView.delegate = self;
    indicatorView.numberOfCircles = 3;
    indicatorView.radius = 8;
    indicatorView.internalSpacing = 1;
    indicatorView.center = loadingBGV.center;
    indicatorView.tag = -565;
    
    [loadingBGV addSubview:indicatorView];
    loadingBGV.tag = -434;
    [self.view addSubview:loadingBGV];
    [self.view bringSubviewToFront:loadingBGV];
    
    [indicatorView startAnimating];
    
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


/*-(void)selectedSegmentAtIndex:(int)index{
    
    selectedIndex = index;
    
    if (index == 1) {
        
        [self getFriendsFeed];
    }
    else{
        [self getHomefeed];
    }
}*/

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
    
    [self performSelector:@selector(showBadgeIcon) withObject:nil afterDelay:1];
    
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
    
    [self performSelector:@selector(showBadgeIcon) withObject:nil afterDelay:1];
    
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

@end
