//
//  CommentsVC.m
//  Beeeper
//
//  Created by User on 3/13/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "CommentsVC.h"
#import "PHFComposeBarView.h"
#import "Comments.h"
#import "EventWS.h"
#import "Timeline_Object.h"
#import "Friendsfeed_Object.h"
#import "Event_Search.h"
#import "Activity_Object.h"
#import "Suggestion_Object.h"

@interface CommentsVC ()<PHFComposeBarViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableDictionary *pendingImagesDict;
    UITapGestureRecognizer *tapG;
        NSMutableArray *rowsToReload;
}

@property (readonly, nonatomic) UIView *container;
@property (readonly, nonatomic) PHFComposeBarView *composeBarView;
@property (readonly, nonatomic) UITextView *textView;
@property (nonatomic,assign) CGRect kInitialViewFrame;
@end

@implementation CommentsVC
@synthesize kInitialViewFrame,comments;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    rowsToReload = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideTabbar" object:self];

    pendingImagesDict = [NSMutableDictionary dictionary];


    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggle:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillToggle:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
   // self.tableV.alpha = 0;

}

-(void)viewWillAppear:(BOOL)animated{
    
    self.navigationController.navigationBar.backItem.title = @"";
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
   // [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.kInitialViewFrame = CGRectMake(0, self.view.frame.size.height-44, 320, 44);
    
    UIView *container = [self container];
    [container addSubview:[self composeBarView]];
    [self.view addSubview:container];
    
    [self.tableV reloadData];
    
    if (self.showKeyboard) {
        [self.composeBarView becomeFirstResponder];
    }
   // self.tableV.alpha = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    self.noCommentsLabel.hidden = comments.count != 0;

    return comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSLog(@"EMPTY CELL");
    }
    
    UILabel *txtV = (id)[cell viewWithTag:3];
    UILabel *name = (id)[cell viewWithTag:1];
    UILabel *date = (id)[cell viewWithTag:4];
    UIImageView *image = (id)[cell viewWithTag:2];
    
    
    id objct = [comments objectAtIndex:indexPath.row];
    
    
    if ([objct isKindOfClass:[Comments class]]) {
    
        Comments *commentObjct = (Comments *)objct;
            
        double timestamp = commentObjct.comment.timestamp;
        double now_timestamp = [[NSDate date] timeIntervalSince1970];
        
        date.text = [self dailyLanguage:now_timestamp-timestamp];
        
        Comments *commentObj = (Comments *)objct;
        NSString *comment = commentObj.comment.comment;
        txtV.text = comment;
        
        name.text = [[NSString stringWithFormat:@"%@ %@",commentObj.commenter.name,commentObj.commenter.lastname] capitalizedString];
        
        CGSize textViewSize = [self frameForText:txtV.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] constrainedToSize:CGSizeMake(242, CGFLOAT_MAX)];
        
        txtV.frame = CGRectMake(txtV.frame.origin.x, txtV.frame.origin.y, 242, textViewSize.height);
        
        //NSString *extension = [[commentObj.commenter.imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        
        if (commentObj.commenter.imagePath) {
            
            [image sd_setImageWithURL:[NSURL URLWithString:[[DTO sharedDTO] fixLink:commentObj.commenter.imagePath]]
                    placeholderImage:[UIImage imageNamed:@"user_icon_180x180"]];
        }
        
    }
    else if([objct isKindOfClass:[NSString class]]){
    
        
    /*
        NSDictionary *dict = (NSDictionary *)objct;
        
        double timestamp = [[dict objectForKey:@"timestamp"] doubleValue];
        double now_timestamp = [[NSDate date] timeIntervalSince1970];
        
        date.text = [self dailyLanguage:now_timestamp-timestamp];
        
        NSString *comment = [dict objectForKey:@"comment"];
        txtV.text = comment;
        
        name.text = [[NSString stringWithFormat:@"%@ %@",commentObj.commenter.name,commentObj.commenter.lastname] capitalizedString];
        
        CGSize textViewSize = [self frameForText:txtV.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13] constrainedToSize:CGSizeMake(242, CGFLOAT_MAX)];
        
        txtV.frame = CGRectMake(txtV.frame.origin.x, txtV.frame.origin.y, 242, textViewSize.height);
        
        NSString *extension = [[commentObj.commenter.imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        
        NSString *imageName = [NSString stringWithFormat:@"%@.%@",[commentObj.commenter.imagePath MD5],extension];
        
        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
        
        if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
            image.image = nil;
            UIImage *img = [UIImage imageWithContentsOfFile:localPath];
            image.image = img;
        }
        else{
            image.image = nil;
            [pendingImagesDict setObject:indexPath forKey:imageName];
            [[DTO sharedDTO]downloadImageFromURL:commentObj.commenter.imagePath];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(imageDownloadFinished:) name:imageName object:nil];
        }
*/
    }
    
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    id objct = [comments objectAtIndex:indexPath.row];
    if ([objct isKindOfClass:[Comments class]]) {
        
        Comments *commentObj = (Comments *)objct;
        NSString *comment = commentObj.comment.comment;
        if (comment == nil) {
            comment = [commentObj.userCommentDict objectForKey:@"comment"];
        }
        
        CGSize textViewSize = [self frameForText:comment sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13] constrainedToSize:CGSizeMake(242, CGFLOAT_MAX)];
        
        return (textViewSize.height + 36 + 8);
    }
    else{
        return 60;
    }
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
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

