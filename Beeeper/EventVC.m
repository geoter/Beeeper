//
//  EventVC.m
//  Beeeper
//
//  Created by User on 3/21/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "EventVC.h"
#import "BeeepItVC.h"
#import "PHFComposeBarView.h"
#import "SuggestBeeepVC.h"
#import "Comment.h"
#import "Comments.h"
#import "EventWS.h"
#import "Activity_Object.h"
#import "BPActivity.h"
#import "Event_Show_Object.h"
#import "FollowListVC.h"
#import "BPSuggestions.h"
#import "Event_Show_Object.h"
#import "Beeep_Object.h"
#import "CommentsVC.h"

@interface EventVC ()<PHFComposeBarViewDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>{

    NSMutableArray *comments;
    NSMutableArray *beeepers;
    NSMutableArray *likers;
    
    BOOL isKeyboardVisible;
    BOOL isContainerVisible;
    UITapGestureRecognizer *tapG;
    NSMutableDictionary *pendingImagesDict;
    BOOL isLiker;
    
    Beeep_Object *beeep_Objct; //-(void)showEventForActivityWithBeeep
    Event_Show_Object *event_show_Objct; //-(void)showEventForActivityWithBeeep
}
@property (readonly, nonatomic) UIView *container;
@property (readonly, nonatomic) PHFComposeBarView *composeBarView;
@property (nonatomic,assign) CGRect kInitialViewFrame;
@property (readonly, nonatomic) UITextView *textView;

@end

@implementation EventVC
@synthesize kInitialViewFrame,tml;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self showLoading];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideTabbar" object:self];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.navigationController.navigationBar.backItem.title = @"";

    pendingImagesDict = [NSMutableDictionary dictionary];
    
    if ([tml isKindOfClass:[Timeline_Object class]]) {
        Timeline_Object *t = tml;
        comments = [NSMutableArray arrayWithArray:t.beeep.beeepInfo.comments];
    }
    else if ([tml isKindOfClass:[Activity_Object class]]){
        
        Activity_Object *activity = tml;
        
        if (activity.beeepInfoActivity.beeepActivity.count > 0) {
           
            [[BPActivity sharedBP]getBeeepInfoFromActivity:tml WithCompletionBlock:^(BOOL completed,Beeep_Object *beeep){
                if (completed) {
                    beeep_Objct = beeep;
                    
                    if (event_show_Objct != nil || (event_show_Objct == nil && activity.eventActivity.count == 0)) {
                        [self showEventForActivityWithBeeep];
                    }
                }
            }];

        }
        
        if(activity.eventActivity.count > 0 || activity.beeepInfoActivity.eventActivity.count >0){
            
            [[BPActivity sharedBP]getEvent:tml WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                if (completed) {
                    event_show_Objct = event;
                    if ((beeep_Objct != nil) || (beeep_Objct == nil && activity.beeepInfoActivity.beeepActivity.count == 0)) {
                          [self showEventForActivityWithBeeep];
                    }
                }
            }];
        }

    }
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];

    UIBarButtonItem *btnLike = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"like_event.png"] style:UIBarButtonItemStylePlain target:self action:@selector(likeIt)];
    UIBarButtonItem *btnShare = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"suggest_it_event.png"] style:UIBarButtonItemStylePlain target:self action:@selector(suggestIt)];
    UIBarButtonItem *btnMore = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more_btn_event.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showMore)];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:btnMore,btnLike,btnShare, nil]];
    
    self.scrollV.contentSize = CGSizeMake(320, 871);
    
//    self.monthLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:24];
//    self.dayNumberLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:41];
//    self.dayLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
//    self.hourLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
//    
//    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:26];
//    self.venueLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:15];
//    
//    self.codeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:13];
//    self.codeNumberLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
//    self.websiteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
//    self.tagsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:12];
    
    
   [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(beeepIt:) name:@"BeeepIt" object:nil];
    
    self.kInitialViewFrame = CGRectMake(0, self.view.frame.size.height-44, 320, 44);
    
    UIView *container = [self container];
    [container addSubview:[self composeBarView]];
    container.frame = CGRectMake(0, self.view.frame.size.height + container.frame.size.height, 320, container.frame.size.height);
    [self.view addSubview:container];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggle:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggle:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    if ([tml isKindOfClass:[Timeline_Object class]]) {
        [self showEventWithTimelineObject];
    }
    else if ([tml isKindOfClass:[Friendsfeed_Object class]]) {
        [self showEventWithFriendFeedObject];
    }
    else if ([tml isKindOfClass:[Suggestion_Object class]]){
        [self showEventWithSuggestion];
    }
}


