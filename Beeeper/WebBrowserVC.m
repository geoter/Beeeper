//
//  WebBrowserVC.m
//  Beeeper
//
//  Created by George on 9/11/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "WebBrowserVC.h"

@interface WebBrowserVC ()

@end

@implementation WebBrowserVC

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
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

-(void)viewDidAppear:(BOOL)animated{

    
    //URL Requst Object
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.url];
    
    //Load the request in the UIWebView.
    
    [self.webV loadRequest:requestObj];
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark webView Delgate
- (void)webViewDidStartLoad:(UIWebView *)webView{

    dispatch_async(dispatch_get_main_queue(), ^{

        [self.Indicator setHidden:NO];
        [self.Indicator startAnimating];
    });
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    dispatch_async(dispatch_get_main_queue(), ^{
       	[self.Indicator stopAnimating];
        [self.Indicator setHidden:YES];
    });

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
