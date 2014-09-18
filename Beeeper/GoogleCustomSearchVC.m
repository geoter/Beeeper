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

    [self.scrollview addGestureRecognizer:tapG];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self.scrollview removeGestureRecognizer:tapG];
}

-(void)releaseKeyboard{
    [self.searchField resignFirstResponder];
}

- (void)getGoogleImagesForQuery:(NSString*)query withPage:(int)page
{
    @try{
    
        int firstImageNumber = page * 6;
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:
                                           @"https://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=6&q=%@&start=%i&&imgsz=medium",query, firstImageNumber]];
        NSLog(@"url is %@",url);
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSLog(@"Request is %@",request);
        
        __weak ASIFormDataRequest *requestAsync = [[ASIFormDataRequest alloc]initWithURL:url];
        [requestAsync setRequestMethod:@"GET"];
        [requestAsync setCompletionBlock:^(void){
            [requestAsync responseData];
        }];
        
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request
                                                     returningResponse:nil error:nil];
        NSError *error;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:
                                     responseData options:NSJSONWritingPrettyPrinted error:&error];
        
        NSArray *resultArray = [[responseDic objectForKey:@"responseData"]
                                objectForKey:@"results"];
        for(int i=0;i<[resultArray count];i++)
           [googleReponseArray addObject:[resultArray objectAtIndex:i]];
        ;

        page = page + 1;
        
        if (page < 5) {
            
            [self getGoogleImagesForQuery:query withPage:page];
            
            [self displayImages];
        }
        
    }
    
    @catch (NSException *ex) {
        NSLog(@"Exception %@",ex);
    }
}


-(void)displayImages{
    
    self.scrollview.contentInset = UIEdgeInsetsZero;
    
    int x = 5;
    int y = 5;
    int height = 110;
    for(int i=0;i<[googleReponseArray count];i++){
        
        if((i != 0) && (i%3==0)){
            x = 5;
            height = height + 105;
            y = y + 105;
            self.scrollview.contentSize = CGSizeMake(320,height );
        }
        
        AsyncImageView* asyncImage = [[AsyncImageView alloc]
                                      initWithFrame:CGRectMake(x, y, 100, 100)];
        asyncImage.contentMode = UIViewContentModeScaleAspectFill;
        asyncImage.clipsToBounds = YES;
        asyncImage.layer.borderColor = [[UIColor grayColor] CGColor];
        asyncImage.layer.borderWidth = 1.0f;
        asyncImage.imageURL = [NSURL URLWithString:
                               [[googleReponseArray objectAtIndex:i]objectForKey:@"tbUrl"]];//tbUrl
        [self.scrollview addSubview:asyncImage];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(x, y, 100, 100);//90,28
        [btn addTarget:self action:@selector(imageSelection:)
                forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [self.scrollview addSubview:btn];
        
        x = x + 105;
        
    }
    
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
