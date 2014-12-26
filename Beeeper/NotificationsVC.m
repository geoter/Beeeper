//
//  NotificationsVC.m
//  Beeeper
//
//  Created by User on 2/21/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "NotificationsVC.h"
#import "Activity_Object.h"
#import "EventVC.h"
#import "TimelineVC.h"
#import "BeeepNotifications.h"

@interface NotificationsVC ()
{
    NSMutableArray *notifications;
    NSMutableDictionary *pendingImagesDict;
    NSMutableArray *rowsToReload;
    BOOL loadNextPage;
    BOOL firstTime;
}
@end

@implementation NotificationsVC



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    firstTime = YES;
    
//    for (UIView *view in [[[self.navigationController.navigationBar subviews] objectAtIndex:0] subviews]) {
//        if ([view isKindOfClass:[UIImageView class]]) view.hidden = YES;
//    }
    
    rowsToReload = [NSMutableArray array];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    refreshControl.tag = 234;
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(getNotifications) forControlEvents:UIControlEventValueChanged];
    [self.tableV addSubview:refreshControl];

    pendingImagesDict = [NSMutableDictionary dictionary];
   
    [[BPUser sharedBP]getLocalNotifications:^(BOOL completed,NSArray *objcts){
        
        UIRefreshControl *refreshControl = (id)[self.tableV viewWithTag:234];
        [refreshControl endRefreshing];
        [self hideLoading];
        
        if (completed && objcts.count > 0) {
            
            notifications = [NSMutableArray arrayWithArray:objcts];
            
            [self.tableV reloadData];
        }
        else{
            [self showLoading];
        }
    }];

}

