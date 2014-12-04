//
//  EventVC.m
//  Beeeper
//
//  Created by User on 3/21/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "EventVC.h"
#import "PHFComposeBarView.h"
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
#import "Event_Search.h"
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import "WebBrowserVC.h"
#import "SearchVC.h"
#import <FacebookSDK/FacebookSDK.h>
#import "BeeepedBy.h"

@interface EventVC ()<PHFComposeBarViewDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>{

    NSMutableArray *comments;
    NSMutableArray *beeepers;
    NSMutableArray *likers;
    
    BOOL isKeyboardVisible;
    BOOL isContainerVisible;
    UITapGestureRecognizer *tapG;
    NSMutableDictionary *pendingImagesDict;
    BOOL isLiker;
    
    Beeep_Object *beeep_Objct; //-(void)showEventForActivityWithBeeep
    
    NSString *fingerprint;
    NSString *websiteURL;
    NSString *beeeperWebsiteURL;
    
    NSString *tinyURL;
    
    NSMutableString *shareText;
    NSMutableArray* rowsToReload;
    
    BOOL passedEvent;
    
    BOOL viewAppeared;
}
@property (nonatomic,strong)  Event_Show_Object *event_show_Objct;
@property (nonatomic,strong) NSString *imageURL;
@property (readonly, nonatomic) UIView *container;
@property (readonly, nonatomic) PHFComposeBarView *composeBarView;
@property (nonatomic,assign) CGRect kInitialViewFrame;
@property (readonly, nonatomic) UITextView *textView;

@end

@implementation EventVC
@synthesize kInitialViewFrame,tml,imageURL,event_show_Objct;

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
        
    UIView *loadingBGV = [[UIView alloc]initWithFrame:self.view.bounds];
    loadingBGV.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
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

    
    UINavigationBar* navigationBar = self.navigationController.navigationBar;
    
    [navigationBar setBarTintColor:[UIColor colorWithRed:240/255.0 green:208/255.0 blue:0 alpha:1]];
    
    rowsToReload = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideTabbar" object:self];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.navigationController.navigationBar.backItem.title = @"";

    pendingImagesDict = [NSMutableDictionary dictionary];
    
    self.scrollV.contentSize = CGSizeMake(320, 871);
    
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
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.redirectToComments = NO;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
    
    UIBarButtonItem *btnLike = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"like_event.png"] style:UIBarButtonItemStylePlain target:self action:@selector(likeIt)];
    UIBarButtonItem *btnShare = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"suggest_it_event.png"] style:UIBarButtonItemStylePlain target:self action:@selector(suggestIt)];
    UIBarButtonItem *btnMore = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more_btn_event.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showMore)];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:btnMore,btnLike,btnShare, nil]];
    
    [self.navigationItem setLeftBarButtonItem:leftItem];
    
    [self downloadInfoAndShowEvent];
    
}

