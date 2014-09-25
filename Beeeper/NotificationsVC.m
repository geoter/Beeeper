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


@interface NotificationsVC ()
{
    NSMutableArray *notifications;
    NSMutableArray *newNotifications;
    NSMutableArray *oldNotifications;
    NSMutableDictionary *pendingImagesDict;
    NSMutableArray *rowsToReload;
    BOOL loadNextPage;
}
@end

@implementation NotificationsVC



- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Notifications";
    
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
    
     self.tableV.decelerationRate = 0.6;
    
    loadNextPage = NO;
    
    newNotifications = nil;
    oldNotifications = nil;
    
    [[BPUser sharedBP]getNotificationsWithCompletionBlock:^(BOOL completed,NSArray *newNotifs,NSArray *oldNotifs){

        UIRefreshControl *refreshControl = (id)[self.tableV viewWithTag:234];
        [refreshControl endRefreshing];
        [self hideLoading];
        
        if (completed) {
            notifications = [NSMutableArray array];
            [notifications addObjectsFromArray:newNotifs];
            
            if (newNotifs.count + oldNotifs.count == 10) {
                loadNextPage = YES;
            }
            
            //check for duplicates
            
            if (newNotifs.count > 0) {
                
                for (Activity_Object *actV in newNotifs) {
                    NSString *newNotifMD5  = [actV.description MD5];
                    
                    for (Activity_Object *oldActV in oldNotifs) {
                        NSString *oldNotifMD5  = [oldActV.description MD5];
                        
                        if (![newNotifMD5 isEqualToString:oldNotifMD5] && [notifications indexOfObject:oldActV] == NSNotFound) {
                            [notifications addObject:oldActV];
                        }
                    }
                    
                }

            }
            else{
                [notifications addObjectsFromArray:oldNotifs];
            }
            
            
            newNotifications = [NSMutableArray arrayWithArray:newNotifs];
            oldNotifications = [NSMutableArray arrayWithArray:oldNotifs];

            if (notifications.count == 0) {
                self.noNotifsFound.hidden = NO;
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"getNotifications Completed but notifications == 0" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
            }
            else{

                self.noNotifsFound.hidden = YES;
            }
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"notifications-%@",[[BPUser sharedBP].user objectForKey:@"id"]]];
            NSError *error;
            
            NSData* notificationsData = [NSKeyedArchiver archivedDataWithRootObject:notifications];
            
            BOOL succeed = [notificationsData writeToFile:filePath atomically:YES];
            
            [self.tableV performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    }];
}

