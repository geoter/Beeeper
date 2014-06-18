//
//  BeeepInfoActivity.h
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventActivity.h"
#import "UserActivity.h"
#import "BeeepActivity.h"
#import "BeeepsActivity.h"


@interface BeeepInfoActivity : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSArray *eventActivity;
@property (nonatomic, strong) NSArray *userActivity;
@property (nonatomic, strong) NSArray *beeepActivity;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
