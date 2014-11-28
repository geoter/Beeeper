//
//  GoogleCustomSearchVC.m
//  Beeeper
//
//  Created by George on 9/17/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "GoogleCustomSearchVC.h"
#import "AsyncImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface GoogleCustomSearchVC ()
{
    NSMutableArray *googleReponseArray;
    NSMutableArray *moreButton;
    UITapGestureRecognizer *tapG;
    int currentPage;
    int lastX;
    int lastY;
    int lastHeight;
}
@end

@implementation GoogleCustomSearchVC

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
    
    CALayer *bottomBorder = [CALayer layer];
    
    bottomBorder.frame = CGRectMake(0.0f, self.topV.frame.size.height, self.topV.frame.size.width, 1.0f);
    
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f
                                                     alpha:1.0f].CGColor;
    
    [self.topV.layer addSublayer:bottomBorder];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelPressed:)];
    
    self.navigationItem.rightBarButtonItem = rightItem;
    googleReponseArray = [NSMutableArray array];
    moreButton = [NSMutableArray array];
    
    if (self.initialText) {
         [self getGoogleImagesForQuery:self.initialText withPage:1];
    }
}

-(void)cancelPressed:(UIBarButtonItem *)btn{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

-(void)viewWillAppear:(BOOL)animated{
    
    self.searchField.text = self.initialText;
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{

    if (!tapG) {
        tapG = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(releaseKeyboard)];
    }
   
    for (UIView *v in self.scrollview.subviews) {
        [v setUserInteractionEnabled:NO];
    }
    
    [self.scrollview addGestureRecognizer:tapG];
}


-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    for (UIView *v in self.scrollview.subviews) {
        [v setUserInteractionEnabled:YES];
    }
    
    [self.scrollview removeGestureRecognizer:tapG];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    for (UIView *v in self.scrollview.subviews) {
        [v setUserInteractionEnabled:YES];
    }
    
    [self.scrollview removeGestureRecognizer:tapG];

    [textField resignFirstResponder];
    
    return YES;
}


-(void)releaseKeyboard{
    [self.searchField resignFirstResponder];
}

- (void)getGoogleImagesForQuery:(NSString*)query withPage:(int)page
{
    @try{
        
        if (page == 1) {
            lastX = 5;
            lastY = 5;
            lastHeight = 110;
            
            for (UIView *v in self.scrollview.subviews) {
                [v removeFromSuperview];
            }
        }
    
        int firstImageNumber = page * 6;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:
                                           @"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=6&q=%@&start=%i&&imgsz=medium",query, firstImageNumber]];
        NSLog(@"url is %@",url);
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSLog(@"Request is %@",request);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager GET:url.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            @try {
                
                NSData *responseData = [operation responseData];
                
                NSError *error;
                NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:
                                             responseData options:NSJSONWritingPrettyPrinted error:&error];
                
                NSArray *resultArray = [[responseDic objectForKey:@"responseData"]
                                        objectForKey:@"results"];
                for(int i=0;i<[resultArray count];i++)
                    [googleReponseArray addObject:[resultArray objectAtIndex:i]];
                ;
                
                [self displayImages:resultArray];
                
                currentPage = page+1;
                
                if (currentPage < 5) {
                    [self getGoogleImagesForQuery:query withPage:currentPage];
                }
                
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"fail");
        }];

    }
    
    @catch (NSException *ex) {
        NSLog(@"Exception %@",ex);
    }
}


-(void)displayImages:(NSArray *)images{
    
//    for (UIView *v in self.scrollview.subviews){
//        [v removeFromSuperview];
//    }
    
    self.scrollview.contentInset = UIEdgeInsetsZero;
    
    int x = lastX;
    int y = lastY;
    int height = lastHeight;
    for(int i=0;i<[images count];i++){
        
        if((i != 0) && (i%3==0)){
            x = 5;
            height = height + 105;
            y = y + 105;
            self.scrollview.contentSize = CGSizeMake(320,height);
        }
        
        AsyncImageView* asyncImage = [[AsyncImageView alloc]
                                      initWithFrame:CGRectMake(x, y, 100, 100)];
        asyncImage.contentMode = UIViewContentModeScaleAspectFill;
        asyncImage.clipsToBounds = YES;
        asyncImage.layer.borderColor = [[UIColor grayColor] CGColor];
        asyncImage.layer.borderWidth = 1.0f;
        asyncImage.imageURL = [NSURL URLWithString:
                               [[images objectAtIndex:i]objectForKey:@"tbUrl"]];//tbUrl
        [self.scrollview addSubview:asyncImage];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(x, y, 100, 100);//90,28
        [btn addTarget:self action:@selector(imageSelection:)
                forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [self.scrollview addSubview:btn];
        
        x = x + 105;
        
        lastX = x;
        lastY = y;
        lastHeight = height;
    }
    
}

-(void)imageSelection:(UIButton *)btn{
    
}


#pragma mark - UITextField

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (newString.length%2 == 0 ) {
        [self getGoogleImagesForQuery:newString withPage:1];
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
