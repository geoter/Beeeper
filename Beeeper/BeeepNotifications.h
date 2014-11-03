//
//  BeeepNotifications.h
//
//  Created by   on 10/31/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface BeeepNotifications : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) double eventTime;
@property (nonatomic, strong) NSArray *invalidatePush;
@property (nonatomic, strong) NSArray *beeepObject;
@property (nonatomic, strong) NSString *userId;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
