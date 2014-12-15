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
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>

#define BeeeperButton 0
#define FacebookButton 1
#define TwitterButton 2
#define MailButton 3


@interface FindFriendsVC ()<UISearchBarDelegate,UISearchDisplayDelegate,UIActionSheetDelegate,MFMessageComposeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    int selectedOption;
    int emailInviteSelectedOption;
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
    UIView *headerView;
    NSIndexPath *actionSheetIndexPath;
    
    int page;
    
    NSMutableArray *searchedPeople;
    NSMutableArray *searchedBeeepers;
    NSMutableArray *searchedFBFriends;
    
    UIGestureRecognizer* cancelGesture;
    
    NSMutableArray *selectedPeople;
    NSMutableArray *selectedEmails;

    NSMutableArray *fbPeople;
    NSMutableArray *beeepers;
    
    NSArray *adressBookPeople;
    NSString *searchStr;
    BOOL loadNextPage;
    NSMutableArray *rowsToReload;
    UIActivityIndicatorView *activityIndicator;
    NSArray *accounts;
    NSArray *usernames;
}

@property (nonatomic,strong)  UIView *loadingView;

@end

@implementation FindFriendsVC
@synthesize loadingView,pageLimit;

- (void)viewDidLoad
{
    [super viewDidLoad];

    rowsToReload = [NSMutableArray array];
    selectedPeople = [NSMutableArray array];
    
    [self.tableV setBackgroundView:nil];
    self.tableV.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.backItem.title = @"";
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideTabbar" object:self];
    
    //self.tableV.decelerationRate = 0.6;
    
    [self createTableViewHeader];

    page = 0;
    loadNextPage = NO;
    
    [self showLoading];
    
    [self getPeople:@"" WithCompletionBlock:^(BOOL completed,NSArray *objcts){
        
        if (selectedOption == BeeeperButton) {
        
            if (completed) {
                
                if (objcts.count > 0) {
                    
                    loadNextPage = (objcts.count == pageLimit);
                    searchedPeople = [NSMutableArray arrayWithArray:objcts];
                    
                    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                    
                    [searchedPeople sortUsingDescriptors:[NSArray arrayWithObject:sort]
                     ];
                    
                    NSRange range = NSMakeRange(0, 1);
                    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
                    [self.tableV reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
                    
                    self.noUsersFoundLabel.text = @"No users found on Beeeper.";
                    self.noUsersFoundLabel.hidden = (searchedPeople.count != 0);
                }
            }
            
            [self hideLoading];
        }
    }];
}

-(void)createTableViewHeader{
    
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
    
    UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0,0, self.tableV.frame.size.width, 1)];
    [topLine setBackgroundColor:[UIColor colorWithRed:218/255.0 green:223/255.0 blue:226/255.0 alpha:1]];
    [headerV addSubview:topLine];
    
    //Buttons
    
    for (int i = 0; i <= 3; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(i*81, 1, 80, 80)];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"option_%d_gray",i]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"option_%d",i]] forState:UIControlStateSelected];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"option_%d",i]] forState:UIControlStateHighlighted];
        [btn setBackgroundColor:[UIColor whiteColor]];
        btn.tag = i;
        [btn addTarget:self action:@selector(optionSelectedFromHeader:) forControlEvents:UIControlEventTouchUpInside];
        [headerV addSubview:btn];
        
        if (i == selectedOption) {
            [btn setSelected:YES];
        }
    }
    
    searchBar.frame = CGRectMake(0, (selectedOption == MailButton)?125:80, searchBar.frame.size.width, searchBar.frame.size.height);
    
    [headerV addSubview:searchBar];
    
    UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0,80, self.tableV.frame.size.width, 1)];
    [bottomLine setBackgroundColor:[UIColor colorWithRed:218/255.0 green:223/255.0 blue:226/255.0 alpha:1]];
    [headerV addSubview:bottomLine];
    
    headerView = headerV;
    
    self.tableV.tableHeaderView = headerView;
}

-(void)createTableViewHeaderWithMailOption:(int)option{
    
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
    
    //UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, (selectedOption == MailButton)?163:124)];

    UIView *headerV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 168)];
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
        
        if (i == selectedOption) {
            [btn setSelected:YES];
        }
    }
    
    if(selectedOption == MailButton){
        
        UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0,79, self.tableV.frame.size.width, 1)];
        [topLine setBackgroundColor:[UIColor colorWithRed:218/255.0 green:223/255.0 blue:226/255.0 alpha:1]];
        
        [headerV addSubview:topLine];
        
        UIButton *inviteSmsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        inviteSmsBtn.frame = CGRectMake(0,80, self.tableV.frame.size.width/2,45);
        
        if (option == 0) {
            [inviteSmsBtn setBackgroundColor:[UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1]];
            [inviteSmsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        else{
            [inviteSmsBtn setBackgroundColor:[UIColor whiteColor]];
            [inviteSmsBtn setTitleColor:[UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1] forState:UIControlStateNormal];
        }

        [inviteSmsBtn setTitle:@"Invite via SMS" forState:UIControlStateNormal];
        
        inviteSmsBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        [inviteSmsBtn addTarget:self action:@selector(inviteSMSPressed:) forControlEvents:UIControlEventTouchUpInside];
        [headerV addSubview:inviteSmsBtn];
        
        UIButton *inviteEmailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        inviteEmailBtn.frame = CGRectMake(inviteSmsBtn.frame.size.width,80, self.tableV.frame.size.width/2,45);
        
        if (option == 0) {
            
            [inviteEmailBtn setBackgroundColor:[UIColor whiteColor]];
            [inviteEmailBtn setTitleColor:[UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1] forState:UIControlStateNormal];
        }
        else{
            [inviteEmailBtn setBackgroundColor:[UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1]];
            [inviteEmailBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
        [inviteEmailBtn setTitle:@"Invite via EMAIL" forState:UIControlStateNormal];
        
        inviteEmailBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
        [inviteEmailBtn addTarget:self action:@selector(inviteEMAILPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [headerV addSubview:inviteEmailBtn];
        
        UIView *bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0,inviteEmailBtn.frame.origin.y+inviteEmailBtn.frame.size.height, self.tableV.frame.size.width, 1)];
        [bottomLine setBackgroundColor:[UIColor colorWithRed:218/255.0 green:223/255.0 blue:226/255.0 alpha:1]];
        
        [headerV addSubview:bottomLine];
    }
    
    searchBar.frame = CGRectMake(0, (selectedOption == MailButton)?125:80, searchBar.frame.size.width, searchBar.frame.size.height);
    
    [headerV addSubview:searchBar];
    
    headerView = headerV;
    
    self.tableV.tableHeaderView = headerView;
}


-(void)inviteSMSPressed:(UIButton *)btn{
   
     self.navigationItem.rightBarButtonItem = nil;
    
    [self createTableViewHeaderWithMailOption:0];
    
    [selectedPeople removeAllObjects];
    selectedEmails = [NSMutableArray array];
    
    
    emailInviteSelectedOption = 0;
    
    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
        if (!granted){
            //4
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Access Denied" message:@"Please allow Beeeper to access your Address Book." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                
                [self hideLoading];
                
            });
            
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
            
            ABMultiValueRef phonesRef    = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
            NSMutableArray *phones = [NSMutableArray array];
            
            if(phonesRef) {
                int count = ABMultiValueGetCount(phonesRef);
                for(int ix = 0; ix < count; ix++){
                    CFStringRef typeTmp = ABMultiValueCopyLabelAtIndex(phonesRef, ix);
                    CFStringRef numberRef = ABMultiValueCopyValueAtIndex(phonesRef, ix);
                    CFStringRef typeRef = ABAddressBookCopyLocalizedLabel(typeTmp);
                    
                    NSString *phoneNumber = (__bridge NSString *)numberRef;
                    NSString *phoneType = (__bridge NSString *)typeRef;
                   
                    if (phoneType.length == 0) {
                        [phones addObject:[NSString stringWithFormat:@"%@",phoneNumber]];
                    }
                    else{
                        [phones addObject:[NSString stringWithFormat:@"%@: %@",phoneType,phoneNumber]];
                    }
                    
                    if(typeTmp) CFRelease(typeTmp);
                    if(numberRef) CFRelease(numberRef);
                    if(typeRef) CFRelease(typeRef);
                }
                CFRelease(phonesRef);
            }
            
        
            if (phones.count > 0) {
              
                NSLog(@"Name:%@ %@ Email: %@", firstName, lastName ,phones);
                
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
                
                [p setObject:phones forKey:@"phones"];
                
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self hideLoading];
            
            if (selectedOption == MailButton) {
                
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
                NSArray *contactsSorted=[contacts sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
                
                adressBookPeople = [NSMutableArray arrayWithArray:contactsSorted];
                searchedPeople = [NSMutableArray arrayWithArray:adressBookPeople];
                [self.tableV reloadData];
                
                self.noUsersFoundLabel.text = @"No contacts found on your contact list.";
                self.noUsersFoundLabel.hidden = (searchedPeople.count != 0);
            }
        });
    });
}

