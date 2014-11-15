//
//  BeeepInfo.h
//
//  Created by George Termentzoglou on 5/13/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface BeeepInfo : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *eventTime;
@property (nonatomic, strong) NSArray *likes;
@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, strong) NSString *weight;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSString *fingerprint;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
