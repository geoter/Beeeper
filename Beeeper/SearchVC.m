//
//  SearchVC.m
//  Beeeper
//
//  Created by User on 4/2/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "SearchVC.h"
#import "EventWS.h"
#import "Event_Search.h"
#import "EventLocation.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "CHTCollectionViewWaterfallHeader.h"
#import "CHTCollectionViewWaterfallFooter.h"
#import "EventVC.h"
#import "GHContextMenuView.h"
#import "BeeepItVC.h"
#import "SuggestBeeepVC.h"
#import "FollowListVC.h"
#import "CommentsVC.h"

@interface SearchVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,CHTCollectionViewDelegateWaterfallLayout,GHContextOverlayViewDataSource,GHContextOverlayViewDelegate>
{
    NSMutableArray *filteredResults;
    NSArray *suggestionValues;
    NSArray *events;
    NSMutableDictionary *pendingImagesDict;
    NSMutableArray *rowsToReload;
    BOOL loadNextPage;
}
@end

@implementation SearchVC


-(void)nextPage{
    
    if (!loadNextPage) {
        return;
    }
    
    loadNextPage = NO;
    
    [[EventWS sharedBP]nextSearchEventsWithCompletionBlock:^(BOOL completed,NSArray *keywords){
        
        if (keywords.count > 0) {
            loadNextPage = YES;
            [filteredResults addObjectsFromArray:keywords];
        }
        
        [self.tableV reloadData];
        
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self resetSearch];
    
    GHContextMenuView* overlay = [[GHContextMenuView alloc] init];
    overlay.dataSource = self;
    overlay.delegate = self;
    
	// Do any additional setup after loading the view.
    //    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    UILongPressGestureRecognizer* _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:overlay action:@selector(longPressDetected:)];
    [self.collectionV addGestureRecognizer:_longPressRecognizer];
    
    rowsToReload = [NSMutableArray array];
    pendingImagesDict = [[NSMutableDictionary alloc]init];
    
    self.collectionV.decelerationRate = 0.6;
    
    CHTCollectionViewWaterfallLayout *layout = (id)self.collectionV.collectionViewLayout;
    
    layout.sectionInset = UIEdgeInsetsMake(3, 8, 3, 8);
    layout.headerHeight = 5;
    layout.footerHeight = 10;
    layout.minimumColumnSpacing = 6;
    layout.minimumInteritemSpacing = 6;
    
    [self.collectionV registerClass:[CHTCollectionViewWaterfallHeader class]
         forSupplementaryViewOfKind:CHTCollectionElementKindSectionHeader
                withReuseIdentifier:@"HeaderView"];
    
    [self.collectionV registerClass:[CHTCollectionViewWaterfallFooter class]
         forSupplementaryViewOfKind:CHTCollectionElementKindSectionFooter
                withReuseIdentifier:@"FooterView"];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ShowTabbar" object:nil];

}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}



