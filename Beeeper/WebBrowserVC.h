//
//  WebBrowserVC.h
//  Beeeper
//
//  Created by George on 9/11/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebBrowserVC : UIViewController
@property (nonatomic,strong) NSURL *url;
@property (weak, nonatomic) IBOutlet UIWebView *webV;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *Indicator;
@end
