//
//  FindFriendsVC.m
//  Beeeper
//
//  Created by User on 3/12/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "FindFriendsVC.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "TimelineVC.h"
#import <AddressBook/AddressBook.h>

#define BeeeperButton 0
#define FacebookButton 1
#define TwitterButton 2
#define MailButton 3


@interface FindFriendsVC ()<UISearchBarDelegate,UISearchDisplayDelegate,UIActionSheetDelegate>
{
    int selectedOption;
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
    UIView *headerView;
    NSIndexPath *actionSheetIndexPath;
    NSMutableDictionary *pendingImagesDict;
    
    int page;
    int pageLimit;
    
    NSMutableArray *searchedPeople;
    UIGestureRecognizer* cancelGesture;
    
    NSMutableArray *selectedPeople;
    NSArray *adressBookPeople;
    NSString *searchStr;
    BOOL loadNextPage;
    NSMutableArray *rowsToReload;

}
@end

@implementation FindFriendsVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    pendingImagesDict = [NSMutableDictionary dictionary];
    rowsToReload = [NSMutableArray array];
    selectedPeople = [NSMutableArray array];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];

    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideTabbar" object:self];
    
    self.tableView.decelerationRate = 0.6;
    
    //search
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    /*the search bar widht must be > 1, the height must be at least 44
     (the real size of the search bar)*/
    searchBar.barTintColor = [UIColor whiteColor];
    searchBar.delegate = self;
    
    searchBar.layer.borderWidth = 1;
    searchBar.layer.borderColor = [[UIColor colorWithRed:218/255.0 green:223/255.0 blue:226/255.0 alpha:1.0] CGColor];
    
//    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
//    /*contents controller is the UITableViewController, this let you to reuse
//     the same TableViewController Delegate method used for the main table.*/
//    
//    searchDisplayController.delegate = self;
//    searchDisplayController.searchResultsDataSource = self;
//    searchDisplayController.searchResultsDelegate = self;
    //set the delegate = self. Previously declared in ViewController.h
    
    //on the top of tableView
    
    UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 124)];
    headerV.backgroundColor = [UIColor colorWithRed:218/255.0 green:223/255.0 blue:226/255.0 alpha:1.0];
    
    //Buttons
    
    for (int i = 0; i <= 3; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(i*81, 0, 80, 80)];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"option_%d_gray",i]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"option_%d",i]] forState:UIControlStateSelected];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"option_%d",i]] forState:UIControlStateHighlighted];
        [btn setBackgroundColor:[UIColor whiteColor]];
        btn.tag = i;
        [btn addTarget:self action:@selector(optionSelectedFromHeader:) forControlEvents:UIControlEventTouchUpInside];
        [headerV addSubview:btn];
        
        if (i == 0) {
            [btn setSelected:YES];
        }
    }
    searchBar.frame = CGRectMake(0, 80, searchBar.frame.size.width, searchBar.frame.size.height);
    
    [headerV addSubview:searchBar];
    
    headerView = headerV;

    self.tableView.tableHeaderView = headerView;

    page = 0;
    loadNextPage = YES;

    [self getPeople:@"" WithCompletionBlock:^(BOOL completed,NSArray *objcts){
        
        if (completed) {
            
            if (objcts.count > 0) {
                loadNextPage = YES;
                searchedPeople = [NSMutableArray arrayWithArray:objcts];
            }
        }
        NSRange range = NSMakeRange(0, 1);
        NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
    }];
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getBeeeperUsers{
    
    page = 0;
    loadNextPage = YES;
    
    [self getPeople:searchBar.text WithCompletionBlock:^(BOOL completed,NSArray *objcts){
        
        if (completed) {
         
            if (objcts > 0) {
                loadNextPage = YES;
                searchedPeople = [NSMutableArray arrayWithArray:objcts];
            }
        }
        
        NSRange range = NSMakeRange(0, 1);
        NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationFade];

    }];
}