-(void)showEventWithSuggestion{
    
    //EVENT DATE
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMM dd, yyyy hh:mm"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:usLocale];
    
    NSDate *date;
    Suggestion_Object *suggestion = tml;
    
    date = [NSDate dateWithTimeIntervalSince1970:suggestion.what.timestamp];
    
    NSString *dateStr = [formatter stringFromDate:date];
    NSArray *components = [dateStr componentsSeparatedByString:@","];
    NSArray *day_month= [[components objectAtIndex:1]componentsSeparatedByString:@" "];
    
    NSString *month = [day_month objectAtIndex:1];
    NSString *daynumber = [day_month objectAtIndex:2];
    NSString *year = [[[components lastObject] componentsSeparatedByString:@" "] firstObject];
    NSString *hour = [[[components lastObject] componentsSeparatedByString:@" "] lastObject];
    
    UILabel *dayNumberLbl = self.dayNumberLabel;
    UILabel *monthLbl = self.monthLabel;
    UILabel *dayLbl = self.dayLabel;
    UILabel *hourLbl = self.hourLabel;
    
    hourLbl.text = hour;
    dayNumberLbl.text = daynumber;
    monthLbl.text = [month uppercaseString];
    dayLbl.text = [[components firstObject] uppercaseString];
    
    //Website
    
    NSString *website = suggestion.what.url;
    
    self.websiteLabel.text = website;
    
    //Venue name + Title
    
    UILabel *venueLbl = self.venueLabel;
    
    NSString *jsonString;
    
    self.titleLabel.text = [suggestion.what.title capitalizedString];
    jsonString = suggestion.what.location;
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
    venueLbl.text = loc.venueStation;
    
    UIView *headerV = self.tableV.tableHeaderView;
    //Likes,Beeeps,Comments
    UILabel *beeepsLbl = (id)[headerV viewWithTag:-5];
    UILabel *likesLbl = (id)[headerV viewWithTag:-3];
    UILabel *commentsLbl = (id)[headerV viewWithTag:-4];
    
    beeepers = [NSMutableArray arrayWithArray:suggestion.beeepersIds];
    likesLbl.text = [NSString stringWithFormat:@"%d",suggestion.what.likes.count];
    // commentsLbl.text = [NSString stringWithFormat:@"%d",t.beeep.beeepInfo.comments.count];
    commentsLbl.hidden = YES;
    self.commentsButton.hidden = YES;
    beeepsLbl.text = [NSString stringWithFormat:@"%d",suggestion.beeepersIds.count];
    
    likers = [NSMutableArray arrayWithArray:suggestion.what.likes];
    NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
    
    isLiker = NO;
    
    if (likers && [likers indexOfObject:my_id] != NSNotFound) {
        isLiker = YES;
    }
    
    if (isLiker) {
        [self.likesButton setImage:[UIImage imageNamed:@"liked_icon_event"] forState:UIControlStateNormal];
    }
    else{
        [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
    }
    
    //Tags
    
    NSMutableString *formattedTags = [[NSMutableString alloc]init];
    NSString *hastags;
    
    @try {
        
        hastags = [suggestion.hashTags stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        hastags = [hastags stringByReplacingOccurrencesOfString:@"[\"" withString:@""];
        hastags = [hastags stringByReplacingOccurrencesOfString:@"\"]" withString:@""];
        hastags = [hastags stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSArray *tags = [hastags componentsSeparatedByString:@","];
        for (NSString *tag in tags) {
            if (tag.length > 1) {
                [formattedTags appendFormat:@"#%@ ",tag];
            }
        }
        
        NSString *correctString = [formattedTags stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.tagsLabel.text = correctString;
        
    }
    @catch (NSException *exception) {
        NSLog(@"NO TAGS");
    }
    @finally {
        
    }
    
    //Image
    
    UIImageView *imgV = self.eventImageV;
    
    NSString *extension;
    NSString *imageName;
    
    @try {
        
        extension  = [[suggestion.what.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        imageName  = [NSString stringWithFormat:@"%@.%@",[suggestion.what.imageUrl MD5],extension];
        
        
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
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventImageDownloadFinished:) name:imageName object:nil];
        }
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"NO IMAGE");
    }
    @finally {
        
    }
    
    [self hideLoading];


}

-(void)showEventWithFriendFeedObject{
    
    
    //EVENT DATE
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMM dd, yyyy hh:mm"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:usLocale];
    
    NSDate *date;
    Friendsfeed_Object *ffo = tml;

    date = [NSDate dateWithTimeIntervalSince1970:ffo.eventFfo.eventDetailsFfo.timestamp];
    
    NSString *dateStr = [formatter stringFromDate:date];
    NSArray *components = [dateStr componentsSeparatedByString:@","];
    NSArray *day_month= [[components objectAtIndex:1]componentsSeparatedByString:@" "];
    
    NSString *month = [day_month objectAtIndex:1];
    NSString *daynumber = [day_month objectAtIndex:2];
    NSString *year = [[[components lastObject] componentsSeparatedByString:@" "] firstObject];
    NSString *hour = [[[components lastObject] componentsSeparatedByString:@" "] lastObject];
    
    UILabel *dayNumberLbl = self.dayNumberLabel;
    UILabel *monthLbl = self.monthLabel;
    UILabel *dayLbl = self.dayLabel;
    UILabel *hourLbl = self.hourLabel;
    
    hourLbl.text = hour;
    dayNumberLbl.text = daynumber;
    monthLbl.text = [month uppercaseString];
    dayLbl.text = [[components firstObject] uppercaseString];
    
    //Website
    
    NSString *website = ffo.eventFfo.eventDetailsFfo.url;
    
    self.websiteLabel.text = website;
    
    //Venue name + Title
    
    UILabel *venueLbl = self.venueLabel;
    
    NSString *jsonString;
    
    self.titleLabel.text = [ffo.eventFfo.eventDetailsFfo.title capitalizedString];
    jsonString = ffo.eventFfo.eventDetailsFfo.location;
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
    venueLbl.text = loc.venueStation;
    
    UIView *headerV = self.tableV.tableHeaderView;
    //Likes,Beeeps,Comments
    UILabel *beeepsLbl = (id)[headerV viewWithTag:-5];
    UILabel *likesLbl = (id)[headerV viewWithTag:-3];
    UILabel *commentsLbl = (id)[headerV viewWithTag:-4];
    
    Beeeps *b = [ffo.beeepFfo.beeeps firstObject];
    
    likers = [NSMutableArray arrayWithArray:[b.likes valueForKey:@"likes"]];
    likesLbl.text = [NSString stringWithFormat:@"%d",b.likes.count];
    
    commentsLbl.text = [NSString stringWithFormat:@"%d",b.comments.count];
    comments = [NSMutableArray arrayWithArray:b.comments];
    
    beeepsLbl.text = [NSString stringWithFormat:@"%d",ffo.eventFfo.beeepedBy.count];
    beeepers = [NSMutableArray arrayWithArray:ffo.eventFfo.beeepedBy];
   
    NSArray *likers = [[b.likes valueForKey:@"likers"] valueForKey:@"likersIdentifier"];
    NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
    
    isLiker = NO;
    
    if ([likers indexOfObject:my_id] != NSNotFound) {
        isLiker = YES;
    }
    
    if (isLiker) {
        [self.likesButton setImage:[UIImage imageNamed:@"liked_icon_event"] forState:UIControlStateNormal];
    }
    else{
        [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
    }
    
    //Tags
    
    NSMutableString *formattedTags = [[NSMutableString alloc]init];
    NSString *hastags;
    
    @try {
        
        hastags = [ffo.eventFfo.hashTags stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        hastags = [hastags stringByReplacingOccurrencesOfString:@"[\"" withString:@""];
        hastags = [hastags stringByReplacingOccurrencesOfString:@"\"]" withString:@""];
        hastags = [hastags stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSArray *tags = [hastags componentsSeparatedByString:@","];
        for (NSString *tag in tags) {
            if (tag.length > 1) {
                [formattedTags appendFormat:@"#%@ ",tag];
            }
        }
        
        NSString *correctString = [formattedTags stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.tagsLabel.text = correctString;
        
    }
    @catch (NSException *exception) {
        NSLog(@"NO TAGS");
    }
    @finally {
        
    }
    
    //Image
    
    UIImageView *imgV = self.eventImageV;
    
    NSString *extension;
    NSString *imageName;
    
    @try {
        
        extension  = [[ffo.eventFfo.eventDetailsFfo.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        imageName  = [NSString stringWithFormat:@"%@.%@",[ffo.eventFfo.eventDetailsFfo.imageUrl MD5],extension];

        
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
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventImageDownloadFinished:) name:imageName object:nil];
        }
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"NO IMAGE");
    }
    @finally {
        
    }

    [self hideLoading];
}

-(void)showEventWithTimelineObject{
    
    //EVENT DATE
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMM dd, yyyy hh:mm"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:usLocale];
    
    NSDate *date;
    Timeline_Object *t = tml; //one of those two will be used

    date = [NSDate dateWithTimeIntervalSince1970:t.event.timestamp];
    
    NSString *dateStr = [formatter stringFromDate:date];
    NSArray *components = [dateStr componentsSeparatedByString:@","];
    NSArray *day_month= [[components objectAtIndex:1]componentsSeparatedByString:@" "];
    
    NSString *month = [day_month objectAtIndex:1];
    NSString *daynumber = [day_month objectAtIndex:2];
    NSString *year = [[[components lastObject] componentsSeparatedByString:@" "] firstObject];
    NSString *hour = [[[components lastObject] componentsSeparatedByString:@" "] lastObject];
    
    UILabel *dayNumberLbl = self.dayNumberLabel;
    UILabel *monthLbl = self.monthLabel;
    UILabel *dayLbl = self.dayLabel;
    UILabel *hourLbl = self.hourLabel;
    
    hourLbl.text = hour;
    dayNumberLbl.text = daynumber;
    monthLbl.text = [month uppercaseString];
    dayLbl.text = [[components firstObject] uppercaseString];
    
    //Website
    
    NSString *website;

    website = t.event.url;
    
    self.websiteLabel.text = website;
    
    //Venue name + Title
    
    UILabel *venueLbl = self.venueLabel;
    
    NSString *jsonString;
    
    self.titleLabel.text = [t.event.title capitalizedString];
    jsonString = t.event.location;
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
    venueLbl.text = loc.venueStation;
    
    UIView *headerV = self.tableV.tableHeaderView;
    //Likes,Beeeps,Comments
    UILabel *beeepsLbl = (id)[headerV viewWithTag:-5];
    UILabel *likesLbl = (id)[headerV viewWithTag:-3];
    UILabel *commentsLbl = (id)[headerV viewWithTag:-4];
    
    likers = [NSMutableArray arrayWithArray:[t.beeep.beeepInfo.likes valueForKey:@"likes"]];
    likesLbl.text = [NSString stringWithFormat:@"%d",t.beeep.beeepInfo.likes.count];
    commentsLbl.text = [NSString stringWithFormat:@"%d",t.beeep.beeepInfo.comments.count];
    beeepsLbl.text = [NSString stringWithFormat:@"%d",t.beeepersIds.count];
   
    
    NSArray *likers = [[t.beeep.beeepInfo.likes valueForKey:@"likers"] valueForKey:@"likersIdentifier"];
    
    NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
    
    isLiker = NO;
    
    if ([likers indexOfObject:my_id] != NSNotFound) {
        isLiker = YES;
    }
    
    if (isLiker) {
        [self.likesButton setImage:[UIImage imageNamed:@"liked_icon_event"] forState:UIControlStateNormal];
    }
    else{
        [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
    }
    
    //Tags
    
    NSMutableString *formattedTags = [[NSMutableString alloc]init];
    NSString *hastags;
    
    @try {
        
        hastags = [t.hashTags stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        
        hastags = [hastags stringByReplacingOccurrencesOfString:@"[\"" withString:@""];
        hastags = [hastags stringByReplacingOccurrencesOfString:@"\"]" withString:@""];
        hastags = [hastags stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSArray *tags = [hastags componentsSeparatedByString:@","];
        for (NSString *tag in tags) {
            if (tag.length > 1) {
                [formattedTags appendFormat:@"#%@ ",tag];
            }
        }
        
        NSString *correctString = [formattedTags stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.tagsLabel.text = correctString;
        
    }
    @catch (NSException *exception) {
        NSLog(@"NO TAGS");
    }
    @finally {
        
    }
    
    //Image
    
    UIImageView *imgV = self.eventImageV;
    
    NSString *extension;
    NSString *imageName;
    
    @try {
        
        extension  = [[t.event.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        imageName  = [NSString stringWithFormat:@"%@.%@",[t.event.imageUrl MD5],extension];
        
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
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventImageDownloadFinished:) name:imageName object:nil];
        }
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"NO IMAGE");
    }
    @finally {
        
    }

    [self hideLoading];
}

-(void)showEventForActivityWithBeeep{
    
    //EVENT DATE
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMM dd, yyyy hh:mm"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:usLocale];
    
    NSDate *date;
    
    Activity_Object *activity = tml;
    Event_Show_Object* event = event_show_Objct;
    Beeep_Object* beeep = beeep_Objct;
    
    date = [NSDate dateWithTimeIntervalSince1970:event.eventInfo.timestamp];
    
    NSString *dateStr = [formatter stringFromDate:date];
    NSArray *components = [dateStr componentsSeparatedByString:@","];
    NSArray *day_month= [[components objectAtIndex:1]componentsSeparatedByString:@" "];
    
    NSString *month = [day_month objectAtIndex:1];
    NSString *daynumber = [day_month objectAtIndex:2];
    NSString *year = [[[components lastObject] componentsSeparatedByString:@" "] firstObject];
    NSString *hour = [[[components lastObject] componentsSeparatedByString:@" "] lastObject];
    
    UILabel *dayNumberLbl = self.dayNumberLabel;
    UILabel *monthLbl = self.monthLabel;
    UILabel *dayLbl = self.dayLabel;
    UILabel *hourLbl = self.hourLabel;
    
    hourLbl.text = hour;
    dayNumberLbl.text = daynumber;
    monthLbl.text = [month uppercaseString];
    dayLbl.text = [[components firstObject] uppercaseString];
    
    //Website
    
    NSString *website = event.eventInfo.url;
    
    self.websiteLabel.text = website;
    
    //Venue name + Title
    
    UILabel *venueLbl = self.venueLabel;
    
    NSString *jsonString;
    
    self.titleLabel.text = [event.eventInfo.title capitalizedString];
    jsonString = event.eventInfo.location;
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
   
    if (data != nil) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
        venueLbl.text = loc.venueStation;
    }
    
    UIView *headerV = self.tableV.tableHeaderView;
    //Likes,Beeeps,Comments
    UILabel *beeepsLbl = (id)[headerV viewWithTag:-5];
    UILabel *likesLbl = (id)[headerV viewWithTag:-3];
    UILabel *commentsLbl = (id)[headerV viewWithTag:-4];
    
    NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
    
    isLiker = NO;
    
    if(beeep == nil){
        self.likesLabel.hidden = YES;
        self.beeepsLabel.hidden = YES;
        self.commentsLabel.hidden = YES;
        self.likesButton.hidden = YES;
        self.commentsButton.hidden = YES;
        self.likesButton.hidden = YES;
    }
    else{
        
        likesLbl.text = [NSString stringWithFormat:@"%d",beeep.likes.count];
        commentsLbl.text = [NSString stringWithFormat:@"%d",beeep.comments.count];
        //beeepsLbl.text = [NSString stringWithFormat:@"%d",beeep.beeepersIds.count];

        
        likers =[NSMutableArray arrayWithArray:beeep.likes];
        
        if ([likers indexOfObject:my_id] != NSNotFound) {
            isLiker = YES;
        }
        
        if (isLiker) {
            [self.likesButton setImage:[UIImage imageNamed:@"liked_icon_event"] forState:UIControlStateNormal];
        }
        else{
            [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
        }

    }
    
    //Tags
    
    NSMutableString *formattedTags = [[NSMutableString alloc]init];
    NSString *hastags;
  
    @try {
        
        hastags = [event.hashTags stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        hastags = [hastags stringByReplacingOccurrencesOfString:@"[\"" withString:@""];
        hastags = [hastags stringByReplacingOccurrencesOfString:@"\"]" withString:@""];
        hastags = [hastags stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSArray *tags = [hastags componentsSeparatedByString:@","];
        for (NSString *tag in tags) {
            if (tag.length > 1) {
                [formattedTags appendFormat:@"#%@ ",tag];
            }
        }
        
        NSString *correctString = [formattedTags stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.tagsLabel.text = correctString;
        
    }
    @catch (NSException *exception) {
        NSLog(@"NO TAGS");
    }
    @finally {
        
    }
    
    //Image
    
    UIImageView *imgV = self.eventImageV;
    
    NSString *extension;
    NSString *imageName;
    
    @try {
        
        extension  = [[event.eventInfo.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        imageName  = [NSString stringWithFormat:@"%@.%@",[event.eventInfo.imageUrl MD5],extension];
        
        
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
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventImageDownloadFinished:) name:imageName object:nil];
        }
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"NO IMAGE");
    }
    @finally {
        
    }
    
    [self hideLoading];
}


-(void)eventImageDownloadFinished:(NSNotification *)notif{
    
    NSString *imageName  = [notif.userInfo objectForKey:@"imageName"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
        
        
        if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
            UIImageView *imgV = self.eventImageV;
            imgV.backgroundColor = [UIColor clearColor];
            imgV.image = nil;
            UIImage *img = [UIImage imageWithContentsOfFile:localPath];
            imgV.image = img;
        }

    });
    
}

-(void)imageDownloadFinished:(NSNotification *)notif{ //comments
    
    NSString *imageName  = [notif.userInfo objectForKey:@"imageName"];
    
    NSArray* rowsToReload = [NSArray arrayWithObjects:[pendingImagesDict objectForKey:imageName], nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
        [pendingImagesDict removeObjectForKey:imageName];
    });
    
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSRange range = NSMakeRange(0, 1);
    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableV reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
   
}

-(void)suggestIt{
    SuggestBeeepVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"SuggestBeeepVC"];
    [self.parentViewController addChildViewController:viewController];
    [viewController showInView:self.view.superview.superview.superview];
}

-(void)likeIt{
    Timeline_Object *t = tml; //one of those two will be used
    Friendsfeed_Object *ffo = tml;
    
    UIView *headerV = self.tableV.tableHeaderView;
    UILabel *likesLbl = (id)[headerV viewWithTag:-3];
    
    if (isLiker) {
        
        if ([tml isKindOfClass:[Friendsfeed_Object class]]) {
            Beeeps *bps = [ffo.beeepFfo.beeeps firstObject];
            
            [[EventWS sharedBP]unlikeBeeep:bps.weight user:ffo.beeepFfo.userId WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                if (completed) {
                    isLiker = NO;
                    [likers removeObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                    likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue - 1)>0)?(likesLbl.text.intValue - 1):0];
                    [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
                }
            }];
        }
        else if ([tml isKindOfClass:[Suggestion_Object class]]){
            Suggestion_Object *suggest = tml;
           
            [[EventWS sharedBP]unlikeEvent:suggest.what.fingerprint WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                if (completed) {
                    isLiker = NO;
                    [likers removeObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                    likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue - 1)>0)?(likesLbl.text.intValue - 1):0];
                    [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
                }
            }];

        }
        else if ([tml isKindOfClass:[Activity_Object class]]){
            Activity_Object *activity = tml;
            
            if (activity.beeepInfoActivity.beeepActivity.count == 0) {
            
                NSString *fingerprint = [[activity.eventActivity firstObject]valueForKeyPath:@"fingerprint"];
                
                [[EventWS sharedBP]unlikeEvent:fingerprint WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                    if (completed) {
                        isLiker = NO;
                        [likers removeObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                        likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue - 1)>0)?(likesLbl.text.intValue - 1):0];
                        [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
                    }
                }];
            }
            else{
                
//                [[EventWS sharedBP]unlikeBeeep:bps.weight user:ffo.beeepFfo.userId WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
//                    if (completed) {
//                        isLiker = NO;
//                        [likers removeObject:[[BPUser sharedBP].user objectForKey:@"id"]];
//                        likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue - 1)>0)?(likesLbl.text.intValue - 1):0];
//                        [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
//                    }
//                }];
            }
            
        }
    }
    else{
        if ([tml isKindOfClass:[Friendsfeed_Object class]]) {
            Beeeps *bps = [ffo.beeepFfo.beeeps firstObject];
            
            [[EventWS sharedBP]likeBeeep:bps.weight user:ffo.beeepFfo.userId WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                if (completed) {
                    isLiker = YES;
                    [likers addObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                    likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue + 1)>0)?(likesLbl.text.intValue + 1):0];
                    [self.likesButton setImage:[UIImage imageNamed:@"liked_icon_event"] forState:UIControlStateNormal];
                }
            }];
        }
        else if ([tml isKindOfClass:[Suggestion_Object class]]){
            Suggestion_Object *suggest = tml;
            
            [[EventWS sharedBP]likeEvent:suggest.what.fingerprint WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                if (completed) {
                    isLiker = NO;
                    [likers removeObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                    likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue - 1)>0)?(likesLbl.text.intValue - 1):0];
                    [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
                }
            }];
            
        }
        else if ([tml isKindOfClass:[Activity_Object class]]){
            Activity_Object *activity = tml;
            
            if (activity.beeepInfoActivity.beeepActivity.count == 0) {
                
                NSString *fingerprint = [[activity.eventActivity firstObject]valueForKeyPath:@"fingerprint"];
                
                [[EventWS sharedBP]likeEvent:fingerprint WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                    if (completed) {
                        isLiker = NO;
                        [likers removeObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                        likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue - 1)>0)?(likesLbl.text.intValue - 1):0];
                        [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
                    }
                }];
            }
            else{
                //                [[EventWS sharedBP]likeBeeep:bps.weight user:ffo.beeepFfo.userId WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                //                    if (completed) {
                //                        isLiker = NO;
                //                        [likers removeObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                //                        likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue - 1)>0)?(likesLbl.text.intValue - 1):0];
                //                        [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
                //                    }
                //                }];

            }
            
        }

        
    }

    
  
}


