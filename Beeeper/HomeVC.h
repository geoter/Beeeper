//
//  HomeVC.h
//  Beeeper
//
//  Created by User on 2/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeVC : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableV;

- (IBAction)showMenu:(id)sender;

//Per Cell methods
- (IBAction)showComments:(id)sender;
@end