-(void)optionSelectedFromHeader:(UIButton *)btn{
    
    [selectedPeople removeAllObjects];
    
    switch (btn.tag) {
        case 0:
            [self getBeeeperUsers];
            break;

        case 1:{ //fb friends
            
            [self requestFBFriends];
            break;
        }
        case 2:
            
            break;
        case 3:
            [self showAddressBook];
            break;
            
        default:
            break;
    }
    
    
    [UIView transitionWithView:self.view
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [btn setSelected:YES];
                    } completion:nil];
    
    selectedOption = (int)btn.tag;
    
    for (UIButton *btn in [headerView subviews]) {
        if (btn.tag != selectedOption && [btn isKindOfClass:[UIButton class]]) {
            
            [UIView transitionWithView:self.view
                              duration:0.2
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [btn setSelected:NO];
                            } completion:nil];
        }
    }
    
}

-(void)showAddressBook{
  
    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
        if (!granted){
            //4

            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Access Denied" message:@"Please allow Beeeper to access your Adress Book." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
            return;
        }
        //5
        
        CFErrorRef errorr = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &errorr);
        NSInteger numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        
        NSMutableArray *contacts = [NSMutableArray array];
        
        for (NSInteger i = 0; i < numberOfPeople; i++) {
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
            
            NSString *firstName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            NSString *lastName  = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));

            ABMultiValueRef emailMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty);
            NSArray *emailAddresses = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailMultiValue);
            CFRelease(emailMultiValue);

            if (emailAddresses.count > 0) {
                NSLog(@"Name:%@ %@ Email: %@", firstName, lastName ,emailAddresses);
                
                NSMutableDictionary *p = [NSMutableDictionary dictionary];
                
                if(ABPersonHasImageData(person)) {
                    
                    NSData *contactImageData = (__bridge NSData*) ABPersonCopyImageDataWithFormat(person,
                                                                                                  kABPersonImageFormatThumbnail);
                    UIImage *img = [[UIImage alloc] initWithData:contactImageData];
                    [p setObject:img forKey:@"image"];

                }
                
                if (firstName != nil) {
                    [p setObject:firstName forKey:@"name"];
                }
                if (lastName != nil) {
                    [p setObject:lastName forKey:@"lastname"];
                }
                
                [p setObject:emailAddresses forKey:@"emails"];
                
                [contacts addObject:p];
                
//                ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
//                
//                CFIndex numberOfPhoneNumbers = ABMultiValueGetCount(phoneNumbers);
//                for (CFIndex i = 0; i < numberOfPhoneNumbers; i++) {
//                    NSString *phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phoneNumbers, i));
//                }
//                
//                CFRelease(phoneNumbers);

                NSLog(@"=============================================");
            }
            
        }
        
        CFRelease(allPeople);
        
        adressBookPeople = [NSMutableArray arrayWithArray:contacts];
        searchedPeople = [NSMutableArray arrayWithArray:adressBookPeople];
        [self.tableV performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    });
}

-(void)requestFBFriends{
   
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        [self makeRequestForUserFriends];
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        // [FBSession.activeSession closeAndClearTokenInformation];
        
        //AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
        // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
        //[appDelegate sessionStateChanged:FBSession.activeSession state:FBSession.activeSession.state error:NULL];
        
        // If the session state is not any of the two "open" states when the button is clicked
    }
    
    
    else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for basic_info permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"user_friends",@"user_events"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Retrieve the app delegate
             AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
             
             if (FBSessionStateOpen == state) {
                 [self makeRequestForUserFriends];
             }
             else{

             }
             
         }];
    }
}