-(void)showMore{
    
}

-(void)beeepIt:(NSNotification *)notif{
    [self close:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)beeepItPressed:(id)sender {
   
    BeeepItVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"BeeepItVC"];
    viewController.tml = event_show_Objct;
    
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)showLikes:(id)sender {
    
    FollowListVC *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowListVC"];
    viewController.mode = LikesMode;
    viewController.ids = likers;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showComments:(id)sender {
    
    CommentsVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentsVC"];
    viewController.event_beeep_object = tml;
    viewController.comments = comments;
    [self.navigationController pushViewController:viewController animated:YES];

}

- (IBAction)showBeeeps:(id)sender {
    FollowListVC *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowListVC"];
    viewController.mode = BeeepersMode;
    viewController.ids = beeepers;

    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)close:(id)sender {
   
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - COMMENTS

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    UILabel *nameLbl = (id)[cell viewWithTag:1];
    nameLbl.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    nameLbl.textColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:1];
    
    Comments *cmnts = [comments objectAtIndex:comments.count-1-indexPath.row];
    Comment *comment = cmnts.comment;
    
    nameLbl.text = [[NSString stringWithFormat:@"%@ %@",cmnts.commenter.name,cmnts.commenter.lastname] capitalizedString];
    
    UILabel *txtV = (id)[cell viewWithTag:3];
    txtV.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
    txtV.text = comment.comment;

    UILabel *timeLbl = (id)[cell viewWithTag:4];
    timeLbl.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
    
    CGSize textViewSize = [self frameForText:txtV.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13] constrainedToSize:CGSizeMake(242, CGFLOAT_MAX)];
    
    txtV.frame = CGRectMake(txtV.frame.origin.x, txtV.frame.origin.y, 242, textViewSize.height);
    
    UIImageView *imageV = (id)[cell viewWithTag:2];
    
    for (UIView * subView in [cell.contentView subviews]) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            imageV = (id)subView;
        }
    }
    
    NSString *extension = [[cmnts.commenter.imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
    
    NSString *imageName = [NSString stringWithFormat:@"%@.%@",[cmnts.commenter.imagePath MD5],extension];
    
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
        imageV.image = nil;
        UIImage *img = [UIImage imageWithContentsOfFile:localPath];
        imageV.image = img;
        
    }
    else{
        imageV.image = nil;
        [pendingImagesDict setObject:indexPath forKey:imageName];
        [[DTO sharedDTO]downloadImageFromURL:cmnts.commenter.imagePath];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(imageDownloadFinished:) name:imageName object:nil];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    Comments *cmnts = [comments objectAtIndex:comments.count-1-indexPath.row];
    Comment *comment = cmnts.comment;
    
    CGSize textViewSize = [self frameForText:comment.comment sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13] constrainedToSize:CGSizeMake(242, CGFLOAT_MAX)];
    
    return (textViewSize.height + 36 + 8);
    
}

