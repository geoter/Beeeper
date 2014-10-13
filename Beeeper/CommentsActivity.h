//
//  CommentsActivity.h
//
//  Created by   on 10/13/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface CommentsActivity : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, assign) double timestamp;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