-(void)inviteEMAILPressed:(UIButton *)btn{
    
     self.navigationItem.rightBarButtonItem = nil;
    
    [self createTableViewHeaderWithMailOption:1];
    
    [selectedPeople removeAllObjects];
    selectedEmails = [NSMutableArray array];
    
    emailInviteSelectedOption = 1;
    
    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
        if (!granted){
            //4
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Access Denied" message:@"Please allow Beeeper to access your Address Book." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                
                [self hideLoading];
                return;
                
            });
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (selectedOption == MailButton) {
                
                [self hideLoading];
                
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
                NSArray *contactsSorted=[contacts sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
                
                adressBookPeople = [NSMutableArray arrayWithArray:contactsSorted];
                searchedPeople = [NSMutableArray arrayWithArray:adressBookPeople];
                [self.tableV reloadData];
                
                self.noUsersFoundLabel.text = @"No emails found on your contact list.";
                self.noUsersFoundLabel.hidden = (searchedPeople.count != 0);
            }

        });
    });
}

-(void)goBack{
    
    if (self.hideNavigationBarOnClose) {
        
        [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getBeeeperUsers{

    page = 0;
    loadNextPage = NO;
    
    [self getPeople:searchBar.text WithCompletionBlock:^(BOOL completed,NSArray *objcts){
        
        if (completed) {
         
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (objcts > 0) {
                    
                    if (selectedOption == BeeeperButton) {
                      
                        loadNextPage = (objcts.count == pageLimit);
                        searchedPeople = [NSMutableArray arrayWithArray:objcts];
                        
                        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                        
                        [searchedPeople sortUsingDescriptors:[NSArray arrayWithObject:sort]
                         ];
                        
                        [self.tableV reloadData];
                        
                        self.noUsersFoundLabel.text = @"No users found on Beeeper.";
                        self.noUsersFoundLabel.hidden = (searchedPeople.count != 0);
                    }
                }
          });
        }
        
        [self hideLoading];
    }];
}

-(void)optionSelectedFromHeader:(UIButton *)btn{
    
    selectedOption = (int)btn.tag;
    
    if (selectedOption == MailButton) {
        [self createTableViewHeaderWithMailOption:0];
    }
    else{
        [self createTableViewHeader];
    }
    
    selectedEmails = [NSMutableArray array];
    
    searchBar.text = @"";
    self.navigationItem.rightBarButtonItem = nil;
    
    [self showLoading];
    
    switch (btn.tag) {
        case 0:
            [self getBeeeperUsers];
            break;

        case 1:{ //fb friends
            
            [self requestFBFriends];
            break;
        }
        case 2:
            [self requestTWFriends];
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

-(void)showLoading{
    
    dispatch_async (dispatch_get_main_queue(), ^{
     
        self.noUsersFoundLabel.hidden = YES;
        
        if (loadingView != nil) {
            [loadingView removeFromSuperview];
            loadingView = nil;
        }
        
        [searchedPeople removeAllObjects];
        [fbPeople removeAllObjects];
        [beeepers removeAllObjects];
        
        [self.tableV reloadData];
        
        loadingView = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
        loadingView.userInteractionEnabled = NO;
        [loadingView setBackgroundColor:[UIColor clearColor]];
        activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [loadingView addSubview:activityIndicator];
        activityIndicator.center =loadingView.center;
        
        [self.view addSubview:loadingView];
        [self.view bringSubviewToFront:loadingView];
        [activityIndicator startAnimating];
        
    });
}

-(void)hideLoading{
    
    dispatch_async (dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.2f
                         animations:^
         {
             loadingView.alpha = 0;
         }
                         completion:^(BOOL finished)
         {
             [loadingView removeFromSuperview];
             loadingView = nil;
         }
         ];

    });
    
}

-(void)showAddressBook{
    
    if (emailInviteSelectedOption == 0) {
        [self inviteSMSPressed:nil];
    }
    else{
        [self inviteEMAILPressed:nil];
    }
}

-(void)requestFBFriends{
    
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        
        ACAccountStore *accountStore = [[ACAccountStore alloc] init]; // you have to retain ACAccountStore
        
        ACAccountType *fbAcc = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        
        NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"222125061288499", ACFacebookAppIdKey,
                                 [NSArray arrayWithObjects:@"email",@"user_friends",nil], ACFacebookPermissionsKey,
                                 nil];

        
        [accountStore requestAccessToAccountsWithType:fbAcc options:options completion:^(BOOL granted, NSError *error)
         {
             if (granted)
             {
              
                 accounts = [NSArray arrayWithArray:[accountStore accountsWithAccountType:fbAcc]];
                 usernames = [NSArray arrayWithArray:[accounts valueForKey:@"username"]];
                 
                 if (usernames.count == 0) {
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         [self hideLoading];
                         
                         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No accounts found" message:@"Please go to Settings > Facebook and sign in with your Facebook account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                     });
                     
                     
                     return ;
                 }

                
                 if (usernames.count > 1) {
                 
                     [self hideLoading];
                     
                     UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
                     
                     popup.tag = 55;
                     
                     for (NSString *name in usernames) {
                         [popup addButtonWithTitle:name];
                     }
                     
                     [popup addButtonWithTitle:@"Cancel"];
                     
                     popup.cancelButtonIndex = popup.numberOfButtons -1;
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [popup showInView:self.view];
                     });
                 }
                 else{
                 
                     ACAccount *facebookAccount = [accounts firstObject];
                  
                     [self requestFBFriendsForAccount:facebookAccount];
                 }
             }
             else{
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     NSLog(@"%@",error);
                     
                     [self hideLoading];
                     
                     UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Facebook Access was denied" message:(error)?error.localizedDescription:@"Please go to Settings > Facebook and enable Beeeper." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                 });
             }
         }];
        
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self hideLoading];
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No accounts found" message:@"Please go to Settings > Facebook and sign in with your Facebook account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        });
    }
}