-(CGSize)frameForText:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size{
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          font, NSFontAttributeName,
                                          nil];
    CGRect frame = [text boundingRectWithSize:size
                                      options:(NSStringDrawingUsesLineFragmentOrigin)
                                   attributes:attributesDictionary
                                      context:nil];
    
    // This contains both height and width, but we really care about height.
    return frame.size;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *numberOfCommentsV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableV.frame.size.width, 41)];
    numberOfCommentsV.backgroundColor = [UIColor clearColor];
    
    UIView *container = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableV.frame.size.width, 40)];
    container.backgroundColor = [UIColor whiteColor];
    [numberOfCommentsV addSubview:container];
    
    UILabel *numberOfComments = [[UILabel alloc]initWithFrame:numberOfCommentsV.bounds];
    numberOfComments.text = [NSString stringWithFormat:@"%d Comments",comments.count];
    numberOfComments.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13];
    numberOfComments.textColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:1];
    numberOfComments.textAlignment = NSTextAlignmentCenter;
    [numberOfCommentsV addSubview:numberOfComments];
    
    UIButton *loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loadMoreButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
    loadMoreButton.frame = numberOfCommentsV.bounds;
    [loadMoreButton setTitle:@"Load More" forState:UIControlStateNormal];
    [loadMoreButton setTitleColor:[UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:1] forState:UIControlStateNormal];
    loadMoreButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [loadMoreButton setTitleEdgeInsets:UIEdgeInsetsMake(0,0, 0, 10)];
    [loadMoreButton addTarget:self action:@selector(loadMorePressed:) forControlEvents:UIControlEventTouchUpInside];
     
    [numberOfCommentsV addSubview:loadMoreButton];

    return numberOfCommentsV;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    //return 41;
    return 0;
}



