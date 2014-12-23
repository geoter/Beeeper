//
//  ViewController.h
//  GMGoogleImageSearchAPI
//
//  Created by GreekMinds on 12/23/14.
//  Copyright (c) 2014 GreekMinds. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GMGoogleImageSearchVC : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *collectionV;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;

@property (weak, nonatomic) IBOutlet UILabel *noResultsLabel;
@property (weak, nonatomic) IBOutlet UIView *fullScreenV;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic,strong) NSString *initialSearchTerm;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollV;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)donePressed:(id)sender;
- (IBAction)cancelPressed:(id)sender;
- (IBAction)backPressed:(id)sender;


@end