-(void)resetSearch{
    
    self.tapG.enabled = NO;
    
    suggestionValues = [NSArray arrayWithObjects:@"popular",@"sports",@"cinema",@"music",@"TV",@"nightlife",@"radio",@"deals", nil];
    
    filteredResults = [NSMutableArray arrayWithArray:suggestionValues];
    
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



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.searchTextField resignFirstResponder];
    
    NSString *tag = [filteredResults objectAtIndex:indexPath.row];
    
    self.searchTextField.text = tag;

    [self.collectionV setContentOffset:CGPointZero];
    
    [[EventWS sharedBP]searchEvent:tag WithCompletionBlock:^(BOOL completed,NSArray *evnts){
        if (completed) {
            events = [NSArray arrayWithArray:evnts];

            if (events.count > 0) {
               loadNextPage = YES;   
            }
            
            self.collectionV.hidden = NO;
            [self.collectionV reloadData];
            
            [UIView animateWithDuration:0.3f
                     animations:^
             {
                 self.tableV.alpha = 0;
             }
                             completion:^(BOOL finished)
             {
                 
             }
             ];

        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Upcoming Beeeps Found" message:@"Please search for another keyword." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
        }
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - SearchField

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    [UIView animateWithDuration:0.2f
                     animations:^
     {
         self.tableV.alpha = 1;

     }
                     completion:^(BOOL finished)
     {
         self.collectionV.hidden = YES;
     }
     ];
    return YES;
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
            
            filteredResults = [NSMutableArray arrayWithArray:keywords];

        }
        else{
            filteredResults = [NSMutableArray array];
        }
        
        if (filteredResults.count == 0) {
            self.tapG.enabled = YES;
            filteredResults = [NSMutableArray arrayWithObject:@"No results found"];
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

#pragma mark - UICollectionView

#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return events.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"EventCellWaterfall" forIndexPath:indexPath];
    
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
//    UIImageView *beeepedByImageV =(id)[beeepedByView viewWithTag:34];
//    UILabel *beeepedByLabel =(id)[beeepedByView viewWithTag:35];
//    UILabel *beeepedByNameLabel =(id)[beeepedByView viewWithTag:33];
//    
//    beeepedByLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:9];
//    beeepedByLabel.textColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1];
//    
//    beeepedByNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
//    beeepedByNameLabel.textColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:1];
//    
//    beeepedByNameLabel.text = [event.whoFfo.name capitalizedString];
//    
//    NSString *who_extension = [[event.eventFfo.eventDetailsFfo.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
//    
//    NSString *who_imageName = [NSString stringWithFormat:@"%@.%@",[event.whoFfo.imagePath MD5],extension];
//    
//    NSString *who_localPath = [documentsDirectoryPath stringByAppendingPathComponent:who_imageName];
//    
//    if ([[NSFileManager defaultManager]fileExistsAtPath:who_localPath]) {
//        beeepedByImageV.backgroundColor = [UIColor clearColor];
//        beeepedByImageV.image = nil;
//        UIImage *img = [UIImage imageWithContentsOfFile:who_localPath];
//        beeepedByImageV.image = img;
//    }
//    else{
//        beeepedByImageV.backgroundColor = [UIColor lightGrayColor];
//        beeepedByImageV.image = nil;
//        [pendingImagesDict setObject:indexPath forKey:who_imageName];
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(imageDownloadFinished:) name:who_imageName object:nil];
//    }
//    
    
    //disable Beeep button if past event
    
    UIButton *beeepBtn = (id)[containerV viewWithTag:99];
    double now_time = [[NSDate date]timeIntervalSince1970];
    double event_timestamp = event.timestamp;
    
    beeepBtn.enabled = (now_time < event_timestamp);
    
    return cell;
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    return UIEdgeInsetsMake(0, 7, 3, 7);
//}

- (UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionReusableView * reusableview = nil ;
    
    if ( kind == CHTCollectionElementKindSectionHeader ) {
        
        UICollectionReusableView * headerView = [collectionView dequeueReusableSupplementaryViewOfKind : CHTCollectionElementKindSectionHeader withReuseIdentifier : @ "HeaderView" forIndexPath : indexPath] ;
        
        //        GTSegmentedControl *segment = [GTSegmentedControl initWithOptions:[NSArray arrayWithObjects:@"Friends",@"All", nil] size:CGSizeMake(185, 25)];
        //        [headerView addSubview:segment];
        //        segment.center = headerView.center;
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
    viewController.tml = [events objectAtIndex:indexPath.row];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    CGSize textsize = [[textSizes objectAtIndex:indexPath.row] CGSizeValue];
    //    CGSize size = CGSizeMake(148, textsize.height + 145 +144);
    return CGSizeMake(148, 278);
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


- (IBAction)showBeeepLikes:(UIButton *)sender {
    
    UICollectionViewCell *cell = (id)sender.superview.superview.superview.superview;
    NSIndexPath *path = [self.collectionV indexPathForCell:cell];
    
    Event_Search* event = [events objectAtIndex:path.row];

    
    FollowListVC *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowListVC"];
    viewController.mode = LikesMode;
    viewController.ids = event.likes;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showBeeepComments:(UIButton *)sender {
    UICollectionViewCell *cell = (id)sender.superview.superview.superview.superview;
    NSIndexPath *path = [self.collectionV indexPathForCell:cell];
    
    Event_Search* event = [events objectAtIndex:path.row];
    
    CommentsVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentsVC"];
    viewController.event_beeep_object = [events objectAtIndex:path.row];
//    viewController.comments = [NSMutableArray arrayWithArray:beeep.comments];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showReBeeeps:(UIButton *)sender {
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
    viewController.tml = [events objectAtIndex:indexpath.row];
    viewController.view.frame = self.parentViewController.parentViewController.view.bounds;
    
    NSLog(@"%@",self.parentViewController.parentViewController);
    
    [self presentViewController:viewController animated:YES completion:nil];
    
}

-(void)likeEventAtIndexPath:(NSIndexPath *)indexpath{
    
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

-(void)suggestEventAtIndexPath:(NSIndexPath *)indexpath{
    
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




-(void)imageDownloadFinished:(NSNotification *)notif{
    
    NSString *imageName  = [notif.userInfo objectForKey:@"imageName"];
    
    NSArray* rows = [NSArray arrayWithObjects:[pendingImagesDict objectForKey:imageName], nil];
    
    [rowsToReload addObjectsFromArray:rows];
    
    [pendingImagesDict removeObjectForKey:imageName];
    
    if (rowsToReload.count == 5  || pendingImagesDict.count < 5) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            @try {
                [self.collectionV reloadItemsAtIndexPaths:rowsToReload];
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