-(void)loadMorePressed:(UIButton *)btn{
    [comments addObjectsFromArray:@[@"bsdfliasdfslaifsadfcbdfsayfkgsdfsadutkfvsaektufjehvfgvckusafgskfjsavefkasufevaksfeusavfeaskvfasasdfliasdfslaifsadfc",@"csdfliasdfslaifsadfcbdfsayfkgsdfsadutkfvs",@"dsdfliasdfslaifsadfcbdfsayfkgsdfsadutkfvsaektufjehvfgvckusafgskfjsavefg",@"esdfliasdfslaifsadfcbdfsayfkgsdfsadutkfvsaektufjehvfgvckusafgskfjsavefkasufevaksfeusavfeaskvfasasdfliasdfslaifsadfcbdfsayfkgsdfsadutkfvsaektufjehvfgvckusafg",@"fsdfliasdfslaifsadfcbdfsayfkgsdfsadutkfvsaektufjehvfgvckusafgskfjsavefkasufevaksfeusavfeaskvfasasdfliasdfslaifsadfc",@"hsdfliasdfslaifsadfcbdfsayfkgsdfsadutkfvsaektufjehvfgvckusafgskfjsavefkasufevaksfeusavfeaskvfasasdfliasdfslaifsadfcbdfsayfkgsdfsadutkfvsaektufjehvfgvckusafg",@"isdfliasdfslaifsadfcbdfsayfkgsdfsadutkfvsaektufjehvfgvckusafgskfjsavefg",@"jsdfliasdfslaifsadfcbdfsayfkgsdfsadutkfvs"]];
    
    [self.tableV reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Compose

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if ([self.tableV numberOfRowsInSection:0] == 0) {
        return;
    }
    
    NSLog(@"%f",scrollView.contentOffset.y);
    
    static BOOL animating = NO;
    
    if (isKeyboardVisible || animating) {
        return;
    }
    
    animating = YES;
    
    if (scrollView.contentOffset.y > 11 && !isContainerVisible) { // when comments section becomes visible
        [UIView animateWithDuration:0.7f
                         animations:^
         {
            [[self container]setFrame:CGRectMake(0, self.view.frame.size.height - [self container].frame.size.height, 320, [self container].frame.size.height)];
         }
                         completion:^(BOOL finished)
         {
             if (finished) {
                 self.tableV.frame = CGRectMake(self.tableV.frame.origin.x, self.tableV.frame.origin.y, self.tableV.frame.size.width, self.view.frame.size.height-44);
                 animating = NO;
                 if (!isContainerVisible && [self.tableV numberOfRowsInSection:0] == 1) {
                     [self.tableV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                 }
                 
                 isContainerVisible = YES;
                 
            }
         }];
        
//        [UIView animateWithDuration:0.9f
//                         animations:^
//         {
//             self.tableV.frame = CGRectMake(self.tableV.frame.origin.x, self.tableV.frame.origin.y, self.tableV.frame.size.width, self.view.frame.size.height-44);
//         }
//                         completion:^(BOOL finished)
//         {
//             
//         }];
    }
    else if(scrollView.contentOffset.y <= 11){
        
//        if (isContainerVisible) {
//            animating = NO;
//            return;
//        }
        
        self.tableV.frame = CGRectMake(self.tableV.frame.origin.x, self.tableV.frame.origin.y, self.tableV.frame.size.width, self.view.frame.size.height);
        [UIView animateWithDuration:0.7f
                         animations:^
         {
             [[self container]setFrame:CGRectMake(0, self.view.frame.size.height + [self container].frame.size.height, 320, [self container].frame.size.height)];
         }
                         completion:^(BOOL finished)
         {
             if (finished) {
                 animating = NO;
             }
             
             isContainerVisible = NO;
             
         }];
        
//        [UIView animateWithDuration:0.9f
//                         animations:^
//         {
//             self.tableV.frame = CGRectMake(self.tableV.frame.origin.x, self.tableV.frame.origin.y, self.tableV.frame.size.width, self.view.frame.size.height);
//         }
//                         completion:^(BOOL finished)
//         {
//         }];
    }
    else{
        animating = NO;
    }
}

-(void)hideKeyboard:(UITapGestureRecognizer *)tapG{
    [self.tableV removeGestureRecognizer:tapG];
    [[self composeBarView] resignFirstResponder];
}

- (void)keyboardWillToggle:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval duration;
    UIViewAnimationCurve animationCurve;
    CGRect startFrame;
    CGRect endFrame;
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey]    getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey]        getValue:&startFrame];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]          getValue:&endFrame];
    
    NSInteger signCorrection = 1;
    if (startFrame.origin.y < 0 || startFrame.origin.x < 0 || endFrame.origin.y < 0 || endFrame.origin.x < 0)
        signCorrection = -1;
    
    CGFloat widthChange  = (endFrame.origin.x - startFrame.origin.x) * signCorrection;
    CGFloat heightChange = (endFrame.origin.y - startFrame.origin.y) * signCorrection;
    
    if (heightChange < 0) { //show keyboard
        isKeyboardVisible = YES;
        tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard:)];
        [self.tableV addGestureRecognizer:tapG];
    }
    else{
        isKeyboardVisible = NO;
        [self.tableV removeGestureRecognizer:tapG];

    }
    
    CGFloat sizeChange = UIInterfaceOrientationIsLandscape([self interfaceOrientation]) ? widthChange : heightChange;
    
    CGRect newContainerFrame = [[self container] frame];
    newContainerFrame.origin.y += sizeChange;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:(animationCurve << 16)|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [[self container] setFrame:newContainerFrame];
                     }
                     completion:NULL];
}

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView {
    NSString *text = [NSString stringWithFormat:@"%@", [composeBarView text]];
    
    if ([tml isKindOfClass:[Timeline_Object class]]) {
        Timeline_Object *t = tml;
        
        [[EventWS sharedBP]postComment:text BeeepId:t.beeep.beeepInfo.weight user:t.beeep.userId WithCompletionBlock:^(BOOL completed,NSArray *objs){
            if (completed) {
                
            }
        }];

    }
   

    [self.tableV reloadData];
    [self prependTextToTextView:text];
    [composeBarView setText:@"" animated:YES];
    [composeBarView resignFirstResponder];
}