-(void)getNotifications{
    
    // self.tableV.decelerationRate = 0.6;
    
    loadNextPage = NO;
    
    [[BPUser sharedBP]getNotificationsWithCompletionBlock:^(BOOL completed,NSArray *notifs){

        UIRefreshControl *refreshControl = (id)[self.tableV viewWithTag:234];
        [refreshControl endRefreshing];
        [self hideLoading];
        
        if (completed) {
          
            notifications = [NSMutableArray array];
            [notifications addObjectsFromArray:notifs];
            
            if (notifs.count == [BPUser sharedBP].notifsPageLimit) {
                loadNextPage = YES;
            }
            
            if (notifications.count > 0) {
                firstTime = NO;
                self.noNotifsFound.hidden = YES;
            }
            else{

                self.noNotifsFound.hidden = NO;
                
                [self.tableV performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                
                return;
            }
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"notifications-%@",[[BPUser sharedBP].user objectForKey:@"id"]]];
            NSError *error;
            
            NSData* notificationsData = [NSKeyedArchiver archivedDataWithRootObject:notifications];
            
            BOOL succeed = [notificationsData writeToFile:filePath atomically:YES];
            
            [self.tableV performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
        else{
            if ([notifs isKindOfClass:[NSString class]]) {
                [[TabbarVC sharedTabbar]showAlert:@"Error" text:(NSString *)notifs];
            }
        }
    }];
}

-(void)nextPage{
    
    if (!loadNextPage) {
        return;
    }
    
    loadNextPage = NO;
    
    [[BPUser sharedBP]nextNotificationsWithCompletionBlock:^(BOOL completed,NSArray *notifs){
        
        if (completed) {
            
            [notifications addObjectsFromArray:notifs];
            
            self.noNotifsFound.hidden = notifications.count != 0;
            
            if (notifs.count == [BPUser sharedBP].notifsPageLimit) {
                loadNextPage = YES;
            }
            
            [self.tableV performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    }];
}

-(void)getNewNotifications{
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.title = @"Notifications";
    self.navigationController.navigationBar.topItem.title = self.title;
    
    for (UIButton *btn in self.tabBar.subviews) {
        
        if (![btn isKindOfClass:[UIButton class]]) {
            continue;
        }
        
        if (btn.tag != 4) {
            btn.selected = NO;
        }
        else{
            btn.selected = YES;
        }
    }
    
    [[BPUser sharedBP]clearBadgeWithCompletionBlock:^(BOOL completed){
        if (completed) {
        }
    }];
    
    if (firstTime) {
        [self getNotifications];
    }
    
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ShowTabbar" object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

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
    int returnValue = (notifications.count>0 && loadNextPage)?(notifications.count+1):notifications.count;
    return returnValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier;
    UITableViewCell *cell;
    
    if (loadNextPage && indexPath.row == notifications.count && notifications.count > 0) {
        
        CellIdentifier = @"LoadMoreCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UIActivityIndicatorView *indicator = (id)[cell viewWithTag:55];
        [indicator startAnimating];
        
        [self nextPage];
        
        return cell;
        
    }

    CellIdentifier = @"Cell";
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSLog(@"EMPTY CELL");
    }
    
    UIImageView *imgV = (UIImageView *)[cell viewWithTag:1];
    
    UILabel *time = (UILabel *)[cell viewWithTag:2];
    time.font =  [UIFont fontWithName:@"HelveticaNeue" size:10];
    
    UILabel *txtV = (id)[cell viewWithTag:3];
    txtV.font =  [UIFont fontWithName:@"HelveticaNeue" size:13];

    Activity_Object *activity = [notifications objectAtIndex:indexPath.row];
   
    @try {

        if(!activity.read){
            cell.backgroundColor = [UIColor colorWithRed:255/255.0 green:253/255.0 blue:236.0/255.0 alpha:1];
        }
        else{
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        Who *w = [[activity.who firstObject] copy];
        Whom *wm = [[activity.whom firstObject] copy];
        
        //see if who or whom is You
        
        NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
        
        if ([my_id isEqualToString:w.whoIdentifier]) {
            w.name = @"You";
        }
        
        if ([my_id isEqualToString:wm.whomIdentifier]) {
            wm.name= @"You";
        }
       
        double now_timestamp = [[NSDate date] timeIntervalSince1970];
        
        NSString *when = [self dailyLanguageFutureDate:now_timestamp pastDate:activity.when];
        time.text = when;

        NSAttributedString *notification_text = [self textForNotification:activity];
        txtV.attributedText = notification_text;

       //NSString *extension;
        NSString *imageName;
        
        if ([activity.did isEqualToString:@"triggered"]) {
            
            EventActivity *event = [activity.eventActivity firstObject];
            
            [imgV setImage:[UIImage imageNamed:@"BeeeperNotifIcon"]];
        }
        else{
            [imgV sd_setImageWithURL:[NSURL URLWithString:[[DTO sharedDTO] fixLink:w.imagePath]]
                     placeholderImage:[UIImage imageNamed:@"user_icon_180x180"]];
        }
        
        CGSize textViewSize = [self frameForText:txtV.attributedText constrainedToSize:CGSizeMake(212, CGFLOAT_MAX)];
        
        int lines = round(textViewSize.height/txtV.font.lineHeight);
        
        if (lines == 2) {
            txtV.frame = CGRectMake(txtV.frame.origin.x, 16, 212, textViewSize.height);
        }
        else{
            txtV.frame = CGRectMake(txtV.frame.origin.x, 20, 212, textViewSize.height);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"eskaseee");
    }
    @finally {
        
    }
    
    
    UIView *line = [cell viewWithTag:88];
    line.frame = CGRectMake(0, cell.frame.size.height-1, self.tableV.frame.size.width, 1);
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Activity_Object *activity = [notifications objectAtIndex:indexPath.row];

    [[BPUser sharedBP]markNotificationRead:activity.internalBaseClassIdentifier completionBlock:^(BOOL completed){
        if (completed) {
            activity.read = YES;
            [self.tableV reloadData];
        }
    }];
    
    if (activity.eventActivity.count > 0 || activity.beeepInfoActivity.eventActivity != nil) {
        
        EventVC *viewController = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"EventVC"];
        
        viewController.tml = activity;
        viewController.redirectToComments = ([activity.did rangeOfString:@"comment"].location != NSNotFound);
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else{
        
        TimelineVC *vC = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"TimelineVC"];
        vC.mode = Timeline_Not_Following;
        vC.showBackButton = YES;
        
        Who *w = [activity.who firstObject];
        Whom *wm = [activity.whom firstObject];
        
        NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
        
        if ([my_id isEqualToString:w.whoIdentifier]) {
            NSDictionary *user = [NSDictionary dictionaryWithObject:wm.whomIdentifier forKey:@"id"];
            vC.user = [NSMutableDictionary dictionaryWithDictionary:user];
        }
        
        if ([my_id isEqualToString:wm.whomIdentifier]) {
            NSDictionary *user = [NSDictionary dictionaryWithObject:w.whoIdentifier forKey:@"id"];
            vC.user = [NSMutableDictionary dictionaryWithDictionary:user];
        }
        
        
        [self.navigationController pushViewController:vC animated:YES];
    }
    
    
}

-(NSAttributedString *)textForNotification:(Activity_Object *)activity{
    
    @try {
        
        Who *w = [[activity.who firstObject] copy];
        Whom *wm = [[activity.whom firstObject] copy];
        
        //see if who or whom is You
        
        NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
        
        if ([my_id isEqualToString:w.whoIdentifier]) {
            w.name = @"You";
        }
        
        if ([my_id isEqualToString:wm.whomIdentifier]) {
            wm.name= @"You";
        }

        
        NSString *formattedString;
        
        if (wm != nil) {
            formattedString = [NSString stringWithFormat:@"%@ %@ %@",[w.name capitalizedString],activity.did,[wm.name capitalizedString]];
        }
        else if(activity.eventActivity.count > 0){
            EventActivity *event = [activity.eventActivity firstObject];
            NSString *event_title = [[event.title unicodeEncode]capitalizedString];
            
            if ([activity.did isEqualToString:@"triggered"]) {
                BeeepNotifications *beeepNotif = [activity.beeepNotifications firstObject];
                BeeepsActivity *beeep = [beeepNotif.beeepObject firstObject];

                formattedString = [NSString stringWithFormat:@"%@ is starting in %@",event_title,[self dailyLanguageLongFutureDate:beeep.eventTime pastDate:beeep.timestamp]];
            }
            else{
                formattedString = [NSString stringWithFormat:@"%@ %@ %@",[w.name capitalizedString],activity.did,event_title];
            }
        }
        else if(activity.beeepInfoActivity.eventActivity.count >0){
            EventActivity *event = [activity.beeepInfoActivity.eventActivity firstObject];
            NSString *event_title = [[event.title unicodeEncode]capitalizedString];
            
            formattedString = [NSString stringWithFormat:@"%@ %@ %@",[w.name capitalizedString],activity.did,event_title];
        }
        else{
            formattedString = [NSString stringWithFormat:@"%@ %@ %@",[w.name capitalizedString],activity.did,activity.what];
        }
        
        NSMutableAttributedString *attText = [[NSMutableAttributedString alloc] initWithString:formattedString];
        
        [attText addAttribute:NSFontAttributeName
                        value:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]
                        range:NSMakeRange(0,formattedString.length)];
        
        if (w != nil && ![w.name isEqualToString:@"You"]) {
            [attText addAttribute:NSFontAttributeName
                            value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]
                            range:[formattedString rangeOfString:[w.name capitalizedString]]];
        }
        
        if (wm != nil && ![wm.name isEqualToString:@"You"]) {
            [attText addAttribute:NSFontAttributeName
                            value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]
                            range:[formattedString rangeOfString:[wm.name capitalizedString]]];
            
            if ([activity.internalBaseClassIdentifier isEqualToString:@"543d29de1ddd13ce40968cb7"]) {
                NSLog(@"edo eimaste");
            }
        }
        else if(activity.beeepInfoActivity.eventActivity.count >0){
            
            EventActivity *event = [activity.beeepInfoActivity.eventActivity firstObject];
            NSString *event_title = [[event.title unicodeEncode] capitalizedString];
            
            [attText addAttribute:NSFontAttributeName
                            value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]
                            range:[formattedString rangeOfString:event_title]];
            
            if ([activity.internalBaseClassIdentifier isEqualToString:@"543d29de1ddd13ce40968cb7"]) {
                NSLog(@"edo eimaste");
            }
            
        }
        else if(activity.eventActivity.count > 0){
            
            EventActivity *event = [activity.eventActivity firstObject];
            NSString *event_title = [[event.title unicodeEncode] capitalizedString];
            [attText addAttribute:NSFontAttributeName
                            value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]
                            range:[formattedString rangeOfString:event_title]];
            
        }
        else{
            [attText addAttribute:NSFontAttributeName
                            value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]
                            range:[formattedString rangeOfString:activity.what]];
            
        }
        
        return attText;
    }
    @catch (NSException *exception) {
        NSLog(@"edoooo");
    }
    @finally {
        
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == notifications.count) {
        return 40;
    }
    else{
        
        @try {
           
            NSAttributedString *str = [self textForNotification:[notifications objectAtIndex:indexPath.row]];
            
            CGSize textViewSize = [self frameForText:str constrainedToSize:CGSizeMake(212, CGFLOAT_MAX)];
            
            float height = ((textViewSize.height + 23 + 10)>60)?(textViewSize.height + 23 + 10):60;
            
            //        NSLog(@"H: %f",height);
            
            return height;

        }
        @catch (NSException *exception) {
            NSLog(@"ke dooo");
        }
        @finally {
            
        }
    }
}

