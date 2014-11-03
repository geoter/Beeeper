//
//  Activity_Object.h
//
//  Created by   on 10/13/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Whom.h"
#import "EventActivity.h"
#import "Who.h"
#import "BeeepInfoActivity.h"

@interface Activity_Object : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSArray *whom;
@property (nonatomic, strong) NSString *did;
@property (nonatomic, strong) NSString *internalBaseClassIdentifier;
@property (nonatomic, strong) NSArray *eventActivity;
@property (nonatomic, strong) NSString *what;
@property (nonatomic, strong) NSArray *who;
@property (nonatomic, assign) BOOL read;
@property (nonatomic, assign) double when;
@property (nonatomic, strong) BeeepInfoActivity *beeepInfoActivity;
@property (nonatomic, strong) NSArray *beeepNotifications;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
