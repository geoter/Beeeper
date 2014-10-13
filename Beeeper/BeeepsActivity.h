//
//  BeeepsActivity.h
//
//  Created by   on 10/13/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface BeeepsActivity : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) double eventTime;
@property (nonatomic, strong) NSArray *likes;
@property (nonatomic, assign) double timestamp;
@property (nonatomic, strong) NSString *weight;
@property (nonatomic, strong) NSArray *commentsActivity;
@property (nonatomic, strong) NSString *fingerprint;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
