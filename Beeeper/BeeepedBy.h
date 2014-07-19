//
//  BeeepedBy.h
//
//  Created by   on 6/25/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface BeeepedBy : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *beeepedByIdentifier;
@property (nonatomic, strong) NSString *lastname;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imagePath;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