-(void)downloadInfoAndShowEvent{
    
    if ([tml isKindOfClass:[Timeline_Object class]]) {
        Timeline_Object *t = tml;
        fingerprint = t.event.fingerprint;
        if (!comments) {
            comments = t.beeep.beeepInfo.comments;   
        }
        
        //get tinyurl
        
        [[EventWS sharedBP]getEvent:fingerprint WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
            if (completed) {
                tinyURL = [NSString stringWithFormat:@"beeep.it/%@",[event.tinyUrl lowercaseString]];
            }
        }];
    }
    else if ([tml isKindOfClass:[Activity_Object class]]){
        
        Activity_Object *activity = tml;
        
        
        if (activity.beeepInfoActivity.beeepActivity.count > 0) {
            
            fingerprint = [NSString stringWithString:[[activity.beeepInfoActivity.eventActivity firstObject]valueForKeyPath:@"fingerprint"]];
            
            [[BPActivity sharedBP]getBeeepInfoFromActivity:tml WithCompletionBlock:^(BOOL completed,Beeep_Object *beeep){
                if (completed) {
                    beeep_Objct = beeep;
                    comments = beeep_Objct.comments;
                    
                    if (event_show_Objct != nil || (event_show_Objct == nil && activity.eventActivity.count == 0)) {
                        tinyURL = [NSString stringWithFormat:@"beeep.it/%@", [event_show_Objct.tinyUrl lowercaseString]];
                        
                        [self showEventWithBeeep];
                    }
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Event not found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }];
            
        }
        
        if(activity.eventActivity.count > 0 || activity.beeepInfoActivity.eventActivity.count >0){
            
            fingerprint = (fingerprint == nil)?[[activity.eventActivity firstObject]valueForKeyPath:@"fingerprint"]:fingerprint;
            
            [[BPActivity sharedBP]getEvent:tml WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                if (completed) {
                    event_show_Objct = event;
                    tinyURL = [NSString stringWithFormat:@"beeep.it/%@",[event_show_Objct.tinyUrl lowercaseString]];
                    
                    if ((beeep_Objct != nil) || (beeep_Objct == nil && activity.beeepInfoActivity.beeepActivity.count == 0)) {
                        [self showEventWithBeeep];
                    }
                }
                else{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Event not found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
            }];
        }
        
    }
    else if ([tml isKindOfClass:[Event_Search class]]){
        
        Event_Search *event = tml;
        fingerprint = event.fingerprint;
        
        [[EventWS sharedBP]getEvent:fingerprint WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
            if (completed) {
                event_show_Objct = event;
                tinyURL = [NSString stringWithFormat:@"beeep.it/%@", [event_show_Objct.tinyUrl lowercaseString]];
                
                dispatch_async (dispatch_get_main_queue(), ^{
                    [self showEventForEventLookUpObject];
                });
                
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Event not found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
        
    }
    else if ([tml isKindOfClass:[Suggestion_Object class]]){
        
        Suggestion_Object *eventObj = tml;
        fingerprint = eventObj.what.fingerprint;
        
        [[EventWS sharedBP]getEvent:fingerprint WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
            if (completed) {
                event_show_Objct = event;
                tinyURL = [NSString stringWithFormat:@"beeep.it/%@", [event_show_Objct.tinyUrl lowercaseString]];
                [self showEventWithSuggestion];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Event not found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
        
    }
    else if ([tml isKindOfClass:[NSString class]]){ //Notification
        
        [[DTO sharedDTO]getBeeep:tml WithCompletionBlock:^(BOOL completed,Beeep_Object *beeep){
            if (completed) {
                
                fingerprint = beeep.fingerprint;
                beeep_Objct = beeep;
                
                [[EventWS sharedBP]getEvent:fingerprint WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                    if (completed) {
                        tinyURL = [NSString stringWithFormat:@"beeep.it/%@", [event.tinyUrl lowercaseString]];
                        event_show_Objct = event;
                        [self showEventWithBeeep];
                    }
                    else{
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Event not found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                }];
                
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Event not found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
        
    }
    else if (self.deepLinkFingerprint){
        [self showEventWithFingerprint:self.deepLinkFingerprint];
    }

    
    
    if ([tml isKindOfClass:[Timeline_Object class]]) {
        [self showEventWithTimelineObject];
    }
    else if ([tml isKindOfClass:[Friendsfeed_Object class]]) {
        [self showEventWithFriendFeedObject];
    }
    else{
        [self updateEventInfo];
    }
}

 //in case of coming back from comments vc

-(void)updateEventInfo{
    self.commentsLabel.text = [NSString stringWithFormat:@"%d",(int)comments.count];
    self.likesLabel.text = [NSString stringWithFormat:@"%d",(int)likers.count];
    self.beeepsLabel.text = [NSString stringWithFormat:@"%d",(int)beeepers.count];
    
    self.commentsLabel.hidden = (comments.count == 0);
    self.likesLabel.hidden = (likers.count == 0);
    self.beeepsLabel.hidden = (beeepers.count == 0);
}

-(void)showEventWithSuggestion{
    
    //EVENT DATE
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMM dd, yyyy HH:mm"];
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
    
    shareText = [[NSMutableString alloc]init];
 
    //Website
    
    NSString *website = suggestion.what.source;
    websiteURL = website;
    beeeperWebsiteURL = [NSString stringWithFormat:@"https://www.beeeper.com/event/%@",suggestion.what.fingerprint];
    
    NSURL *url = [NSURL URLWithString:websiteURL];
    
    self.websiteLabel.text = [url host];
    
    //Venue name + Title
    
    UILabel *venueLbl = self.venueLabel;
    
    NSString *jsonString;
    
    self.titleLabel.text = [suggestion.what.title capitalizedString];
    self.titleLabel.center = CGPointMake(self.titleLabel.superview.center.x, self.titleLabel.center.y);
    
    jsonString = suggestion.what.location;
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
    venueLbl.text = [loc.venueStation capitalizedString];
    
    CGPoint oldCenter = self.titleLabel.center;
    [self.titleLabel sizeToFit];
    self.titleLabel.center = oldCenter;
    
    if (self.titleLabel.frame.origin.y < 291) {
        self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, 291, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
    }

    [venueLbl sizeToFit];
    
    if (venueLbl.frame.size.width > 265) {
        [venueLbl setFrame:CGRectMake(0, 0, 265, venueLbl.frame.size.height)];
    }
    
    venueLbl.center = CGPointMake(venueLbl.superview.center.x, self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height+5+(int)(venueLbl.frame.size.height/2));
    self.venueIcon.frame = CGRectMake(venueLbl.frame.origin.x - 15, venueLbl.frame.origin.y, self.venueIcon.frame.size.width, self.venueIcon.frame.size.height);
    self.venueIcon.center = CGPointMake(self.venueIcon.center.x+4, self.venueLabel.center.y-0.5);

    
    UIView *headerV = self.tableV.tableHeaderView;
    //Likes,Beeeps,Comments
    UILabel *beeepsLbl = (id)[headerV viewWithTag:-5];
    UILabel *likesLbl = (id)[headerV viewWithTag:-3];
    UILabel *commentsLbl = (id)[headerV viewWithTag:-4];
    
    if (event_show_Objct) {
        comments = event_show_Objct.eventInfo.comments;
    }

    commentsLbl.text = [NSString stringWithFormat:@"%d",comments.count];
    self.commentsLabel.hidden = (comments.count == 0);
    
    if (!beeepers){
        beeepers = [NSMutableArray arrayWithArray:suggestion.beeepersIds];
    }
    
    beeepsLbl.text = [NSString stringWithFormat:@"%d",(int)beeepers.count];
    self.beeepsLabel.hidden = (beeepers.count == 0);
    
    if (!likers) {
        likers = suggestion.what.likes;
        if (likers == nil) {
            likers = [NSMutableArray array];
        }
    }

    likesLbl.text = [NSString stringWithFormat:@"%d",(int)likers.count];
    self.likesLabel.hidden = (likers.count == 0);

    
    NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
    
    isLiker = NO;
    
    if (likers && [likers indexOfObject:my_id] != NSNotFound) {
        isLiker = YES;
    }
    
    if (isLiker) {
        
        UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
        likeBtn.image = [UIImage imageNamed:@"liked_event.png"];
        
        //[self.likesButton setImage:[UIImage imageNamed:@"liked_icon_event"] forState:UIControlStateNormal];
    }
    else{

        UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
        likeBtn.image = [UIImage imageNamed:@"like_event.png"];
        

//        [self.likesButton setImage:[UIImage imageNamed:@"liked_event"] forState:UIControlStateNormal];
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
        self.tagsField.text = [correctString unicodeEncode];
        self.tagsField.textAlignment = NSTextAlignmentCenter;
        
    }
    @catch (NSException *exception) {
        NSLog(@"NO TAGS");
    }
    @finally {
        
    }
    
    double now_time = [[NSDate date]timeIntervalSince1970];
    double event_timestamp = suggestion.what.timestamp;

    if (now_time > event_timestamp) {
        passedEvent = YES;
//        self.titleLabel.textColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1];
//        self.dayNumberLabel.textColor = [UIColor colorWithRed:150/255.0 green:153/255.0 blue:159/255.0 alpha:1];
//        self.monthLabel.textColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1];
//        self.hourLabel.textColor =[UIColor colorWithRed:150/255.0 green:153/255.0 blue:159/255.0 alpha:1];
//        self.dayLabel.textColor =[UIColor colorWithRed:150/255.0 green:153/255.0 blue:159/255.0 alpha:1];
//        UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Passed_white"] style:UIBarButtonItemStyleBordered target:nil action:nil];
//        [self.navigationItem setRightBarButtonItem:beeepItem];
        
//        self.passedIcon.hidden = NO;
//        self.beeepItButton.hidden = YES;
//        [self.beeepItButton setUserInteractionEnabled:NO];
    }
    else{
        
        @try {
            if (beeepers && [[beeepers valueForKey:@"id"] indexOfObject:my_id] == NSNotFound) {
                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeepit_outlined"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
                
                self.beeepItButton.hidden = NO;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = YES;
                
                
            }
            else if (beeepers && [[beeepers valueForKey:@"id"] indexOfObject:my_id] != NSNotFound) {
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeeped_white"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
//                

                self.beeepItButton.hidden = YES;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = NO;
            }
            else{
                self.beeepItButton.hidden = YES;
                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeepit_outlined"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
                
                
                self.beeepItButton.hidden = NO;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = YES;
            }
        }
        @catch (NSException *exception) {
            if (beeepers && [beeepers indexOfObject:my_id] == NSNotFound) {
               
                self.beeepItButton.hidden = NO;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = YES;
                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeepit_outlined"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
                
            }
            else if (beeepers && [beeepers indexOfObject:my_id] != NSNotFound) {
                
                self.beeepItButton.hidden = YES;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = NO;
                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeeped_white"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
                
            }
            
        }
        @finally {
            
        }
        

    }
    
    //Image
    
    UIImageView *imgV = self.eventImageV;
    
    NSString *extension;
    NSString *imageName;
    
    @try {
        imageURL = [[DTO sharedDTO] fixLink:suggestion.what.imageUrl];
        [imgV sd_setImageWithURL:[NSURL URLWithString:imageURL]
                placeholderImage:[UIImage imageNamed:@"event_image"]];
    }
    @catch (NSException *exception) {
        NSLog(@"NO IMAGE");
    }
    @finally {
        
    }
    
    [shareText appendFormat:@"%@ on %@,%@ %@ - %@",suggestion.what.title,[month uppercaseString],daynumber,hour,[loc.venueStation capitalizedString]];
    
    [self hideLoading];
    
    if (self.redirectToComments) {
        [self showCommentsWillDelay];
    }

}

-(void)showEventWithFriendFeedObject{
    
    
    //EVENT DATE
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMM dd, yyyy HH:mm"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:usLocale];
    
    NSDate *date;
    Friendsfeed_Object *ffo = tml;

    fingerprint = ffo.eventFfo.eventDetailsFfo.fingerprint;
    
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
    
    
    shareText = [[NSMutableString alloc]init];
   
    
    //Website
    
    NSString *website = ffo.eventFfo.eventDetailsFfo.source;
    websiteURL = website;
    beeeperWebsiteURL = [NSString stringWithFormat:@"https://www.beeeper.com/event/%@",ffo.eventFfo.eventDetailsFfo.fingerprint];
    NSURL *url = [NSURL URLWithString:websiteURL];
    
    self.websiteLabel.text = [url host];

    
    //Venue name + Title
    
    UILabel *venueLbl = self.venueLabel;
    
    NSString *jsonString;
    
    self.titleLabel.text = [ffo.eventFfo.eventDetailsFfo.title capitalizedString];
    jsonString = ffo.eventFfo.eventDetailsFfo.location;
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
    venueLbl.text = [loc.venueStation capitalizedString];
    
    CGPoint oldCenter = self.titleLabel.center;
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake(oldCenter.x, self.titleLabel.center.y);
    
    if (self.titleLabel.frame.origin.y < 293) {
        self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, 293, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
    }
    
    [venueLbl sizeToFit];
    
    if (venueLbl.frame.size.width > 265) {
        [venueLbl setFrame:CGRectMake(0, 0, 265, venueLbl.frame.size.height)];
    }
    
    venueLbl.center = CGPointMake(venueLbl.superview.center.x, self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height+5+(int)(venueLbl.frame.size.height/2));
    self.venueIcon.frame = CGRectMake(venueLbl.frame.origin.x - 15, venueLbl.frame.origin.y, self.venueIcon.frame.size.width, self.venueIcon.frame.size.height);
    self.venueIcon.center = CGPointMake(self.venueIcon.center.x+4, self.venueLabel.center.y-0.5);

    UIView *headerV = self.tableV.tableHeaderView;
    //Likes,Beeeps,Comments
    UILabel *beeepsLbl = (id)[headerV viewWithTag:-5];
    UILabel *likesLbl = (id)[headerV viewWithTag:-3];
    UILabel *commentsLbl = (id)[headerV viewWithTag:-4];
    
    Beeeps *b = [ffo.beeepFfo.beeeps firstObject];
    
    if (!likers) {
        likers = [NSMutableArray arrayWithArray:[b.likes valueForKey:@"likes"]];
    }
    
    likesLbl.text = [NSString stringWithFormat:@"%d",(int)likers.count];
    
    if (!comments) {
        comments = b.comments;
    }

    commentsLbl.text = [NSString stringWithFormat:@"%d",(int)comments.count];
    
    if (!beeepers) {
        beeepers = [NSMutableArray arrayWithArray:ffo.eventFfo.beeepedBy];
    }

    beeepsLbl.text = [NSString stringWithFormat:@"%d",(int)beeepers.count];
    
    NSArray *likersIDS = [[b.likes valueForKey:@"likers"] valueForKey:@"likersIdentifier"];
    NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
    
    isLiker = NO;
    
    if ([likersIDS indexOfObject:my_id] != NSNotFound) {
        isLiker = YES;
    }
    
    if (isLiker) {
        
        UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
        likeBtn.image = [UIImage imageNamed:@"liked_event.png"];
        
//        [self.likesButton setImage:[UIImage imageNamed:@"liked_icon_event"] forState:UIControlStateNormal];
    }
    else{

        UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
       likeBtn.image = [UIImage imageNamed:@"like_event.png"];
        
       // [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
    }
    
    
    self.likesLabel.hidden = (likers.count == 0);
    self.commentsLabel.hidden = (comments.count == 0);
    self.beeepsLabel.hidden = (beeepers.count == 0);
    
    
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
        self.tagsField.text = [correctString unicodeEncode];
        self.tagsField.textAlignment = NSTextAlignmentCenter;
    }
    @catch (NSException *exception) {
        NSLog(@"NO TAGS");
    }
    @finally {
        
    }
    
    double now_time = [[NSDate date]timeIntervalSince1970];
    double event_timestamp = ffo.eventFfo.eventDetailsFfo.timestamp;
    
    if (now_time > event_timestamp) {
        passedEvent = YES;
//        self.titleLabel.textColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1];
//        self.dayNumberLabel.textColor = [UIColor colorWithRed:150/255.0 green:153/255.0 blue:159/255.0 alpha:1];
//        self.monthLabel.textColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1];
//        self.hourLabel.textColor =[UIColor colorWithRed:150/255.0 green:153/255.0 blue:159/255.0 alpha:1];
//        self.dayLabel.textColor =[UIColor colorWithRed:150/255.0 green:153/255.0 blue:159/255.0 alpha:1];

//        UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Passed_white"] style:UIBarButtonItemStyleBordered target:nil action:nil];
//        [self.navigationItem setRightBarButtonItem:beeepItem];
        
        self.passedIcon.hidden = NO;
        self.beeepItButton.hidden = YES;
        self.beeepedGray.hidden = YES;
        [self.beeepItButton setUserInteractionEnabled:NO];
    }
    else{
        
        @try {
            if (beeepers && [[beeepers valueForKey:@"id"] indexOfObject:my_id] == NSNotFound) {
                
                self.beeepItButton.hidden = NO;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = YES;
                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeepit_outlined"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
                
                
            }
            else if (beeepers && [[beeepers valueForKey:@"id"] indexOfObject:my_id] != NSNotFound) {
                
                self.beeepItButton.hidden = YES;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = NO;
               
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeeped_white"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
                
                
            }
            else{
                
                self.beeepItButton.hidden = YES;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = NO;
                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeepit_outlined"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
                
            }
        }
        @catch (NSException *exception) {
            if (beeepers && [beeepers indexOfObject:my_id] == NSNotFound) {
                
                self.beeepItButton.hidden = NO;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = YES;
                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeepit_outlined"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
//                
            }
            else if (beeepers && [beeepers indexOfObject:my_id] != NSNotFound) {
                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeeped_white"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                self.beeepItButton.hidden = YES;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = NO;
                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
                
            }
            
        }
        @finally {
            
        }
        
    }

    
    //Image
    
    NSString *extension;
    NSString *imageName;
    
    @try {
        
       // extension  = [[ffo.eventFfo.eventDetailsFfo.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        imageName  = [NSString stringWithFormat:@"%@",ffo.eventFfo.eventDetailsFfo.imageUrl];
        
        imageURL = [[DTO sharedDTO] fixLink:imageName];
        [self.eventImageV sd_setImageWithURL:[NSURL URLWithString:imageURL]
                placeholderImage:[UIImage imageNamed:@"event_image"]];
        
    }
    @catch (NSException *exception) {
        NSLog(@"NO IMAGE");
    }
    @finally {
        
    }
    
    [shareText appendFormat:@"%@ on %@,%@ %@ - %@",[ffo.eventFfo.eventDetailsFfo.title capitalizedString],[month uppercaseString],daynumber,hour,[loc.venueStation capitalizedString]];

    [self hideLoading];
    
    if (self.redirectToComments) {
        [self showCommentsWillDelay];
    }
}

-(void)showEventWithTimelineObject{
    
    //EVENT DATE
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMM dd, yyyy HH:mm"];
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
    
    
    shareText = [[NSMutableString alloc]init];
   
    //Website
    
    NSString *website;

    website = t.event.source;
    websiteURL = website;
    beeeperWebsiteURL = [NSString stringWithFormat:@"https://www.beeeper.com/event/%@",t.event.fingerprint];
    
    NSURL *url = [NSURL URLWithString:websiteURL];
    
    self.websiteLabel.text = [url host];
    
    //Venue name + Title
    
    UILabel *venueLbl = self.venueLabel;
    
    NSString *jsonString;
    
    self.titleLabel.text = [t.event.title capitalizedString];
    jsonString = t.event.location;
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
    venueLbl.text = [loc.venueStation capitalizedString];
    
    CGPoint oldCenter = self.titleLabel.center;
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake(oldCenter.x, self.titleLabel.center.y);
    
    if (self.titleLabel.frame.origin.y < 293) {
        self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, 293, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
    }
    
    [venueLbl sizeToFit];
    
    if (venueLbl.frame.size.width > 265) {
        [venueLbl setFrame:CGRectMake(0, 0, 265, venueLbl.frame.size.height)];
    }
    
    venueLbl.center = CGPointMake(venueLbl.superview.center.x, self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height+5+(int)(venueLbl.frame.size.height/2));
    self.venueIcon.frame = CGRectMake(venueLbl.frame.origin.x - 15, venueLbl.frame.origin.y, self.venueIcon.frame.size.width, self.venueIcon.frame.size.height);
    self.venueIcon.center = CGPointMake(self.venueIcon.center.x+4, self.venueLabel.center.y-0.5);

    
    UIView *headerV = self.tableV.tableHeaderView;
    //Likes,Beeeps,Comments
    UILabel *beeepsLbl = (id)[headerV viewWithTag:-5];
    UILabel *likesLbl = (id)[headerV viewWithTag:-3];
    UILabel *commentsLbl = (id)[headerV viewWithTag:-4];
    
    if (!likers) {
        @try {
            likers = [NSMutableArray arrayWithArray:[t.beeep.beeepInfo.likes valueForKey:@"likes"]];
        }
        @catch (NSException *exception) {
            likers = [NSMutableArray arrayWithArray:t.beeep.beeepInfo.likes];
        }
        @finally {
            
        }

    }
    
    likesLbl.text = [NSString stringWithFormat:@"%d",(int)likers.count];
    self.likesLabel.hidden = (likers.count == 0);
    
    if (comments) {
        commentsLbl.text = [NSString stringWithFormat:@"%d",(int)comments.count];
    }
    
    self.commentsLabel.hidden = (comments.count == 0);
   
    if (!beeepers) {
        beeepers = [NSMutableArray arrayWithArray:t.beeepersIds];
    }

    beeepsLbl.text = [NSString stringWithFormat:@"%d",(int)beeepers.count];
    
    self.beeepsLabel.hidden = (beeepers.count == 0);
    
    NSMutableArray *likersIDS;
    
    @try {
        likersIDS = [NSMutableArray arrayWithArray:[[t.beeep.beeepInfo.likes valueForKey:@"likers"] valueForKey:@"likersIdentifier"]];
    }
    @catch (NSException *exception) {
        likersIDS = [NSMutableArray arrayWithArray:t.beeep.beeepInfo.likes];
    }
    @finally {
        
    }
    
    NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
    
    isLiker = NO;
    
    if ([likersIDS indexOfObject:my_id] != NSNotFound) {
        isLiker = YES;
    }
    
    if (isLiker) {
        
        UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
        likeBtn.image = [UIImage imageNamed:@"liked_event.png"];
        
       // [self.likesButton setImage:[UIImage imageNamed:@"liked_icon_event"] forState:UIControlStateNormal];
    }
    else{
        
        UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
        likeBtn.image = [UIImage imageNamed:@"like_event.png"];
        
//        [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
    }
    
    double now_time = [[NSDate date]timeIntervalSince1970];
    double event_timestamp = t.event.timestamp;
    
    if (now_time > event_timestamp) {
        passedEvent = YES;
//        self.titleLabel.textColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1];
//        self.dayNumberLabel.textColor = [UIColor colorWithRed:150/255.0 green:153/255.0 blue:159/255.0 alpha:1];
//        self.monthLabel.textColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1];
//        self.hourLabel.textColor =[UIColor colorWithRed:150/255.0 green:153/255.0 blue:159/255.0 alpha:1];
//        self.dayLabel.textColor =[UIColor colorWithRed:150/255.0 green:153/255.0 blue:159/255.0 alpha:1];

        self.beeepItButton.hidden = YES;
        self.passedIcon.hidden = NO;
        self.beeepedGray.hidden = YES;
        
//        UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Passed_white"] style:UIBarButtonItemStyleBordered target:nil action:nil];
//        [self.navigationItem setRightBarButtonItem:beeepItem];

    }
    else{
        
        @try {
            if (beeepers && [[beeepers valueForKey:@"id"] indexOfObject:my_id] == NSNotFound) {
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                [btn setBackgroundImage:[UIImage imageNamed:@"beeepit_outlined"] forState:UIControlStateNormal];
                [btn sizeToFit];
                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
                
                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
                [self.navigationItem setRightBarButtonItem:beeepItem];
                
                self.beeepItButton.hidden = NO;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = YES;
                
                
            }
            else if (beeepers && [[beeepers valueForKey:@"id"] indexOfObject:my_id] != NSNotFound) {
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeeped_white"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
                
                
                self.beeepItButton.hidden = YES;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = NO;
                
            }
            else{
                
                self.beeepItButton.hidden = NO;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = NO;            }
        }
        @catch (NSException *exception) {
            if (beeepers && [beeepers indexOfObject:my_id] == NSNotFound) {

                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeepit_outlined"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
                
                self.beeepItButton.hidden = NO;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = YES;
                
            }
            else if (beeepers && [beeepers indexOfObject:my_id] != NSNotFound) {
                
                self.beeepItButton.hidden = YES;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = NO;
                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeeped_white"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
                
            }
            
        }
        @finally {
            
        }
        

    
    }
    
    //Tags
    
    NSMutableString *formattedTags = [[NSMutableString alloc]init];
    NSString *hastags;
    
    @try {
        
        hastags = [t.hashTags stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        
        hastags = [hastags stringByReplacingOccurrencesOfString:@"[\"" withString:@""];
        hastags = [hastags stringByReplacingOccurrencesOfString:@"\"]" withString:@""];
        hastags = [hastags stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        hastags = [hastags stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
        
        NSArray *tags = [hastags componentsSeparatedByString:@","];
        for (NSString *tag in tags) {
            if (tag.length > 1) {
                [formattedTags appendFormat:@"#%@ ",tag];
            }
        }
        
        NSString *correctString = [formattedTags stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        self.tagsField.text = [correctString unicodeEncode];
        self.tagsField.textAlignment = NSTextAlignmentCenter;
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
        
        //extension  = [[t.event.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        imageName  = [NSString stringWithFormat:@"%@",t.event.imageUrl];
        
        imageURL = [[DTO sharedDTO] fixLink:imageName];
        [self.eventImageV sd_setImageWithURL:[NSURL URLWithString:imageURL]
                            placeholderImage:[UIImage imageNamed:@"event_image"]];
        
    }
    @catch (NSException *exception) {
        NSLog(@"NO IMAGE");
    }
    @finally {
        
    }
    
    [shareText appendFormat:@"%@ on %@,%@ %@ - %@",[t.event.title capitalizedString],[month uppercaseString],daynumber,hour,[loc.venueStation capitalizedString]];
    
    [self hideLoading];
    
    if (self.redirectToComments) {
        [self showCommentsWillDelay];
    }
}

-(void)showEventWithFingerprint:(NSString *)fingerprintDeep{

    [self showLoading];
    
    [[BPActivity sharedBP]getEventFromFingerprint:fingerprintDeep WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
        if (completed) {
            event_show_Objct = event;
            [self showEventForEventLookUpObject];
            [self hideLoading];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Event not found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

-(void)showEventForEventLookUpObject{
    
    //EVENT DATE
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMM dd, yyyy HH:mm"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:usLocale];
    
    NSDate *date;
    
    Event_Show_Object* event = event_show_Objct;
    
    Event_Search *eventSearch = tml;
    
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
    
    
    shareText = [[NSMutableString alloc]init];

    //Website
    
    NSString *website = event.eventInfo.source;
    websiteURL = website;
    beeeperWebsiteURL = [NSString stringWithFormat:@"https://www.beeeper.com/event/%@",event.eventInfo.fingerprint];
    
    NSURL *url = [NSURL URLWithString:websiteURL];
    
    self.websiteLabel.text = [url host];
    
    //Venue name + Title
    
    UILabel *venueLbl = self.venueLabel;
    
    NSString *jsonString;
    
    self.titleLabel.text = [event.eventInfo.title capitalizedString];
    jsonString = event.eventInfo.location;
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    if (data != nil) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
        venueLbl.text = [loc.venueStation capitalizedString];
        
        CGPoint oldCenter = self.titleLabel.center;
        [self.titleLabel sizeToFit];
        self.titleLabel.center = CGPointMake(oldCenter.x, self.titleLabel.center.y);
        
        if (self.titleLabel.frame.origin.y < 293) {
            self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, 293, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
        }

        
        [venueLbl sizeToFit];
        
        if (venueLbl.frame.size.width > 265) {
            [venueLbl setFrame:CGRectMake(0, 0, 265, venueLbl.frame.size.height)];
        }
        
        venueLbl.center = CGPointMake(venueLbl.superview.center.x, self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height+5
                                      +(int)(venueLbl.frame.size.height/2));
        self.venueIcon.frame = CGRectMake(venueLbl.frame.origin.x - 15, venueLbl.frame.origin.y, self.venueIcon.frame.size.width, self.venueIcon.frame.size.height);
        self.venueIcon.center = CGPointMake(self.venueIcon.center.x+4, self.venueLabel.center.y-0.5);
        
    }
    
    UIView *headerV = self.tableV.tableHeaderView;
    //Likes,Beeeps,Comments
    UILabel *beeepsLbl = (id)[headerV viewWithTag:-5];
    UILabel *likesLbl = (id)[headerV viewWithTag:-3];
    UILabel *commentsLbl = (id)[headerV viewWithTag:-4];
    
    NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
    
    isLiker = NO;
    
    if (!likers) {
        likers = eventSearch.likes;
        
        if (likers == nil) {
            likers = [NSMutableArray array];
        }
    }
    
    likesLbl.text = [NSString stringWithFormat:@"%d",(int)likers.count];

    if (!comments) {
        comments = eventSearch.comments;
    }
    
    self.commentsLabel.text = [NSString stringWithFormat:@"%d",(int)eventSearch.comments.count];

    if (!beeepers) {
        beeepers = [event.beeepedBy objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    }
    
    beeepsLbl.text = [NSString stringWithFormat:@"%d",(int)beeepers.count];
    
    if (likers && [likers indexOfObject:my_id] != NSNotFound) {
        isLiker = YES;
    }
    
    if (isLiker) {
        UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
        likeBtn.image = [UIImage imageNamed:@"liked_event.png"];
        
        //[self.likesButton setImage:[UIImage imageNamed:@"liked_icon_event"] forState:UIControlStateNormal];
    }
    else{
        
        UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
        likeBtn.image = [UIImage imageNamed:@"like_event.png"];
        
//        [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
    }
    
    
    BOOL hideComments = (comments.count == 0);
    
    self.likesLabel.hidden = (likers.count == 0);
    self.commentsLabel.hidden = hideComments;
    self.beeepsLabel.hidden = (beeepers.count == 0);
        
    double now_time = [[NSDate date]timeIntervalSince1970];
    double event_timestamp = event.eventInfo.timestamp;
    
    if (now_time > event_timestamp) {
        passedEvent = YES;
//        self.titleLabel.textColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1];
//        self.dayNumberLabel.textColor = [UIColor colorWithRed:150/255.0 green:153/255.0 blue:159/255.0 alpha:1];
//        self.monthLabel.textColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1];
//        self.hourLabel.textColor =[UIColor colorWithRed:150/255.0 green:153/255.0 blue:159/255.0 alpha:1];
//        self.dayLabel.textColor =[UIColor colorWithRed:150/255.0 green:153/255.0 blue:159/255.0 alpha:1];

        
//        UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Passed_white"] style:UIBarButtonItemStyleBordered target:nil action:nil];
//        [self.navigationItem setRightBarButtonItem:beeepItem];
        
        self.beeepItButton.hidden = YES;
        self.passedIcon.hidden = NO;
        self.beeepedGray.hidden = YES;
        [self.beeepItButton setUserInteractionEnabled:NO];
    }
    else{
        
        @try {
            if (beeepers && [[beeepers valueForKey:@"id"] indexOfObject:my_id] == NSNotFound) {
                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeepit_outlined"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
                
                self.beeepItButton.hidden = NO;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = YES;
                
                
            }
            else if (beeepers && [[beeepers valueForKey:@"id"] indexOfObject:my_id] != NSNotFound) {
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeeped_white"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
                
                self.beeepItButton.hidden = YES;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = NO;
                
                
            }
            else{
                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeepit_outlined"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
                
                self.beeepItButton.hidden = NO;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = YES;
                
            }
        }
        @catch (NSException *exception) {
            if (beeepers && [beeepers indexOfObject:my_id] == NSNotFound) {
               
                self.beeepItButton.hidden = NO;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = YES;
                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeepit_outlined"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
                
            }
            else if (beeepers && [beeepers indexOfObject:my_id] != NSNotFound) {
                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeeped_white"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];

                self.beeepItButton.hidden = YES;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = NO;
                
            }
            
        }
        @finally {
            
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
        self.tagsField.text = [correctString unicodeEncode];
        self.tagsField.textAlignment = NSTextAlignmentCenter;
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
        
        // extension  = [[event.eventInfo.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        
        imageName  = [NSString stringWithFormat:@"%@",event.eventInfo.imageUrl];
        
        imageURL = [[DTO sharedDTO] fixLink:imageName];
        [self.eventImageV sd_setImageWithURL:[NSURL URLWithString:imageURL]
                            placeholderImage:[UIImage imageNamed:@"event_image"]];
        
    }
    @catch (NSException *exception) {
        NSLog(@"NO IMAGE");
    }
    @finally {
        
    }
    
    [shareText appendFormat:@"%@ on %@,%@ %@ - %@",[event.eventInfo.title capitalizedString],[month uppercaseString],daynumber,hour,venueLbl.text];
    
    [self hideLoading];
    
    if (self.redirectToComments) {
        [self showCommentsWillDelay];
    }
}


-(void)showEventWithBeeep{
    
    //EVENT DATE
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMM dd, yyyy HH:mm"];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:usLocale];
    
    NSDate *date;
    
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
    
    
    shareText = [[NSMutableString alloc]init];
    
    //Website
    
    NSString *website = event.eventInfo.source;
    websiteURL = website;
    beeeperWebsiteURL = [NSString stringWithFormat:@"https://www.beeeper.com/event/%@",event.eventInfo.fingerprint];
    
    NSURL *url = [NSURL URLWithString:websiteURL];
    
    self.websiteLabel.text = [url host];
    
    //Venue name + Title
    
    UILabel *venueLbl = self.venueLabel;
    
    NSString *jsonString;
    
    self.titleLabel.text = [event.eventInfo.title capitalizedString];
    
    jsonString = event.eventInfo.location;
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
   
    if (data != nil) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        EventLocation *loc = [EventLocation modelObjectWithDictionary:dict];
        venueLbl.text = [loc.venueStation capitalizedString];
        
        CGPoint oldCenter = self.titleLabel.center;
        [self.titleLabel sizeToFit];
        self.titleLabel.center = CGPointMake(oldCenter.x, self.titleLabel.center.y);
        
        if (self.titleLabel.frame.origin.y < 293) {
            self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, 293, self.titleLabel.frame.size.width, self.titleLabel.frame.size.height);
        }

        
        [venueLbl sizeToFit];
        
        if (venueLbl.frame.size.width > 265) {
            [venueLbl setFrame:CGRectMake(0, 0, 265, venueLbl.frame.size.height)];
        }
        
        venueLbl.center = CGPointMake(venueLbl.superview.center.x, self.titleLabel.frame.origin.y+self.titleLabel.frame.size.height+5
                                      +(int)(venueLbl.frame.size.height/2));
        self.venueIcon.frame = CGRectMake(venueLbl.frame.origin.x - 15, venueLbl.frame.origin.y, self.venueIcon.frame.size.width, self.venueIcon.frame.size.height);
        self.venueIcon.center = CGPointMake(self.venueIcon.center.x+4, self.venueLabel.center.y-0.5);

    }
    
    UIView *headerV = self.tableV.tableHeaderView;
    //Likes,Beeeps,Comments
    UILabel *beeepsLbl = (id)[headerV viewWithTag:-5];
    UILabel *likesLbl = (id)[headerV viewWithTag:-3];
    UILabel *commentsLbl = (id)[headerV viewWithTag:-4];
    
    NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
    
    isLiker = NO;
    
    @try {
        NSArray *beeepersArr = [event.beeepedBy objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
        beeepers = [beeepersArr valueForKey:@"id"];
    }
    @catch (NSException *exception) {
    
    }
    @finally {
    
    }
   
    
    if(beeep == nil){
        
        if (event != nil) {
            
            if (!comments) {
                comments = event.eventInfo.comments;
            }

            if (!likers) {
                likers = [NSMutableArray arrayWithArray:event.eventInfo.likes];
            }
            
            self.likesLabel.hidden = (likers.count == 0);
            self.beeepsLabel.hidden = (beeepers.count == 0);
            self.commentsLabel.hidden = (comments.count == 0);
            
            self.beeepsLabel.text = [NSString stringWithFormat:@"%d",(int)beeepers.count];
            self.likesLabel.text = [NSString stringWithFormat:@"%d",(int)likers.count];
            self.commentsLabel.text = [NSString stringWithFormat:@"%d",(int)comments.count];
            
            isLiker = (likers && [likers indexOfObject:my_id] != NSNotFound);
            
            if (isLiker) {
                UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
                likeBtn.image = [UIImage imageNamed:@"liked_event.png"];
                //            [self.likesButton setImage:[UIImage imageNamed:@"liked_icon_event"] forState:UIControlStateNormal];
            }
            else{
                UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
                likeBtn.image = [UIImage imageNamed:@"like_event.png"];
                //          [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
            }
        }
        else{
            self.likesLabel.hidden = YES;
            self.beeepsLabel.hidden = YES;
            self.commentsLabel.hidden = YES;
        }
    }
    else{
        
        if (!likers) {
            likers = [NSMutableArray arrayWithArray:beeep.likes];
        }
        
        if (!comments) {
            comments = beeep.comments;
        }
        
        likesLbl.text = [NSString stringWithFormat:@"%d",(int)likers.count];
        commentsLbl.text = [NSString stringWithFormat:@"%d",(int)comments.count];
        beeepsLbl.text = [NSString stringWithFormat:@"%d",beeepers.count];
        
        if (likers && [likers indexOfObject:my_id] != NSNotFound) {
            isLiker = YES;
        }
        
        if (isLiker) {
            UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
            likeBtn.image = [UIImage imageNamed:@"liked_event.png"];
//            [self.likesButton setImage:[UIImage imageNamed:@"liked_icon_event"] forState:UIControlStateNormal];
        }
        else{
            UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
            likeBtn.image = [UIImage imageNamed:@"like_event.png"];
            //          [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
        }
        
        
        self.likesLabel.hidden = (likers.count == 0);
        self.commentsLabel.hidden = (comments.count == 0);
        self.beeepsLabel.hidden = (beeepers.count == 0);

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
        self.tagsField.text = [correctString unicodeEncode];
        self.tagsField.textAlignment = NSTextAlignmentCenter;
        
    }
    @catch (NSException *exception) {
        NSLog(@"NO TAGS");
    }
    @finally {
        
    }
    
    double now_time = [[NSDate date]timeIntervalSince1970];
    double event_timestamp = event.eventInfo.timestamp;
    
    if (now_time > event_timestamp) {
        passedEvent = YES;
//        self.titleLabel.textColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1];
//        self.dayNumberLabel.textColor = [UIColor colorWithRed:150/255.0 green:153/255.0 blue:159/255.0 alpha:1];
//        self.monthLabel.textColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1];
//        self.hourLabel.textColor =[UIColor colorWithRed:150/255.0 green:153/255.0 blue:159/255.0 alpha:1];
//        self.dayLabel.textColor =[UIColor colorWithRed:150/255.0 green:153/255.0 blue:159/255.0 alpha:1];

//        UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Passed_white"] style:UIBarButtonItemStyleBordered target:nil action:nil];
//        [self.navigationItem setRightBarButtonItem:beeepItem];
        
        self.beeepItButton.hidden = YES;
        self.passedIcon.hidden = NO;
        self.beeepedGray.hidden = YES;
        
        [self.beeepItButton setUserInteractionEnabled:NO];
    }
    else{
        
        @try {
            if (beeepers && [[beeepers valueForKey:@"id"] indexOfObject:my_id] == NSNotFound) {
//                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeepit_outlined"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
                
                self.beeepItButton.hidden = NO;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = YES;
                
                
            }
            else if (beeepers && [[beeepers valueForKey:@"id"] indexOfObject:my_id] != NSNotFound) {
                
                self.beeepItButton.hidden = YES;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = NO;
                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeeped_white"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
//                
                
            }
            else{
                self.beeepItButton.hidden = NO;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = YES;
                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeepit_outlined"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
                
            }
        }
        @catch (NSException *exception) {
            if (beeepers && [beeepers indexOfObject:my_id] == NSNotFound) {
                self.beeepItButton.hidden = YES;
                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeepit_outlined"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];
                
                self.beeepItButton.hidden = NO;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = YES;
                
            }
            else if (beeepers && [beeepers indexOfObject:my_id] != NSNotFound) {
                
//                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//                [btn setBackgroundImage:[UIImage imageNamed:@"beeeped_white"] forState:UIControlStateNormal];
//                [btn sizeToFit];
//                [btn addTarget:self action:@selector(beeepItPressed:) forControlEvents:UIControlEventTouchUpInside];
//                
//                UIBarButtonItem *beeepItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
//                [self.navigationItem setRightBarButtonItem:beeepItem];

                self.beeepItButton.hidden = YES;
                self.passedIcon.hidden = YES;
                self.beeepedGray.hidden = NO;
            }
            
        }
        @finally {
            
        }
        

    }
    
    //Image
    
    UIImageView *imgV = self.eventImageV;
    
    NSString *extension;
    NSString *imageName;
    
    @try {
        
       // extension  = [[event.eventInfo.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        
        imageName  = [NSString stringWithFormat:@"%@",event.eventInfo.imageUrl];
        
        imageURL = [[DTO sharedDTO] fixLink:imageName];
        [self.eventImageV sd_setImageWithURL:[NSURL URLWithString:imageURL]
                            placeholderImage:[UIImage imageNamed:@"event_image"]];
        
    }
    @catch (NSException *exception) {
        NSLog(@"NO IMAGE");
    }
    @finally {
        
    }
    
    [shareText appendFormat:@"%@ on %@,%@ %@ - %@",[event.eventInfo.title capitalizedString],[month uppercaseString],daynumber,hour,venueLbl.text];
    
    [self hideLoading];
    
    if (self.redirectToComments) {
        [self showCommentsWillDelay];
    }
}


-(void)goBack{
    
     [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    viewAppeared = YES;
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideTabbar" object:self];

    NSRange range = NSMakeRange(0, 1);
    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableV reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
   
    
    self.tableV.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    self.tableV.layer.shadowOpacity = 0.7;
    self.tableV.layer.shadowOffset = CGSizeMake(0, 0.1);
    self.tableV.layer.shadowRadius = 0.8;
    self.tableV.layer.masksToBounds = NO;

}


-(void)suggestIt{
    
    if (fingerprint != nil) {
        [[TabbarVC sharedTabbar]suggestPressed:fingerprint controller:self sendNotificationWhenFinished:NO selectedPeople:nil showBlur:YES];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There is a problem with this Beeep. Please refresh and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }

}

-(void)likeIt{

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
        //            [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
                    
                    likesLbl.hidden = (likers.count == 0);
                    
                    UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
                    likeBtn.image = [UIImage imageNamed:@"like_event.png"];
                    
                    
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                    [SVProgressHUD showSuccessWithStatus:@"Unliked"];
                }
                else{
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                    [SVProgressHUD showErrorWithStatus:@"Something went wrong"];
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
                 //   [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
                    
                    likesLbl.hidden = (likers.count == 0);
                    
                    UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
                    likeBtn.image = [UIImage imageNamed:@"like_event.png"];
                    
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                    [SVProgressHUD showSuccessWithStatus:@"Unliked"];
                }
                else{
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                    [SVProgressHUD showErrorWithStatus:@"Something went wrong"];
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
                    //    [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
                        
                        UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
                        likeBtn.image = [UIImage imageNamed:@"like_event.png"];
                        
                        likesLbl.hidden = (likers.count == 0);
                        
                        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                        [SVProgressHUD showSuccessWithStatus:@"Unliked"];
                    }
                    else{
                        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                        [SVProgressHUD showErrorWithStatus:@"Something went wrong"];
                    }
                }];
            }
            else{
                Beeep *bps = [activity.beeepInfoActivity.beeepActivity firstObject];
                [[EventWS sharedBP]unlikeBeeep:bps.beeepInfo.weight user:ffo.beeepFfo.userId WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                    if (completed) {
                        isLiker = NO;
                        [likers removeObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                        likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue - 1)>0)?(likesLbl.text.intValue - 1):0];
                        likesLbl.hidden = (likers.count == 0);
                        
                        [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
                    }
                }];
            }
            
        }
        else if ([tml isKindOfClass:[Event_Search class]]){
            
            Event_Search *event = tml;
            
            [[EventWS sharedBP]unlikeEvent:event.fingerprint WithCompletionBlock:^(BOOL completed,Event_Show_Object *eventShow){
                if (completed) {
                    isLiker = NO;
                    [likers removeObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                    likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue - 1)>0)?(likesLbl.text.intValue - 1):0];
//                    [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
                 
                    likesLbl.hidden = (likers.count == 0);
                    
                    UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
                    likeBtn.image = [UIImage imageNamed:@"like_event.png"];
                    
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                    [SVProgressHUD showSuccessWithStatus:@"Unliked"];

                }
                else{
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                    [SVProgressHUD showErrorWithStatus:@"Something went wrong"];
                }
                
            }];

        }
        else if ([tml isKindOfClass:[Timeline_Object class]]){
            
            Timeline_Object *t = tml; //one of those two will be used
            
            //NSString *fingerprint = t.event.fingerprint;
           
            [[EventWS sharedBP]unlikeBeeep:t.beeep.beeepInfo.weight user:t.beeep.userId WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
          
                if (completed) {
                    isLiker = NO;
                    [likers removeObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                    likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue - 1)>0)?(likesLbl.text.intValue - 1):0];
                    //    [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
                    
                    likesLbl.hidden = (likers.count == 0);
                    
                    UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
                    likeBtn.image = [UIImage imageNamed:@"like_event.png"];
                    
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                    [SVProgressHUD showSuccessWithStatus:@"Unliked"];
                }
                else{
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                    [SVProgressHUD showErrorWithStatus:@"Something went wrong"];
                }
            }];

        }
        else if ([tml isKindOfClass:[NSString class]]){
            
            Event_Show_Object* event = event_show_Objct;
            Beeep_Object* beeep = beeep_Objct;
            
            //NSString *fingerprint = t.event.fingerprint;
             NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
            
            [[EventWS sharedBP]unlikeBeeep:beeep.weight user:my_id WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                
                if (completed) {
                    isLiker = NO;
                    [likers removeObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                    likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue - 1)>0)?(likesLbl.text.intValue - 1):0];
                    //    [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
                    
                    likesLbl.hidden = (likers.count == 0);
                    
                    UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
                    likeBtn.image = [UIImage imageNamed:@"like_event.png"];
                    
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                    [SVProgressHUD showSuccessWithStatus:@"Unliked"];
                }
                else{
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                    [SVProgressHUD showErrorWithStatus:@"Something went wrong"];
                }
            }];
            
        }
        else if (self.deepLinkFingerprint){
            
            [[EventWS sharedBP]unlikeEvent:self.deepLinkFingerprint WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                if (completed) {
                    isLiker = NO;
                    [likers removeObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                    likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue - 1)>0)?(likesLbl.text.intValue - 1):0];
                    //    [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
                    
                    UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
                    likeBtn.image = [UIImage imageNamed:@"like_event.png"];
                    
                    likesLbl.hidden = (likers.count == 0);
                    
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                    [SVProgressHUD showSuccessWithStatus:@"Unliked"];
                }
                else{
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                    [SVProgressHUD showErrorWithStatus:@"Something went wrong"];
                }
            }];
        }

    }
    else{
        if ([tml isKindOfClass:[Friendsfeed_Object class]]) {
            Beeeps *bps = [ffo.beeepFfo.beeeps firstObject];
            
            [[EventWS sharedBP]likeBeeep:bps.weight user:ffo.beeepFfo.userId WithCompletionBlock:^(BOOL completed,NSDictionary *response){
                if (completed) {
                    isLiker = YES;
                    [likers addObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                    
                    likesLbl.hidden = (likers.count == 0);
                    likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue + 1)>0)?(likesLbl.text.intValue + 1):0];
//                    [self.likesButton setImage:[UIImage imageNamed:@"liked_icon_event"] forState:UIControlStateNormal];
                    
                    UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
                    likeBtn.image = [UIImage imageNamed:@"liked_event.png"];
                    
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
        else if ([tml isKindOfClass:[Suggestion_Object class]]){
            Suggestion_Object *suggest = tml;
            
            [[EventWS sharedBP]likeEvent:suggest.what.fingerprint WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                if (completed) {
                    isLiker = YES;
                
                    [likers addObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                    likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue + 1)>0)?(likesLbl.text.intValue + 1):0];
  //                  [self.likesButton setImage:[UIImage imageNamed:@"liked_icon_event"] forState:UIControlStateNormal];
                    
                    likesLbl.hidden = (likers.count == 0);
                    
                    UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
                    likeBtn.image = [UIImage imageNamed:@"liked_event.png"];
                    
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                    [SVProgressHUD showSuccessWithStatus:@"Liked!"];
                }
                else{
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                    [SVProgressHUD showErrorWithStatus:@"Something went wrong"];
                }
                
            }];
            
        }
        else if ([tml isKindOfClass:[Activity_Object class]]){
            Activity_Object *activity = tml;
            
            if (activity.beeepInfoActivity.beeepActivity.count == 0) {
                
                NSString *fingerprint = [[activity.eventActivity firstObject]valueForKeyPath:@"fingerprint"];
                
                [[EventWS sharedBP]likeEvent:fingerprint WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                    if (completed) {
                        isLiker = YES;
                        [likers addObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                        likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue + 1)>0)?(likesLbl.text.intValue + 1):0];
                        
                        likesLbl.hidden = (likers.count ==0);
                        
                    //    [self.likesButton setImage:[UIImage imageNamed:@"liked_icon_event"] forState:UIControlStateNormal];
                      
                        UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
                        likeBtn.image = [UIImage imageNamed:@"liked_event.png"];
                        
                        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                        [SVProgressHUD showSuccessWithStatus:@"Liked!"];
                    }
                    else{
                        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                        [SVProgressHUD showErrorWithStatus:@"Something went wrong"];
                    }
                }];
            }
            else{
                NSLog(@"oooops");
                     /*   [[EventWS sharedBP]likeBeeep:bps.weight user:ffo.beeepFfo.userId WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                            if (completed) {
                                isLiker = NO;
                                [likers removeObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                                likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue - 1)>0)?(likesLbl.text.intValue - 1):0];
                      
                                likesLbl.hidden = (likers.count == 0);
                                [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
                            }
                        }];*/

            }
            
        }
        else if ([tml isKindOfClass:[Event_Search class]]){
            
            Event_Search *event = tml;
            
            [[EventWS sharedBP]likeEvent:event.fingerprint WithCompletionBlock:^(BOOL completed,Event_Show_Object *eventShow){
                if (completed) {
                    isLiker = YES;
                    [likers addObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                    likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue + 1)>0)?(likesLbl.text.intValue + 1):0];
                    //[self.likesButton setImage:[UIImage imageNamed:@"liked_icon_event"] forState:UIControlStateNormal];
                    
                    likesLbl.hidden = (likers.count == 0);
                    
                    UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
                    likeBtn.image = [UIImage imageNamed:@"liked_event.png"];
                    
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                    [SVProgressHUD showSuccessWithStatus:@"Liked!"];
                }
                else{
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                    [SVProgressHUD showErrorWithStatus:@"Something went wrong"];
                }
                
            }];
            
        }
        else if ([tml isKindOfClass:[Timeline_Object class]]){
            
            Timeline_Object *t = tml; //one of those two will be used
            
            NSString *fingerprint = t.event.fingerprint;
            
            
            [[EventWS sharedBP]likeBeeep:t.beeep.beeepInfo.weight user:t.beeep.userId WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                
                if (completed) {
                    isLiker = YES;
                    [likers addObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                    likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue + 1)>0)?(likesLbl.text.intValue + 1):0];
                    //    [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
                    
                    likesLbl.hidden = (likers.count == 0);
                    
                    UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
                    likeBtn.image = [UIImage imageNamed:@"liked_event.png"];
                    
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                    [SVProgressHUD showSuccessWithStatus:@"Liked"];
                }
                else{
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                    [SVProgressHUD showErrorWithStatus:@"Something went wrong"];
                }
            }];
            
        }
        else if ([tml isKindOfClass:[NSString class]]){
            
            Event_Show_Object* event = event_show_Objct;
            Beeep_Object* beeep = beeep_Objct;
            
            //NSString *fingerprint = t.event.fingerprint;
            NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
            
            [[EventWS sharedBP]likeBeeep:beeep.weight user:my_id WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                
                if (completed) {
                    isLiker = YES;
                    [likers addObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                    likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue + 1)>0)?(likesLbl.text.intValue + 1):0];
                    //    [self.likesButton setImage:[UIImage imageNamed:@"likes_icon_event"] forState:UIControlStateNormal];
                    
                    likesLbl.hidden = (likers.count == 0);
                    
                    UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
                    likeBtn.image = [UIImage imageNamed:@"liked_event.png"];
                    
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                    [SVProgressHUD showSuccessWithStatus:@"Liked"];
                }
                else{
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                    [SVProgressHUD showErrorWithStatus:@"Something went wrong"];
                }
            }];
            
        }
        else if (self.deepLinkFingerprint){
            
            [[EventWS sharedBP]likeEvent:self.deepLinkFingerprint WithCompletionBlock:^(BOOL completed,Event_Show_Object *event){
                if (completed) {
                    isLiker = YES;
                    [likers addObject:[[BPUser sharedBP].user objectForKey:@"id"]];
                    likesLbl.text = [NSString stringWithFormat:@"%d",((likesLbl.text.intValue + 1)>0)?(likesLbl.text.intValue + 1):0];
                    
                    likesLbl.hidden = (likers.count ==0);
                    
                    //    [self.likesButton setImage:[UIImage imageNamed:@"liked_icon_event"] forState:UIControlStateNormal];
                    
                    UIBarButtonItem *likeBtn  = [self.navigationItem.rightBarButtonItems objectAtIndex:1];
                    likeBtn.image = [UIImage imageNamed:@"liked_event.png"];
                    
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                    [SVProgressHUD showSuccessWithStatus:@"Liked!"];
                }
                else{
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                    [SVProgressHUD showErrorWithStatus:@"Something went wrong"];
                }
            }];        }
        

        
    }

    
  
}


