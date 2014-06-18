//
//  BeeepFfo.h
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Beeeps.h"

@interface BeeepFfo : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSArray *beeeps;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, assign) double eventTime;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
