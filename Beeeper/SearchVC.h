//
//  SearchVC.h
//  Beeeper
//
//  Created by User on 4/2/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchVC : UIViewController
@property (weak, nonatomic) IBOutlet UIView *topV;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapG;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionV;
@property (nonatomic,strong) NSString *initialSearchTerm;


- (IBAction)cancelPressed:(id)sender;
- (IBAction)releaseSearch:(id)sender;

+(void)showInVC:(UIViewController *)vc withSeachTerm:(NSString *)term;

@end
