//
//  HomeFeedVC.m
//  Beeeper
//
//  Created by User on 3/19/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "HomeFeedVC.h"
#import "BeeepItVC.h"
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
#import "SuggestBeeepVC.h"
#import "BorderTextField.h"
#import "Event_Search.h"

@interface HomeFeedVC ()<UICollectionViewDataSource,UICollectionViewDelegate,CHTCollectionViewDelegateWaterfallLayout,GHContextOverlayViewDataSource, GHContextOverlayViewDelegate,MONActivityIndicatorViewDelegate>
{
    NSMutableArray *textSizes;
    
    NSMutableArray *beeeps;
    NSMutableArray *events;
    NSMutableDictionary *pendingImagesDict;
    
    NSMutableArray *rowsToReload;
    int selectedIndex;
    BOOL loadNextPage;
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
    
    loadNextPage = NO;
    
    if (selectedIndex == 0) {
        [self getNextFriendsFeed];
    }
    else{
        [self nextHomeFeed];
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    rowsToReload = [NSMutableArray array];
    
    GHContextMenuView* overlay = [[GHContextMenuView alloc] init];
    overlay.dataSource = self;
    overlay.delegate = self;
    
	// Do any additional setup after loading the view.
    //    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    UILongPressGestureRecognizer* _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:overlay action:@selector(longPressDetected:)];
    [self.collectionV addGestureRecognizer:_longPressRecognizer];

    
    for (UIView *view in [[[self.navigationController.navigationBar subviews] objectAtIndex:0] subviews]) {
        if ([view isKindOfClass:[UIImageView class]]) view.hidden = YES;
    }
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    refreshControl.tag = 234;
    refreshControl.tintColor = [UIColor whiteColor];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionV addSubview:refreshControl];
    self.collectionV.alwaysBounceVertical = YES;
    
    pendingImagesDict = [[NSMutableDictionary alloc]init];
    
    self.collectionV.decelerationRate = 0.6;
    
    CHTCollectionViewWaterfallLayout *layout = (id)self.collectionV.collectionViewLayout;
    
    layout.sectionInset = UIEdgeInsetsMake(3, 8, 3, 8);
    layout.headerHeight = 40;
    layout.footerHeight = 50;
    layout.minimumColumnSpacing = 6;
    layout.minimumInteritemSpacing = 6;

    [self.collectionV registerClass:[CHTCollectionViewWaterfallHeader class]
        forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader
               withReuseIdentifier:@"HeaderView"];

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
    
    [[BPHomeFeed sharedBP]getLocalFriendsFeed:^(BOOL completed,NSArray *objs){
        
        if (completed) {
            
            if (objs.count > 0) {
                
                UIRefreshControl *refreshControl = (id)[self.collectionV viewWithTag:234];
                [refreshControl endRefreshing];
                
                [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:NO];
                events = nil;
                beeeps = [NSMutableArray arrayWithArray:objs];
                [self.collectionV reloadData];
                
            }
        }
    }];

}

-(void)refresh{
    if (selectedIndex == 0) {
        [self getFriendsFeed];
    }
    else{
        [self getHomefeed];
    }
}

-(void)getFriendsFeed{
    
    loadNextPage = NO;
    
    [[BPHomeFeed sharedBP]getFriendsFeedWithCompletionBlock:^(BOOL completed,NSArray *objs){
        
        [self hideLoading];
        
        if (completed) {
            
            UIRefreshControl *refreshControl = (id)[self.collectionV viewWithTag:234];
            [refreshControl endRefreshing];
            
            if (objs.count > 0) {
                loadNextPage = YES;
            }
            
            events = nil;
            beeeps = [NSMutableArray arrayWithArray:objs];
            
            [self.collectionV reloadData];
        }
    }];

}

-(void)getNextFriendsFeed{

    [[BPHomeFeed sharedBP]nextFriendsFeedWithCompletionBlock:^(BOOL completed,NSArray *objs){
        
        if (completed && objs.count >0) {
            events = nil;
            [beeeps addObjectsFromArray:objs];
            loadNextPage = YES;
        }
        
       [self.collectionV reloadData];
    }];
}

