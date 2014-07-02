//
//  SuggestionsVC.m
//  Beeeper
//
//  Created by User on 3/27/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "SuggestionsVC.h"
#import "EventVC.h"
#import "BeeepItVC.h"
#import "BPSuggestions.h"
#import "MONActivityIndicatorView.h"

@interface SuggestionsVC ()<UITableViewDataSource,UITableViewDelegate,MONActivityIndicatorViewDelegate>
{
    NSMutableArray *suggestions;
    NSMutableArray *sections;
    NSMutableDictionary *pendingImagesDict;
    BOOL loadNextPage;
    NSMutableDictionary *suggestionsPerSection;

}
@end

@implementation SuggestionsVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
    refreshControl.tag = 234;
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(getSuggestions) forControlEvents:UIControlEventValueChanged];
    [self.tableV addSubview:refreshControl];
    self.tableV.alwaysBounceVertical = YES;

    pendingImagesDict = [NSMutableDictionary dictionary];
    
    [self getSuggestions];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];

}

-(void)nextPage{
    
    if (!loadNextPage) {
        return;
    }
    
    loadNextPage = NO;
    
    [[BPSuggestions sharedBP]nextSuggestionsWithCompletionBlock:^(BOOL completed,NSArray *objcts){
        
        if (completed) {
            if (objcts>0) {
                [suggestions addObjectsFromArray:objcts];
                [self groupSuggestionsByMonth];
                loadNextPage = YES;
            }
        }
    }];

}

-(void)getSuggestions{
    
    loadNextPage = YES;
    
    [self showLoading];
    
    [[BPSuggestions sharedBP]getSuggestionsWithCompletionBlock:^(BOOL completed,NSArray *objcts){
        
        UIRefreshControl *refreshControl = (id)[self.tableV viewWithTag:234];
        [refreshControl endRefreshing];
        [self hideLoading];
        
        if (objcts.count > 0) {
            self.noSuggestionsLabel.hidden = YES;
        }
        else{
            self.noSuggestionsLabel.hidden = NO;
        }
        
        if (completed) {
            suggestions = [NSMutableArray arrayWithArray:objcts];
            [self groupSuggestionsByMonth];
        }
    }];

}

-(void)groupSuggestionsByMonth{
    
    sections = [NSMutableArray array];
    
    [suggestions sortUsingComparator:^NSComparisonResult(Suggestion_Object *obj1, Suggestion_Object *obj2) {
        
        //1401749430
        //1401749422
        if (obj1.what.timestamp > obj2.what.timestamp) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if (obj1.what.timestamp < obj2.what.timestamp) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    for (Suggestion_Object *activity in suggestions) {
        //EVENT DATE
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE, MMM dd, yyyy hh:mm"];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [formatter setLocale:usLocale];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:activity.what.timestamp];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideTabbar" object:self];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    
    NSMutableArray *filtered_activities = [self suggestionsForSection:section];
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
        NSMutableArray *filtered_activities = [self suggestionsForSection:indexPath.section];
        
        Suggestion_Object *suggestion = [filtered_activities objectAtIndex:indexPath.row];
        Who *w = suggestion.who;
        What_Suggest *what = suggestion.what;

        double now_time = [[NSDate date]timeIntervalSince1970];
        double event_timestamp = what.timestamp;
        
        BOOL futureEvent = (now_time < event_timestamp);
        UIButton *beeepBtn = (id)[cell viewWithTag:67];
        beeepBtn.enabled = futureEvent;
        
        UIImageView *imageV = (id)[cell viewWithTag:1];
        UILabel *nameLbl = (id)[cell viewWithTag:2];
        UILabel *venueLbl = (id)[cell viewWithTag:3];
        UILabel *beeepedBy = (id)[cell viewWithTag:4];
        
        nameLbl.text = [what.title capitalizedString];
        
        NSData *data = [what.location dataUsingEncoding:NSUTF8StringEncoding];
        
        if (data != nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
            venueLbl.text = loc.venueStation;

        }
        
        beeepedBy.text = [NSString stringWithFormat:@"%@",[w.name capitalizedString]];
        
        //Image
       // NSString *extension = [[what.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        NSString *imageName = [NSString stringWithFormat:@"%@",[what.imageUrl MD5]];
        
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

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(section == sections.count) {
        return 1;
    }
    else{
        return 47;
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 7;
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
    
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 303, 44)];
    header.backgroundColor = [UIColor whiteColor];
    
    UILabel *mlbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 6, 303, 18)];
    mlbl.font =  [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    mlbl.textColor = [UIColor colorWithRed:250/255.0 green:217/255.0 blue:0/255.0 alpha:1];
    mlbl.text = [month uppercaseString];
    mlbl.textAlignment = NSTextAlignmentCenter;
    [header addSubview:mlbl];
    
    UILabel *dlbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 21, 303, 18)];
    dlbl.font =  [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
    dlbl.textColor = [UIColor colorWithRed:14/255.0 green:21/255.0 blue:40/255.0 alpha:1];
    dlbl.text = daynumber;
    dlbl.textAlignment = NSTextAlignmentCenter;
    [header addSubview:dlbl];
    
    
    return header;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableArray *filtered_activities = [self suggestionsForSection:indexPath.section];
    
    Suggestion_Object *suggestion = [filtered_activities objectAtIndex:indexPath.row];
    
    EventVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"EventVC"];
    
    viewController.tml = suggestion;
    
    [self.navigationController pushViewController:viewController animated:YES];

}


-(void)imageDownloadFinished:(NSNotification *)notif{
    
    NSString *imageName  = [notif.userInfo objectForKey:@"imageName"];
    
    NSArray* rowsToReload = [NSArray arrayWithObjects:[pendingImagesDict objectForKey:imageName], nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
        [pendingImagesDict removeObjectForKey:imageName];
    });
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)beeepItPressed:(UIButton *)sender{
    
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview.superview;
    NSIndexPath *path = [self.tableV indexPathForCell:cell];
    
    NSMutableArray *filtered_activities = [self suggestionsForSection:path.section];
    
    Suggestion_Object *suggestion = [filtered_activities objectAtIndex:path.row];
    
    BeeepItVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"BeeepItVC"];
    viewController.tml = suggestion;
    
    [self presentViewController:viewController animated:YES completion:NULL];
}

-(NSMutableArray *)suggestionsForSection:(int)section{
    
    if ([suggestionsPerSection objectForKey:[NSString stringWithFormat:@"%d",section]]) {
        return [suggestionsPerSection objectForKey:[NSString stringWithFormat:@"%d",section]];
    }
    else{

        NSString *section_signature = [sections objectAtIndex:section];
        NSMutableArray *filtered_activities = [NSMutableArray array];
        
        for (Suggestion_Object *suggestion in suggestions) {
            //EVENT DATE
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"EEEE, MMM dd, yyyy hh:mm"];
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [formatter setLocale:usLocale];
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:suggestion.what.timestamp];
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