-(void)requestFBFriendsForAccount:(ACAccount *)facebookAccount{
    
    [self showLoading];
    
    NSString *accessToken = [NSString stringWithFormat:@"%@",facebookAccount.credential.oauthToken];
    NSDictionary *parameters = @{@"access_token": accessToken,@"fields":@"id,name"};
    NSURL *feedURL = [NSURL URLWithString:@"https://graph.facebook.com/me/friends"];
    SLRequest *feedRequest = [SLRequest
                              requestForServiceType:SLServiceTypeFacebook
                              requestMethod:SLRequestMethodGET
                              URL:feedURL
                              parameters:parameters];
    feedRequest.account = facebookAccount;
    [feedRequest performRequestWithHandler:^(NSData *responseData,
                                             NSHTTPURLResponse *urlResponse, NSError *error)
     {
         
         NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseData
                                                                            options:0 error:NULL];
         NSArray *friends = [responseDictionary objectForKey:@"data"];
         
         NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
         friends=[friends sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
         NSArray *fb_ids = [friends valueForKey:@"id"];
         NSString *friendStr = [fb_ids componentsJoinedByString:@","];
         
         fbPeople = [NSMutableArray arrayWithArray:friends];
         searchedFBFriends = [NSMutableArray arrayWithArray:friends];
         
         
         [[BPUser sharedBP]beeepersFromFB_IDs:friendStr WithCompletionBlock:^(BOOL completed,NSArray *objcts){
             
             if (selectedOption == FacebookButton) {
                
                 if (completed) {
                     
                     if (objcts && objcts.count>0) {
                         
                         NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
                         NSArray *friends=[objcts sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
                         
                         beeepers = [NSMutableArray arrayWithArray:friends];
                         searchedBeeepers = [NSMutableArray arrayWithArray:friends];
                         
                         dispatch_async(dispatch_get_main_queue(), ^{

                             self.noUsersFoundLabel.text = @"No one of your Facebook friends\nis on Beeeper yet.";
                
                             self.noUsersFoundLabel.hidden = (searchedBeeepers.count + searchedFBFriends.count != 0);
                             
                             [self.tableV reloadData];
                             
                             [self hideLoading];
                         });
                         
                     }
                     else{
                         [self.tableV reloadData];
                     }
                 }
                 else{
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         [self hideLoading];
                         [self.tableV reloadData];
                         
//                         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Something went wrong" message:@"Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                         [alert show];
                     });
                     
                     
                 }
             }
         }];
         
         
     }];

}

-(void)requestTWFriends{
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            accounts = [NSArray arrayWithArray:[accountStore accountsWithAccountType:accountType]];
            usernames = [NSArray arrayWithArray:[accounts valueForKey:@"username"]];

            if (usernames.count == 0) {

                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self hideLoading];
                    
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No accounts found" message:@"Please go to Settings > Twitter and sign in with your Twitter account.." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });

                
                return ;
            }
            
            if (usernames.count > 1) {
            
                UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                popup.tag = 77;
                
                for (NSString *name in usernames) {
                    [popup addButtonWithTitle:[NSString stringWithFormat:@"@%@",name]];
                }
                
                [popup addButtonWithTitle:@"Cancel"];
                
                popup.cancelButtonIndex = popup.numberOfButtons -1;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [popup showInView:self.view];
                });
                
            }
            else{
                
                ACAccount *twitterAccount = [accounts firstObject];
                
                [self requestTWFriendsForAccount:twitterAccount];
            }

            
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self hideLoading];
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No accounts found" message:@"Please go to Settings > Twittwe and sign in with your Twitter account." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            });

        }
    }];
}

-(void)requestTWFriendsForAccount:(ACAccount *)twitterAccount{
    
    [self showLoading];
    
    NSString *userID = ((NSDictionary*)[twitterAccount valueForKey:@"properties"])[@"user_id"];
    
    SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/friends/ids.json"] parameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", userID],@"user_id", nil]];
    [twitterInfoRequest setAccount:twitterAccount];
    // Making the request
    [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Check if we reached the reate limit
            if ([urlResponse statusCode] == 429) {
                NSLog(@"Rate limit reached");
                return;
            }
            // Check if there was an error
            if (error) {
                NSLog(@"Error: %@", error.localizedDescription);
                return;
            }
            // Check if there is some response data
            if (responseData) {
                NSError *error = nil;
                NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                
                NSArray *idsArr = [TWData valueForKey:@"ids"];
                
                if (idsArr.count == 0) {
                    
                    if (selectedOption == TwitterButton) {
                      
                        fbPeople = [NSMutableArray array];
                        searchedPeople = [NSMutableArray array];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            self.noUsersFoundLabel.text = @"No one of your Twitter friends\nis on Beeeper yet.";
                            self.noUsersFoundLabel.hidden = (searchedPeople.count != 0);
                            
                            [self.tableV reloadData];
                            
                            [self hideLoading];
                        });
                    }
                    
                    return;
                }
            
                NSString *ids = [[TWData valueForKey:@"ids"] componentsJoinedByString:@","];
                
                [[BPUser sharedBP]beeepersFromTW_IDs:ids WithCompletionBlock:^(BOOL completed,NSArray *objcts){
                    
                    if (selectedOption == TwitterButton) {
                    
                        if (completed) {
                            
                            if (objcts && objcts.count>0) {
                                
                                    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
                                    NSArray *friends=[objcts sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
                                    
                                    fbPeople = [NSMutableArray arrayWithArray:friends];
                                    searchedPeople = [NSMutableArray arrayWithArray:friends];

                            }
                            else{
                                fbPeople = [NSMutableArray array];
                                searchedPeople = [NSMutableArray array];
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                
                                self.noUsersFoundLabel.text = @"No one of your Twitter friends\nis on Beeeper yet.";
                                
                                self.noUsersFoundLabel.hidden = (searchedPeople.count != 0);
                                
                                [self.tableV reloadData];
                                
                                [self hideLoading];
                            });
                        }
                        else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                fbPeople = [NSMutableArray array];
                                searchedPeople = [NSMutableArray array];
                                
                                self.noUsersFoundLabel.text = @"No one of your Twitter friends\nis on Beeeper yet.";
                                self.noUsersFoundLabel.hidden = (searchedPeople.count != 0);
                                
                                [self hideLoading];
                                
//                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Something went wrong" message:@"Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                                [alert show];
                            });
                            
                            
                        }
                    }
                }];
            }
        });
    }];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag == 555 && buttonIndex != actionSheet.cancelButtonIndex) { //Mail button multiple mails selection
        
        if (emailInviteSelectedOption == 0) {
            
            UITableViewCell *cell = [actionSheet.UserInfo objectForKey:@"cell"];
            NSMutableDictionary *user = [actionSheet.UserInfo objectForKey:@"user_object"];
            NSArray *phones = [user objectForKey:@"phones"];
            NSString *phone = [[[phones objectAtIndex:buttonIndex] componentsSeparatedByString:@":"] lastObject];
            
            [selectedPeople addObject:user];
            [selectedEmails addObject: phone];
            
            UIImageView *tickedV = (id)[cell viewWithTag:5];
            
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
            
            if (selectedPeople.count > 0) {
                UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Invite"
                                                                                style:UIBarButtonItemStyleDone target:self action:@selector(invitePressed:)];
                self.navigationItem.rightBarButtonItem = rightButton;
            }
            else{
                self.navigationItem.rightBarButtonItem = nil;
            }
        }
        else{
            
            UITableViewCell *cell = [actionSheet.UserInfo objectForKey:@"cell"];
            NSMutableDictionary *user = [actionSheet.UserInfo objectForKey:@"user_object"];
            NSArray *emailAdresses = [user objectForKey:@"emails"];
            NSString *email = [emailAdresses objectAtIndex:buttonIndex];
            
            [selectedPeople addObject:user];
            [selectedEmails addObject: email];
            
            UIImageView *tickedV = (id)[cell viewWithTag:5];
            
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
            
            if (selectedPeople.count > 0) {
                UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Invite"
                                                                                style:UIBarButtonItemStyleDone target:self action:@selector(invitePressed:)];
                self.navigationItem.rightBarButtonItem = rightButton;
            }
            else{
                self.navigationItem.rightBarButtonItem = nil;
            }
        }
     
        return;
    }
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        if (actionSheet.tag == 77 || actionSheet.tag == 66) {
            [self hideLoading];
        }

        return;
    }
    
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        
        if(actionSheet.tag == 66){
            
            NSMutableDictionary *user = (FacebookButton == selectedOption)?nil:[searchedPeople objectAtIndex:actionSheetIndexPath.row];
            
            if (selectedOption == FacebookButton && searchedBeeepers.count >0) {
                user = [searchedBeeepers objectAtIndex:actionSheetIndexPath.row];
            }
            
            int positionSB = [searchedBeeepers indexOfObject:user];
            int positionB = [beeepers indexOfObject:user];
            int positionSP = [searchedPeople indexOfObject:user];
            
            [[BPUser sharedBP]unfollow:[user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
                if (completed) {
                    
                    NSMutableDictionary *newUser = [NSMutableDictionary dictionaryWithDictionary:user];
                    [newUser setObject:@"0" forKey:@"following"];
                    
                    if (selectedOption == FacebookButton) {
                        [beeepers replaceObjectAtIndex:positionB withObject:newUser];
                        [searchedBeeepers replaceObjectAtIndex:positionSB withObject:newUser];
                    }
                    else{
                        [searchedPeople replaceObjectAtIndex:positionSP withObject:newUser];
                    }
                    
                    NSRange range = NSMakeRange(0, 1);
                    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
                    [self.tableV reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
                    
                }
                
                actionSheetIndexPath = nil;
            }];
            return;
        }
        
    }
    
    if (actionSheet.tag == 77) { // twitter
        
        [self requestTWFriendsForAccount:[accounts objectAtIndex:buttonIndex]];

    }
    else{
        [self requestFBFriendsForAccount:[accounts objectAtIndex:buttonIndex]];
    }
    
}