-(void)showMore{

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Share on Facebook", @"Share on Twitter", nil];
    
    if([MFMessageComposeViewController canSendText])
    {
        [actionSheet addButtonWithTitle:@"Share via SMS"];
    }
    
    
    if ([MFMailComposeViewController canSendMail]) {
        [actionSheet addButtonWithTitle:@"Share via Email"];
    }
    
    if (websiteURL != nil) {
        [actionSheet addButtonWithTitle:@"Copy Link"];
    }

    [actionSheet addButtonWithTitle:@"Cancel"];
    
    
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons -1;

    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            [self sendFacebook];
            break;
        case 1:
            [self sendTwitter];
            break;
        case 2:{
            if ([MFMessageComposeViewController canSendText]) {
                [self sendSMS];
            }
            else if ([MFMailComposeViewController canSendMail]) {
                [self sendEmail];
            }
            else{
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = websiteURL;
            }
            break;
        }
        case 3:
        {
            if ([MFMessageComposeViewController canSendText] && [MFMailComposeViewController canSendMail]) {
                [self sendEmail];
            }
            else{
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = websiteURL;
                
                [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                [SVProgressHUD showSuccessWithStatus:@"Copied to Clipboard"];

            }
        }
            break;
        case 4:{
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = websiteURL;

            [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
            [SVProgressHUD showSuccessWithStatus:@"Copied to Clipboard"];
            
            break;
        }
        default:
            break;
    }
}

-(void)beeepIt:(NSNotification *)notif{
    
    [self close:nil];
    
    self.beeepItButton.hidden = YES;
    self.beeepedGray.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ShowWebsite:(id)sender {
    NSLog(@"link");
    
   WebBrowserVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"WebBrowser"];
    viewController.url = [NSURL URLWithString:websiteURL];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)beeepItPressed:(id)sender {
   
    if (passedEvent) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Passed Event" message:@"You can’t  Beeep a passed event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
    
    if ([beeepers indexOfObject:my_id] != NSNotFound) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Already Beeeped" message:@"You have already Beeeped this event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    @try {
        for (id beeeper in beeepers) {
            if ([[beeeper objectForKey:@"id"] isEqualToString:my_id]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Already Beeeped" message:@"You have already Beeeped this event." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
        }
    }
    @catch (NSException *exception) {
    
    }
    @finally {
    
    }

    id tml;
    
    if([self.tml isKindOfClass:[Friendsfeed_Object class]] || [self.tml isKindOfClass:[Timeline_Object class]] || [self.tml isKindOfClass:[Suggestion_Object class]]){
        tml = self.tml;
    }
    else{
        tml = event_show_Objct;
    }
    
    [[TabbarVC sharedTabbar]reBeeepPressed:tml image:self.eventImageV.image controller:self];

}

- (IBAction)showLikes:(id)sender {
    
    FollowListVC *viewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FollowListVC"];
    viewController.mode = LikesMode;
    viewController.ids = likers;
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showComments:(id)sender {
    
    CommentsVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentsVC"];
    viewController.event_beeep_object = ([tml isKindOfClass:[NSString class]])?beeep_Objct:tml;
    viewController.comments = comments;
    [self.navigationController pushViewController:viewController animated:YES];

}

-(void)showCommentsWillDelay{
    if (viewAppeared && self.redirectToComments) {
        self.redirectToComments = NO;
        [self showComments:nil];
    }
    else{
        [self performSelector:@selector(showCommentsWillDelay) withObject:nil afterDelay:1];
    }
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

/*-(void)sendFacebook{
    
    SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    [composeController setInitialText:shareText];
    
    if (self.eventImageV.image != nil) {
        
        [composeController addImage:self.eventImageV.image];
        
    }
    
    [composeController addURL: [NSURL URLWithString:(websiteURL != nil)?websiteURL:@"http://www.beeeper.com"]];
    
    [self presentViewController:composeController animated:YES completion:nil];
    
    
    SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
        if (result == SLComposeViewControllerResultDone){
            [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:59/255.0 green:89/255.0 blue:152/255.0 alpha:1]];
            [SVProgressHUD showSuccessWithStatus:@"Posted on Facebook!"];
        }
        
        //    [composeController dismissViewControllerAnimated:YES completion:Nil];
    };
    composeController.completionHandler =myBlock;
    
    
}*/

-(void)sendFacebook{
    
    
    [FBSession openActiveSessionWithReadPermissions:@[@"publish_actions"]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState state,
                                                      NSError *error) {
                                      if (error) {
                                          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                              message:error.localizedDescription
                                                                                             delegate:nil
                                                                                    cancelButtonTitle:@"OK"
                                                                                    otherButtonTitles:nil];
                                          [alertView show];
                                          
                                          [self sendFacebookNoApp];
                                          
                                          
                                      } else if (session.isOpen) {
                                          
                                          
                                          //            UIImage *img;
                                          //
                                          //            if(imageURL == nil){
                                          //                NSString *base64Image = [self.values objectForKey:@"base64_image"];
                                          //                NSData *base64Data = [self base64DataFromString:base64Image];
                                          //
                                          //                if (base64Data != nil) {
                                          //                    img = [UIImage imageWithData:base64Data];
                                          //                }
                                          //            }
                                          //            else{
                                          //                NSString *imageName = [NSString stringWithFormat:@"%@",[imageURL MD5]];
                                          //
                                          //                NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                                          //
                                          //                NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
                                          //
                                          //                if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
                                          //
                                          //                    img = [UIImage imageWithContentsOfFile:localPath];
                                          //                }
                                          //            }
                                          
                                          
                                          // Check if the Facebook app is installed and we can present the share dialog
                                          FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
                                          params.link = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.beeeper.com/event/%@", fingerprint]];
                                          NSURL *url = [NSURL URLWithString:imageURL];
                                          params.picture = url;
                                          params.name = self.titleLabel.text;
                                          params.linkDescription = self.venueLabel.text;
                                          
                                          // If the Facebook app is installed and we can present the share dialog
                                          if ([FBDialogs canPresentShareDialogWithParams:params]) {
                                              // Present share dialog
                                              
                                              [FBDialogs presentShareDialogWithParams:params clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                  if(error) {
                                                      // An error occurred, we need to handle the error
                                                      // See: https://developers.facebook.com/docs/ios/errors
                                                      
                                                      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                          message:error.localizedDescription
                                                                                                         delegate:nil
                                                                                                cancelButtonTitle:@"OK"
                                                                                                otherButtonTitles:nil];
                                                      [alertView show];
                                                      
                                                      NSLog(@"Error publishing story: %@", error.description);
                                                 
                                                      
                                                  } else {
                                                      // Success
                                                      NSLog(@"result %@", results);
                                                  }
                                              }];
                                          } else {
                                              // Present the feed dialog
                                              [self sendFacebookNoApp];
                                          }
                                          
                                          
                                          //run your user info request here
                                      }
                                  }];
}

