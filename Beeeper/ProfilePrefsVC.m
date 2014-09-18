//
//  ProfilePrefsVC.m
//  Beeeper
//
//  Created by User on 2/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "ProfilePrefsVC.h"
#import "DZNPhotoPickerController.h"
#import "UIImagePickerController+Edit.h"
#import "UIImagePickerController+Block.h"
#import "SPGooglePlacesAutocompleteDemoViewController.h"
#import "SPGooglePlacesAutocomplete.h"
#import "GKImagePicker.h"

@interface ProfilePrefsVC ()<UITextFieldDelegate,UITextViewDelegate,UINavigationControllerDelegate,DZNPhotoPickerControllerDelegate,UIImagePickerControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,GKImagePickerDelegate>
{
    GKImagePicker *mediaPicker;
    NSString *base64Image;
    NSDictionary *user;
    NSString *gender;
    BOOL changedImage;

}
@property(nonatomic,strong) SVPlacemark *place;
@end

@implementation ProfilePrefsVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

-(void)savePressed{
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [self navigationItem].rightBarButtonItem = barButton;
    [activityIndicator startAnimating];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:self.usernameTextfield.text forKey:@"username"];
    [dict setObject:self.firstNameTextfield.text forKey:@"name"];
    [dict setObject:self.lastNameTextfield.text forKey:@"lastname"];
    [dict setObject:[user objectForKey:@"timezone"] forKey:@"timezone"];
    [dict setObject:[user objectForKey:@"email"] forKey:@"email"];
//    [dict setObject:[user objectForKey:@"password"] forKey:@"password"];
    
    switch (self.segmentControl.selectedSegmentIndex)
    {
        case 0:{

            [dict setObject:@"1" forKey:@"sex"];
            break;
        }
        case 1:{

            [dict setObject:@"0" forKey:@"sex"];
        }
            break;
        default:
            break;
    }
    
    if (self.place != nil) {
            [dict setObject:self.place.locality forKey:@"city"];
            [dict setObject:self.place.subAdministrativeArea forKey:@"state"];
            [dict setObject:self.place.country forKey:@"country"];
        
            NSString *lat = [[NSString alloc] initWithFormat:@"%g", self.place.coordinate.latitude];
            NSString *longitude = [[NSString alloc] initWithFormat:@"%g", self.place.coordinate.longitude];
        
            [dict setObject:lat forKey:@"lat"];
            [dict setObject:longitude forKey:@"long"];
    }
    
    if (base64Image != nil) {
        [dict setObject:base64Image forKey:@"base64_image"];
    }
    
    [[BPUser sharedBP]setUserSettings:dict WithCompletionBlock:^(BOOL completed,NSArray *objs){
        if (completed) { 
            
            [SVProgressHUD showSuccessWithStatus:@"Successfully \nupdated"];
            self.navigationItem.rightBarButtonItem = nil;
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Editing failed" message:@"Something went wrong.Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
            UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                            style:UIBarButtonItemStyleDone target:self action:@selector(savePressed) ];
            self.navigationItem.rightBarButtonItem = rightButton;
        }
    }];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideTabbar" object:self];
    [self adjustFonts];
    [self setUserInfo];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(placeSelected:) name:@"LocationSettingsSelected" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.scrollV.contentSize = CGSizeMake(self.scrollV.frame.size.width, self.scrollV.frame.size.height+1);
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
}


-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)placeSelected:(NSNotification *)notif{
    self.place = [notif.userInfo objectForKey:@"LocationObject"];
   self.locationTxtF.text = self.place.formattedAddress;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(savePressed) ];
    
    self.navigationItem.rightBarButtonItem = rightButton;

}

-(void)adjustFonts{
    
    for(UIView *v in [self.scrollV allSubViews])
    {
        if([v isKindOfClass:[UILabel class]])
        {
            ((UILabel*)v).font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:10];
            
        }
        else if ([v isKindOfClass:[UIButton class]]){
            ((UIButton*)v).titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        }
    }
    
}

