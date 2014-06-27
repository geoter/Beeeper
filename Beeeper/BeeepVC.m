//
//  BeeepVC.m
//  Beeeper
//
//  Created by User on 3/19/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "BeeepVC.h"
#import "BeeepItVC.h"
#import "DZNPhotoPickerController.h"
#import "UIImagePickerController+Edit.h"
#import "UIImagePickerController+Block.h"
#import "MyDateTimePicker.h"
#import "Private.h"
#import "LocationManager.h"
#import <AddressBook/AddressBook.h>
#import "BPCreate.h"

@class BorderTextField;
@interface BeeepVC ()<UITextFieldDelegate,UIScrollViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,DZNPhotoPickerControllerDelegate,LocationManagerDelegate,UIAlertViewDelegate,UITextViewDelegate>
{
    NSMutableDictionary *values;
    UIImagePickerController *mediaPicker;
    MyDateTimePicker *datePicker;
    UITextField *activeTXTF;
    LocationManager *locManager;
    NSString *base64Image;
}
@end

@implementation BeeepVC

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

    values = [NSMutableDictionary dictionary];
    
    if ([DTO sharedDTO].userPlace == nil) {
        
        locManager = [[LocationManager alloc]init];
        
        locManager.delegate = self;
        
        [locManager startTracking];
    }
    else{
        [self getLocationInfo:[DTO sharedDTO].userPlace];
    }
    
    self.tagsV.layer.borderColor = [UIColor colorWithRed:221/255.0 green:224/255.0 blue:226/255.0 alpha:1].CGColor;
    self.tagsV.layer.borderWidth = 1;
    self.tagsV.layer.masksToBounds = YES;
    self.tagsV.layer.cornerRadius = 2;

    
    datePicker = [[MyDateTimePicker alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 260)];
    datePicker.tag = 99;
    datePicker.backgroundColor = [UIColor whiteColor];
    
    [DZNPhotoPickerController registerService:DZNPhotoPickerControllerServiceGoogleImages
                                  consumerKey:kGoogleImagesConsumerKey
                               consumerSecret:kGoogleImagesSearchEngineID
                                 subscription:DZNPhotoPickerControllerSubscriptionFree];
    
    self.containerScrollV.contentSize = CGSizeMake(305, 534);
    self.scrollV.contentSize = CGSizeMake(320, self.scrollV.frame.size.height);
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(beeepIt:) name:@"BeeepIt" object:nil];
    [self adjustFonts];
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
    adress = [[placemark addressDictionary] objectForKey:(NSString *)kABPersonAddressStreetKey];
    latitude = [NSNumber numberWithDouble:placemark.location.coordinate.latitude];
    longitude = [NSNumber numberWithDouble:placemark.location.coordinate.longitude];
    
    [values setObject:city forKey:@"city"];
    [values setObject:country forKey:@"country"];
    [values setObject:state forKey:@"state"];
    [values setObject:adress forKey:@"address"];
    [values setObject:[longitude stringValue] forKey:@"longitude"];
    [values setObject:[latitude stringValue] forKey:@"latitude"];
}

- (void)locationError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Location Error" message:@"Please make sure Beeeper can receive your current location." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = 99;
    [alert show];
}

- (void)locationDisabled{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Location Disabled" message:@"Please allow Beeeper to use your current location." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
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

-(void)adjustFonts{
    for (UIView *v in self.containerScrollV.subviews) {
        if ([v isKindOfClass:[UITextField class]]) {
            UITextField *txtF = (UITextField *)v;
            
            switch (txtF.tag) {
                case 1:
                case 2:
                case 3:
                {
                    txtF.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
                }
                break;
                case 4:
                case 5:{
                    txtF.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
                }
                default:
                    break;
            }
        }
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
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
        
        datePicker.frame = CGRectMake(0, self.view.frame.size.height, 320, 260);
        [self.view addSubview:datePicker];
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
        textField.textAlignment = NSTextAlignmentLeft;
        
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
    
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    [self.containerScrollV setContentOffset:CGPointMake(0, 200) animated:YES];
    textView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    textView.textColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:1];
    
    if ([textView.text isEqualToString:@"HASHTAGS (OPTIONAL)"]) {
        textView.text = @"";
    }
    
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    NSString * typedStr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if (typedStr.length == 0) {
        
        //remove value
        [values removeObjectForKey:@"keywords"];
    }
    else{
        //save value
        
        if ([text isEqualToString:@"\n"]) {
            
            [self.containerScrollV setContentOffset:CGPointZero animated:YES];
            [textView resignFirstResponder];
            // Return FALSE so that the final '\n' character doesn't get added
            return NO;
        }
        
        [values setObject:typedStr forKey:@"keywords"];
    }

    
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.text.length == 0) {
        [values removeObjectForKey:@"keywords"];

        textView.text = @"HASHTAGS (OPTIONAL)";
    }
}