-(void)sendFacebookNoApp{
    
    SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    [composeController setInitialText:[shareText stringByAppendingFormat:@" %@",(tinyURL)?tinyURL:@""]];
    
    if (self.eventImageV.image != nil) {
        
        [composeController addImage:self.eventImageV.image];
        
    }
    
    [composeController addURL: [NSURL URLWithString:(websiteURL != nil)?websiteURL:@"http://www.beeeper.com"]];
    
    [self presentViewController:composeController animated:YES completion:nil];
    
    
    SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
        if (result == SLComposeViewControllerResultDone) {
            [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:85/255.0 green:172/255.0 blue:238/255.0 alpha:1]];
            [SVProgressHUD showSuccessWithStatus:@"Posted on Facebook!"];
        }
        
        //    [composeController dismissViewControllerAnimated:YES completion:Nil];
    };
    composeController.completionHandler =myBlock;
}

-(void)sendTwitter {
    
    SLComposeViewController *composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    [composeController setInitialText:[shareText stringByAppendingFormat:@" %@",(tinyURL)?tinyURL:@""]];
    
    if (self.eventImageV.image != nil) {
        
        [composeController addImage:self.eventImageV.image];
        
    }
    
    [composeController addURL: [NSURL URLWithString:(websiteURL != nil)?websiteURL:@"http://www.beeeper.com"]];
    
    [self presentViewController:composeController animated:YES completion:nil];
    
    
    SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
        if (result == SLComposeViewControllerResultDone) {
            [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:85/255.0 green:172/255.0 blue:238/255.0 alpha:1]];
            [SVProgressHUD showSuccessWithStatus:@"Posted on Twitter!"];
        }
        
        //    [composeController dismissViewControllerAnimated:YES completion:Nil];
    };
    composeController.completionHandler =myBlock;
}