- (void)composeBarViewDidPressUtilityButton:(PHFComposeBarView *)composeBarView {
    [self prependTextToTextView:@"Utility button pressed"];
}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
   willChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame
              duration:(NSTimeInterval)duration
        animationCurve:(UIViewAnimationCurve)animationCurve
{
    [self prependTextToTextView:[NSString stringWithFormat:@"Height changing by %d", (NSInteger)(endFrame.size.height - startFrame.size.height)]];
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 0.0f, endFrame.size.height, 0.0f);
    UITextView *textView = [self textView];
    [textView setContentInset:insets];
    [textView setScrollIndicatorInsets:insets];
}

- (void)composeBarView:(PHFComposeBarView *)composeBarView
    didChangeFromFrame:(CGRect)startFrame
               toFrame:(CGRect)endFrame
{
    [self prependTextToTextView:@"Height changed"];
}

- (void)prependTextToTextView:(NSString *)text {
    NSString *newText = [text stringByAppendingFormat:@"\n\n%@", [[self textView] text]];
    [[self textView] setText:newText];
}

@synthesize container = _container;
- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] initWithFrame:kInitialViewFrame];
        _container.backgroundColor = [UIColor whiteColor];
        [_container setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    }
    
    return _container;
}

@synthesize composeBarView = _composeBarView;
- (PHFComposeBarView *)composeBarView {
    if (!_composeBarView) {
        CGRect frame = CGRectMake(0.0f,
                                  kInitialViewFrame.size.height - PHFComposeBarViewInitialHeight,
                                  kInitialViewFrame.size.width,
                                  PHFComposeBarViewInitialHeight);
        _composeBarView = [[PHFComposeBarView alloc] initWithFrame:frame];
        //        [_composeBarView setMaxCharCount:160];
        [_composeBarView setMaxLinesCount:4];
        [_composeBarView setPlaceholder:@"Add a comment..."];
        [_composeBarView setUtilityButtonImage:[UIImage imageNamed:@"Camera"]];
        [_composeBarView setDelegate:self];
    }
    
    return _composeBarView;
}