-(void)hideDatePicker{
    MyDateTimePicker *picker = (MyDateTimePicker*)[self.view viewWithTag:99];
    [picker setHidden:YES animated:YES];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"DatePickerDone" object:nil];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd/MM/yyyy-HH:mm"];
    
    
    for (UIView *v in self.containerScrollV.subviews) {
        if ([v isKindOfClass:[UITextField class]] && [v tag]==2) {
            [df setDateFormat:@"dd/MM/yyyy-HH:mm-ZZ"];
            NSString *date = [NSString stringWithFormat:@"%@",[df stringFromDate:picker.date]];
            
            NSTimeInterval timestamp = [picker.date timeIntervalSince1970];
            float timezoneoffset = ([[NSTimeZone systemTimeZone] secondsFromGMT])/60;
            [df setDateFormat:@"dd/MM/yyyy HH:mm ZZ"];
            
            [values setObject:[NSString stringWithFormat:@"%d",(int)timestamp] forKey:@"timestamp"];
            [values setObject:[NSString stringWithFormat:@"%d",(int)timezoneoffset] forKey:@"utcoffset"];
            
            [(UITextField *)v setText:[NSString stringWithFormat:@"%@",[df stringFromDate:picker.date]]];
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
    for (UIView *v in self.containerScrollV.subviews) {
        if ([v isKindOfClass:[UITextField class]]) {
            UITextField *txtF = (UITextField *)v;
            [self textFieldShouldReturn:txtF];
        }
    }

}

- (IBAction)close:(id)sender {
    
    [[NSUserDefaults standardUserDefaults]setObject:@"0" forKey:@"dontShowNavOnClose"];
    
    [self.parentViewController.navigationController setNavigationBarHidden:NO animated:YES];
    
    [UIView animateWithDuration:0.4f
                     animations:^
     {
         self.view.frame = CGRectMake(0, self.view.frame.size.height,self.view.frame.size.width , self.view.frame.size.height);
     }
                     completion:^(BOOL finished)
     {
         [self removeFromParentViewController];
         [self.view removeFromSuperview];
     }
     ];
}

- (IBAction)nextPressed:(id)sender {
 
    //adjust format of keywords
    @try {
        
        NSMutableString *keywords = [[NSMutableString alloc]init];
        NSString *keywords_comma  = [values objectForKey:@"keywords"];
        
        if (keywords_comma) {
            NSArray *words = [keywords_comma componentsSeparatedByString:@","];
            
            for (NSString *word in words)  {
                [keywords appendFormat:@"%@,",word];
            }
            [keywords deleteCharactersInRange:NSMakeRange([keywords length]-1, 1)];
        }
        
        [values setObject:keywords forKey:@"keywords"];
        [values setObject:base64Image forKey:@"base64_image"];
        [values setObject:[self urlencode:@"http://www.beeeper.com"] forKey:@"url"];
        
        BOOL proceed = [self areAllDataAvailable:values];
        
        if (proceed) {
            [[BPCreate sharedBP]eventCreate:values completionBlock:^(BOOL completed,id objs){
                
                if (completed) {
                    BeeepItVC *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"BeeepItVC"];
                    
                    if ([objs isKindOfClass:[NSArray class]]) {
                        viewController.values = [(NSArray *)objs firstObject];
                    }
                    else{
                        viewController.values = objs;
                    }
                    
                    if (values == nil) {
                        NSLog(@"NIL values");
                        return;
                    }
                    
                    [viewController.view setFrame:CGRectMake(0, self.view.frame.size.height, 320, viewController.view.frame.size.height)];
    //                [self.view.superview addSubview:viewController.view];
    //                [self.parentViewController addChildViewController:viewController];
    //
    //                
    //                [UIView animateWithDuration:0.4f
    //                                 animations:^
    //                 {
    //                     viewController.view.frame = CGRectMake(0, 0, 320, viewController.view.frame.size.height);
    //                 }
    //                                 completion:^(BOOL finished)
    //                 {
    //                 }
    //                 ];;
                    
                    [self.navigationController presentViewController:viewController animated:YES completion:NULL];
                }
            }];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Missing information" message:@"Please make sure you have entered all required information and location information are available to Beeeper." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }

    }
    @catch (NSException *exception) {
        NSLog(@"ESKASE");
    }
    @finally {
    
    }
    
   
}

-(BOOL)areAllDataAvailable:(NSDictionary *)values{
    if(values.allKeys.count < 14)    return NO;
    else return YES;
}

- (IBAction)imageSelected:(UIButton *)sender {
  
    
    for (UIButton *btn in self.scrollV.subviews) {
        if (btn != sender) {
            btn.layer.borderWidth = 0.0f;
        }
        else{
            sender.layer.borderColor = [UIColor colorWithRed:250/255.0 green:217/255.0 blue:0 alpha:1].CGColor;
            sender.layer.borderWidth = 1.0f;
        }
    }
  
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

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex != actionSheet.cancelButtonIndex && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        mediaPicker = [[UIImagePickerController alloc] init];
        [mediaPicker setDelegate:self];
        mediaPicker.allowsEditing = YES;
        
        
        switch (buttonIndex) {
            case 0: //Take Photo
            {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    mediaPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:mediaPicker animated:YES completion:NULL];
                }
            }
                break;
            case 1: //Choose existing
            {
                mediaPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:mediaPicker animated:YES completion:NULL];
            }
                break;
            case 2://search web
            {
                
                DZNPhotoPickerController *picker = [[DZNPhotoPickerController alloc] init];
                picker.supportedServices = DZNPhotoPickerControllerServiceGoogleImages ;
                picker.allowsEditing = YES;
                picker.delegate = self;
                picker.initialSearchTerm = [values objectForKey:@"title"];
                picker.editingMode = DZNPhotoEditViewControllerCropModeSquare;
                picker.enablePhotoDownload = YES;
                picker.supportedLicenses = DZNPhotoPickerControllerCCLicenseBY_ALL;
                
                picker.finalizationBlock = ^(DZNPhotoPickerController *picker, NSDictionary *info) {
                    [self userPickedPhoto:info];
                    [picker dismissViewControllerAnimated:YES completion:NULL];
                };
                
                picker.cancellationBlock = ^(DZNPhotoPickerController *picker) {
                     [picker dismissViewControllerAnimated:YES completion:NULL];
                };
                
                [self presentViewController:picker animated:YES completion:NO];
            }
                break;
            default:
                break;
        }
    }
    else{
        mediaPicker = [[UIImagePickerController alloc] init];
        [mediaPicker setDelegate:self];
        mediaPicker.allowsEditing = YES;
        
        
        switch (buttonIndex) {
            case 0: //Choose existing
            {
                mediaPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                [self presentViewController:mediaPicker animated:YES completion:NULL];
            }
                break;
            case 1://search web
            {
                
            }
                break;
            default:
                break;
        }

    }
}


