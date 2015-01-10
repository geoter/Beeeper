//
//  ViewController.m
//  GMGoogleImageSearchAPI
//
//  Created by GreekMinds on 12/23/14.
//  Copyright (c) 2014 GreekMinds. All rights reserved.
//

#import "GMGoogleImageSearchVC.h"
#import "AFNetworking/AFNetworking.h"
#import "GoogleImageSearchAPIObject.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "DZNPhotoEditorViewController.h"

@interface GMGoogleImageSearchVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate,UIScrollViewDelegate,UIScrollViewDelegate>
{
    UITapGestureRecognizer *tapG;
    NSIndexPath *selectedIndex;
    BOOL firstTime;
}
@property(nonatomic,strong) NSMutableArray *images;
@end

@implementation GMGoogleImageSearchVC
@synthesize images;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.searchBar addTarget:self action:@selector(searchStringChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPickImage:) name:DZNPhotoPickerDidFinishPickingNotification object:nil];
    
    firstTime = YES;

}

- (void)didPickImage:(NSNotification *)notification
{
    NSDictionary *userinfo = notification.userInfo;
    
    [self donePressed:[userinfo objectForKey:UIImagePickerControllerEditedImage]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DZNPhotoPickerDidFinishPickingNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (firstTime) {
        [self searchForTerm:self.initialSearchTerm];
        self.searchBar.text = self.initialSearchTerm;
        [self.searchBar becomeFirstResponder];
        firstTime = NO;
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
  
    GoogleImageSearchAPIObject *object = [images objectAtIndex:indexPath.row];
    
    UIImageView *imgV = (id)[cell viewWithTag:1];
    
    [imgV sd_setImageWithURL:[NSURL URLWithString:[self fixLink:object.url]]
            placeholderImage:[UIImage imageNamed:@"event_image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
            }];
    
    return cell;
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    return UIEdgeInsetsMake(0, 7, 3, 7);
//}





-(void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedIndex = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    
    GoogleImageSearchAPIObject *object = [images objectAtIndex:indexPath.row];
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    UIImageView *imgV = (id)[cell viewWithTag:1];
    
    [self donePressed:imgV];
}


#pragma mark - Search

#pragma mark - SearchField

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (tapG == nil) {
        tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(releaseSearch:)];
    }
    
    [self.collectionV addGestureRecognizer:tapG];
    
    
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    [self resetSearch];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.collectionV removeGestureRecognizer:tapG];
    
    [textField resignFirstResponder];
    return YES;
}

-(void)searchStringChanged:(UITextField *)txtF{
    
    if (txtF.text.length == 0) {
        [self resetSearch];
        return;
    }
    
    [self searchForTerm:txtF.text];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString * searchStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (searchStr.length < 2) {
        if (searchStr.length == 0) {
            [self resetSearch];
        }
    }
    
    return YES;
}



- (IBAction)releaseSearch:(id)sender {
    [self.searchBar resignFirstResponder];
    [self.collectionV removeGestureRecognizer:tapG];
}

-(void)resetSearch{
    
    tapG.enabled = NO;
    
    [self.images removeAllObjects];
    
     self.noResultsLabel.hidden = YES;
    
    [self.collectionV reloadData];
}


-(void)searchForTerm:(NSString *)term{
    
    if (term == nil) {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&rsz=8",[self urlencode:term]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        dispatch_async (dispatch_get_main_queue(), ^{
            [self.activityIndicator stopAnimating];
        });

        
        @try {
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[operation responseData] options:0 error:nil];
            
            NSDictionary *responseData = [response objectForKey:@"responseData"];
            NSArray *results = [responseData objectForKey:@"results"];
            
            self.images = [NSMutableArray array];
            
            if (results.count == 0) {
                
                dispatch_async (dispatch_get_main_queue(), ^{
                    self.collectionV.alpha = 0;
                    self.noResultsLabel.hidden = NO;
                    self.pageControl.hidden = YES;
                    
                });
                
                return;
            }
            
            for (NSDictionary *dict in results) {
                [self.images addObject:[GoogleImageSearchAPIObject modelObjectWithDictionary:dict]];
            }
            
            dispatch_async (dispatch_get_main_queue(), ^{
                [self.collectionV reloadData];
                self.collectionV.alpha = 1;
                self.noResultsLabel.hidden = YES;
                self.pageControl.hidden = NO;
                self.pageControl.numberOfPages = self.images.count;
            
            });
        }
        @catch (NSException *exception) {
            dispatch_async (dispatch_get_main_queue(), ^{
                self.collectionV.alpha = 0;
                self.noResultsLabel.hidden = NO;
                self.pageControl.hidden = YES;
            });
        }
        @finally {
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
      
    }];

}

