//
//  Timeline_Object.h
//
//  Created by George Termentzoglou on 5/13/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "Beeep.h"
#import "Likes.h"

@interface Timeline_Object : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *hashTags;
@property (nonatomic, strong) Beeep *beeep;
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) NSArray *beeepersIds;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
