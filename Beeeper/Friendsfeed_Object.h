//
//  Friendsfeed_Object.h
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WhoFfo.h"
#import "EventFfo.h"
#import "BeeepFfo.h"

@interface Friendsfeed_Object : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) WhoFfo *whoFfo;
@property (nonatomic, strong) EventFfo *eventFfo;
@property (nonatomic, assign) double when;
@property (nonatomic, strong) BeeepFfo *beeepFfo;

- (id) init;
+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
