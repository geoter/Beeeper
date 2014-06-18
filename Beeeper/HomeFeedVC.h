//
//  HomeFeedVC.h
//  Beeeper
//
//  Created by User on 3/19/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeFeedVC : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *collectionV;

- (IBAction)beeepPressed:(id)sender;
- (IBAction)eventBeeepPressed:(id)sender;
- (IBAction)showUser:(id)sender;

- (IBAction)showBeeepLikes:(id)sender;
- (IBAction)showBeeepComments:(id)sender;
- (IBAction)showReBeeeps:(id)sender;
@end
