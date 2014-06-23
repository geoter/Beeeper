//
//  MissingFields.h
//  Beeeper
//
//  Created by George on 6/22/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MissingFieldsDelegate
-(NSDictionary *)fieldsCompleted;
@end

@interface MissingFields : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollV;
@property (nonatomic,strong) NSDictionary *fields;
@property (nonatomic,assign) id delegate;

@end