-(void)imagePickerController:
(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self userPickedPhoto:info];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)userPickedPhoto:(NSDictionary *)info{
   
    @try {
        NSDictionary *info_values = [info objectForKey:@"DZNPhotoPickerControllerPhotoMetadata"];
        NSURL *image_url = [info_values objectForKey:@"source_url"];
        
        [values setObject:[self urlencode:image_url.absoluteString] forKey:@"image_url"];
        
        UIImage *img = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        UIButton *chosenPhotoBtn = (id)[self.scrollV viewWithTag:6];
        [chosenPhotoBtn setImage:img forState:UIControlStateNormal];
        chosenPhotoBtn.hidden = NO;
        
        UIButton *addPhotoBtn = (id)[self.scrollV viewWithTag:7];
        addPhotoBtn.center = CGPointMake(chosenPhotoBtn.center.x + chosenPhotoBtn.frame.size.width +10, 50);
        //[self.scrollV setContentSize:CGSizeMake(749, self.scrollV.contentSize.height)];
        //[self.scrollV setContentOffset:CGPointMake((self.scrollV.contentSize.width - CGRectGetWidth(self.scrollV.frame)), 0.0)];
        
        NSData *imageData = UIImageJPEGRepresentation(img, 1.0);
        base64Image = [self base64forData:imageData];
        
        [self imageSelected:chosenPhotoBtn];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Something went wrong,please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    @finally {
        
    }
    
}

- (NSString *)urlencode:(NSString *)str {
    CFStringRef safeString =
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef)str,
                                            NULL,
                                            CFSTR("/%&=?$#+-~@<>|\*,()[]{}^!:"),
                                            kCFStringEncodingUTF8);
    return [NSString stringWithFormat:@"%@", safeString];
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
    
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
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



@end