-(void)viewWillAppear:(BOOL)animated{
    
    self.title = @"Find Friends";
    self.navigationController.navigationBar.topItem.title = self.title;
  
    [self.tableV reloadData];
    
    NSLog(@"%.2f",self.tableV.frame.origin.y + self.tableV.tableHeaderView.frame.size.height);
    NSLog(@"%.2f",self.tableV.frame.size.height-self.tableV.tableHeaderView.frame.size.height);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    if (selectedOption == FacebookButton && searchedBeeepers.count > 0) {
        return 2;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if (selectedOption == FacebookButton) {
        if (section == 0 && searchedBeeepers.count > 0) {
            return searchedBeeepers.count;
        }
        else{
            return searchedFBFriends.count;
        }
        
        return 0;
    }
    
    return (searchedPeople.count>0 && loadNextPage && selectedOption == BeeeperButton)?(searchedPeople.count+1):searchedPeople.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier;
    UITableViewCell *cell;
    
    if (indexPath.row == searchedPeople.count && selectedOption == BeeeperButton && loadNextPage) {
        
        CellIdentifier = @"LoadMoreCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UIActivityIndicatorView *indicator = (id)[cell viewWithTag:55];
        [indicator startAnimating];

        [self nextPage];
        
        return cell;
        
    }
    
    if (selectedOption == MailButton) { //mail
        CellIdentifier = @"Cell";
    }
    else{
        CellIdentifier = @"Cell2";
    }

    cell = [self.tableV dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UITextField *txtF = (id)[cell viewWithTag:1];
    txtF.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
    
    UIImageView *userImage = (id)[cell viewWithTag:2];
    UIButton *followBtn = (id)[cell viewWithTag:3];
    UITextField *detailstxtF = (id)[cell viewWithTag:4];
    UIImageView *tickedV = (id)[cell viewWithTag:5];
    UIImageView *fbtickedV = (id)[cell viewWithTag:14];
    
    NSMutableDictionary *user = (selectedOption == FacebookButton)?nil:[searchedPeople objectAtIndex:indexPath.row];
    
    BOOL isBeeeper = NO;
    
    if (selectedOption == FacebookButton) {
        if (indexPath.section == 0 && searchedBeeepers.count > 0) {
            user = [searchedBeeepers objectAtIndex:indexPath.row];
            isBeeeper = YES;
        }
        else{
            user = [searchedFBFriends objectAtIndex:indexPath.row];
            isBeeeper = NO;
        }
    }
    
     if (selectedOption != BeeeperButton) {
         
         if ((selectedOption == FacebookButton && !isBeeeper) || selectedOption == MailButton) {
             
             tickedV.hidden = NO;
             fbtickedV.hidden = YES;
             followBtn.hidden = YES;
             
             if ([selectedPeople indexOfObject:user] != NSNotFound) {
                 [tickedV setImage:[UIImage imageNamed:@"suggest_selected"]];
             }
             else{
                 [tickedV setImage:[UIImage imageNamed:@"suggest_unselected"]];
             }
         }
         else if (selectedOption == FacebookButton && isBeeeper) {
             
             tickedV.hidden = YES;
             fbtickedV.hidden = YES;
             followBtn.hidden = NO;
             
             NSNumber *following = (NSNumber *)[user objectForKey:@"following"];
             
             if (following.boolValue) {
                 [followBtn setImage:[UIImage imageNamed:@"invited_new.png"] forState:UIControlStateNormal];
             }
             else{
                 [followBtn setImage:[UIImage imageNamed:@"invite_new.png"] forState:UIControlStateNormal];
             }
         }
         else{
             
             tickedV.hidden = YES;
             followBtn.hidden = NO;
             fbtickedV.hidden = YES;
             
             NSNumber *following = (NSNumber *)[user objectForKey:@"following"];
             
             if (following.boolValue) {
                 [followBtn setImage:[UIImage imageNamed:@"invited_new.png"] forState:UIControlStateNormal];
             }
             else{
                 [followBtn setImage:[UIImage imageNamed:@"invite_new.png"] forState:UIControlStateNormal] ;
             }

         }
     }
     else{
    
         if ([[user objectForKey:@"id"]isEqualToString:[[BPUser sharedBP].user objectForKey:@"id"]]) {
             followBtn.hidden = YES;
             tickedV.hidden = YES;
             fbtickedV.hidden = YES;
         }
         else{
         
            followBtn.hidden = NO;
            tickedV.hidden = YES;
            fbtickedV.hidden = YES;
             
            NSNumber *following = (NSNumber *)[user objectForKey:@"following"];
            
            if (following.boolValue) {
                [followBtn setImage:[UIImage imageNamed:@"invited_new.png"] forState:UIControlStateNormal] ;
            }
            else{
                [followBtn setImage:[UIImage imageNamed:@"invite_new.png"] forState:UIControlStateNormal] ;
            }
         }
     }

            
      if (selectedOption == FacebookButton && !isBeeeper) {
                
            txtF.text = [user objectForKey:@"name"];
            
            NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString *imagePath = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture",[user objectForKey:@"id"]];
            
            NSString *imageName = [NSString stringWithFormat:@"%@",[imagePath MD5]];
            
            NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
            
            if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
                userImage.backgroundColor = [UIColor clearColor];
                userImage.image = [UIImage imageNamed:@"user_icon_180x180"];
                UIImage *img = [UIImage imageWithContentsOfFile:localPath];
                userImage.image = img;
            }
            else{
                userImage.backgroundColor = [UIColor lightGrayColor];
                
                [userImage sd_setImageWithURL:[NSURL URLWithString:[[DTO sharedDTO] fixLink:imagePath]]
                             placeholderImage:[UIImage imageNamed:@"user_icon_180x180"]];

            }
        }
        else{
    
        //applies for email && all other cases
        
            NSString *name =[[user objectForKey:@"name"] capitalizedString];
            NSString *lastname =[[user objectForKey:@"lastname"] capitalizedString];

            if (emailInviteSelectedOption == 0) {
                
                NSArray *phones= [user objectForKey:@"phones"];
                NSMutableString *phonesStr = [[NSMutableString alloc]init];
                
                if (phones.count > 0) {
                    
                    for (NSString *phone in phones) {
                        [phonesStr appendFormat:@"%@ ,",phone];
                    }
                    [phonesStr deleteCharactersInRange:NSMakeRange([phonesStr length]-1, 1)];
                    
                }
                
                if (name && lastname) {
                    txtF.text = [NSString stringWithFormat:@"%@ %@",[[user objectForKey:@"name"] capitalizedString],[[user objectForKey:@"lastname"] capitalizedString]];
                }
                else if(name == nil && lastname == nil && phones.count > 0){
                    
                    txtF.text = phonesStr;
                }
                else{
                    txtF.text = [NSString stringWithFormat:@"%@",([[user objectForKey:@"name"] capitalizedString])?[[user objectForKey:@"name"] capitalizedString]:[[user objectForKey:@"lastname"] capitalizedString]];
                }
                
                detailstxtF.text = phonesStr;

            }
            else{
                
                NSArray *emails= [user objectForKey:@"emails"];
                NSMutableString *emailsStr = [[NSMutableString alloc]init];
                
                if (emails.count > 0) {
                    
                    for (NSString *email in emails) {
                        [emailsStr appendFormat:@"%@ ,",email];
                    }
                    [emailsStr deleteCharactersInRange:NSMakeRange([emailsStr length]-1, 1)];
                    
                }
                
                if (name && lastname) {
                    txtF.text = [NSString stringWithFormat:@"%@ %@",[[user objectForKey:@"name"] capitalizedString],[[user objectForKey:@"lastname"] capitalizedString]];
                }
                else if(name == nil && lastname == nil && emails.count > 0){
                    
                    txtF.text = emailsStr;
                }
                else{
                    txtF.text = [NSString stringWithFormat:@"%@",([[user objectForKey:@"name"] capitalizedString])?[[user objectForKey:@"name"] capitalizedString]:[[user objectForKey:@"lastname"] capitalizedString]];
                }
                
                detailstxtF.text = emailsStr;

            }

        
        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *imagePath = [user objectForKey:@"image_path"];
        
        @try {
        
            if (imagePath != nil && ![imagePath isKindOfClass:[NSNull class]]) {
                
                [userImage sd_setImageWithURL:[NSURL URLWithString:[[DTO sharedDTO] fixLink:imagePath]]
                        placeholderImage:[UIImage imageNamed:@"user_icon_180x180"]];
            }
            else{
                
                userImage.image = nil;
                
                UIImage *imageContact = [user objectForKey:@"image"];
                if (imageContact != nil) {
                    userImage.image = imageContact;
                    userImage.backgroundColor = [UIColor clearColor];
                }
                else{
                    userImage.image = [UIImage imageNamed:@"user_icon_180x180"];
                }
                
            }
            
            

        }
        @catch (NSException *exception) {
            NSLog(@"provlima");
        }
        @finally {
            
        }
        }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *tickedV = (id)[cell viewWithTag:5];
    UIImageView *fbtickedV = (id)[cell viewWithTag:14];
    
    NSMutableDictionary *user = (selectedOption == FacebookButton)?nil:[searchedPeople objectAtIndex:indexPath.row];
   
    if (selectedOption == FacebookButton) {
        if (searchedBeeepers.count > 0 && indexPath.section == 0) {
            user  = [searchedBeeepers objectAtIndex:indexPath.row];
        }
        else{
            user  = [searchedFBFriends objectAtIndex:indexPath.row];
        }
    }
    
    BOOL isBeeeper = (beeepers != nil && [beeepers indexOfObject:user] != NSNotFound);
    
    if (selectedOption == MailButton) {
        
        if ([selectedPeople indexOfObject:user] == NSNotFound) {
            
            if (emailInviteSelectedOption == 0) {
                
                NSArray *phones = [user objectForKey:@"phones"];
                
                if (phones.count > 1) {
                    
                    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select phone number" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                    popup.tag = 555;
                    for (NSString *phone in phones) {
                        [popup addButtonWithTitle:phone];
                    }
                    
                    [popup addButtonWithTitle:@"Cancel"];
                    
                    popup.cancelButtonIndex = popup.numberOfButtons -1;
                    
                    [popup.UserInfo setObject:user forKey:@"user_object"];
                    [popup.UserInfo setObject:cell forKey:@"cell"];
                    [popup showInView:self.view];
                    
                    return;
                }
                else{
                    
                    NSString *phone = [[[phones firstObject] componentsSeparatedByString:@":"] lastObject];
                    
                    [selectedEmails addObject:phone];
                }
            }
            else{
            
                NSArray *emailAdresses = [user objectForKey:@"emails"];
                
                if (emailAdresses.count > 1) {
                    
                    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select email adress" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                    popup.tag = 555;
                    for (NSString *mail in emailAdresses) {
                        [popup addButtonWithTitle:mail];
                    }
                    
                    [popup addButtonWithTitle:@"Cancel"];
                    
                    popup.cancelButtonIndex = popup.numberOfButtons -1;
                    
                    popup.tag = 555;
                    
                    [popup.UserInfo setObject:user forKey:@"user_object"];
                    [popup.UserInfo setObject:cell forKey:@"cell"];
                    [popup showInView:self.view];
                    
                    return;
                }
                else{
                    [selectedEmails addObject:emailAdresses.firstObject];
                }
            }
            
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
        else{
          
            NSArray *phones = [user objectForKey:@"phones"];
            
            for (NSString *str in phones) {
               
                NSString *phone = [[str componentsSeparatedByString:@":"] lastObject];

                [selectedEmails removeObject:phone];
            }
            
            [selectedPeople removeObject:user];
            
            if (emailInviteSelectedOption == 0) {
                NSArray *phones = [user objectForKey:@"phones"];
                
                for (NSString *phone in phones) {
                    [selectedEmails removeObject:phone];
                }
            }
            else{
                NSArray *emailAdresses = [user objectForKey:@"emails"];
                
                for (NSString *email in emailAdresses) {
                    [selectedEmails removeObject:email];
                }
            }
            
            [UIView animateWithDuration:0.0f
                             animations:^
             {
                 tickedV.alpha = 0;
             }
                             completion:^(BOOL finished)
             {
                 [tickedV setImage:[UIImage imageNamed:@"suggest_unselected.png"]];
                 
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
        
        if (selectedPeople.count > 0) {
            UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Invite"
                                                                            style:UIBarButtonItemStyleDone target:self action:@selector(invitePressed:)];
             self.navigationItem.rightBarButtonItem = rightButton;
        }
        else{
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
    else if (selectedOption == FacebookButton && !isBeeeper){
        
        
        if ([selectedPeople indexOfObject:user] != NSNotFound) {
            [selectedPeople removeObject:user];
            
            [UIView animateWithDuration:0.0f
                             animations:^
             {
                 tickedV.alpha = 0;
             }
                             completion:^(BOOL finished)
             {
                 [tickedV setImage:[UIImage imageNamed:@"suggest_unselected"]];
                 
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
        else{
            
            if (selectedPeople.count == 50 && selectedOption == FacebookButton) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Cannot select more users." message:@"You have reached the limit of 50 selected people." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                return;
            }
            
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
        
        if (selectedPeople.count > 0) {
            UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Invite"
                                                                            style:UIBarButtonItemStyleDone target:self action:@selector(invitePressed:)];
            self.navigationItem.rightBarButtonItem = rightButton;
        }
        else{
            self.navigationItem.rightBarButtonItem = nil;
        }
        
        if (selectedPeople.count > 0) {
            UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Invite"
                                                                            style:UIBarButtonItemStyleDone target:self action:@selector(invitePressed:)];
            self.navigationItem.rightBarButtonItem = rightButton;
        }
        else{
            self.navigationItem.rightBarButtonItem = nil;
        }
        
        if (searchedBeeepers.count > 0) {
            NSRange range = NSMakeRange(1, 1);
            NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
            [self.tableV reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
        }
        else{
            NSRange range = NSMakeRange(0, 1);
            NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
            [self.tableV reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }
    else{
        
        TimelineVC *timelineVC = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"TimelineVC"];
        
        BOOL following = [[user objectForKey:@"following"] boolValue];
        
        if (following) {
            timelineVC.mode = Timeline_Following;
        }
        else{
            timelineVC.mode = Timeline_Not_Following;
        }

        timelineVC.showBackButton = YES; //in case of My_Timeline
        timelineVC.user = user;
        
        NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
        if ([[user objectForKey:@"id"]isEqualToString:my_id]) {
            timelineVC.mode = Timeline_My;
        }
        
        [self.navigationController pushViewController:timelineVC animated:YES];
    }
   
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (selectedOption == FacebookButton) {
        if (indexPath.section == 1) {
            if (indexPath.row == searchedFBFriends.count) {
                return 40;
            }
            else{
                return 61;
            }
        }
        else if (indexPath.section == 0 && searchedBeeepers.count == 0){
           
            if (indexPath.row == searchedFBFriends.count) {
                return 40;
            }
            else{
                return 61;
            }
        }
        else{
            if (indexPath.row == searchedBeeepers.count) {
                return 40;
            }
            else{
                return 61;
            }
        }
    }
    
    if (indexPath.row == searchedPeople.count) {
        return 40;
    }
    else{
        return 61;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
   
    if (selectedOption == FacebookButton) {
        return 47;
    }
    else{
        return 0;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (selectedOption == FacebookButton && searchedBeeepers.count+searchedFBFriends.count > 0) {
       
        UIView *header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableV.frame.size.width, 47)];
        header.backgroundColor = [UIColor colorWithRed:218/255.0 green:223/255.0 blue:226/255.0 alpha:1];
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(10,0, self.tableV.frame.size.width-105,  47)];
        lbl.textColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:1];
        [lbl setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
        
        [header addSubview:lbl];
        
        if (searchedBeeepers.count > 0) {
            
            if (section == 0) {
                
                if (searchedBeeepers.count == 1) {
                    lbl.text = [NSString stringWithFormat:@"%d Friend on Beeeper",searchedBeeepers.count];
                }
                else{
                    lbl.text = [NSString stringWithFormat:@"%d Friends on Beeeper",searchedBeeepers.count];
                }
                
                UIButton *followAll = [UIButton buttonWithType:UIButtonTypeCustom];
                [followAll setImage:[UIImage imageNamed:@"follow_all"] forState:UIControlStateNormal];
                [followAll setFrame:CGRectMake(header.frame.size.width-95, 0, 95, header.frame.size.height)];
                [followAll addTarget:self action:@selector(followAllPressed:) forControlEvents:UIControlEventTouchUpInside];
                [header addSubview:followAll];
                
                return header;
            }
            else{ //fb header

    
                lbl.text = [NSString stringWithFormat:@"%d Friends from Facebook",searchedFBFriends.count];
                
                
//                UIButton *selectAll = [UIButton buttonWithType:UIButtonTypeCustom];
//                [selectAll setImage:[UIImage imageNamed:@"select_all"] forState:UIControlStateNormal];
//                [selectAll setFrame:CGRectMake(header.frame.size.width-95, 0, 95, header.frame.size.height)];
//                [selectAll addTarget:self action:@selector(selectAllPressed:) forControlEvents:UIControlEventTouchUpInside];
//                [header addSubview:selectAll];
                
                return header;
            }
            
        }
        else{
            
            //fb header
            lbl.text = [NSString stringWithFormat:@"%d Friends from Facebook",searchedFBFriends.count];
            return header;
        }
    }
    else{
        return nil;
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

-(void)followAllPressed:(UIButton *)btn{
    
    for (int i=0; i<beeepers.count ; i++) {

        NSMutableDictionary *user = [searchedBeeepers objectAtIndex:i];
        
        int positionSB = [searchedBeeepers indexOfObject:user];
        int positionB = [beeepers indexOfObject:user];
        int positionS = [searchedPeople indexOfObject:user];
        
        NSNumber *following = (NSNumber *)[user objectForKey:@"following"];
        
        NSMutableDictionary *newUser = [NSMutableDictionary dictionaryWithDictionary:user];
        [newUser setObject:@"1" forKey:@"following"];
        
        if (FacebookButton == selectedOption) {
            [searchedBeeepers replaceObjectAtIndex:positionSB withObject:newUser];
            [beeepers replaceObjectAtIndex:positionB withObject:newUser];
        }
        else{
            [searchedPeople replaceObjectAtIndex:positionS withObject:newUser];
        }
        
        if (!following.boolValue) {
            
            //follow user
            [[BPUser sharedBP]follow:[user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
                if (completed) {
                
                    
                }
            }];
            
        }
    }
    
    [self.tableV reloadData];

}

-(void)selectAllPressed:(UIButton *)btn{
    
    [selectedPeople removeAllObjects];
    
    for (NSMutableDictionary *user in fbPeople) {
        [selectedPeople addObject:user];
    }
    
    
    if (selectedPeople.count > 0) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Invite"
                                                                        style:UIBarButtonItemStyleDone target:self action:@selector(invitePressed:)];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    else{
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self.tableV reloadData];
}

-(void)invitePressed:(UIBarButtonItem *)inviteButton{
    
    if (selectedOption  == MailButton) {
        
        if (emailInviteSelectedOption == 0) {
            [self sendSMS];
        }
        else{
        
            NSURL *url = [NSURL URLWithString:@"https://api.elasticemail.com/mailer/send"];
            
            NSMutableDictionary *postValuesDict = [NSMutableDictionary dictionary];
            
            [postValuesDict setObject:@"5c718e43-3ceb-47d5-ad45-fc9f8ad86d6d" forKey:@"username"];
            [postValuesDict setObject:@"5c718e43-3ceb-47d5-ad45-fc9f8ad86d6d" forKey:@"api_key"];
            [postValuesDict setObject:@"hello@beeeper.com" forKey:@"from"];
            [postValuesDict setObject:@"Beeeper" forKey:@"from_name"];
            
            NSMutableString *recipients = [[NSMutableString alloc]init];
            
            for (NSString *email in selectedEmails) {

                [recipients appendFormat:@"%@;",email];
            }
            
            [postValuesDict setObject:recipients forKey:@"to"];
            [postValuesDict setObject:@"Join Beeeper" forKey:@"subject"];
            [postValuesDict setObject:@"invitefriend" forKey:@"template"];
            [postValuesDict setObject:[[BPUser sharedBP].user objectForKey:@"name"] forKey:@"merge_firstname"];
            [postValuesDict setObject:[[BPUser sharedBP].user objectForKey:@"lastname"] forKey:@"merge_lastname"];
            
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            
            [manager POST:url.absoluteString parameters:postValuesDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSString *responseString = [operation responseString];
                NSLog(@"Send Response: %@", responseString);
                
                if ([responseString rangeOfString:@"Error"].location != NSNotFound) {
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                    [SVProgressHUD showSuccessWithStatus:@"Invitation \nFailed!"];
                    
                }
                else{
                    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                    [SVProgressHUD showSuccessWithStatus:@"Invitation \nSent!"];
                    
                    [selectedPeople removeAllObjects];
                    
                    [self.tableV reloadData];
                    
                    self.navigationItem.rightBarButtonItem = nil;
                    
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                [SVProgressHUD showSuccessWithStatus:@"Invitation \nFailed!"];

            }];

        }
    }
    else if (selectedOption == FacebookButton){
        
        [self inviteFBFriendsPressed];

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
    
    if (cancelGesture) {
        [self.tableV removeGestureRecognizer:cancelGesture];
        cancelGesture = nil;
    }
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
        loadNextPage = NO;

        [self getPeople:@"" WithCompletionBlock:^(BOOL completed,NSArray *objcts){
            
            if (completed) {
                if (objcts > 0) {
                    loadNextPage = (objcts.count == pageLimit);
                
                    searchedPeople = [NSMutableArray arrayWithArray:objcts];
                
                    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                    
                    [searchedPeople sortUsingDescriptors:[NSArray arrayWithObject:sort]
                     ];
                    
                    self.noUsersFoundLabel.text = @"No users found on Beeeper.";
                    self.noUsersFoundLabel.hidden = (searchedPeople.count != 0);
                }
             }

            NSRange range = NSMakeRange(0, 1);
            NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
            [self.tableV reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
        }];
    }
    else if (selectedOption == MailButton){
        searchedPeople = [NSMutableArray arrayWithArray:adressBookPeople];
        self.noUsersFoundLabel.hidden = (searchedPeople.count != 0);
        self.noUsersFoundLabel.text = @"No contacts found on your contact list.";
        [self.tableV reloadData];
    }
    else if (selectedOption == FacebookButton){
        searchedBeeepers = [NSMutableArray arrayWithArray:beeepers];
        searchedFBFriends = [NSMutableArray arrayWithArray:fbPeople];
        
        self.noUsersFoundLabel.text = @"No one of your Facebook friends\nis on Beeeper yet.";
        self.noUsersFoundLabel.hidden = (searchedFBFriends.count+searchedBeeepers.count != 0);
        
        [self.tableV reloadData];
    }
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    static int count = 0;
    
    if ([text isEqualToString:@"\n"]) {
        [searchBar resignFirstResponder];
        return YES;
    }
    
    if (count == 1 || selectedOption != BeeeperButton) {
         NSString* searchText = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
         [self filterContentForSearchText:searchText scope:nil];
        count = 0;
    }
    else{
        count ++;
    }
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    if ([searchText length] == 0) {
        if (selectedOption == MailButton){
             searchedPeople = [NSMutableArray arrayWithArray:adressBookPeople];
            self.noUsersFoundLabel.text = @"No contacts found on your contact list.";
            self.noUsersFoundLabel.hidden = (searchedPeople.count != 0);
            [self.tableV reloadData];
        }
        else if (selectedOption == FacebookButton){
            searchedBeeepers = [NSMutableArray arrayWithArray:beeepers];
            searchedFBFriends = [NSMutableArray arrayWithArray:fbPeople];
            self.noUsersFoundLabel.text = @"No one of your Facebook friends\nis on Beeeper yet.";
            self.noUsersFoundLabel.hidden = (searchedFBFriends.count+searchedBeeepers.count != 0);
            
            [self.tableV reloadData];
        }
        else if (selectedOption == BeeeperButton){
       
            page = 0;
            loadNextPage = NO;
            
            [self getPeople:@"" WithCompletionBlock:^(BOOL completed,NSArray *objcts){
                
                if (completed) {
                    if (objcts > 0) {
                        loadNextPage = (objcts.count == pageLimit);
                        searchedPeople = [NSMutableArray arrayWithArray:objcts];
                       
                        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                        
                        [searchedPeople sortUsingDescriptors:[NSArray arrayWithObject:sort]
                         ];
                        
                        self.noUsersFoundLabel.text = @"No users found on Beeeper.";
                        self.noUsersFoundLabel.hidden = (searchedPeople.count != 0);
                    }
                }
                
                NSRange range = NSMakeRange(0, 1);
                NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
                [self.tableV reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
            }];

        }
        
        
    }
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
     if (selectedOption == BeeeperButton) {
        
          if (searchText.length > 0) {
         
                page = 0;
         
                [self getPeople:searchText WithCompletionBlock:^(BOOL completed,NSArray *objcts){
                    
                    if (completed) {
                        
                        if (objcts.count > 0) {
                            searchedPeople = [NSMutableArray arrayWithArray:objcts];
                        }
                        else{
                            searchedPeople = [NSMutableArray array];
                        }
                        
                        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                        
                        [searchedPeople sortUsingDescriptors:[NSArray arrayWithObject:sort]
                         ];
                    }

                    self.noUsersFoundLabel.text = @"";//@"No users found on Beeeper.";
                    self.noUsersFoundLabel.hidden = (searchedPeople.count != 0);
                    
                    NSRange range = NSMakeRange(0, 1);
                    NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
                    [self.tableV reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
            
                }];
        }
        else{
            
            
            page = 0;
            loadNextPage = NO;
            
            [self getPeople:@"" WithCompletionBlock:^(BOOL completed,NSArray *objcts){
                
                if (completed) {
                    if (objcts > 0) {
                        loadNextPage = (objcts.count == pageLimit);
                        searchedPeople = [NSMutableArray arrayWithArray:objcts];
                        
                        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                        
                        [searchedPeople sortUsingDescriptors:[NSArray arrayWithObject:sort]
                         ];
                    }
                }
                
                self.noUsersFoundLabel.text = @"No users found on Beeeper.";
                self.noUsersFoundLabel.hidden = (searchedPeople.count != 0);
                
                NSRange range = NSMakeRange(0, 1);
                NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
                [self.tableV reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
            }];

            
        }
     }
     else if (selectedOption == MailButton){
       
         if (searchText.length > 0) {
             searchedPeople = [NSMutableArray arrayWithArray:[adressBookPeople filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name contains[cd] %@) OR (ANY emails contains[cd] %@)", searchText,searchText]]];
         }
         else{
             searchedPeople = [NSMutableArray arrayWithArray:adressBookPeople];
         }
        
         self.noUsersFoundLabel.text = @"";//@"No contacts found on your contact list.";
         self.noUsersFoundLabel.hidden = (searchedPeople.count != 0);
         [self.tableV reloadData];
     }
     else if (selectedOption == FacebookButton){
         
         if (searchText.length > 0) {
             searchedBeeepers = [NSMutableArray arrayWithArray:[beeepers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name contains[cd] %@)", searchText]]];
             
            searchedFBFriends = [NSMutableArray arrayWithArray:[fbPeople filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name contains[cd] %@)", searchText]]];
         }
         else{
             searchedBeeepers = [NSMutableArray arrayWithArray:beeepers];
             searchedFBFriends = [NSMutableArray arrayWithArray:fbPeople];
         }
        
         self.noUsersFoundLabel.text = @"";//@"No one of your Facebook friends\nis on Beeeper yet.";
         self.noUsersFoundLabel.hidden = (searchedFBFriends.count+searchedBeeepers.count != 0);
         
         [self.tableV reloadData];
     }
     else if (selectedOption ==  TwitterButton){
         
         if (searchText.length > 0) {
             searchedPeople = [NSMutableArray arrayWithArray:[fbPeople filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(name contains[cd] %@)", searchText,searchText]]];
         }
         else{
             searchedPeople = [NSMutableArray arrayWithArray:fbPeople];
         }
         
         self.noUsersFoundLabel.text = @"";//@"No one of your Twitter friends\nis on Beeeper yet.";
         self.noUsersFoundLabel.hidden = (searchedPeople.count != 0);
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
                loadNextPage = (objcts.count == pageLimit);
                [searchedPeople addObjectsFromArray:objcts];
                
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
                
                [searchedPeople sortUsingDescriptors:[NSArray arrayWithObject:sort]
                 ];
            }
        }
        
        [self.tableV reloadData];

    }];
}

-(void)getPeople:(NSString *)searchString WithCompletionBlock:(completed)compbloc{
    
    if (searchString == nil) {
        searchString = @"";
    }
    
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
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerGETRequest:URL values:array] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:URLwithVars parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self getPeopleFinished:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self getPeopleFailed:error.localizedDescription];
    }];
    
}

-(void)getPeopleFinished:(id)request{
    
    NSString *responseString = request;

    NSArray *people = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    if (people == nil || (people.count == 0 && searchStr.length == 0)) {
        [self getPeople:searchStr WithCompletionBlock:self.search_completed];
    }
    
    NSMutableArray *mutablePeople = [NSMutableArray array];
    
    for (NSMutableDictionary *user in people) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:user];
        [mutablePeople addObject:dict];
    }
    
    self.search_completed(YES,mutablePeople);
}

-(void)getPeopleFailed:(id )request{
    
    NSString *responseString = request;
    self.search_completed(NO,nil);
}

- (IBAction)rightButtonPressed:(UIButton *)sender {
    
    UIView *view = sender;
    while (view != nil && ![view isKindOfClass:[UITableViewCell class]]) {
        view = [view superview];
    }
    
    UITableViewCell *cell = (UITableViewCell *)view;
    NSIndexPath *path = [self.tableV indexPathForCell:cell];
    
    NSMutableDictionary *user = (selectedOption == FacebookButton)?nil:[searchedPeople objectAtIndex:path.row];
    
    if (selectedOption == FacebookButton && searchedBeeepers.count >0) {
        user = [searchedBeeepers objectAtIndex:path.row];
    }
    
    NSNumber *following = (NSNumber *)[user objectForKey:@"following"];
    
    int positionB = [beeepers indexOfObject:user];
    int positionSB = [searchedBeeepers indexOfObject:user];
    int positionSP = [searchedPeople indexOfObject:user];
    
    if (following.boolValue) {
        
        NSString *username = [[NSString stringWithFormat:@"%@ %@",[user objectForKey:@"name"],[user objectForKey:@"lastname"]] capitalizedString];
        
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:username delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Unfollow" otherButtonTitles:nil];
        [popup showInView:self.view];
        popup.tag = 66;
        actionSheetIndexPath = path;
    }
    else{
        
        //follow user
        [[BPUser sharedBP]follow:[user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
            if (completed) {
                
                NSMutableDictionary *newUser = [NSMutableDictionary dictionaryWithDictionary:user];
                [newUser setObject:@"1" forKey:@"following"];

                if (selectedOption == FacebookButton) {
                    [searchedBeeepers replaceObjectAtIndex:positionSB withObject:newUser];
                    [beeepers replaceObjectAtIndex:positionB withObject:newUser];
                }
                else{
                    [searchedPeople replaceObjectAtIndex:positionSP withObject:newUser];
                }
                
                NSRange range = NSMakeRange(0, 1);
                NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
                [self.tableV reloadSections:section withRowAnimation:UITableViewRowAnimationFade];
                
            }
        }];
        
    }
}

- (void)inviteFBFriendsPressed{
    
    if (selectedOption == FacebookButton){
        
        
        NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [[selectedPeople valueForKey:@"id"] componentsJoinedByString:@","], @"to",
                                         nil];
        
        
        NSString *title = @"Beeeper invitation";
        
        NSString *fullName = [[NSString stringWithFormat:@"%@ %@",[[BPUser sharedBP].user objectForKey:@"name"],[[BPUser sharedBP].user objectForKey:@"lastname"]] capitalizedString];
        
        NSString *message = [NSString stringWithFormat:@"%@ has invited you to join Beeeper",fullName];
        
        
        [FBWebDialogs presentRequestsDialogModallyWithSession:FBSession.activeSession
                                                      message:message
                                                        title:title
                                                   parameters:params
                                                      handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                          if (error)
                                                          {

                 // Error launching the dialog or sending the request.
                 NSLog(@"Error sending request.");
                 
                 [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                 [SVProgressHUD showSuccessWithStatus:@"Error sending request."];
                 
             } else {
                 if (result == FBWebDialogResultDialogNotCompleted) {
                     // User clicked the "x" icon
                     NSLog(@"User canceled request.");
                     
                 } else {
                     // Handle the send request callback
                     NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                     if (![urlParams valueForKey:@"request"]) {
                         // User clicked the Cancel button
                         NSLog(@"User canceled request.");
                         
                         [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
                         [SVProgressHUD showErrorWithStatus:@"Invitation \nFailed!"];
                         
                     } else {
                         // User clicked the Send button
                         NSString *requestID = [urlParams valueForKey:@"request"];
                         NSLog(@"Request ID: %@", requestID);
                             
                         [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
                         [SVProgressHUD showSuccessWithStatus:@"Invitation \nSent!"];
                         
                         [selectedPeople removeAllObjects];
                         
                         [self.tableV reloadData];
                         
                         self.navigationItem.rightBarButtonItem = nil;

                         
                     }
                 }
             }
         }];
        
    }

}



- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [[kv objectAtIndex:1]
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

#pragma mark - SMS

-(void)sendSMS{
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSArray *recipents = selectedEmails;
    
    NSString *message = [NSString stringWithFormat:@"Join Beeeper and never forget an event again. It's awesome!\nhttps://beeeper.com \n\n_______\nAlso available in the App Store: https://appsto.re/gr/SM883.i"];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    
    [messageController.navigationBar setTintColor:[UIColor whiteColor]];
    
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{

    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:209/255.0 green:93/255.0 blue:99/255.0 alpha:1]];
            [SVProgressHUD showSuccessWithStatus:@"Invitations \nFailed!"];
            break;
        }
            
        case MessageComposeResultSent:
        {
            [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:52/255.0 green:134/255.0 blue:57/255.0 alpha:1]];
            [SVProgressHUD showSuccessWithStatus:@"Invitations \nSent!"];
        }
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^
     {
         [self.tableV reloadData];
     }];
}
@end
