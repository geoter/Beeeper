//
//  BeeepVC.m
//  Beeeper
//
//  Created by User on 3/19/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "BeeepVC.h"
#import "DZNPhotoPickerController.h"
#import "UIImagePickerControllerExtended.h"
#import "MyDateTimePicker.h"
#import "Private.h"
#import "LocationManager.h"
#import <AddressBook/AddressBook.h>
#import "BPCreate.h"
#import "GoogleCustomSearchVC.h"

@interface InputTextView : UITextView
@end

@implementation InputTextView

/*************************************************
 * fixes the issue with single lined uitextview
 *************************************************/
- (UIEdgeInsets) contentInset { return UIEdgeInsetsZero; }

@end

@class BorderTextField;
@interface BeeepVC ()<UITextFieldDelegate,UIScrollViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,DZNPhotoPickerControllerDelegate,LocationManagerDelegate,UIAlertViewDelegate,UITextViewDelegate>
{
    NSMutableDictionary *values;
    MyDateTimePicker *datePicker;
    UITextField *activeTXTF;
    LocationManager *locManager;
    NSMutableArray *predefinedTags;
}
@property(nonatomic,strong) NSString *base64Image;
@end

@implementation BeeepVC
@synthesize base64Image;

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
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    UIImage *blurredImg = [[DTO sharedDTO]convertViewToBlurredImage:self.superviewToBlur withRadius:7];
    self.blurredImageV.image = blurredImg;
    
    predefinedTags = [NSMutableArray array];
    
    self.blurContainerV.alpha = 0;
    
    self.titleBGV.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    self.titleBGV.layer.shadowOpacity = 0.2;
   // self.titleBGV.layer.shadowOffset = CGSizeMake(0, -0.1);
   // self.titleBGV.layer.shadowRadius = 0.0;
    [self.titleBGV.layer setShadowPath:[[UIBezierPath
                                bezierPathWithRect:self.titleBGV.bounds] CGPath]];
    
    self.whenBGV.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    self.whenBGV.layer.shadowOpacity = 0.7;
    self.whenBGV.layer.shadowOffset = CGSizeMake(0, 0.1);
    self.whenBGV.layer.shadowRadius = 0.0;
    [self.whenBGV.layer setShadowPath:[[UIBezierPath
                                         bezierPathWithRect:self.whenBGV.bounds] CGPath]];
    
   
    self.tagsBGV.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    self.tagsBGV.layer.shadowOpacity = 0.7;
    self.tagsBGV.layer.shadowOffset = CGSizeMake(0, 0.0);
    self.tagsBGV.layer.shadowRadius = 0.0;
    [self.tagsBGV.layer setShadowPath:[[UIBezierPath
                                        bezierPathWithRect:self.tagsBGV.bounds] CGPath]];
   
    
    self.scrollV.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    self.scrollV.layer.shadowOpacity = 0.7;
    self.scrollV.layer.shadowOffset = CGSizeMake(0, 0.0);
    self.scrollV.layer.shadowRadius = 0.0;
    [self.scrollV.layer setShadowPath:[[UIBezierPath
                                        bezierPathWithRect:self.scrollV.bounds] CGPath]];


    
    self.titleBGV.roundedCorners = TKRoundedCornerTopLeft | TKRoundedCornerTopRight;
    self.titleBGV.borderColor = [UIColor lightGrayColor];
    self.titleBGV.borderWidth = 0.0f;
    self.titleBGV.cornerRadius = 0;
    self.titleBGV.drawnBordersSides = TKDrawnBorderSidesAll;

    self.whereBGV.roundedCorners = TKRoundedCornerNone;
    self.whereBGV.borderColor = [UIColor lightGrayColor];
    self.whereBGV.borderWidth = 0.0f;
    self.whereBGV.cornerRadius = 0;
    self.whereBGV.drawnBordersSides = TKDrawnBorderSidesAll;
    
    self.whenBGV.roundedCorners = TKRoundedCornerBottomLeft | TKRoundedCornerBottomRight;
    self.whenBGV.borderColor = [UIColor whiteColor];
    self.whenBGV.borderWidth = 0.0f;
    self.whenBGV.cornerRadius = 0;
    self.whenBGV.drawnBordersSides = TKDrawnBorderSidesAll;
    
    self.tagsBGV.roundedCorners = TKRoundedCornerAll;
    self.tagsBGV.borderColor = [UIColor lightGrayColor];
    self.tagsBGV.borderWidth = 0.0f;
    self.tagsBGV.cornerRadius = 0;
    self.tagsBGV.drawnBordersSides = TKDrawnBorderSidesAll;
    
    values = [NSMutableDictionary dictionary];
    
    if ([DTO sharedDTO].userPlace == nil) {
        
        locManager = [[LocationManager alloc]init];
        
        locManager.delegate = self;
        
        [locManager startTracking];
    }
    else{
        [self getLocationInfo:[DTO sharedDTO].userPlace];
    }
    
    
    datePicker = [[MyDateTimePicker alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 260)];
    datePicker.backgroundColor = [UIColor whiteColor];
    
    [DZNPhotoPickerController registerService:DZNPhotoPickerControllerServiceGoogleImages
                                  consumerKey:kGoogleImagesConsumerKey
                               consumerSecret:kGoogleImagesSearchEngineID
                                 subscription:DZNPhotoPickerControllerSubscriptionFree];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(beeepIt:) name:@"BeeepIt" object:nil];
 //   [self adjustFonts];
}

