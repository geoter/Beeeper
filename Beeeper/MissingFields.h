//
//  MissingFields.h
//  Beeeper
//
//  Created by George on 6/22/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MissingFields : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollV;
@property (nonatomic,strong) NSMutableDictionary *fields;
@property (nonatomic,strong) NSMutableDictionary *misssingfields;
@property (nonatomic,assign) id delegate;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

- (IBAction)backpressed:(id)sender;
- (IBAction)joinPressed:(id)sender;

@end