@synthesize textView = _textView;
- (UITextView *)textView {
    if (!_textView) {
        CGRect frame = CGRectMake(0.0f,
                                  20.0f,
                                  kInitialViewFrame.size.width,
                                  kInitialViewFrame.size.height - 20.0f);
        _textView = [[UITextView alloc] initWithFrame:frame];
        [_textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [_textView setEditable:NO];
        [_textView setBackgroundColor:[UIColor clearColor]];
        [_textView setAlwaysBounceVertical:YES];
        [_textView setFont:[UIFont systemFontOfSize:[UIFont labelFontSize]]];
        UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 0.0f, PHFComposeBarViewInitialHeight, 0.0f);
        [_textView setContentInset:insets];
        [_textView setScrollIndicatorInsets:insets];
        [_textView setText:@"Welcome to the Demo!\n\nThis is just some placeholder text to give you a better feeling of how the compose bar can be used along other components."];
        
        UIView *bubbleView = [[UIView alloc] initWithFrame:CGRectMake(80.0f, 480.0f, 220.0f, 60.0f)];
        [bubbleView setBackgroundColor:[UIColor colorWithHue:206.0f/360.0f saturation:0.81f brightness:0.99f alpha:1]];
        [[bubbleView layer] setCornerRadius:25.0f];
        [_textView addSubview:bubbleView];
    }
    
    return _textView;
}

#pragma mark - MONActivityIndicatorView

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