- (void)locationUpdate:(CLLocation *)location{
   
    if ([DTO sharedDTO].userPlace == nil) {
    
        CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            for (CLPlacemark * placemark in placemarks) {
               [DTO sharedDTO].userPlace = placemark;
                [self getLocationInfo:[DTO sharedDTO].userPlace];
                break;
            }
        }];
    }
    else{
        [self getLocationInfo:[DTO sharedDTO].userPlace];
    }
}

-(void)getLocationInfo:(CLPlacemark *)placemark{
    
    NSString *city;
    NSString *country;
    NSString *state;
    NSString *adress;
    NSNumber *latitude;
    NSNumber *longitude;
    
    city = placemark.locality;
    country = placemark.country;
    state  = placemark.administrativeArea;
    NSDictionary *dict = [placemark addressDictionary];
    
    @try {
        adress = [dict objectForKey:(NSString *)kABPersonAddressStreetKey];
    }
    @catch (NSException *exception) {
        adress = @"";
    }
    @finally {
        
    }
    
    
    latitude = [NSNumber numberWithDouble:placemark.location.coordinate.latitude];
    longitude = [NSNumber numberWithDouble:placemark.location.coordinate.longitude];
    
    [values setObject:(city)?city:@"" forKey:@"city"];
    [values setObject:(country)?country:@"" forKey:@"country"];
    [values setObject:(state)?state:@"" forKey:@"state"];
    [values setObject:(adress)?adress:@"" forKey:@"address"];
    [values setObject:[longitude stringValue] forKey:@"longitude"];
    [values setObject:[latitude stringValue] forKey:@"latitude"];
}

- (void)locationError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Where are you?" message:@"Please go to Settings > Privacy > Location Services and set Beeeper to on." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = 99;
    [alert show];
}

- (void)locationDisabled{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Where are you?" message:@"Please go to Settings > Privacy > Location Services and set Beeeper to on." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = 99;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 99) {
        [self close:nil];
    }
}

