//
//  ActivityVC.m
//  Beeeper
//
//  Created by User on 4/3/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "ActivityVC.h"
#import "EventVC.h"
#import "TimelineVC.h"
#import "BPActivity.h"

@interface ActivityVC ()<MONActivityIndicatorViewDelegate>
{
    NSMutableArray *activities;
    NSMutableArray *sections;
    NSMutableDictionary *pendingImagesDict;
    BOOL loadNextPage;
    NSMutableDictionary *activitiesPerSection;
    NSMutableArray *rowsToReload;
}
@end

@implementation ActivityVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    rowsToReload = [NSMutableArray array];
    
    [self showLoading];
    
    [[BPActivity sharedBP]getLocalActivityWithCompletionBlock:^(BOOL completed,NSArray *objs){
        
        if (completed && objs.count > 0) {

            
            activities = [NSMutableArray arrayWithArray:objs];
            [self groupActivitiesByMonth];
            
            [self hideLoading];
            
            
            //            UILabel *numberLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 30)];
            //            numberLbl.text = [NSString stringWithFormat:@"%d",activities.count];
            //            numberLbl.textColor = [UIColor whiteColor];
            //            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:numberLbl];
            
        }
    
    }];

    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    refreshControl.tag = 234;
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(getActivity) forControlEvents:UIControlEventValueChanged];
    [self.tableV addSubview:refreshControl];
    self.tableV.alwaysBounceVertical = YES;
   // self.tableV.decelerationRate = 0.6;
    pendingImagesDict = [NSMutableDictionary dictionary];
    
}


-(void)nextPage{
    
    if (!loadNextPage) {
        return;
    }
    
    loadNextPage = NO;
    
    [[BPActivity sharedBP]nextPageActivityWithCompletionBlock:^(BOOL completed,NSArray *objcts){
        
        if (completed) {
            
            if (objcts.count != 0) {
                
                [activities addObjectsFromArray:objcts];
                loadNextPage = (objcts.count == [BPActivity sharedBP].pageLimit);
                [self groupActivitiesByMonth];
            }
        }
    }];

    
}

-(void)getActivity{
    
    loadNextPage = YES;
    
    [[BPActivity sharedBP]getActivityWithCompletionBlock:^(BOOL completed,NSArray *objcts){

        UIRefreshControl *refreshControl = (id)[self.tableV viewWithTag:234];
        [refreshControl endRefreshing];
        [self hideLoading];
        
        if (completed) {
            
            activities = [NSMutableArray arrayWithArray:objcts];
            
            if (activities.count > 0) {
                self.noActivityFound.hidden = YES;
            }
            else{
                
                if ([objcts isKindOfClass:[NSString class]]) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"getAllEvents Completed but objs.count == 0" message:(NSString *)objcts delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                    [alert show];
                    
                }

                
                self.noActivityFound.hidden = NO;
            }
            
            [self groupActivitiesByMonth];
            
//            UILabel *numberLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 10, 30)];
//            numberLbl.text = [NSString stringWithFormat:@"%d",activities.count];
//            numberLbl.textColor = [UIColor whiteColor];
//            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:numberLbl];
        }
    }];

}

-(NSMutableArray *)activitiesForSection:(int)section{

    if ([activitiesPerSection objectForKey:[NSString stringWithFormat:@"%d",section]]) {
        return [activitiesPerSection objectForKey:[NSString stringWithFormat:@"%d",section]];
    }
    else{
        NSString *section_signature = [sections objectAtIndex:section];
        NSMutableArray *filtered_activities = [NSMutableArray array];
        
        for (Activity_Object *activity in activities) {
            //EVENT DATE
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEEE, MMM dd, yyyy HH:mm"];
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [formatter setLocale:usLocale];
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:activity.when];
            NSString *dateStr = [formatter stringFromDate:date];
            NSArray *components = [dateStr componentsSeparatedByString:@","];
            NSArray *day_month= [[components objectAtIndex:1]componentsSeparatedByString:@" "];
            
            NSString *month = [day_month objectAtIndex:1];
            NSString *daynumber = [day_month objectAtIndex:2];
            NSString *year = [[[components lastObject] componentsSeparatedByString:@" "] objectAtIndex:1];
            NSString *hour = [[[components lastObject] componentsSeparatedByString:@" "] lastObject];
            
            NSString *signature = [NSString stringWithFormat:@"%@#%@#%@",month,daynumber,year];
            
            if ([section_signature isEqualToString:signature]) {
                [filtered_activities addObject:activity];
            }
        }
        
        [activitiesPerSection setObject:filtered_activities forKey:[NSString stringWithFormat:@"%d",section]];
        
        return filtered_activities;
    }
    
    return nil;
}