-(CGSize)frameForText:(NSAttributedString*)text constrainedToSize:(CGSize)size{
    
    @try {
        CGRect frame =  [text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin) context:nil];
        
        // This contains both height and width, but we really care about height.
        return frame.size;
    }
    @catch (NSException *exception) {
    
    }
    @finally {
    
    }
}

-(void)imageDownloadFinished:(NSNotification *)notif{
    
    NSString *imageName  = [notif.userInfo objectForKey:@"imageName"];
    
    NSArray* rows = [NSArray arrayWithObjects:[pendingImagesDict objectForKey:imageName], nil];
    
    [rowsToReload addObjectsFromArray:rows];
    
    [pendingImagesDict removeObjectForKey:imageName];
    
    if (rowsToReload.count == 5  || (pendingImagesDict.count < 5 && pendingImagesDict.count > 0)) {
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
        overdueMessage = [NSString stringWithFormat:@"%d%@", (years), (years==1?@"y":@"y")];
    }else if (months>0){
        overdueMessage = [NSString stringWithFormat:@"%d%@", (months), (months==1?@"mo":@"mo")];
    }else if (days>0){
        overdueMessage = [NSString stringWithFormat:@"%d%@", (days), (days==1?@"d":@"d")];
    }else if (hours>0){
        overdueMessage = [NSString stringWithFormat:@"%d%@", (hours), (hours==1?@"h":@"h")];
    }else if (minutes>0){
        overdueMessage = [NSString stringWithFormat:@"%d%@", (minutes), (minutes==1?@"m":@"m")];
    }else if (timeDiff<60){
        overdueMessage = [NSString stringWithFormat:@"a few seconds"];
    }
    
    return overdueMessage;
}

