//
//  SuggestionsVC.m
//  Beeeper
//
//  Created by User on 3/27/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "SuggestionsVC.h"
#import "EventVC.h"
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
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
    
   // self.tableV.decelerationRate = 0.6;
    
    [self getSuggestions];
    
    [[DTO sharedDTO]clearSuggestions];

}

-(void)getLocalSuggestions{

    [self showLoading];
    
    [[BPSuggestions sharedBP]getLocalSuggestions:^(BOOL completed,NSArray *objcts){
        
        if (completed && objcts.count > 0) {
            
            suggestions = [NSMutableArray arrayWithArray:objcts];
            [self groupSuggestionsByMonth];
            [self hideLoading];
        }
    }];
}

-(void)nextPage{
    
    [[BPSuggestions sharedBP]nextSuggestionsWithCompletionBlock:^(BOOL completed,NSArray *objcts){
        
        if (completed) {
            if (objcts && objcts.count>0) {
                
                for (Suggestion_Object *sugg in objcts) {
                    
                    BOOL uparxei = NO;
                    
                    for (Suggestion_Object *suggO in suggestions) {
                        if (sugg.when == suggO.when) {
                            uparxei = YES;
                        }
                    }
                    
                    if (!uparxei) {
                        [suggestions addObject:sugg];
                    }
                    
                }
                
                [self.tableV reloadData];
                
            }
            else{
                [self.tableV reloadData];
            }
        }
        else{
            [self.tableV reloadData];
        }
    }];

}

-(void)getSuggestions{
    
    [self showLoading];
    
    [[BPSuggestions sharedBP]getSuggestionsWithCompletionBlock:^(BOOL completed,NSArray *objcts){
        
        UIRefreshControl *refreshControl = (id)[self.tableV viewWithTag:234];
        [refreshControl endRefreshing];
        
        if (completed) {
            
            if (objcts.count > 0) {
                
                suggestions = [NSMutableArray arrayWithArray:objcts];
                [self groupSuggestionsByMonth];
                
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
            
            [self hideLoading];
        }
        else{
            self.noSuggestionsLabel.hidden = NO;
            
            [self hideLoading];

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
        [formatter setDateFormat:@"EEEE, MMMM dd, yyyy HH:mm"];
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
        
        NSString *signature = [NSString stringWithFormat:@"%@#%@",month,year];
        
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
    
   // [self getLocalSuggestions];
    
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
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return ([BPSuggestions sharedBP].loadNextPage && suggestions.count > 0)?suggestions.count+1:suggestions.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == suggestions.count && suggestions.count > 0 && [BPSuggestions sharedBP].loadNextPage) {
        
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
            
        Suggestion_Object *suggestion = [suggestions objectAtIndex:indexPath.row];
        Who *w = suggestion.who;
        What_Suggest *what = suggestion.what;

        double now_time = [[NSDate date]timeIntervalSince1970];
        double event_timestamp = what.timestamp;
        
        BOOL futureEvent = (now_time < event_timestamp);
        UIButton *beeepBtn = (id)[cell viewWithTag:67];
        beeepBtn.enabled = futureEvent;
        
        UIImageView *imageV = (id)[cell viewWithTag:3];
        UILabel *nameLbl = (id)[cell viewWithTag:4];
        UILabel *venueLbl = (id)[cell viewWithTag:5];
        UILabel *dayLbl = (id)[cell viewWithTag:2];
        UILabel *monthLbl = (id)[cell viewWithTag:1];
        UILabel *suggestedBy = (id)[cell viewWithTag:7];
        UILabel *timeLabel = (id)[cell viewWithTag:55];
        
        nameLbl.text = [what.title capitalizedString];
       // [nameLbl sizeToFitHeight];

//        UIView *bottomV = (id)[cell viewWithTag:666];
      //  bottomV.frame = CGRectMake(nameLbl.frame.origin.x, nameLbl.frame.origin.y+nameLbl.frame.size.height, bottomV.frame.size.width,bottomV.frame.size.height);
        
        NSData *data = [what.location dataUsingEncoding:NSUTF8StringEncoding];
        
        if (data != nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
            venueLbl.text = [loc.venueStation capitalizedString];

        }
        
        //EVENT DATE
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE, MMM dd, yyyy HH:mm"];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [formatter setLocale:usLocale];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:what.timestamp];
        NSString *dateStr = [formatter stringFromDate:date];
        NSArray *components = [dateStr componentsSeparatedByString:@","];
        NSArray *day_month= [[components objectAtIndex:1]componentsSeparatedByString:@" "];
        
        NSString *month = [day_month objectAtIndex:1];
        NSString *daynumber = [day_month objectAtIndex:2];
        NSString *year = [[[components lastObject] componentsSeparatedByString:@" "] firstObject];
        NSString *hour = [[[components lastObject] componentsSeparatedByString:@" "] lastObject];
        
        timeLabel.text = hour;
        dayLbl.text = daynumber;
        monthLbl.text = [month uppercaseString];
        
        suggestedBy.text = [NSString stringWithFormat:@"%@ %@",[w.name capitalizedString],[w.lastname capitalizedString]];
        
        //Image
       // NSString *extension = [[what.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        
        [imageV sd_setImageWithURL:[NSURL URLWithString:[[DTO sharedDTO]fixLink:what.imageUrl]]
                placeholderImage:[UIImage imageNamed:@"event_image"]];
        
        UIImageView *beeepedByImageV = (id)[cell viewWithTag:34];
        
        [beeepedByImageV sd_setImageWithURL:[NSURL URLWithString:[[DTO sharedDTO] fixLink:w.imagePath]]
                           placeholderImage:[UIImage imageNamed:@"user_icon_180x180"]];
        
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
    
    if (indexPath.row == suggestions.count){
        return 51;
    }
    else{
        return 81;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Suggestion_Object *suggestion = [suggestions objectAtIndex:indexPath.row];
    
    EventVC *viewController = [[[DTO sharedDTO]storyboardWithNameDeviceSpecific:@"Storyboard-No-AutoLayout"] instantiateViewControllerWithIdentifier:@"EventVC"];
    
    viewController.tml = suggestion;
    
    [self.navigationController pushViewController:viewController animated:YES];

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
    
    Suggestion_Object *suggestion = [suggestions objectAtIndex:path.row];
    
    NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
    
    if ([suggestion.beeepersIds indexOfObject:my_id] != NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Already Beeeped" message:@"You have already Beeeeped this event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    UIImageView *imageV = (id)[cell viewWithTag:3];
    
    [[TabbarVC sharedTabbar]reBeeepPressed:suggestion image:imageV.image controller:self];
    
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
            [formatter setDateFormat:@"EEEE, MMMM dd, yyyy HH:mm"];
            NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [formatter setLocale:usLocale];
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:suggestion.what.timestamp];
            [formatter setDateFormat:@"MMMM#YYYY"];
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
             self.tableV.alpha = 1;
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