-(void)sendEmail{
    
        MFMailComposeViewController *mailComposer =
        [[MFMailComposeViewController alloc] init];
        [mailComposer setSubject:@"Check out this Event I found on Beeeper for iOS"];
        NSString *message = shareText;
        [mailComposer setMessageBody:message
                              isHTML:YES];
        NSData *imageData = UIImageJPEGRepresentation(self.eventImageV.image, 0.5);
        [mailComposer addAttachmentData:imageData mimeType:@"image/jpeg" fileName:[NSString stringWithFormat:@"%@.jpg",self.titleLabel.text]];
        mailComposer.mailComposeDelegate = self;
        [self presentViewController:mailComposer animated:YES completion:nil];
}

-(void)sendSMS{
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = @"Check out this Event I found on Beeeper for iOS";
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    [self dismissModalViewControllerAnimated:YES];
    
    if (result == MessageComposeResultFailed) {
        
        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
        [SVProgressHUD showSuccessWithStatus:@"Error sendig SMS"];
        
    } else if (result == MessageComposeResultSent) {
        
        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1]];
        [SVProgressHUD showSuccessWithStatus:@"SMS Sent!"];
    }
    
}


#pragma mark MFMailComposeViewControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result
                       error:(NSError *)error{
    if (result == MFMailComposeResultSent) {
        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1]];
        [SVProgressHUD showSuccessWithStatus:@"Email Sent!"];
    }
    else if(result == MFMailComposeResultFailed){
        [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
        [SVProgressHUD showSuccessWithStatus:@"Error sendig email"];

    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
  // NSString *extension = [[cmnts.commenter.imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
    
    [imageV sd_setImageWithURL:[NSURL URLWithString:[[DTO sharedDTO] fixLink:cmnts.commenter.imagePath]]
            placeholderImage:[UIImage imageNamed:@"user_icon_180x180"]];
    
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

#pragma mark - Tags

- (IBAction)tagSelected:(id)sender {
    NSLog(@"Clicked");
    
    CGPoint pos = [sender locationInView:self.tagsField];
    UITextView *_tv = self.tagsField;
    
    NSLog(@"Tap Gesture Coordinates: %.2f %.2f", pos.x, pos.y);
    
    
    //eliminate scroll offset
   // pos.y += _tv.contentOffset.y;
    
    //get location in text from textposition at point
    UITextPosition *tapPos = [_tv closestPositionToPoint:pos];
    
    //fetch the word at this position (or nil, if not available)
    UITextRange * wr = [_tv.tokenizer rangeEnclosingPosition:tapPos withGranularity:UITextGranularityWord inDirection:UITextLayoutDirectionRight];
    
    NSString *tag = [_tv textInRange:wr];
    
    if (tag.length != 0) {
        [SearchVC showInVC:self withSeachTerm:[tag stringByReplacingOccurrencesOfString:@"#" withString:@""]];   
    }
}


@end