-(void)makeRequestForUserFriends{
 
    [FBRequestConnection startWithGraphPath:@"/me/friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                             
                          }];

}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.backItem.title = @"";
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
   return (searchedPeople.count>0 && loadNextPage)?(searchedPeople.count+1):searchedPeople.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier;
    UITableViewCell *cell;
    
    if (indexPath.row == searchedPeople.count) {
        
        CellIdentifier = @"LoadMoreCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UIActivityIndicatorView *indicator = (id)[cell viewWithTag:55];
        [indicator startAnimating];

        [self nextPage];
        
        return cell;
        
    }
    
    CellIdentifier = @"Cell";
    cell = [self.tableV dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UITextField *txtF = (id)[cell viewWithTag:1];
    txtF.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    
    UIImageView *userImage = (id)[cell viewWithTag:2];
    UIButton *followBtn = (id)[cell viewWithTag:3];
    UITextField *emailtxtF = (id)[cell viewWithTag:4];
    UIImageView *tickedV = (id)[cell viewWithTag:5];

    NSDictionary *user = [searchedPeople objectAtIndex:indexPath.row];
    
     if (selectedOption != MailButton) {
    
         if ([[user objectForKey:@"id"]isEqualToString:[[BPUser sharedBP].user objectForKey:@"id"]]) {
             followBtn.hidden = YES;
             tickedV.hidden = YES;
         }
         else{
         
            followBtn.hidden = NO;
            tickedV.hidden = YES;
             
            NSNumber *following = (NSNumber *)[user objectForKey:@"following"];
            
            if (following.boolValue) {
                [followBtn setImage:[UIImage imageNamed:@"following-icon.png"] forState:UIControlStateNormal] ;
            }
            else{
                [followBtn setImage:[UIImage imageNamed:@"not-following-icon.png"] forState:UIControlStateNormal] ;
            }
         }
     }
     else{
         
         tickedV.hidden = NO;
         followBtn.hidden = YES;
         
         if ([selectedPeople indexOfObject:user] != NSNotFound) {
             [tickedV setImage:[UIImage imageNamed:@"suggest_selected"]];
         }
         else{
             [tickedV setImage:[UIImage imageNamed:@"suggest_unselected"]];
         }
     }
    
    
    
    NSString *name =[user objectForKey:@"name"];
    NSString *lastname =[user objectForKey:@"lastname"];

    NSArray *emails= [user objectForKey:@"emails"];
    NSMutableString *emailsStr = [[NSMutableString alloc]init];
    
    if (emails.count > 0) {

        for (NSString *email in emails) {
            [emailsStr appendFormat:@"%@ ,",email];
        }
        [emailsStr deleteCharactersInRange:NSMakeRange([emailsStr length]-1, 1)];
        
    }
       if (name && lastname) {
        txtF.text = [NSString stringWithFormat:@"%@ %@",[user objectForKey:@"name"],[user objectForKey:@"lastname"]];
    }
    else if(name == nil && lastname == nil && emails.count > 0){
       
        txtF.text = emailsStr;
    }
    else{
        txtF.text = [NSString stringWithFormat:@"%@",([user objectForKey:@"name"])?[user objectForKey:@"name"]:[user objectForKey:@"lastname"]];
    }

    emailtxtF.text = emailsStr;
    
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *imagePath = [user objectForKey:@"image_path"];
    
    @try {
    
        if (imagePath != nil && ![imagePath isKindOfClass:[NSNull class]]) {
            
            //NSString *extension = [[imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
            
            NSString *imageName = [NSString stringWithFormat:@"%@",[imagePath MD5]];
            
            NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
            
            if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
                userImage.backgroundColor = [UIColor clearColor];
                userImage.image = nil;
                UIImage *img = [UIImage imageWithContentsOfFile:localPath];
                userImage.image = img;
            }
            else{
                userImage.backgroundColor = [UIColor lightGrayColor];
                userImage.image = nil;
                [pendingImagesDict setObject:indexPath forKey:imageName];
                [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(imageDownloadFinished:) name:imageName object:nil];
            }
            
        }
        else{
            
            userImage.image = nil;
            
            UIImage *imageContact = [user objectForKey:@"image"];
            if (imageContact != nil) {
                userImage.image = imageContact;
                userImage.backgroundColor = [UIColor clearColor];
            }
            else{
                userImage.backgroundColor = [UIColor colorWithRed:201/255.0 green:201/255.0 blue:201/255.0 alpha:1];
            }
            
        }
        
        

    }
    @catch (NSException *exception) {
        NSLog(@"provlima");
    }
    @finally {
        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *tickedV = (id)[cell viewWithTag:5];

    if (selectedOption == MailButton) {

    
        NSDictionary *user = [searchedPeople objectAtIndex:indexPath.row];
        
        if ([selectedPeople indexOfObject:user] == NSNotFound) {
            [selectedPeople addObject:user];
            tickedV.alpha = 0;
            tickedV.hidden = NO;
            
            [UIView animateWithDuration:0.0f
                             animations:^
             {
                 tickedV.alpha = 0;
             }
                             completion:^(BOOL finished)
             {
                 [tickedV setImage:[UIImage imageNamed:@"suggest_selected"]];
                 
                 [UIView animateWithDuration:0.0f
                                  animations:^
                  {
                      tickedV.alpha = 1;
                  }
                                  completion:^(BOOL finished)
                  {
                  }
                  ];
             }
             ];
            
        }
    }
    else{
        
        TimelineVC *timelineVC = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"TimelineVC"];
        timelineVC.mode = Timeline_Not_Following;
        timelineVC.showBackButton = YES; //in case of My_Timeline
        NSDictionary *user = [searchedPeople objectAtIndex:indexPath.row];
        timelineVC.user = user;
        
        [self.navigationController pushViewController:timelineVC animated:YES];
    }
   
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == searchedPeople.count) {
        return 40;
    }
    else{
        return 61;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 303, 1)];
    header.backgroundColor = [UIColor clearColor];
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

