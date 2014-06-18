//
//  CommentsVC.h
//  Beeeper
//
//  Created by User on 3/13/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsVC : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic,strong)  NSMutableArray *comments;
@property (nonatomic,strong) id event_beeep_object;
@end