-(void)nextHomeFeed{
    
    [[EventWS sharedBP]nextAllEventsWithCompletionBlock:^(BOOL completed,NSArray *objs){
        
        if (completed) {
            
            if (objs.count != 0) {
                
                beeeps = nil;
                [events addObjectsFromArray:objs];
                
                loadNextPage = YES;
                
                UIRefreshControl *refreshControl = (id)[self.collectionV viewWithTag:234];
                [refreshControl endRefreshing];
                
                [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:NO];
            }
            
        }
        
        [self.collectionV performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
}

-(void)getHomefeed{
    
    loadNextPage = NO;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [pendingImagesDict removeAllObjects];
    
    [[EventWS sharedBP]getAllLocalEvents:^(BOOL completed,NSArray *objs){
        
        if (completed) {
          
            if (objs.count != 0) {
          
                beeeps = nil;
                events = [NSMutableArray arrayWithArray:objs];
                
                loadNextPage = YES;
                
                UIRefreshControl *refreshControl = (id)[self.collectionV viewWithTag:234];
                [refreshControl endRefreshing];
                
                [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:NO];
            }
        }
        
        [self.collectionV performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];

    
    
    [[EventWS sharedBP]getAllEventsWithCompletionBlock:^(BOOL completed,NSArray *objs){
        
        UIRefreshControl *refreshControl = (id)[self.collectionV viewWithTag:234];
        [refreshControl endRefreshing];
        
        [self hideLoading];
        
        if (completed) {
            beeeps = nil;
            events = [NSMutableArray arrayWithArray:objs];
            
            [self.collectionV reloadData];
        }
    }];
}





-(void)showFindFriends{
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FindFriendsVC"];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ShowTabbar" object:nil];
    
    [self refresh];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
 //   [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
   
    beeeps = nil;
    pendingImagesDict = nil;
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
    return (selectedIndex == 0)?beeeps.count:events.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (events != nil) {
        
        UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"EventCellWaterfallLite" forIndexPath:indexPath];
    

        Event_Search *event = [events objectAtIndex:indexPath.row];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE, MMM dd, yyyy hh:mm"];
        
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
        
        monthLbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        monthLbl.textColor = [UIColor colorWithRed:250/255.0 green:217/255.0 blue:0/255.0 alpha:1];
        monthLbl.text = [month uppercaseString];
        
        dayLbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:24];
        dayLbl.text = daynumber;
        dayLbl.textColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:1];
        
        //imageV.image = [UIImage imageNamed:[event objectForKey:@"image"]];
        
        titleLbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
        titleLbl.textColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:1];
        
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
        [titleLbl setFrame:CGRectMake(titleLbl.frame.origin.x, titleLbl.frame.origin.y, 116, titleLbl.frame.size.height)];
        
        //    CGSize size = [self frameForText:titleLbl.attributedText constrainedToSize:CGSizeMake(116, CGFLOAT_MAX)];
        
        //    titleLbl.frame = CGRectMake(titleLbl.frame.origin.x, titleLbl.frame.origin.y, 116, size.height + 5);
        
        UIView *bottomV = (id)[cell viewWithTag:5];
        
        //bottomV.frame = CGRectMake(bottomV.frame.origin.x, title.frame.origin.y + title.frame.size.height, bottomV.frame.size.width, bottomV.frame.size.height);
        
        UILabel *area = (id)[containerV viewWithTag:-2];
        area.frame = CGRectMake(37, 190, 108, 32);
        
        area.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
        area.textColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1];
        NSString *jsonString = event.location;
        
        if (jsonString != nil) {
            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
            area.text = [loc.venueStation uppercaseString];
            [area sizeToFit];
        }

        area.center = CGPointMake(containerV.center.x, area.center.y);
        area.frame = CGRectMake(area.frame.origin.x, titleLbl.frame.origin.y+titleLbl.frame.size.height+2, area.frame.size.width, area.frame.size.height);
        
        UILabel *areaIcon = (id)[containerV viewWithTag:-1];
        areaIcon.frame = CGRectMake(area.frame.origin.x-10, area.frame.origin.y+2, areaIcon.frame.size.width, areaIcon.frame.size.height);
        
        //now move are to center
        area.textAlignment = NSTextAlignmentCenter;
        
        UILabel *favorites = (id)[containerV viewWithTag:-3];
        UILabel *comments = (id)[containerV viewWithTag:-4];
        UILabel *beeeps = (id)[containerV viewWithTag:-5];
        favorites.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
        comments.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
        beeeps.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
        
        beeeps.text = [NSString stringWithFormat:@"%d",(int)event.beeepedBy.count];
        favorites.text = [NSString stringWithFormat:@"%d",(int)event.likes.count];
        
        favorites.hidden = (favorites.text.intValue == 0);
        comments.hidden = (comments.text.intValue == 0);
        beeeps.hidden = (beeeps.text.intValue == 0);
        
        
        NSString *extension = [[event.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        
        NSString *imageName = [NSString stringWithFormat:@"%@.%@",[event.imageUrl MD5],extension];
        
        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
        
        if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
            imageV.backgroundColor = [UIColor clearColor];
            imageV.image = nil;
            UIImage *img = [UIImage imageWithContentsOfFile:localPath];
            imageV.image = img;
        }
        else{
            imageV.backgroundColor = [UIColor lightGrayColor];
            imageV.image = nil;
            [pendingImagesDict setObject:indexPath forKey:imageName];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(imageDownloadFinished:) name:imageName object:nil];
        }
        
        UIView *beeepedByView = (id)[containerV viewWithTag:32];
        
        //disable Beeep button if past event
        
        UIButton *beeepBtn = (id)[containerV viewWithTag:99];
        double now_time = [[NSDate date]timeIntervalSince1970];
        double event_timestamp = event.timestamp;
        
        beeepBtn.enabled = (now_time < event_timestamp);

        return cell;
    }
    else{
            UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"EventCellWaterfall" forIndexPath:indexPath];
        
            Friendsfeed_Object *event = [beeeps objectAtIndex:indexPath.row];
            
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEEE, MMM dd, yyyy hh:mm"];
            
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
            
            monthLbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
            monthLbl.textColor = [UIColor colorWithRed:250/255.0 green:217/255.0 blue:0/255.0 alpha:1];
            monthLbl.text = [month uppercaseString];
            
            dayLbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:24];
            dayLbl.text = daynumber;
            dayLbl.textColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:1];
            
            //imageV.image = [UIImage imageNamed:[event objectForKey:@"image"]];

            titleLbl.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
            titleLbl.textColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:1];
            
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
            [titleLbl setFrame:CGRectMake(titleLbl.frame.origin.x, titleLbl.frame.origin.y, 116, titleLbl.frame.size.height)];
            
        //    CGSize size = [self frameForText:titleLbl.attributedText constrainedToSize:CGSizeMake(116, CGFLOAT_MAX)];
            
        //    titleLbl.frame = CGRectMake(titleLbl.frame.origin.x, titleLbl.frame.origin.y, 116, size.height + 5);
            
            UIView *bottomV = (id)[cell viewWithTag:5];
            
            //bottomV.frame = CGRectMake(bottomV.frame.origin.x, title.frame.origin.y + title.frame.size.height, bottomV.frame.size.width, bottomV.frame.size.height);
            
            UILabel *area = (id)[containerV viewWithTag:-2];
            area.frame = CGRectMake(37, 190, 108, 32);
            
            area.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
            area.textColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1];
            NSString *jsonString = event.eventFfo.eventDetailsFfo.location;
            
            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
            area.text = [loc.venueStation uppercaseString];
            [area sizeToFit];
            area.center = CGPointMake(containerV.center.x, area.center.y);
            area.frame = CGRectMake(area.frame.origin.x, titleLbl.frame.origin.y+titleLbl.frame.size.height+2, area.frame.size.width, area.frame.size.height);
            
            UILabel *areaIcon = (id)[containerV viewWithTag:-1];
            areaIcon.frame = CGRectMake(area.frame.origin.x-10, area.frame.origin.y+2, areaIcon.frame.size.width, areaIcon.frame.size.height);
            
            //now move are to center
            area.textAlignment = NSTextAlignmentCenter;
            
            UILabel *favorites = (id)[containerV viewWithTag:-3];
            UILabel *comments = (id)[containerV viewWithTag:-4];
            UILabel *beeeps = (id)[containerV viewWithTag:-5];
            favorites.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
            comments.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
            beeeps.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
            
            Beeeps *b = [event.beeepFfo.beeeps firstObject];
            
            favorites.text = [NSString stringWithFormat:@"%d",(int)b.likes.count];
            comments.text = [NSString stringWithFormat:@"%d",(int)b.comments.count];
            beeeps.text = [NSString stringWithFormat:@"%d",(int)event.eventFfo.beeepedBy.count];
            
            favorites.hidden = (favorites.text.intValue == 0);
            comments.hidden = (comments.text.intValue == 0);
            beeeps.hidden = (beeeps.text.intValue == 0);

            
            NSString *extension = [[event.eventFfo.eventDetailsFfo.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
            
            NSString *imageName = [NSString stringWithFormat:@"%@.%@",[event.eventFfo.eventDetailsFfo.imageUrl MD5],extension];
            
            NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
            
            if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
                imageV.backgroundColor = [UIColor clearColor];
                imageV.image = nil;
                UIImage *img = [UIImage imageWithContentsOfFile:localPath];
                imageV.image = img;
            }
            else{
                imageV.backgroundColor = [UIColor lightGrayColor];
                imageV.image = nil;
                [pendingImagesDict setObject:indexPath forKey:imageName];
                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(imageDownloadFinished:) name:imageName object:nil];
            }

            UIView *beeepedByView = (id)[containerV viewWithTag:32];
            UIImageView *beeepedByImageV =(id)[beeepedByView viewWithTag:34];
            UILabel *beeepedByLabel =(id)[beeepedByView viewWithTag:35];
            UILabel *beeepedByNameLabel =(id)[beeepedByView viewWithTag:33];
            
            beeepedByLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:9];
            beeepedByLabel.textColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1];

            beeepedByNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
            beeepedByNameLabel.textColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:1];
            
            beeepedByNameLabel.text = [event.whoFfo.name capitalizedString];
            
            NSString *who_extension = [[event.eventFfo.eventDetailsFfo.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
            
            NSString *who_imageName = [NSString stringWithFormat:@"%@.%@",[event.whoFfo.imagePath MD5],extension];
            
            NSString *who_localPath = [documentsDirectoryPath stringByAppendingPathComponent:who_imageName];
            
            if ([[NSFileManager defaultManager]fileExistsAtPath:who_localPath]) {
                beeepedByImageV.backgroundColor = [UIColor clearColor];
                beeepedByImageV.image = nil;
                UIImage *img = [UIImage imageWithContentsOfFile:who_localPath];
                beeepedByImageV.image = img;
            }
            else{
                beeepedByImageV.backgroundColor = [UIColor lightGrayColor];
                beeepedByImageV.image = nil;
                [pendingImagesDict setObject:indexPath forKey:who_imageName];
                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(imageDownloadFinished:) name:who_imageName object:nil];
            }

            
            //disable Beeep button if past event
            
            UIButton *beeepBtn = (id)[containerV viewWithTag:99];
            double now_time = [[NSDate date]timeIntervalSince1970];
            double event_timestamp = event.eventFfo.eventDetailsFfo.timestamp;
            
            beeepBtn.enabled = (now_time < event_timestamp);
        
            return cell;
    }

}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    return UIEdgeInsetsMake(0, 7, 3, 7);
//}

- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{

    UICollectionReusableView * reusableview = nil ;
    
    if ( kind == CHTCollectionElementKindSectionHeader ) {
        
        UICollectionReusableView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind : CHTCollectionElementKindSectionHeader withReuseIdentifier : @ "HeaderView" forIndexPath : indexPath] ;

        GTSegmentedControl *segment = [GTSegmentedControl initWithOptions:[NSArray arrayWithObjects:@"Friends",@"All", nil] size:CGSizeMake(185, 25) selectedIndex:selectedIndex];
        segment.delegate = self;
        [headerView addSubview:segment];
        segment.center = headerView.center;
        reusableview = headerView;
    }
    
    if ([kind isEqualToString:CHTCollectionElementKindSectionFooter]) {
        UICollectionReusableView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind : CHTCollectionElementKindSectionFooter withReuseIdentifier : @ "FooterView" forIndexPath : indexPath] ;
        
        UIActivityIndicatorView *actv = (id)[headerView viewWithTag:12];
        actv.hidden = YES;
        [actv removeFromSuperview];

        if (loadNextPage) {
            UIActivityIndicatorView *activIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, 25)];
            activIndicator.tag = 12;
            [headerView addSubview:activIndicator];
            [activIndicator startAnimating];
            
            [self nextPage];
        }

        reusableview = headerView;

    }
    
    return reusableview;
}

