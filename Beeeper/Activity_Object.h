//
//  Activity_Object.h
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BeeepInfoActivity.h"
#import "Whom.h"
#import "Who.h"
#import "EventActivity.h"

@interface Activity_Object : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSArray *whom;
@property (nonatomic, strong) NSString *did;
@property (nonatomic, strong) BeeepInfoActivity *beeepInfoActivity;
@property (nonatomic, strong) NSArray *who;
@property (nonatomic, strong) NSArray *eventActivity;
@property (nonatomic, strong) NSString *what;
@property (nonatomic, assign) double when;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