-(NSString*)dailyLanguageLongFutureDate:(NSTimeInterval )futureInterval pastDate:(NSTimeInterval) pastInterval{
    
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
        overdueMessage = [NSString stringWithFormat:@"%d %@", (years), (years==1?@"year":@"years")];
    }else if (months>0){
        overdueMessage = [NSString stringWithFormat:@"%d %@", (months), (months==1?@"month":@"months")];
    }else if (days>0){
        overdueMessage = [NSString stringWithFormat:@"%d %@", (days), (days==1?@"day":@"days")];
    }else if (hours>0){
        overdueMessage = [NSString stringWithFormat:@"%d %@", (hours), (hours==1?@"hour":@"hours")];
    }else if (minutes>0){
        overdueMessage = [NSString stringWithFormat:@"%d %@", (minutes), (minutes==1?@"minute":@"minutes")];
    }else if (timeDiff<60){
        overdueMessage = [NSString stringWithFormat:@"a few seconds"];
    }
    
    return overdueMessage;
}


-(void)showLoading{
    
    if ([self.view viewWithTag:-434]) {
        return;
    }
    
    dispatch_async (dispatch_get_main_queue(), ^{
        
        self.tableV.alpha = 0;
        
        UIView *loadingBGV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableV.frame.size.width, self.tableV.frame.size.height)];
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


- (IBAction)tabbarButtonTapped:(UIButton *)sender{
    
    [[TabbarVC sharedTabbar]tabbarButtonTapped:sender];
}


- (IBAction)addNewBeeep:(id)sender {
    [[TabbarVC sharedTabbar]addBeeepPressed:self];
}


@end