-(void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  
    EventVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"EventVC"];
    
    if (beeeps != nil || selectedIndex == 0) {
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
    return CGSizeMake(148, (selectedIndex == 0)?298:270);
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


-(void)imageDownloadFinished:(NSNotification *)notif{
    
    NSString *imageName  = [notif.userInfo objectForKey:@"imageName"];
    
    NSArray* rows = [NSArray arrayWithObjects:[pendingImagesDict objectForKey:imageName], nil];
    
    [rowsToReload addObjectsFromArray:rows];
    
    [pendingImagesDict removeObjectForKey:imageName];
    
    if (rowsToReload.count == 5  || pendingImagesDict.count < 5) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            @try {
                [self.collectionV reloadData];
                [rowsToReload removeAllObjects];
            }
            @catch (NSException *exception) {
    
            }
            @finally {
    
            }
        });

    }
    
    
}

-(CGSize)frameForText:(NSAttributedString *) text constrainedToSize:(CGSize)size{
    
    CGRect frame = [text boundingRectWithSize:size
                                      options:(NSStringDrawingUsesLineFragmentOrigin) context:nil];
    
    // This contains both height and width, but we really care about height.
    return frame.size;
}

- (IBAction)beeepPressed:(id)sender {

    
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"BeeepVC"];
    
    [viewController.view setFrame:CGRectMake(0, self.view.frame.size.height, 320, viewController.view.frame.size.height)];
    [self.view addSubview:viewController.view];
    [self addChildViewController:viewController];
    
    [UIView animateWithDuration:0.4f
                     animations:^
     {
         viewController.view.frame = CGRectMake(0, 0, 320, viewController.view.frame.size.height);
     }
                     completion:^(BOOL finished)
     {

     }
     ];
    
     [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (IBAction)eventBeeepPressed:(UIButton *)sender {
    
    UICollectionViewCell *cell = (id)sender.superview.superview.superview.superview;
    
    NSIndexPath *path = [self.collectionV indexPathForCell:cell];
    
    BeeepItVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"BeeepItVC"];
    viewController.tml = [beeeps objectAtIndex:path.row];
    viewController.view.frame = self.parentViewController.parentViewController.view.bounds;
    
    NSLog(@"%@",self.parentViewController.parentViewController);
    
    [viewController.view setFrame:CGRectMake(0, self.view.frame.size.height, 320, viewController.view.frame.size.height)];
    [self.parentViewController.parentViewController.view addSubview:viewController.view];
    [self.parentViewController.parentViewController.view bringSubviewToFront:viewController.view];
    [self.parentViewController.parentViewController addChildViewController:viewController];
    
    [UIView animateWithDuration:0.4f
                     animations:^
     {
         viewController.view.frame = CGRectMake(0, 0, 320, viewController.view.frame.size.height);
     }
                     completion:^(BOOL finished)
     {
         
     }
     ];
    

}

