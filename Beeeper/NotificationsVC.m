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
    NSMutableDictionary *pendingImagesDict;
}
@end

@implementation NotificationsVC

- (void)viewDidLoad
{
    [super viewDidLoad];

//    for (UIView *view in [[[self.navigationController.navigationBar subviews] objectAtIndex:0] subviews]) {
//        if ([view isKindOfClass:[UIImageView class]]) view.hidden = YES;
//    }

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    refreshControl.tag = 234;
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(getNotifications) forControlEvents:UIControlEventValueChanged];
    [self.tableV addSubview:refreshControl];

    pendingImagesDict = [NSMutableDictionary dictionary];
    
    [self getNotifications];
}

-(void)getNotifications{
    
    [self showLoading];
    
    [[BPUser sharedBP]getLocalNotifications:^(BOOL completed,NSArray *objcts){
        
        UIRefreshControl *refreshControl = (id)[self.tableV viewWithTag:234];
        [refreshControl endRefreshing];
        [self hideLoading];
        
        if (completed) {
            notifications = [NSMutableArray arrayWithArray:objcts];
            [self.tableV reloadData];
        }
    }];
    
    [[BPUser sharedBP]getNotificationsWithCompletionBlock:^(BOOL completed,NSArray *objcts){

        UIRefreshControl *refreshControl = (id)[self.tableV viewWithTag:234];
        [refreshControl endRefreshing];
        [self hideLoading];
        if (completed) {
            notifications = [NSMutableArray arrayWithArray:objcts];
            [self.tableV reloadData];
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
    return notifications.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSLog(@"EMPTY CELL");
    }
    
    UIImageView *imgV = (UIImageView *)[cell viewWithTag:1];
    
    UILabel *time = (UILabel *)[cell viewWithTag:2];
    time.font =  [UIFont fontWithName:@"HelveticaNeue" size:10];
    
    UILabel *txtV = (id)[cell viewWithTag:3];
    txtV.font =  [UIFont fontWithName:@"HelveticaNeue" size:13];

    Activity_Object *activity = [notifications objectAtIndex:indexPath.row];
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

    NSString *extension;
    NSString *imageName;

    
    if ([w.name isEqualToString:@"You"] && activity.eventActivity.count == 0 && activity.beeepInfoActivity.eventActivity == nil) {
        extension = [[wm.imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        imageName = [NSString stringWithFormat:@"%@.%@",[wm.imagePath MD5],extension];
    }
    else if (activity.eventActivity.count > 0){
        EventActivity *event = [activity.eventActivity firstObject];
        NSString *path = event.imageUrl;
        extension = [[path.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        imageName = [NSString stringWithFormat:@"%@.%@",[path MD5],extension];
        
    }
    else if(activity.beeepInfoActivity.eventActivity != nil){
        EventActivity *event = [activity.beeepInfoActivity.eventActivity firstObject];
        extension = [[event.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        imageName = [NSString stringWithFormat:@"%@.%@",[event.imageUrl MD5],extension];
    }
    else if ([wm.name isEqualToString:@"You"]){
        extension = [[w.imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        imageName = [NSString stringWithFormat:@"%@.%@",[w.imagePath MD5],extension];
    }
    
    
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
    
    txtV.frame = CGRectMake(txtV.frame.origin.x, txtV.frame.origin.y, 212, textViewSize.height);
    
    
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
        NSString *event_title = [event.title capitalizedString];
        formattedString = [NSString stringWithFormat:@"%@ %@ %@",[w.name capitalizedString],activity.did,event_title];
    }
    else if(activity.beeepInfoActivity.eventActivity.count >0){
        EventActivity *event = [activity.beeepInfoActivity.eventActivity firstObject];
        formattedString = [NSString stringWithFormat:@"%@ %@ %@",[w.name capitalizedString],activity.did,[event.title capitalizedString]];
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
        NSString *event_title = [event.title capitalizedString];
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
    
    NSAttributedString *str = [self textForNotification:[notifications objectAtIndex:indexPath.row]];
    
    CGSize textViewSize = [self frameForText:str constrainedToSize:CGSizeMake(212, CGFLOAT_MAX)];
    
    float height = 60.0;((textViewSize.height + 23 + 10)>60)?(textViewSize.height + 23 + 10):60;
    
    NSLog(@"H: %f",height);
    
    return height;
    
}

-(CGSize)frameForText:(NSAttributedString*)text constrainedToSize:(CGSize)size{
    
    CGRect frame =  [text boundingRectWithSize:size options:(NSStringDrawingUsesLineFragmentOrigin) context:nil];
    
    // This contains both height and width, but we really care about height.
    return frame.size;
}

-(void)imageDownloadFinished:(NSNotification *)notif{
    
    NSString *imageName  = [notif.userInfo objectForKey:@"imageName"];
    
    NSArray* rowsToReload = [NSArray arrayWithObjects:[pendingImagesDict objectForKey:imageName], nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
        [pendingImagesDict removeObjectForKey:imageName];
    });
    
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
        overdueMessage = [NSString stringWithFormat:@"%d %@", (years), (years==1?@"year":@"years")];
    }else if (months>0){
        overdueMessage = [NSString stringWithFormat:@"%d %@", (months), (months==1?@"month":@"months")];
    }else if (days>0){
        overdueMessage = [NSString stringWithFormat:@"%d %@", (days), (days==1?@"day":@"days")];
    }else if (hours>0){
        overdueMessage = [NSString stringWithFormat:@"%d %@", (hours), (hours==1?@"hour":@"hours")];
    }else if (minutes>0){
        overdueMessage = [NSString stringWithFormat:@"%d %@", (minutes), (minutes==1?@"minute":@"minutes")];
    }else if (overdueTimeInterval<60){
        overdueMessage = [NSString stringWithFormat:@"a few seconds"];
    }
    
    return [overdueMessage stringByAppendingString:@" ago"];
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