-(void)setUserInfo{
    
    @try {
        user = [BPUser sharedBP].user;
        
        [self downloadUserImageIfNecessery];
        
        self.firstNameTextfield.text = [[user objectForKey:@"name"] capitalizedString];
        self.lastNameTextfield.text = [[user objectForKey:@"lastname"] capitalizedString];
        self.usernameTextfield.text = [[user objectForKey:@"username"] capitalizedString];
        self.segmentControl.selectedSegmentIndex = ([user objectForKey:@"sex"] != nil && ![[user objectForKey:@"sex"] isKindOfClass:[NSNull class]] && [[user objectForKey:@"sex"] intValue] == 1)?0:1;
        
        NSString *city = [[user objectForKey:@"city"] capitalizedString];
        NSString *country = [[user objectForKey:@"country"] capitalizedString];
        
        self.locationTxtF.text = [NSString stringWithFormat:@"%@, %@",city,country];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    @finally {
        
    }
    
    
}

-(void)downloadUserImageIfNecessery{
    
    NSString *imagePath = [user objectForKey:@"image_path"];
    
  //  NSString *extension = [[imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
    
    NSString *imageName = [NSString stringWithFormat:@"%@",[imagePath MD5]];
    
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
        UIImage *img = [UIImage imageWithContentsOfFile:localPath];
        self.profileImage.image = img;
    }
    else{
        
        dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(q, ^{
            /* Fetch the image from the server... */
            NSString *imagePath = [user objectForKey:@"image_path"];
            imagePath = [imagePath stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[DTO sharedDTO]fixLink:imagePath]]];
            UIImage *img = [[UIImage alloc] initWithData:data];
            
            [self saveImage:img withFileName:imageName inDirectory:localPath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                /* This is the main thread again, where we set the tableView's image to
                 be what we just fetched. */
                self.profileImage.image = img;
            });
        });
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    

    if (textField.tag == 4) {
         SPGooglePlacesAutocompleteDemoViewController *viewController = [[SPGooglePlacesAutocompleteDemoViewController alloc] init];
        [self.navigationController pushViewController:viewController animated:YES];
        return NO;
    }
    
    if (textField.superview.frame.origin.y > 150) {
        [self.scrollV setContentOffset:CGPointMake(0, textField.superview.frame.origin.y - ((IS_IPHONE_5)?200:130)) animated:YES];
    }
    
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(savePressed) ];
    
    self.navigationItem.rightBarButtonItem = rightButton;

    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{

    if (textField.returnKeyType == UIReturnKeyNext) {
        int nextTag = textField.tag +1;
        UITextField *txtF = (id)[self.scrollV viewWithTag:nextTag];
        [txtF becomeFirstResponder];
    }
    else{
        [textField resignFirstResponder];
    }
    
     [self.scrollV setContentOffset:CGPointZero animated:YES];
    
    

//    if (textField.tag >= 4) {
//          [self.scrollV setContentOffset:CGPointMake(0, self.scrollV.contentSize.height - self.scrollV.frame.size.height) animated:YES];
//    }
//    else{
//        [self.scrollV setContentOffset:CGPointZero animated:YES];
//    }
    
    return YES;
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return YES;
    }
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(savePressed) ];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    return YES;
}


-(void)textViewDidBeginEditing:(UITextView *)textView{
    
    if ([textView.text isEqualToString:@"Enter description"]) {
        textView.text = @"";
    }
    [self.scrollV setContentOffset:CGPointMake(0, textView.frame.origin.y - 100) animated:YES];
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    if (textView.text.length == 0) {
        textView.text = @"Enter description";
    }
}


- (IBAction)changeProfilePicture:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose Existing", nil];
        [popup showInView:self.view];
    }
    else{
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose Existing", nil];
        [popup showInView:self.view];
    }
}

