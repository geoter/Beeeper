//
//  BeeepActivity.h
//
//  Created by   on 10/13/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeeepsActivity.h"


@interface BeeepActivity : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) double eventTime;
@property (nonatomic, strong) NSArray *beeepsActivity;
@property (nonatomic, strong) NSArray *invalidatePush;
@property (nonatomic, strong) NSString *userId;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
