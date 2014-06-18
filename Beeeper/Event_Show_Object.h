//
//  Event_Show_Object.h
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EventInfo.h"

@interface Event_Show_Object : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *tinyUrl;
@property (nonatomic, strong) NSString *hashTags;
@property (nonatomic, strong) NSString *beeepedBy;
@property (nonatomic, strong) EventInfo *eventInfo;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