- (IBAction)changedGender:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex)
    {
        case 0:
            gender = @"Male";
            break;
        case 1:
            gender = @"Female";
            break;
        default: 
            break; 
    }
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(savePressed) ];
    
    self.navigationItem.rightBarButtonItem = rightButton;
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    
    mediaPicker = [[GKImagePicker alloc] init];
    mediaPicker.cropSize = CGSizeMake(300,300);
    mediaPicker.delegate = self;
    
    if (buttonIndex != actionSheet.cancelButtonIndex && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        
        switch (buttonIndex) {
            case 0: //Take Photo
            {
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    mediaPicker.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [self presentViewController:mediaPicker.imagePickerController animated:YES completion:NULL];
                }
            }
                break;
            case 1: //Choose existing
            {
                mediaPicker.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:mediaPicker.imagePickerController animated:YES completion:NULL];
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
                mediaPicker.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:mediaPicker.imagePickerController animated:YES completion:NULL];
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

        
      //  [values setObject:[self urlencode:image_url.absoluteString] forKey:@"image_url"];
        
        UIImage *img = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        UIButton *chosenPhotoBtn = (id)[self.scrollV viewWithTag:6];
        [chosenPhotoBtn setImage:img forState:UIControlStateNormal];
        chosenPhotoBtn.hidden = NO;
        
        UIButton *addPhotoBtn = (id)[self.scrollV viewWithTag:7];
        addPhotoBtn.center = CGPointMake(chosenPhotoBtn.center.x + chosenPhotoBtn.frame.size.width +10, 50);
        //[self.scrollV setContentSize:CGSizeMake(749, self.scrollV.contentSize.height)];
        //[self.scrollV setContentOffset:CGPointMake((self.scrollV.contentSize.width - CGRectGetWidth(self.scrollV.frame)), 0.0)];
        
        NSData *imageData = UIImageJPEGRepresentation(img, 0.6);
        base64Image = [self base64forData:imageData];
        
        if (base64Image != nil) {
            UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                            style:UIBarButtonItemStyleDone target:self action:@selector(savePressed) ];
            
            self.navigationItem.rightBarButtonItem = rightButton;
        }
        
        changedImage = YES;
        self.profileImage.image = img;
        
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

- (NSString *)urlencode:(NSString *)str {
    CFStringRef safeString =
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef)str,
                                            NULL,
                                            CFSTR("/%&=?$#+-~@<>|\*,()[]{}^!:"),
                                            kCFStringEncodingUTF8);
    return [NSString stringWithFormat:@"%@", safeString];
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

# pragma mark -
# pragma mark GKImagePicker Delegate Methods

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image{
    
    UIButton *chosenPhotoBtn = (id)[self.scrollV viewWithTag:6];
    [chosenPhotoBtn setImage:image forState:UIControlStateNormal];
    chosenPhotoBtn.hidden = NO;
    
    UIButton *addPhotoBtn = (id)[self.scrollV viewWithTag:7];
    addPhotoBtn.center = CGPointMake(chosenPhotoBtn.center.x + chosenPhotoBtn.frame.size.width +10, 50);
    //[self.scrollV setContentSize:CGSizeMake(749, self.scrollV.contentSize.height)];
    //[self.scrollV setContentOffset:CGPointMake((self.scrollV.contentSize.width - CGRectGetWidth(self.scrollV.frame)), 0.0)];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    base64Image = [self base64forData:imageData];
    
    if (base64Image != nil) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                        style:UIBarButtonItemStyleDone target:self action:@selector(savePressed) ];
        
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    
    changedImage = YES;
    self.profileImage.image = image;
    [self hideImagePicker];

}

- (void)hideImagePicker{
    [mediaPicker.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark -
# pragma mark UIImagePickerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    
    UIButton *chosenPhotoBtn = (id)[self.scrollV viewWithTag:6];
    [chosenPhotoBtn setImage:image forState:UIControlStateNormal];
    chosenPhotoBtn.hidden = NO;
    
    UIButton *addPhotoBtn = (id)[self.scrollV viewWithTag:7];
    addPhotoBtn.center = CGPointMake(chosenPhotoBtn.center.x + chosenPhotoBtn.frame.size.width +10, 50);
    //[self.scrollV setContentSize:CGSizeMake(749, self.scrollV.contentSize.height)];
    //[self.scrollV setContentOffset:CGPointMake((self.scrollV.contentSize.width - CGRectGetWidth(self.scrollV.frame)), 0.0)];
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    base64Image = [self base64forData:imageData];
    
    if (base64Image != nil) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                        style:UIBarButtonItemStyleDone target:self action:@selector(savePressed) ];
        
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    
    changedImage = YES;
    self.profileImage.image = image;
    [self hideImagePicker];
    
}



@end
/*   UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
 style:UIBarButtonItemStyleDone target:self action:@selector(donePressed) ];
 
 self.navigationItem.rightBarButtonItem = rightButton;
 */