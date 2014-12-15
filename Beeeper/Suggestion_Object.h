//
//  Suggestion_Object.h
//
//  Created by George Termentzoglou on 6/18/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Who.h"
#import "What_Suggest.h"

@interface Suggestion_Object : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *did;
@property (nonatomic, strong) Who *who;
@property (nonatomic, strong) What_Suggest *what;
@property (nonatomic, strong) NSString *hashTags;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, assign) double when;
@property (nonatomic, strong) NSMutableArray *beeepersIds;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