-(void)imageDownloadFinished:(NSNotification *)notif{
    
    NSString *imageName  = [notif.userInfo objectForKey:@"imageName"];
    
    NSArray* rows = [NSArray arrayWithObjects:[pendingImagesDict objectForKey:imageName], nil];
    
    [rowsToReload addObjectsFromArray:rows];
    [pendingImagesDict removeObjectForKey:imageName];
    
    if (rowsToReload.count == 5  || pendingImagesDict.count < 5) {
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

#pragma mark - UISearchDisplayController

- (void) backgroundTouched:(id)sender {
    [searchBar resignFirstResponder];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    cancelGesture = [UITapGestureRecognizer new];
    [cancelGesture addTarget:self action:@selector(backgroundTouched:)];
    [self.tableV addGestureRecognizer:cancelGesture];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    if (cancelGesture) {
        [self.tableV removeGestureRecognizer:cancelGesture];
        cancelGesture = nil;
    }
}



- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    
    if (selectedOption == BeeeperButton) {

        page = 0;
        loadNextPage = YES;

        [self getPeople:@"" WithCompletionBlock:^(BOOL completed,NSArray *objcts){
            
            if (completed) {
                if (objcts > 0) {
                    loadNextPage = YES;
                    searchedPeople = [NSMutableArray arrayWithArray:objcts];
                }
             }

            NSRange range = NSMakeRange(0, 1);
            NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
            [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
        }];
    }
    else if (selectedOption == MailButton){
        searchedPeople = [NSMutableArray arrayWithArray:adressBookPeople];
        [self.tableV reloadData];
    }
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString* searchText = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    
    [self filterContentForSearchText:searchText scope:nil];
    
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
     if (selectedOption == BeeeperButton) {
        
         page = 0;
         
        [self getPeople:searchText WithCompletionBlock:^(BOOL completed,NSArray *objcts){
            
            if (completed) {
                
                if (objcts.count > 0) {
                    searchedPeople = [NSMutableArray arrayWithArray:objcts];
                }
            }
            
            NSRange range = NSMakeRange(0, 1);
            NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
            [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
    
        }];
     }
     else if (selectedOption == MailButton){
       
         if (searchText.length > 0) {
             searchedPeople = [NSMutableArray arrayWithArray:[adressBookPeople filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name BEGINSWITH[cd] %@)", searchText]]];
         }
         else{
          searchedPeople = [NSMutableArray arrayWithArray:adressBookPeople];
         }

         [self.tableV reloadData];
     }
}

-(void)nextPage{

    if (!loadNextPage) {
        return;
    }
    
    loadNextPage = NO;
    page++;
    
    [self getPeople:searchStr WithCompletionBlock:^(BOOL completed,NSArray *objcts){
        
        if (completed) {
            
            if (objcts.count > 0) {
                loadNextPage = YES;
                [searchedPeople addObjectsFromArray:objcts];
            }
        }
        
        [self.tableView reloadData];

    }];
}

-(void)getPeople:(NSString *)searchString WithCompletionBlock:(completed)compbloc{
    
    self.search_completed = compbloc;
    searchStr = searchString;
    
    pageLimit = 20;
    
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/user/search"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/user/search?"];
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"count=%d",pageLimit]];
    [array addObject:[NSString stringWithFormat:@"page=%d",page]];
    [array addObject:[NSString stringWithFormat:@"q=%@",searchString]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerGETRequest:URL values:array]];
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    //[[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(getPeopleFinished:)];
    
    [request setDidFailSelector:@selector(getPeopleFailed:)];
    
    [request startAsynchronous];
    
}