- (IBAction)showUser:(UIButton *)sender {
    
    UICollectionViewCell *cell = (id)sender.superview.superview.superview.superview.superview;
    NSIndexPath *path = [self.collectionV indexPathForCell:cell];
    
    Friendsfeed_Object*b = [beeeps objectAtIndex:path.row];
  
    TimelineVC *timelineVC = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"TimelineVC"];
    timelineVC.mode = Timeline_Not_Following;
    
    NSDictionary *user = [b.whoFfo dictionaryRepresentation];
    timelineVC.user = user;
    
    [self.navigationController pushViewController:timelineVC animated:YES];
}

- (IBAction)showBeeepLikes:(UIButton *)sender {
    
    UICollectionViewCell *cell = (id)sender.superview.superview.superview.superview;
    NSIndexPath *path = [self.collectionV indexPathForCell:cell];
    
    Friendsfeed_Object*b = [beeeps objectAtIndex:path.row];
    Beeeps *beeep = [b.beeepFfo.beeeps firstObject];
    
    FollowListVC *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowListVC"];
    viewController.mode = LikesMode;
    viewController.ids = [beeep.likes valueForKey:@"likes"];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showBeeepComments:(UIButton *)sender {
    
    UICollectionViewCell *cell = (id)sender.superview.superview.superview.superview;
    NSIndexPath *path = [self.collectionV indexPathForCell:cell];
    
    Friendsfeed_Object*b = [beeeps objectAtIndex:path.row];
    Beeeps *beeep = [b.beeepFfo.beeeps firstObject];
    
    CommentsVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentsVC"];
    viewController.event_beeep_object = [beeeps objectAtIndex:path.row];
    viewController.comments = [NSMutableArray arrayWithArray:beeep.comments];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showReBeeeps:(UIButton *)sender {
    UICollectionViewCell *cell = (id)sender.superview.superview.superview.superview;
    NSIndexPath *path = [self.collectionV indexPathForCell:cell];

    Friendsfeed_Object*b = [beeeps objectAtIndex:path.row];
    
    FollowListVC *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowListVC"];
    viewController.mode = BeeepersMode;
    viewController.ids = b.eventFfo.beeepedBy;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showEventLikes:(UIButton *)sender {
    
    UICollectionViewCell *cell = (id)sender.superview.superview.superview.superview;
    NSIndexPath *path = [self.collectionV indexPathForCell:cell];
    
    Event_Search* event = [events objectAtIndex:path.row];
    
    
    FollowListVC *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowListVC"];
    viewController.mode = LikesMode;
    viewController.ids = event.likes;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showEventComments:(UIButton *)sender {
    
    UICollectionViewCell *cell = (id)sender.superview.superview.superview.superview;
    NSIndexPath *path = [self.collectionV indexPathForCell:cell];
    
    Event_Search* event = [events objectAtIndex:path.row];
    
    CommentsVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentsVC"];
    viewController.event_beeep_object = [events objectAtIndex:path.row];
    //    viewController.comments = [NSMutableArray arrayWithArray:beeep.comments];
    [self.navigationController pushViewController:viewController animated:YES];

}

- (IBAction)showEventBeepers:(UIButton *)sender {
    UICollectionViewCell *cell = (id)sender.superview.superview.superview.superview;
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
    
    return cell != nil;
}

- (NSInteger) numberOfMenuItems
{
    return 3;
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
            
        default:
            break;
    }

}


-(void)beeepEventAtIndexPath:(NSIndexPath *)indexpath{
    
    BeeepItVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"BeeepItVC"];
    
    if (beeeps != nil || selectedIndex == 0) {
         viewController.tml = [beeeps objectAtIndex:indexpath.row];
    }
    else{
         viewController.tml = [events objectAtIndex:indexpath.row];
    }
    
    viewController.view.frame = self.parentViewController.parentViewController.view.bounds;
    
    [self presentViewController:viewController animated:YES completion:nil];

}

-(void)likeEventAtIndexPath:(NSIndexPath *)indexpath{
    
    if (beeeps != nil || selectedIndex == 0) {
        
        Friendsfeed_Object *ffo = [beeeps objectAtIndex:indexpath.row];
        
        Beeeps *bps = [ffo.beeepFfo.beeeps firstObject];
        
        [[EventWS sharedBP]likeBeeep:bps.weight user:ffo.beeepFfo.userId WithCompletionBlock:^(BOOL completed,NSDictionary *response){
            if (completed) {
                [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                [SVProgressHUD showSuccessWithStatus:@"Liked!"];
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
        
        Event_Search *event = [events objectAtIndex:indexpath.row];
        
        [[EventWS sharedBP]likeEvent:event.fingerprint WithCompletionBlock:^(BOOL completed,NSDictionary *response){
            
            if (completed) {
                [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                [SVProgressHUD showSuccessWithStatus:@"Liked!"];
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
    
}

-(void)suggestEventAtIndexPath:(NSIndexPath *)indexpath{
    
    if (beeeps != nil || selectedIndex == 0) {
            
        Friendsfeed_Object *ffo = [beeeps objectAtIndex:indexpath.row];
        
        Beeeps *bps = [ffo.beeepFfo.beeeps firstObject];
        
        SuggestBeeepVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"SuggestBeeepVC"];
        viewController.fingerprint = ffo.eventFfo.eventDetailsFfo.fingerprint;
        
        if (viewController.fingerprint != nil) {
             [self presentViewController:viewController animated:YES completion:nil];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There is a problem with this Beeep. Please refresh and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    }
    else{
        
        Event_Search *event = [events objectAtIndex:indexpath.row];
        
        SuggestBeeepVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"SuggestBeeepVC"];
        viewController.fingerprint = event.fingerprint;
        
        if (viewController.fingerprint != nil) {
            [self presentViewController:viewController animated:YES completion:nil];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There is a problem with this Beeep. Please refresh and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }

    }
}


#pragma mark - MONActivityIndicatorView

-(void)showLoading{
    
    if (self.collectionV.alpha == 0) {
        return;
    }
    
    self.collectionV.alpha = 0;
    
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
         self.collectionV.alpha = 1;
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


-(void)selectedSegmentAtIndex:(int)index{
    
    selectedIndex = index;
    
    if (index == 0) {
        
        [self getFriendsFeed];
    }
    else{
        [self getHomefeed];
    }
}

@end
