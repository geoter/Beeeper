//
//  UserActivity.h
//
//  Created by   on 10/13/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface UserActivity : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *userActivityIdentifier;
@property (nonatomic, strong) NSString *lastname;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imagePath;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