-(void)getPeopleFinished:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];

    NSArray *people = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    for (NSDictionary *user in people) {
        NSArray *keys = user.allKeys;
        NSString *imagePath = [user objectForKey:@"image_path"];
        [[DTO sharedDTO]downloadImageFromURL:imagePath];
    }
    
    self.search_completed(YES,people);
}

-(void)getPeopleFailed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    self.search_completed(NO,nil);
}

- (IBAction)rightButtonPressed:(UIButton *)sender {
    
    UITableViewCell *cell = (UITableViewCell *)sender.superview.superview.superview;
    NSIndexPath *path = [self.tableV indexPathForCell:cell];
    
    NSDictionary *user = [searchedPeople objectAtIndex:path.row];
    
    NSNumber *following = (NSNumber *)[user objectForKey:@"following"];
    
    if (following.boolValue) {
        
        NSString *username = [[NSString stringWithFormat:@"%@ %@",[user objectForKey:@"name"],[user objectForKey:@"lastname"]] capitalizedString];
        
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:username delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Unfollow" otherButtonTitles:nil];
        [popup showInView:self.view];
        actionSheetIndexPath = path;
    }
    else{
        
        //follow user
        [[BPUser sharedBP]follow:[user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
            if (completed) {
                
                NSMutableDictionary *newUser = [NSMutableDictionary dictionaryWithDictionary:user];
                [newUser setObject:@"1" forKey:@"following"];

                [searchedPeople replaceObjectAtIndex:path.row withObject:newUser];
                NSArray* rowsToReload = [NSArray arrayWithObjects:path, nil];
                
                [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
                
            }
        }];
        
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        
        
        NSDictionary *user = [searchedPeople objectAtIndex:actionSheetIndexPath.row];
        
        [[BPUser sharedBP]unfollow:[user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
            if (completed) {
                
                NSMutableDictionary *newUser = [NSMutableDictionary dictionaryWithDictionary:user];
                [newUser setObject:@"0" forKey:@"following"];
                
                [searchedPeople replaceObjectAtIndex:actionSheetIndexPath.row withObject:newUser];
                NSArray* rowsToReload = [NSArray arrayWithObjects:actionSheetIndexPath, nil];
                
                [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
                
            }
            
            actionSheetIndexPath = nil;
        }];
        
    }
}

@end