-(void)createFullScreen:(int)initialImage{
    
    [self.scrollV.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.scrollV.contentSize = CGSizeZero;
    
    for (GoogleImageSearchAPIObject *object in images) {
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:self.scrollV.bounds];
        imgV.frame = CGRectMake(self.scrollV.contentSize.width, 0, self.scrollV.frame.size.width, self.scrollV.frame.size.height);
        imgV.tag = [images indexOfObject:object]+1;
        imgV.contentMode = UIViewContentModeScaleAspectFit;
        [imgV sd_setImageWithURL:[NSURL URLWithString:[self fixLink:object.url]]
                placeholderImage:[UIImage imageNamed:@"event_image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            dispatch_async (dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
            });}];
        
        [self.scrollV addSubview:imgV];
        self.scrollV.contentSize = CGSizeMake(imgV.frame.origin.x+imgV.frame.size.width,self.scrollV.frame.size.height);
    }
    
    [self.scrollV setContentOffset:CGPointMake(initialImage*self.scrollV.frame.size.width, 0)];
}

- (NSString *)urlencode:(NSString *)str {
    CFStringRef safeString =
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef)str,
                                            NULL,
                                            CFSTR("/%&=?$#+-~@<>|\*,()[]{}^!:;'"),
                                            kCFStringEncodingUTF8);
    return [NSString stringWithFormat:@"%@", safeString];
}

- (NSString *)fixLink:(NSString *)link{
    
    @try {
        
        link = [link stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        
        if ([[link substringToIndex:2]isEqualToString:@"//"]) {
            NSString *fixedLink = [NSString stringWithFormat:@"http://%@",[link substringFromIndex:2]];
            return fixedLink;
        }
        NSLog(@"%@",link);
        
        return link;
        
    }
    @catch (NSException *exception) {
        return link;
    }
    @finally {
        
    }
}



- (IBAction)donePressed:(id)sender {

    
    if ([sender isKindOfClass:[UIImageView class]]) {
        
        UIImageView *imgV = (UIImageView *)sender;
        
        DZNPhotoEditorViewController *editor = [[DZNPhotoEditorViewController alloc] initWithImage:imgV.image cropMode:DZNPhotoEditorViewControllerCropModeCustom cropSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.width /1.5384)];
        [self.navigationController pushViewController:editor animated:YES];
        
        return;
    }
    
    if ([sender isKindOfClass:[UIImage class]]) {
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:[images objectAtIndex:selectedIndex.row] forKey:@"GoogleSearchImageObject"];
        
        [userInfo setObject:sender forKey:@"GoogleSearchImage"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"GoogleImageSearchResult" object:nil userInfo:userInfo];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancelPressed:(id)sender {
    
    [self.searchBar resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}



- (IBAction)backPressed:(id)sender {
    [UIView animateWithDuration:0.4f
                     animations:^
     {
         self.fullScreenV.alpha = 0;
     }
                     completion:^(BOOL finished)
     {
     }
     ];
}


-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView  {
    NSInteger pageNumber = roundf(scrollView.contentOffset.x / (scrollView.frame.size.width));
    selectedIndex = [NSIndexPath indexPathForRow:pageNumber inSection:selectedIndex.section];
    self.pageControl.currentPage = selectedIndex.row;
}

@end