-(void)nextPage{
    
    if (!loadNextPage) {
        return;
    }
    
    loadNextPage = NO;
    
    [[BPUser sharedBP]nextNotificationsWithCompletionBlock:^(BOOL completed,NSArray *newNotifs,NSArray *oldNotifs){
        
        if (completed) {
            [notifications addObjectsFromArray:newNotifs];
            
            self.noNotifsFound.hidden = notifications.count != 0;
            
            if (newNotifs.count + oldNotifs.count == 10) {
                loadNextPage = YES;
            }
            
            if (newNotifs.count > 0) {
                
                for (Activity_Object *actV in newNotifs) {
                    NSString *newNotifMD5  = [actV.description MD5];
                    
                    for (Activity_Object *oldActV in oldNotifs) {
                        NSString *oldNotifMD5  = [oldActV.description MD5];
                        
                        if (![newNotifMD5 isEqualToString:oldNotifMD5] && [notifications indexOfObject:oldActV] == NSNotFound) {
                            [notifications addObject:oldActV];
                        }
                    }
                    
                }
                
            }
            else{
                [notifications addObjectsFromArray:oldNotifs];
            }
            
            [newNotifications addObjectsFromArray:newNotifs];
            [oldNotifications addObjectsFromArray:oldNotifs];
            
            [self.tableV performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please slide to reload" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self getNotifications];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ShowTabbar" object:nil];
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
    
    if (loadNextPage && indexPath.row == notifications.count) {
        
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
    
    if(newNotifications != nil && [newNotifications indexOfObject:activity] != NSNotFound){
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
    
    NSString *when = [self dailyLanguage:now_timestamp-activity.when];
    time.text = when;

    NSAttributedString *notification_text = [self textForNotification:activity];
    txtV.attributedText = notification_text;

   //NSString *extension;
    NSString *imageName;
    
   /* if ([w.name isEqualToString:@"You"] && activity.eventActivity.count == 0 && activity.beeepInfoActivity.eventActivity == nil) {
    //    extension = [[wm.imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        imageName = [NSString stringWithFormat:@"%@",[wm.imagePath MD5]];
    }
    else if (activity.eventActivity.count > 0){
        EventActivity *event = [activity.eventActivity firstObject];
        NSString *path = event.imageUrl;
     //   extension = [[path.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        imageName = [NSString stringWithFormat:@"%@",[path MD5]];
        
    }
    else if(activity.beeepInfoActivity.eventActivity != nil){
        EventActivity *event = [activity.beeepInfoActivity.eventActivity firstObject];
      //  extension = [[event.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        imageName = [NSString stringWithFormat:@"%@",[event.imageUrl MD5]];
    }
    else if ([wm.name isEqualToString:@"You"]){
      //  extension = [[w.imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        imageName = [NSString stringWithFormat:@"%@",[w.imagePath MD5]];
    }*/
    
    imageName = [NSString stringWithFormat:@"%@",[w.imagePath MD5]];
    
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
    
    
    CGSize textViewSize = [self frameForText:txtV.attributedText constrainedToSize:CGSizeMake(212, CGFLOAT_MAX)];
    
    int lines = round(textViewSize.height/txtV.font.lineHeight);
    
    if (lines == 2) {
        txtV.frame = CGRectMake(txtV.frame.origin.x, 16, 212, textViewSize.height);
    }
    else{
        txtV.frame = CGRectMake(txtV.frame.origin.x, 20, 212, textViewSize.height);
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Activity_Object *activity = [notifications objectAtIndex:indexPath.row];
    
    if (activity.eventActivity.count > 0 || activity.beeepInfoActivity.eventActivity != nil) {
        
        EventVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"EventVC"];
        
        viewController.tml = activity;
        
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else{
        
        TimelineVC *vC = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"TimelineVC"];
        vC.mode = Timeline_Not_Following;
        vC.showBackButton = YES;
        
        Who *w = [activity.who firstObject];
        Whom *wm = [activity.whom firstObject];
        
        NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
        
        if ([my_id isEqualToString:w.whoIdentifier]) {
            NSDictionary *user = [NSDictionary dictionaryWithObject:wm.whomIdentifier forKey:@"id"];
            vC.user = user;
        }
        
        if ([my_id isEqualToString:wm.whomIdentifier]) {
            NSDictionary *user = [NSDictionary dictionaryWithObject:w.whoIdentifier forKey:@"id"];
            vC.user = user;
        }
        
        
        [self.navigationController pushViewController:vC animated:YES];
    }
    
    
}

-(NSAttributedString *)textForNotification:(Activity_Object *)activity{

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
        formattedString = [NSString stringWithFormat:@"%@ %@ %@",[w.name capitalizedString],activity.did,event_title];
    }
    else if(activity.beeepInfoActivity.eventActivity.count >0){
        EventActivity *event = [activity.beeepInfoActivity.eventActivity firstObject];
        formattedString = [NSString stringWithFormat:@"%@ %@ %@",[w.name capitalizedString],activity.did,[NSString stringWithUTF8String:[[event.title capitalizedString] cStringUsingEncoding:[NSString defaultCStringEncoding]]]];
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
    }
    else if(activity.beeepInfoActivity.eventActivity.count >0){
        
        EventActivity *event = [activity.beeepInfoActivity.eventActivity firstObject];
        
        [attText addAttribute:NSFontAttributeName
                        value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]
                        range:[formattedString rangeOfString:[event.title capitalizedString]]];
        
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

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == notifications.count) {
        return 40;
    }
    else{
        NSAttributedString *str = [self textForNotification:[notifications objectAtIndex:indexPath.row]];

        CGSize textViewSize = [self frameForText:str constrainedToSize:CGSizeMake(212, CGFLOAT_MAX)];

        float height = ((textViewSize.height + 23 + 10)>60)?(textViewSize.height + 23 + 10):60;

        NSLog(@"H: %f",height);

        return height;
    }
}

-(CGSize)frameForText:(NSAttributedString*)text constrainedToSize:(CGSize)size{
    
    CGRect frame =  [text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin) context:nil];
    
    // This contains both height and width, but we really care about height.
    return frame.size;
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
        overdueMessage = [NSString stringWithFormat:@"%d%@", (years), (years==1?@"y":@"y")];
    }else if (months>0){
        overdueMessage = [NSString stringWithFormat:@"%d%@", (months), (months==1?@"mo":@"mo")];
    }else if (days>0){
        overdueMessage = [NSString stringWithFormat:@"%d%@", (days), (days==1?@"d":@"d")];
    }else if (hours>0){
        overdueMessage = [NSString stringWithFormat:@"%d%@", (hours), (hours==1?@"h":@"h")];
    }else if (minutes>0){
        overdueMessage = [NSString stringWithFormat:@"%d%@", (minutes), (minutes==1?@"m":@"m")];
    }else if (overdueTimeInterval<60){
        overdueMessage = [NSString stringWithFormat:@"a few seconds"];
    }
    
    return overdueMessage;
}

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




@end
