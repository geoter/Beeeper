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


@interface SuggestionsVC ()<UITableViewDataSource,UITableViewDelegate,MONActivityIndicatorViewDelegate>
{
    NSMutableArray *suggestions;
    NSMutableArray *sections;
    NSMutableDictionary *pendingImagesDict;
    NSMutableDictionary *suggestionsPerSection;
        NSMutableArray *rowsToReload;

}
@end

@implementation SuggestionsVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    rowsToReload = [NSMutableArray array];
    
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
    
    
    [[BPSuggestions sharedBP]nextSuggestionsWithCompletionBlock:^(BOOL completed,NSArray *objcts){
        
        if (completed) {
            if (objcts && objcts.count>0) {
                [suggestions addObjectsFromArray:objcts];
                [self groupSuggestionsByMonth];
            }
            else{
                [self.tableV reloadData];
            }
        }
    }];

}

-(void)getSuggestions{
    
    
    [self showLoading];
    
    [[BPSuggestions sharedBP]getSuggestionsWithCompletionBlock:^(BOOL completed,NSArray *objcts){
        
        UIRefreshControl *refreshControl = (id)[self.tableV viewWithTag:234];
        [refreshControl endRefreshing];
        [self hideLoading];
        
        if (completed) {
            
            if (objcts.count > 0) {
                
                self.noSuggestionsLabel.hidden = YES;
                self.tableV.hidden = NO;
            }
            else{
                self.noSuggestionsLabel.hidden = NO;
                self.tableV.hidden = YES;
                
                if ([objcts isKindOfClass:[NSArray class]] && objcts.count == 0) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"getSuggestions Completed but objcts == 0" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                        [alert show];
                        
                    });
                }
                
            }

            
            suggestions = [NSMutableArray arrayWithArray:objcts];
            [self groupSuggestionsByMonth];
        }
        else{
            self.noSuggestionsLabel.hidden = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"getSuggestions not Completed" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
                
            });
        }
    }];

}

-(void)groupSuggestionsByMonth{
    
    sections = [NSMutableArray array];
    suggestionsPerSection = [NSMutableDictionary dictionary];
    
    [suggestions sortUsingComparator:^NSComparisonResult(Suggestion_Object *obj1, Suggestion_Object *obj2) {
        
        //1401749430
        //1401749422
        if (obj1.what.timestamp > obj2.what.timestamp) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (obj1.what.timestamp < obj2.what.timestamp) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    for (Suggestion_Object *activity in suggestions) {
        //EVENT DATE
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE, MMM dd, yyyy HH:mm"];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [formatter setLocale:usLocale];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:activity.what.timestamp];
        NSString *dateStr = [formatter stringFromDate:date];
        NSArray *components = [dateStr componentsSeparatedByString:@","];
        NSArray *day_month= [[components objectAtIndex:1]componentsSeparatedByString:@" "];
        
        NSString *month = [day_month objectAtIndex:1];
        NSString *daynumber = [day_month objectAtIndex:2];
        NSString *year = [[[components lastObject] componentsSeparatedByString:@" "] objectAtIndex:1];
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
   return (sections.count>0 && [BPSuggestions sharedBP].loadNextPage)?(sections.count+1):sections.count;
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
    
    if (indexPath.section == sections.count) {
        
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
        [nameLbl sizeToFitHeight];

        UIView *bottomV = (id)[cell viewWithTag:666];
       // bottomV.frame = CGRectMake(110, nameLbl.frame.origin.y+nameLbl.frame.size.height, 196, 51);
        
        NSData *data = [what.location dataUsingEncoding:NSUTF8StringEncoding];
        
        if (data != nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
            venueLbl.text = [loc.venueStation uppercaseString];

        }
        
        beeepedBy.text = [NSString stringWithFormat:@"%@ %@",[w.name capitalizedString] ,[w.lastname capitalizedString]];
        
        NSString *who_imageName = [NSString stringWithFormat:@"%@",[w.imagePath MD5]];
        
        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *who_localPath = [documentsDirectoryPath stringByAppendingPathComponent:who_imageName];
        UIImageView *beeepedByImageV = (id)[cell viewWithTag:34];
        
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
        

        //Image
       // NSString *extension = [[what.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        NSString *imageName = [NSString stringWithFormat:@"%@",[what.imageUrl MD5]];
        imageName = [[DTO sharedDTO]fixLink:imageName];
      
        
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == sections.count){
        return 51;
    }
    else{
        return 102;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 7;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(section == sections.count ) {
        return 1;
    }
    else{
        return 47;
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

    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 47)];
    header.backgroundColor = [UIColor clearColor];
    UIView *backV = [[UIView alloc]initWithFrame:CGRectMake(7, 0, 306, 46)];
    [backV setBackgroundColor:[UIColor whiteColor]];
    [header addSubview:backV];
    
    if (isToday || isTomorrow) {
        UILabel *mlbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 6, 306, 36)];
        mlbl.font =  [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        mlbl.textColor = [UIColor colorWithRed:14/255.0 green:21/255.0 blue:40/255.0 alpha:1];
        mlbl.text = (isToday)?@"Today":@"Tomorrow";
        mlbl.textAlignment = NSTextAlignmentCenter;
        [backV addSubview:mlbl];
    }
    else{
        
        UILabel *mlbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 6, 306, 18)];
        mlbl.font =  [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
        mlbl.textColor = [UIColor colorWithRed:240/255.0 green:208/255.0 blue:0/255.0 alpha:1];
        mlbl.text = [month uppercaseString];
        mlbl.textAlignment = NSTextAlignmentCenter;
        [backV addSubview:mlbl];
        
        UILabel *dlbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 21, 306, 18)];
        dlbl.font =  [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
        dlbl.textColor = [UIColor colorWithRed:14/255.0 green:21/255.0 blue:40/255.0 alpha:1];
        dlbl.text = daynumber;
        dlbl.textAlignment = NSTextAlignmentCenter;
        [backV addSubview:dlbl];
    }
    
    UIView *headerBottomLine = [[UIView alloc]initWithFrame:CGRectMake(7, header.frame.size.height-1, 306, 1)];
    headerBottomLine.backgroundColor = [UIColor colorWithRed:218/255.0 green:223/255.0 blue:227/255.0 alpha:1];
    [header addSubview:headerBottomLine];
    
    return header;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 303, 7)];
    footer.backgroundColor = [UIColor clearColor];
    return footer;
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
    
    NSArray* rows = [NSArray arrayWithObjects:[pendingImagesDict objectForKey:imageName], nil];
    
     [rowsToReload addObjectsFromArray:rows];
    
    if (rowsToReload.count == 5  || (pendingImagesDict.count < 5 && pendingImagesDict.count > 0)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [pendingImagesDict removeObjectForKey:imageName];
            
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)beeepItPressed:(UIButton *)sender{
    
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    
    UITableViewCell *cell = (UITableViewCell *)view;
    NSIndexPath *path = [self.tableV indexPathForCell:cell];
    
    NSMutableArray *filtered_activities = [self suggestionsForSection:path.section];
    
    Suggestion_Object *suggestion = [filtered_activities objectAtIndex:path.row];
    
    NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
    
    if ([suggestion.beeepersIds indexOfObject:my_id] != NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Already Beeeped" message:@"You have already Beeeeped this event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
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
            [formatter setDateFormat:@"EEEE, MMM dd, yyyy HH:mm"];
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [formatter setLocale:usLocale];
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:suggestion.what.timestamp];
            [formatter setDateFormat:@"MMM#dd#YYYY"];
            NSString *signature = [formatter stringFromDate:date];
            
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