-(void)beeepIt:(NSNotification *)notif{
    [self close:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
  
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [datePicker setHidden:YES animated:YES];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
//    
//    if (textField.textAlignment == NSTextAlignmentLeft) {
//        textField.text = @"";
//        textField.textAlignment = NSTextAlignmentCenter;
//    }
    
    if (textField.tag == 2) { //pick date
        
        UIView *backV = [[UIView alloc]initWithFrame:self.view.bounds];
        backV.tag = 92;
        backV.backgroundColor = [ UIColor colorWithWhite:0 alpha:0];

        datePicker.frame = CGRectMake(0, self.view.frame.size.height, 320, 260);
        [backV addSubview:datePicker];
        
        [self.scrollV endEditing:YES];
        
        [self.view addSubview:backV];
        
        [UIView animateWithDuration:0.4f
                         animations:^
         {
            backV.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
         }
                         completion:^(BOOL finished)
         {
             
         }
         ];
        
        [datePicker setHidden:NO animated:YES];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(hideDatePicker) name:@"DatePickerDone" object:nil];
        [activeTXTF resignFirstResponder];
        activeTXTF = nil;
        
 
        return NO;
    }
    
    if(textField.tag > 3){
        [self.containerScrollV setContentOffset:CGPointMake(0, 200) animated:YES];
    }
    
    activeTXTF = textField;
   
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString * typedStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (typedStr.length == 0) {
        textField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        //remove value
        
        switch (textField.tag) {
            case 1:
                [values removeObjectForKey:@"title"];
                break;
            case 2:
                [values removeObjectForKey:@"timestamp"];
                break;
            case 3:
                [values removeObjectForKey:@"station"];
                break;
            case 4:
                [values removeObjectForKey:@"keywords"];
                break;
            case 5:
                [values removeObjectForKey:@"description"];
                break;
            default:
                break;
        }
    }
    else{
        //save value
        [self validTextfield:textField];
        
        switch (textField.tag) {
            case 1:
                [values setObject:typedStr forKey:@"title"];
                break;
            case 2:
                [values setObject:typedStr forKey:@"timestamp"];
                break;
            case 3:
                [values setObject:typedStr forKey:@"station"];
                break;
            case 4:
                [values setObject:typedStr forKey:@"keywords"];
                break;
            case 5:
                [values setObject:typedStr forKey:@"description"];
                break;
            default:
                break;
        }

        textField.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
       // textField.textColor = [UIColor colorWithRed:240/255.0 green:208/255.0 blue:0 alpha:1];
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{

    activeTXTF = nil;
    [textField resignFirstResponder];
    
    if (textField.text.length == 0) {
      //  textField.textAlignment = NSTextAlignmentLeft;
//        
//        switch (textField.tag) {
//            case 1:
//                textField.text = @"TITLE";
//                break;
//            case 2:
//                textField.text = @"DATE";
//                break;
//            case 3:
//                textField.text = @"VENUE";
//                break;
//            case 4:
//                textField.placeholder = @"TAGS (OPTIONAL)";
//                break;
//            case 5:
//                textField.placeholder = @"DESCRIPTION (OPTIONAL)";
//                break;
//            default:
//                break;
//        }
        
        //save value
        
        switch (textField.tag) {
            case 1:
                [values removeObjectForKey:@"title"];
                break;
//            case 2:
//                [values removeObjectForKey:@"timestamp"];
//                break;
            case 3:
                [values removeObjectForKey:@"station"];
                break;
            case 4:
                [values removeObjectForKey:@"keywords"];
                break;
            case 5:
                [values removeObjectForKey:@"description"];
                break;
            default:
                break;
        }
    }
    else{
        //save value
        
        switch (textField.tag) {
            case 1:
                [values setObject:textField.text forKey:@"title"];
                break;
//            case 2:
//                [values setObject:textField.text forKey:@"timestamp"];
//                break;
            case 3:
                [values setObject:textField.text forKey:@"station"];
                break;
            case 4:
                [values setObject:textField.text forKey:@"keywords"];
                break;
            case 5:
                [values setObject:textField.text forKey:@"description"];
                break;
            default:
                break;
        }
    }
    
    [self.containerScrollV setContentOffset:CGPointZero animated:YES];
    
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    if (textField.text.length == 0) {
    //    textField.textAlignment = NSTextAlignmentLeft;
        
//        switch (textField.tag) {
//            case 1:
//                textField.text = @"TITLE";
//                break;
//            case 2:
//                textField.text = @"DATE";
//                break;
//            case 3:
//                textField.text = @"VENUE";
//                break;
//            case 4:
//                textField.placeholder = @"TAGS (OPTIONAL)";
//                break;
//            case 5:
//                textField.placeholder = @"DESCRIPTION (OPTIONAL)";
//                break;
//            default:
//                break;
//        }
//        
        switch (textField.tag) {
            case 1:
                [values removeObjectForKey:@"title"];
                break;
                //            case 2:
                //                [values removeObjectForKey:@"timestamp"];
                //                break;
            case 3:
                [values removeObjectForKey:@"station"];
                break;
            case 4:
                [values removeObjectForKey:@"keywords"];
                break;
            case 5:
                [values removeObjectForKey:@"description"];
                break;
            default:
                break;
        }

    }
    else{
        //save value
        
        switch (textField.tag) {
            case 1:
                [values setObject:textField.text forKey:@"title"];
                break;
                //            case 2:
                //                [values setObject:textField.text forKey:@"timestamp"];
                //                break;
            case 3:
                [values setObject:textField.text forKey:@"station"];
                break;
            case 4:
                [values setObject:textField.text forKey:@"keywords"];
                break;
            case 5:
                [values setObject:textField.text forKey:@"description"];
                break;
            default:
                break;
        }
    }
    
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    [self.containerScrollV setContentOffset:CGPointMake(0, 170) animated:YES];
    
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"#";
        
        if (textView.selectedRange.location == 0) {
            [textView setSelectedRange:NSMakeRange(1, 0)];
        }

        textView.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
    }
    
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if (textView.selectedRange.location == 0 && textView.selectedRange.length >= 1) {
        [textView setSelectedRange:NSMakeRange(1, 0)];
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    NSString * typedStr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if (typedStr.length == 0) {
        
        //remove value
        [values removeObjectForKey:@"keywords"];
    }
    else{
        //save value
        
         [values setObject:typedStr forKey:@"keywords"];
        
        if ([text isEqualToString:@"\n"]) {
            
            [self.containerScrollV setContentOffset:CGPointZero animated:YES];
            [textView resignFirstResponder];
            // Return FALSE so that the final '\n' character doesn't get added
            return NO;
        }
        else if ([text isEqualToString:@" "]){
            textView.text =  [textView.text stringByReplacingCharactersInRange:range withString:@" #"];
            return NO;
        }
      
        

    }

    
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView{
  
    if (textView.text.length == 0 || [textView.text isEqualToString:@"#"]) {
        [values removeObjectForKey:@"keywords"];

        textView.text = @"";
        
        textView.textColor = [UIColor colorWithRed:184/255.0 green:185/255.0 blue:186/255.0 alpha:1];
        textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    }
    
    NSString *lastCharacter = [textView.text substringWithRange:NSMakeRange([textView.text length]-1, 1)];

    NSMutableString *mutableStr =[[NSMutableString alloc]initWithString:textView.text];
    
    if ([lastCharacter isEqualToString:@"#"]) {
        [mutableStr deleteCharactersInRange:NSMakeRange([textView.text length]-2, 2)];
        textView.text = mutableStr;
    }
}

-(void)hideDatePicker{
    UIView *pickerBGV = (id)[self.view viewWithTag:92];
    [datePicker setHidden:YES animated:YES];
    
    [UIView animateWithDuration:0.4f
                     animations:^
     {
         pickerBGV.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
     }
                     completion:^(BOOL finished)
     {
         [datePicker removeFromSuperview];
         [pickerBGV removeFromSuperview];
     }
     ];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DatePickerDone" object:nil];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yyyy-HH:mm"];
    
    
    for (UIView *v1 in self.containerScrollV.subviews) {
        
        for (UIView *v2 in v1.subviews) {
            
            if ([v2 isKindOfClass:[UITextField class]] && [v2 tag]==2) {
                [df setDateFormat:@"dd/MM/yyyy-HH:mm-ZZ"];
                NSString *date = [NSString stringWithFormat:@"%@",[df stringFromDate:datePicker.date]];
                
                NSTimeInterval timestamp = [datePicker.date timeIntervalSince1970];
                float timezoneoffset = ([[NSTimeZone systemTimeZone] secondsFromGMT])/60;
                [df setDateFormat:@"dd/MM/yyyy HH:mm ZZ"];
                
                [values setObject:[NSString stringWithFormat:@"%d",(int)timestamp] forKey:@"timestamp"];
                [values setObject:[NSString stringWithFormat:@"%d",(int)timezoneoffset] forKey:@"utcoffset"];
                
                [(UITextField *)v2 setText:[NSString stringWithFormat:@"%@",[df stringFromDate:datePicker.date]]];
                
               // [(UITextField *)v2 setTextColor:[UIColor colorWithRed:240/255.0 green:208/255.0 blue:0 alpha:1]];
                
                [(UITextField *)v2 setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:15]];
                
                [self validTextfield:(UITextField *)v2];
            }
        }
    }
    
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = self.scrollV.frame.size.width; // you need to have a **iVar** with getter for scrollView
    float fractionalPage = self.scrollV.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    self.imagesPageControl.currentPage = page;
}

- (IBAction)releaseKeyborad:(id)sender {
   
    for (UIView *subV in self.tagsV.subviews) {
        UITextView *txtV = (id)subV;
        [txtV resignFirstResponder];
    }
    
    [[self.titleBGV viewWithTag:1] resignFirstResponder];
    [[self.whereBGV viewWithTag:3] resignFirstResponder];

    [self.containerScrollV setContentOffset:CGPointZero animated:YES];
}

- (IBAction)close:(id)sender {
    
    [UIView animateWithDuration:0.3f
                     animations:^
     {
         self.blurContainerV.alpha = 0;
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.4f
                          animations:^
          {
              self.view.frame = CGRectMake(0, self.view.frame.size.height,self.view.frame.size.width , self.view.frame.size.height);
          }
                          completion:^(BOOL finished)
          {
              [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
              
              [self removeFromParentViewController];
              [self.view removeFromSuperview];
          }
          ];
     }
     ];
   
}

- (IBAction)nextPressed:(UIButton *)sender {
 
    //adjust format of keywords
    @try {
    
        NSMutableString *keywords = [[NSMutableString alloc]init];
        
        for (NSString *tag in predefinedTags) {
             [keywords appendFormat:@"%@,",[tag stringByReplacingOccurrencesOfString:@"#" withString:@""]];
        }
    
        NSString *keywords_comma  = [values objectForKey:@"keywords"];
        
        if (keywords_comma) {
            NSArray *words = [keywords_comma componentsSeparatedByString:@"#"];
            
            for (NSString *word in words)  {
                NSString *formatted_word = [word stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                if (formatted_word.length != 0) {
                    NSString *trimmedSpaces = [self string:formatted_word ByTrimmingTrailingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [keywords appendFormat:@"%@,",trimmedSpaces];
                }
            }
        
        }
        
        if (keywords.length > 0) {
            
            NSString *lastCharacter = [keywords substringWithRange:NSMakeRange([keywords length]-1, 1)];
            
            if ([lastCharacter isEqualToString:@","]) {
                [keywords deleteCharactersInRange:NSMakeRange([keywords length]-1, 1)];
            }
            
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Hashtags" message:@"Please select at least one Hashtag or select Other to type your own hashtags" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        [values setObject:keywords forKey:@"keywords"];
      
        [values setObject:[[DTO sharedDTO] urlencode:@"http://www.beeeper.com"] forKey:@"src"];
        
        BOOL proceed = [self areAllDataAvailable:values];
        
        if (proceed) {
            
            UIActivityIndicatorView *activityInd = [[UIActivityIndicatorView alloc]initWithFrame:sender.bounds];
            activityInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            [sender setTitle:@"" forState:UIControlStateNormal];
            [sender addSubview:activityInd];
            [activityInd startAnimating];
            
            [[BPCreate sharedBP]eventCreate:values completionBlock:^(BOOL completed,id objs){
                
                [activityInd stopAnimating];
                [activityInd removeFromSuperview];
                [sender setTitle:@"NEXT" forState:UIControlStateNormal];
                
                if (completed) {
                   
                    id tml;
                    
                    if ([objs isKindOfClass:[NSArray class]]) {
                        tml = [(NSArray *)objs firstObject];
                    }
                    else{
                        tml = objs;
                    }
                    
                    [[TabbarVC sharedTabbar]reBeeepPressed:tml image:nil controller:self];
                
                }
                else{
                    
                    Reachability *reachability = [Reachability reachabilityForInternetConnection];
                    [reachability startNotifier];
                    
                    NetworkStatus status = [reachability currentReachabilityStatus];
                    
                    if(status != NotReachable)
                    {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:([objs isKindOfClass:[NSString class]])?objs:@"Something went wrong. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                }
                
                [activityInd removeFromSuperview];
                [sender setTitle:@"NEXT" forState:UIControlStateNormal];
            }];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Missing information" message:@"Please make sure you entered all required information." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }

    }
    @catch (NSException *exception) {
        NSLog(@"ESKASE");
    }
    @finally {
    
    }
}

-(BOOL)areAllDataAvailable:(NSMutableDictionary *)values{
    
    BOOL mpike = NO;
    
    if (![values objectForKey:@"title"]) {
        [self invalidTextfield:self.titleTxtF];
        mpike = YES;
    }
    else{
        
//        NSString *title = [values objectForKey:@"title"];
//        title = [[DTO sharedDTO] urlencode:title];
//        [values setObject:title forKey:@"title"];
//        
        [self validTextfield:self.titleTxtF];
    }
    if (![values objectForKey:@"timestamp"]) {
        [self invalidTextfield:self.dateTxtF];
        mpike = YES;
    }
    else{
        [self validTextfield:self.dateTxtF];
    }

    if (![values objectForKey:@"station"]) {
        [self invalidTextfield:self.venueTxtF];
        mpike = YES;
    }
    else{
        [self validTextfield:self.venueTxtF];
    }
    
    
    if (base64Image) {
        [values setObject:base64Image forKey:@"base64_image"];
       
        //self.addPhotoBGV.borderColor = [UIColor clearColor];
    }
    else if (![values objectForKey:@"image_url"]){
        //self.addPhotoBGV.borderColor = [UIColor colorWithRed:220/255.0 green:61/255.0 blue:61/255.0 alpha:1];
        mpike = YES;
    }
    else{
        //self.addPhotoBGV.borderColor = [UIColor clearColor];
    }
    

    
    BOOL haskeywords = ([values objectForKey:@"keywords"] != nil || predefinedTags.count > 0);
    
    if (haskeywords) {
        if (values.allKeys.count == 13) {
            return YES;
        }
    }
    else{
        if (values.allKeys.count == 12) {
            return YES;
        }
    }
    
    return NO;

}

-(void)invalidTextfield:(UITextField *)txtF{
    
    TKRoundedView *backV = (id)txtF.superview;
    [self.containerScrollV bringSubviewToFront:backV];
    
    backV.borderWidth = 1.0;
    
    [UIView animateWithDuration:0.3f
                     animations:^
     {    backV.borderColor = [UIColor redColor];
     }
                     completion:^(BOOL finished)
     {
     }
     ];
}

-(void)validTextfield:(UITextField *)txtF{
    
    TKRoundedView *backV = (id)txtF.superview;
    [self.containerScrollV sendSubviewToBack:backV];
    
    [UIView animateWithDuration:0.3f
                     animations:^
     {
        backV.borderColor = [UIColor whiteColor];
     }
                     completion:^(BOOL finished)
     {
     }
     ];

}

- (void)imageSelected{
  
//    self.addPhotoBGV.borderColor = [UIColor colorWithRed:240/255.0 green:208/255.0 blue:0 alpha:1];
}


- (IBAction)addPhotoPressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose Existing",@"Search Web", nil];
        [popup showInView:self.view];
    }
    else{
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose Existing",@"Search Web", nil];
        [popup showInView:self.view];
    }
    
    
}

- (IBAction)tagSelected:(UIButton *)sender {
   
    NSString *tag = [sender titleForState:UIControlStateNormal];
    
    if ([predefinedTags indexOfObject:tag] == NSNotFound) {
        [predefinedTags addObject:tag];
        
        [sender setTitleColor:[UIColor colorWithRed:132/255.0 green:139/255.0 blue:145/255.0 alpha:1] forState:UIControlStateNormal];
    }
    else{
        [predefinedTags removeObject:tag];
        
        [sender setTitleColor:[UIColor colorWithRed:207/255.0 green:208/255.0 blue:209/255.0 alpha:1] forState:UIControlStateNormal];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    
    if (buttonIndex != actionSheet.cancelButtonIndex && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera                                  ]) {
        
        switch (buttonIndex) {
            case 0: //Take Photo
            {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    
                    [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
                }
            }
                break;
            case 1: //Choose existing
            {
                 [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            }
                break;
            case 2://search web
            {
               
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                
                DZNPhotoPickerController *picker = [[DZNPhotoPickerController alloc] init];
                picker.supportedServices = DZNPhotoPickerControllerServiceGoogleImages ;
                picker.allowsEditing = YES;
                picker.delegate = self;
                picker.initialSearchTerm = [values objectForKey:@"title"];
                picker.cropMode = DZNPhotoEditorViewControllerCropModeCustom;
                picker.cropSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.width /1.5384);
                picker.enablePhotoDownload = YES;
                picker.supportedLicenses = DZNPhotoPickerControllerCCLicenseBY_ALL;
                
                picker.finalizationBlock = ^(DZNPhotoPickerController *picker, NSDictionary *info) {
                    [self userPickedPhoto:info];
                    [picker dismissViewControllerAnimated:YES completion:NULL];
                };
                
                picker.cancellationBlock = ^(DZNPhotoPickerController *picker) {
                     [picker dismissViewControllerAnimated:YES completion:NULL];
                };
                
                [self presentViewController:picker animated:YES completion:NULL];
            }
                break;
            default:
                break;
        }
    }
    else{
        
        switch (buttonIndex) {
            case 0: //Choose existing
            {
               [self presentImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            }
                break;
            case 1://search web
            {
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
                
                DZNPhotoPickerController *picker = [[DZNPhotoPickerController alloc] init];
                picker.supportedServices = DZNPhotoPickerControllerServiceGoogleImages ;
                picker.allowsEditing = YES;
                picker.delegate = self;
                picker.cropMode = DZNPhotoEditorViewControllerCropModeCustom;
                picker.cropSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.width /1.5384);
                picker.enablePhotoDownload = YES;
                picker.initialSearchTerm = [values objectForKey:@"title"];
                picker.supportedLicenses = DZNPhotoPickerControllerCCLicenseBY_ALL;
                
                picker.finalizationBlock = ^(DZNPhotoPickerController *picker, NSDictionary *info) {
                    [self userPickedPhoto:info];
                    [picker dismissViewControllerAnimated:YES completion:NULL];
                };
                
                picker.cancellationBlock = ^(DZNPhotoPickerController *picker) {
                    [picker dismissViewControllerAnimated:YES completion:NULL];
                };
                
                [self presentViewController:picker animated:YES completion:NULL];
            }
                break;
            default:
                break;
        }

    }
}

-(void)userPickedPhoto:(NSDictionary *)info{
   
    @try {
        NSDictionary *info_values = [info objectForKey:@"DZNPhotoPickerControllerPhotoMetadata"];
        NSURL *image_url = [info_values objectForKey:@"source_url"];
        
        UIImage *img = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        
       // self.addPhotoBGV.frame = CGRectMake(self.selectedPhotoButton.frame.origin.x+self.selectedPhotoButton.frame.size.width+11, self.addPhotoBGV.frame.origin.y, self.addPhotoBGV.frame.size.width, self.addPhotoBGV.frame.size.height);
        
//        self.selectedPhotoButton.layer.borderWidth = 1;
//        self.selectedPhotoButton.layer.borderColor = [UIColor whiteColor].CGColor;

//        self.selectedPhotoButton.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
//        self.selectedPhotoButton.layer.shadowOpacity = 0.7;
//        self.selectedPhotoButton.layer.shadowOffset = CGSizeMake(0, 0.1);
//        self.selectedPhotoButton.layer.shadowRadius = 0.8;

        
        [self.selectedPhotoButton setBackgroundImage:img forState:UIControlStateNormal];
        self.selectedPhotoButton.hidden = NO;
        
        //[self.scrollV setContentSize:CGSizeMake(749, self.scrollV.contentSize.height)];
        //[self.scrollV setContentOffset:CGPointMake((self.scrollV.contentSize.width - CGRectGetWidth(self.scrollV.frame)), 0.0)];
        
        if (image_url == nil) {
            NSData *imageData = UIImageJPEGRepresentation(img, 0.8);
            base64Image = [self base64forData:imageData];
            [values removeObjectForKey:@"image_url"];
        }
        else{
            base64Image = nil;
             [values setObject:[[DTO sharedDTO] urlencode:image_url.absoluteString] forKey:@"image_url"];
        }
        
        [self imageSelected];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Something went wrong,please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    @finally {
        
    }
    
}


- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

- (NSString*)base64forData:(NSData*)theData {
    
    const uint8_t* input = (const uint8_t*)[theData bytes];
	NSInteger length = [theData length];
	
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
	
	NSInteger i,i2;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
		for (i2=0; i2<3; i2++) {
            value <<= 8;
            if (i+i2 < length) {
                value |= (0xFF & input[i+i2]);
            }
        }
		
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
	
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

}

# pragma mark -
# pragma mark GKImagePicker Delegate Methods

- (void)imagePicker:(UIImagePickerController *)imagePicker pickedImage:(UIImage *)image{

    NSLog(@"%@",NSStringFromCGSize(image.size));
    UIButton *chosenPhotoBtn = (id)[self.addPhotoBGV viewWithTag:6];
    [chosenPhotoBtn setImage:image forState:UIControlStateNormal];
    chosenPhotoBtn.hidden = NO;
    [chosenPhotoBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
 
    //[self.scrollV setContentSize:CGSizeMake(749, self.scrollV.contentSize.height)];
    //[self.scrollV setContentOffset:CGPointMake((self.scrollV.contentSize.width - CGRectGetWidth(self.scrollV.frame)), 0.0)];
    
    [values removeObjectForKey:@"image_url"];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    base64Image = [self base64forData:imageData];
    
    [self imageSelected];
}


- (void)presentImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.allowsEditing = NO;
    picker.cropMode = DZNPhotoEditorViewControllerCropModeCustom;
    picker.delegate = self;
   // picker.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:picker animated:YES completion:NULL];
    
    // picker.editingMode = DZNPhotoEditViewControllerCropModeSquare;
    /*picker.finalizationBlock = ^(UIImagePickerController *picker, NSDictionary *info) {
     //   [self handleImagePicker:picker withMediaInfo:info];
    };
    
    picker.cancellationBlock = ^(UIImagePickerController *picker) {
     //   [self dismissController:picker];
    };*/
 
}

-(void)imagePickerController:
(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if ([info objectForKey:UIImagePickerControllerEditedImage] == nil) {
        DZNPhotoEditorViewController *editor = [[DZNPhotoEditorViewController alloc] initWithImage:image cropMode:DZNPhotoEditorViewControllerCropModeCustom cropSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.width /1.5384)];
        [picker pushViewController:editor animated:YES];
        return;
    }
    
    
    [self userPickedPhoto:info];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


# pragma mark -
# pragma mark UIImagePickerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
  
    UIButton *chosenPhotoBtn = (id)[self.addPhotoBGV viewWithTag:6];
    [chosenPhotoBtn setImage:image forState:UIControlStateNormal];
    [chosenPhotoBtn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    chosenPhotoBtn.hidden = NO;
    
  
    //[self.scrollV setContentSize:CGSizeMake(749, self.scrollV.contentSize.height)];
    //[self.scrollV setContentOffset:CGPointMake((self.scrollV.contentSize.width - CGRectGetWidth(self.scrollV.frame)), 0.0)];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    base64Image = [self base64forData:imageData];
    
    [self imageSelected];

}

- (NSString *)string:(NSString *)str ByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet {
    NSUInteger location = 0;
    NSUInteger length = [str length];
    unichar charBuffer[length];
    [str getCharacters:charBuffer];
    
    for (length; length > 0; length--) {
        if (![characterSet characterIsMember:charBuffer[length - 1]]) {
            break;
        }
    }
    
    return [str substringWithRange:NSMakeRange(location, length - location)];
}



@end
