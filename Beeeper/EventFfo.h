//
//  EventFfo.h
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventDetailsFfo.h"

@interface EventFfo : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSArray *beeepedBy;
@property (nonatomic, strong) EventDetailsFfo *eventDetailsFfo;
@property (nonatomic, strong) NSString *hashTags;

- (id) init;
+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