-(void)groupActivitiesByMonth{
   
    @try {
        activitiesPerSection = [NSMutableDictionary dictionary];
        
        NSMutableArray *sectionsArr = [NSMutableArray array];
        
        [activities sortUsingComparator:^NSComparisonResult(Activity_Object *obj1, Activity_Object *obj2) {
            if (obj1.when > obj2.when) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            
            if (obj1.when < obj2.when) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        for (Activity_Object *activity in activities) {
            //EVENT DATE
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEEE, MMM dd, yyyy HH:mm"];
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [formatter setLocale:usLocale];
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:activity.when];
            NSString *dateStr = [formatter stringFromDate:date];
            NSArray *components = [dateStr componentsSeparatedByString:@","];
            NSArray *day_month= [[components objectAtIndex:1]componentsSeparatedByString:@" "];
            
            NSString *month = [day_month objectAtIndex:1];
            NSString *daynumber = [day_month objectAtIndex:2];
            NSString *year = [[[components lastObject] componentsSeparatedByString:@" "] objectAtIndex:1];
            NSString *hour = [[[components lastObject] componentsSeparatedByString:@" "] lastObject];
            
            NSString *signature = [NSString stringWithFormat:@"%@#%@#%@",month,daynumber,year];
            
            if ([sectionsArr indexOfObject:signature] == NSNotFound) {
                [sectionsArr addObject:signature];
            }
        }
        
        
        sections = sectionsArr;
        
        [self.tableV performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

    }
    @catch (NSException *exception) {
        NSLog(@"ESKASE");
    }
    @finally {

    }
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self getActivity];
    
    self.title = @"Activity";
    self.navigationController.navigationBar.topItem.title = self.title;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideTabbar" object:self];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return (sections.count>0 && loadNextPage)?(sections.count+1):sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == sections.count) {
        return 1;
    }
    
    NSMutableArray *filtered_activities = [self activitiesForSection:section];
    return filtered_activities.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.section == sections.count) {

        static NSString *CellIdentifier = @"LoadMoreCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UIActivityIndicatorView *indicator = (id)[cell viewWithTag:55];
        [indicator startAnimating];
        
        [self nextPage];
        
        return cell;
        
    }
    
    @try {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [self.tableV dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        
        NSMutableArray *filtered_activities = [self activitiesForSection:indexPath.section];
        Activity_Object *activity = [filtered_activities objectAtIndex:indexPath.row];
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
        
        UILabel *lbl = (id)[cell viewWithTag:2];
        lbl.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
        
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
        
        formattedString = [formattedString stringByReplacingOccurrencesOfString:@"comment" withString:@"commented on"];
        
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
        
        lbl.attributedText = attText;
        
        
        UIImageView *imgV = (id)[cell viewWithTag:1];
        
       // NSString *extension;
        NSString *imagePath;
        
        if ([w.name isEqualToString:@"You"] && activity.eventActivity.count == 0 && activity.beeepInfoActivity.eventActivity == nil) {
          //  extension = [[wm.imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
            imagePath = [NSString stringWithFormat:@"%@",wm.imagePath];
        }
        else if (activity.eventActivity.count > 0){
            EventActivity *event = [activity.eventActivity firstObject];
            imagePath = event.imageUrl;
            
        }
        else if(activity.beeepInfoActivity.eventActivity != nil){
            EventActivity *event = [activity.beeepInfoActivity.eventActivity firstObject];
        //    extension = [[event.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
            imagePath = [NSString stringWithFormat:@"%@",event.imageUrl];
        }
        else if ([wm.name isEqualToString:@"You"]){
         //   extension = [[w.imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
            imagePath = w.imagePath;
        }
        
        [imgV sd_setImageWithURL:[NSURL URLWithString:[[DTO sharedDTO] fixLink:imagePath]]
                     placeholderImage:[[DTO sharedDTO] imageWithColor:[UIColor lightGrayColor]]];
        
        return cell;

    }
    @catch (NSException *exception) {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [self.tableV dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        return cell;
    }
    @finally {

    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == sections.count+1 && loadNextPage){
        return 51;
    }
    else{
        return 60;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(section == sections.count) {
        return 1;
    }
    else{
        return 47;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(section == sections.count) {
        return 1;
    }
    else{
        return 7;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if(section == sections.count) {

        UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 303, 1)];
        header.backgroundColor = [UIColor clearColor];
        return header;
    }
    
    NSString *signature = [sections objectAtIndex:section];
    NSArray *components = [signature componentsSeparatedByString:@"#"];
    NSString *month = [components objectAtIndex:0];
    NSString *daynumber = [components objectAtIndex:1];
    
    //Today
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter  = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMM#d#YYYY"];
    NSString *signatureToday = [formatter stringFromDate:date];
    
    BOOL isToday = [signature isEqualToString:signatureToday];
    
    //Tommorrow
    
    NSDate *dateTmw = [date dateByAddingTimeInterval:60*60*24];
    NSString *signatureTmw = [formatter stringFromDate:dateTmw];
    
    BOOL isTomorrow = [signature isEqualToString:signatureTmw];
    
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableV.frame.size.width, 47)];
    header.backgroundColor = [UIColor clearColor];
    UIView *backV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableV.frame.size.width, 46)];
    [backV setBackgroundColor:[UIColor whiteColor]];
    [header addSubview:backV];
    
    if (isToday || isTomorrow) {
        UILabel *mlbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 6, self.tableV.frame.size.width, 36)];
        mlbl.font =  [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        mlbl.textColor = [UIColor colorWithRed:14/255.0 green:21/255.0 blue:40/255.0 alpha:1];
        mlbl.text = (isToday)?@"Today":@"Tomorrow";
        mlbl.textAlignment = NSTextAlignmentCenter;
        [backV addSubview:mlbl];
    }

    else{
        
        UILabel *mlbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 6, self.tableV.frame.size.width, 18)];
        mlbl.font =  [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        mlbl.textColor = [UIColor colorWithRed:240/255.0 green:208/255.0 blue:0/255.0 alpha:1];
        mlbl.text = [month uppercaseString];
        mlbl.textAlignment = NSTextAlignmentCenter;
        [backV addSubview:mlbl];
        
        UILabel *dlbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 21, self.tableV.frame.size.width, 18)];
        dlbl.font =  [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
        dlbl.textColor = [UIColor colorWithRed:14/255.0 green:21/255.0 blue:40/255.0 alpha:1];
        dlbl.text = daynumber;
        dlbl.textAlignment = NSTextAlignmentCenter;
        [backV addSubview:dlbl];
    }
    
