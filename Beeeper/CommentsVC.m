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

@interface CommentsVC ()<PHFComposeBarViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableDictionary *pendingImagesDict;
    UITapGestureRecognizer *tapG;
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
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideTabbar" object:self];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;

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

    self.kInitialViewFrame = CGRectMake(0, self.view.frame.size.height-44, 320, 44);
    
    UIView *container = [self container];
    [container addSubview:[self composeBarView]];
    [self.view addSubview:container];

}

-(void)viewWillDisappear:(BOOL)animated{
   // [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.tableV reloadData];
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
    
    
    Comments *objct = [comments objectAtIndex:indexPath.row];
    
    if ([objct isKindOfClass:[Comments class]]) {
    
        if (objct.userCommentDict == nil) {
            
            double timestamp = objct.comment.timestamp;
            double now_timestamp = [[NSDate date] timeIntervalSince1970];
            
            date.text = [self dailyLanguage:now_timestamp-timestamp];
            
            Comments *commentObj = (Comments *)objct;
            NSString *comment = commentObj.comment.comment;
            txtV.text = comment;
            
            name.text = [[NSString stringWithFormat:@"%@ %@",commentObj.commenter.name,commentObj.commenter.lastname] capitalizedString];
            
            CGSize textViewSize = [self frameForText:txtV.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] constrainedToSize:CGSizeMake(242, CGFLOAT_MAX)];
            
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

        }
        else{
            
            date.text= @"Just Now";
            
            NSDictionary *user =  [BPUser sharedBP].user;
            
            NSString *nameStr=[objct.userCommentDict objectForKey:@"name"];
            NSString *comment=[objct.userCommentDict objectForKey:@"comment"];
            txtV.text = comment;
            name.text = nameStr;
            
            CGSize textViewSize = [self frameForText:txtV.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] constrainedToSize:CGSizeMake(242, CGFLOAT_MAX)];
            
            txtV.frame = CGRectMake(txtV.frame.origin.x, txtV.frame.origin.y, 242, textViewSize.height);
            
            NSString *imagePath = [[BPUser sharedBP].user objectForKey:@"image_path"];
            
            NSString *extension = [[imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
            
            NSString *imageName = [NSString stringWithFormat:@"%@.%@",[imagePath MD5],extension];
            
            NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
            
            if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
                UIImage *img = [UIImage imageWithContentsOfFile:localPath];
                image.image = img;
            }
            else{
                
                dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(q, ^{
                    /* Fetch the image from the server... */
                    NSString *imagePath = [[BPUser sharedBP].user objectForKey:@"image_path"];
                    imagePath = [imagePath stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[DTO sharedDTO]fixLink:imagePath]]];
                    UIImage *img = [[UIImage alloc] initWithData:data];
                    
                    [self saveImage:img withFileName:imageName inDirectory:localPath];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        /* This is the main thread again, where we set the tableView's image to
                         be what we just fetched. */
                        image.image = img;
                    });
                });
            }

        }
        
    }
    else if([objct isKindOfClass:[NSDictionary class]]){
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

-(void)imageDownloadFinished:(NSNotification *)notif{
    
    NSString *imageName  = [notif.userInfo objectForKey:@"imageName"];
    
    NSArray* rowsToReload = [NSArray arrayWithObjects:[pendingImagesDict objectForKey:imageName], nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        @try {
            [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
            [pendingImagesDict removeObjectForKey:imageName];
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    });
    
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
                     }
                     completion:NULL];
}

- (void)composeBarViewDidPressButton:(PHFComposeBarView *)composeBarView {
    NSString *text = [NSString stringWithFormat:@"%@", [composeBarView text]];
    
    if ([self.event_beeep_object isKindOfClass:[Timeline_Object class]]) {
        Timeline_Object *t = self.event_beeep_object;
        
        [[EventWS sharedBP]postComment:text BeeepId:t.beeep.beeepInfo.weight user:t.beeep.userId WithCompletionBlock:^(BOOL completed,NSArray *objs){
            if (completed) {
                
                NSMutableDictionary *commentDict = [NSMutableDictionary dictionary];
                NSString *name = [[[BPUser sharedBP].user objectForKey:@"name"] capitalizedString];
                NSString *surname = [[[BPUser sharedBP].user objectForKey:@"lastname"] capitalizedString];
                
                [commentDict setObject:[NSString stringWithFormat:@"%@ %@",name,surname] forKey:@"name"];
                [commentDict setObject:text forKey:@"comment"];
                
                Comments *c = [[Comments alloc]init];
                c.userCommentDict = commentDict;
                [comments addObject:c];

                [self.tableV reloadData];
                [self prependTextToTextView:text];
                [composeBarView setText:@"" animated:YES];
                [composeBarView resignFirstResponder];

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
                
                NSMutableDictionary *commentDict = [NSMutableDictionary dictionary];
                NSString *name = [[BPUser sharedBP].user objectForKey:@"name"];
                NSString *surname = [[BPUser sharedBP].user objectForKey:@"lastname"];
                
                [commentDict setObject:[NSString stringWithFormat:@"%@ %@",name,surname] forKey:@"name"];
                [commentDict setObject:text forKey:@"comment"];
                
                Comments *c = [[Comments alloc]init];
                c.userCommentDict = commentDict;
                [comments addObject:c];
                
                [self.tableV reloadData];
                [self prependTextToTextView:text];
                [composeBarView setText:@"" animated:YES];
                [composeBarView resignFirstResponder];
                
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
