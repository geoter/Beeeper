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

@interface ProfilePrefsVC ()<UITextFieldDelegate,UITextViewDelegate,UINavigationControllerDelegate,DZNPhotoPickerControllerDelegate,UIImagePickerControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>
{
    UIImagePickerController *mediaPicker;
    NSString *base64Image;
    NSDictionary *user;
}
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"HideTabbar" object:self];
    [self adjustFonts];
    [self setUserInfo];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
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
    
    
    user = [BPUser sharedBP].user;
    
    [self downloadUserImageIfNecessery];
    
    
}

-(void)downloadUserImageIfNecessery{
    
    NSString *imagePath = [user objectForKey:@"image_path"];
    
    NSString *extension = [[imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
    
    NSString *imageName = [NSString stringWithFormat:@"%@.%@",[imagePath MD5],extension];
    
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
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]];
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
    
    
    if (textField.superview.frame.origin.y > 200) {
         [self.scrollV setContentOffset:CGPointMake(0, textField.superview.frame.origin.y - 200) animated:YES];
    }
    
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
    }
    
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
                DZNPhotoPickerController *picker = [[DZNPhotoPickerController alloc] init];
                picker.supportedServices = DZNPhotoPickerControllerServiceGoogleImages ;
                picker.allowsEditing = YES;
                picker.delegate = self;
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
                
                [self presentViewController:picker animated:YES completion:NO];            }
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
        
        NSData *imageData = UIImageJPEGRepresentation(img, 1.0);
        base64Image = [self base64forData:imageData];
        
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