//    UIView *headerBottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, header.frame.size.height-1, 306, 1)];
//    headerBottomLine.backgroundColor = [UIColor colorWithRed:218/255.0 green:223/255.0 blue:226/255.0 alpha:1];
//    [header addSubview:headerBottomLine];
    
    backV.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    backV.layer.shadowOpacity = 0.7;
    backV.layer.shadowOffset = CGSizeMake(0, 0.1);
    backV.layer.shadowRadius = 0.8;
    [backV.layer setShadowPath:[[UIBezierPath
                                bezierPathWithRect:backV.bounds] CGPath]];

    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    
      UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableV.frame.size.width, 7)];
      footer.backgroundColor = [UIColor clearColor];
      return footer;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    NSMutableArray *filtered_activities = [self activitiesForSection:indexPath.section];
    Activity_Object *activity = [filtered_activities objectAtIndex:indexPath.row];
    
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

-(void)showLoading{
    
    if ([self.view viewWithTag:-434]) {
        return;
    }
    
    dispatch_async (dispatch_get_main_queue(), ^{
        
        UIView *loadingBGV = [[UIView alloc]initWithFrame:self.view.bounds];
        loadingBGV.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
        
        MONActivityIndicatorView *indicatorView = [[MONActivityIndicatorView alloc] init];
        indicatorView.delegate = self;
        indicatorView.numberOfCircles = 3;
        indicatorView.radius = 8;
        indicatorView.internalSpacing = 1;
        indicatorView.center = self.view.center;
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


@end

