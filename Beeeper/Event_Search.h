//
//  Event_Search.h
//
//  Created by   on 6/25/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Event_Search : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *internalBaseClassDescription;
@property (nonatomic, strong) NSString *fingerprint;
@property (nonatomic, assign) double timestamp;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSArray *beeepedBy;
@property (nonatomic, assign) double locked;
@property (nonatomic, strong) NSString *hashTags;
@property (nonatomic, strong) NSArray *loc;
@property (nonatomic, assign) double likesCount;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