#pragma mark - Compose


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
        tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard:)];
        [self.tableV addGestureRecognizer:tapG];
    }
    else{
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
                         self.tableV.frame = CGRectMake(self.tableV.frame.origin.x, self.tableV.frame.origin.y, self.tableV.frame.size.width, newContainerFrame.origin.y);
                     }
                     completion:^(BOOL finished)
                    {
                        if (comments.count > 0) {
                            [self.tableV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[comments count]-1 inSection:0]
                                               atScrollPosition:UITableViewScrollPositionBottom
                                                       animated:YES];
                        }
                    }];
}

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView {
    NSString *text = [NSString stringWithFormat:@"%@", [composeBarView text]];
    
    if ([self.event_beeep_object isKindOfClass:[Timeline_Object class]]) {
        Timeline_Object *t = self.event_beeep_object;
        
        [[EventWS sharedBP]postComment:text BeeepId:t.beeep.beeepInfo.weight user:t.beeep.userId WithCompletionBlock:^(BOOL completed,NSArray *objs){
            if (completed) {
                
                NSString *name = [[BPUser sharedBP].user objectForKey:@"name"];
                NSString *surname = [[BPUser sharedBP].user objectForKey:@"lastname"];
                NSString *myID = [[BPUser sharedBP].user objectForKey:@"id"];
                Comments *c = [[Comments alloc]init];
                
                c.comment = [[Comment alloc]init];
                c.comment.comment = text;
                c.comment.timestamp = [[NSDate date]timeIntervalSince1970];
                
                c.commenter = [[Commenter alloc]init];
                c.commenter.name = name;
                c.commenter.lastname = surname;
                c.commenter.imagePath = [NSString stringWithFormat:@"//assets.beeeper.com/img/user/%@.jpg",myID];
                
                [comments addObject:c];
                
                [self.tableV reloadData];
                [self prependTextToTextView:text];
                [composeBarView setText:@"" animated:YES];
                [composeBarView resignFirstResponder];

            }
            else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
            }
        }];
        
    }
    else if ([self.event_beeep_object isKindOfClass:[Friendsfeed_Object class]]){
        Friendsfeed_Object *ffo = self.event_beeep_object;
        NSString *userID = ffo.beeepFfo.userId;
        if (userID == nil) {
            userID = ffo.whoFfo.whoFfoIdentifier;
        }
        
        Beeeps *b = [ffo.beeepFfo.beeeps objectAtIndex:0];
        NSString *weight = b.weight;
        
        [[EventWS sharedBP]postComment:text BeeepId:weight user:userID WithCompletionBlock:^(BOOL completed,NSArray *objs){
            if (completed) {
                
                NSString *name = [[BPUser sharedBP].user objectForKey:@"name"];
                NSString *surname = [[BPUser sharedBP].user objectForKey:@"lastname"];
                NSString *myID = [[BPUser sharedBP].user objectForKey:@"id"];
                Comments *c = [[Comments alloc]init];
                
                c.comment = [[Comment alloc]init];
                c.comment.comment = text;
                c.comment.timestamp = [[NSDate date]timeIntervalSince1970];
                
                c.commenter = [[Commenter alloc]init];
                c.commenter.name = name;
                c.commenter.lastname = surname;
                c.commenter.imagePath = [NSString stringWithFormat:@"//assets.beeeper.com/img/user/%@.jpg",myID];
                
                [comments addObject:c];
                
                [self.tableV reloadData];
                [self prependTextToTextView:text];
                [composeBarView setText:@"" animated:YES];
                [composeBarView resignFirstResponder];
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
            }
        }];
       
    }
    else if ([self.event_beeep_object isKindOfClass:[Event_Search class]]){
        Event_Search *event = self.event_beeep_object;
        
        [[EventWS sharedBP]postComment:text Event:event.fingerprint WithCompletionBlock:^(BOOL completed,NSArray *objs){
            if (completed) {
                
                NSString *name = [[BPUser sharedBP].user objectForKey:@"name"];
                NSString *surname = [[BPUser sharedBP].user objectForKey:@"lastname"];
                NSString *myID = [[BPUser sharedBP].user objectForKey:@"id"];
                Comments *c = [[Comments alloc]init];
                
                c.comment = [[Comment alloc]init];
                c.comment.comment = text;
                c.comment.timestamp = [[NSDate date]timeIntervalSince1970];
                
                c.commenter = [[Commenter alloc]init];
                c.commenter.name = name;
                c.commenter.lastname = surname;
                c.commenter.imagePath = [NSString stringWithFormat:@"//assets.beeeper.com/img/user/%@.jpg",myID];
                
                [comments addObject:c];
                
                [self.tableV reloadData];
                [self prependTextToTextView:text];
                [composeBarView setText:@"" animated:YES];
                [composeBarView resignFirstResponder];
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
            }
        }];

    }
    else if ([self.event_beeep_object isKindOfClass:[Activity_Object class]]){
        Activity_Object *activity = self.event_beeep_object;
        
        NSString *fingerprint;
        
        if(activity.eventActivity.count > 0){
            EventActivity *event = [activity.eventActivity firstObject];
            fingerprint = event.fingerprint;
        }
        else if(activity.beeepInfoActivity.eventActivity.count >0){
            EventActivity *event = [activity.beeepInfoActivity.eventActivity firstObject];
            fingerprint = event.fingerprint;
        }
        
        [[EventWS sharedBP]postComment:text Event:fingerprint WithCompletionBlock:^(BOOL completed,NSArray *objs){
            if (completed) {
                
                NSString *name = [[BPUser sharedBP].user objectForKey:@"name"];
                NSString *surname = [[BPUser sharedBP].user objectForKey:@"lastname"];
                NSString *myID = [[BPUser sharedBP].user objectForKey:@"id"];
                Comments *c = [[Comments alloc]init];
                
                c.comment = [[Comment alloc]init];
                c.comment.comment = text;
                c.comment.timestamp = [[NSDate date]timeIntervalSince1970];
                
                c.commenter = [[Commenter alloc]init];
                c.commenter.name = name;
                c.commenter.lastname = surname;
                c.commenter.imagePath = [NSString stringWithFormat:@"//assets.beeeper.com/img/user/%@.jpg",myID];
                
                [comments addObject:c];
                
                [self.tableV reloadData];
                [self prependTextToTextView:text];
                [composeBarView setText:@"" animated:YES];
                [composeBarView resignFirstResponder];
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
            }
        }];
        
    }else if ([self.event_beeep_object isKindOfClass:[Suggestion_Object class]]){
        
        Suggestion_Object *event = self.event_beeep_object;
        
        [[EventWS sharedBP]postComment:text Event:event.what.fingerprint WithCompletionBlock:^(BOOL completed,NSArray *objs){
            if (completed) {
                
                NSString *name = [[BPUser sharedBP].user objectForKey:@"name"];
                NSString *surname = [[BPUser sharedBP].user objectForKey:@"lastname"];
                NSString *myID = [[BPUser sharedBP].user objectForKey:@"id"];
                Comments *c = [[Comments alloc]init];

                c.comment = [[Comment alloc]init];
                c.comment.comment = text;
                c.comment.timestamp = [[NSDate date]timeIntervalSince1970];
                
                c.commenter = [[Commenter alloc]init];
                c.commenter.name = name;
                c.commenter.lastname = surname;
                c.commenter.imagePath = [NSString stringWithFormat:@"//assets.beeeper.com/img/user/%@.jpg",myID];
                
                [comments addObject:c];
                
                [self.tableV reloadData];
                [self prependTextToTextView:text];
                [composeBarView setText:@"" animated:YES];
                [composeBarView resignFirstResponder];
                
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
            }
        }];

    }
    else if ([self.event_beeep_object isKindOfClass:[Beeep_Object class]]) {
        Beeep_Object *t = self.event_beeep_object;
        
        [[EventWS sharedBP]postComment:text BeeepId:t.weight user:[[BPUser sharedBP].user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
            if (completed) {
                
                NSString *name = [[BPUser sharedBP].user objectForKey:@"name"];
                NSString *surname = [[BPUser sharedBP].user objectForKey:@"lastname"];
                NSString *myID = [[BPUser sharedBP].user objectForKey:@"id"];
                Comments *c = [[Comments alloc]init];
                
                c.comment = [[Comment alloc]init];
                c.comment.comment = text;
                c.comment.timestamp = [[NSDate date]timeIntervalSince1970];
                
                c.commenter = [[Commenter alloc]init];
                c.commenter.name = name;
                c.commenter.lastname = surname;
                c.commenter.imagePath = [NSString stringWithFormat:@"//assets.beeeper.com/img/user/%@.jpg",myID];
                
                [comments addObject:c];
                
                [self.tableV reloadData];
                [self prependTextToTextView:text];
                [composeBarView setText:@"" animated:YES];
                [composeBarView resignFirstResponder];
                
            }
            else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
            }
        }];
        
    }
    
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

-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName inDirectory:(NSString *)directoryPath {
    
    if ([imageName rangeOfString:@"n/a"].location != NSNotFound) {
        return;
    }
    
    if ([[imageName lowercaseString] rangeOfString:@".png"].location != NSNotFound) {
        [UIImagePNGRepresentation(image) writeToFile:directoryPath options:NSAtomicWrite error:nil];
        NSLog(@"Saved Image: %@",imageName);
        
    } else {
        
        BOOL write = [UIImageJPEGRepresentation(image, 1) writeToFile:directoryPath options:NSAtomicWrite error:nil];
        NSLog(@"Saved Image: %@ - %d",directoryPath,write);
        
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:imageName object:nil userInfo:[NSDictionary dictionaryWithObject:imageName forKey:@"imageName"]];
}


@end
