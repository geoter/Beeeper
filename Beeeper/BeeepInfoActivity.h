//
//  BeeepInfoActivity.h
//
//  Created by   on 10/13/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserActivity.h"
#import "EventActivity.h"
#import "BeeepActivity.h"

@interface BeeepInfoActivity : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSArray *userActivity;
@property (nonatomic, strong) NSArray *eventActivity;
@property (nonatomic, strong) NSArray *beeepActivity;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
