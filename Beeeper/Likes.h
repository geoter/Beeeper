//
//  Likes.h
//
//  Created by George Termentzoglou on 5/13/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Likers.h"

@interface Likes : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *likes;
@property (nonatomic, strong) Likers *likers;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
