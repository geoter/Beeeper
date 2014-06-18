//
//  Likers.h
//
//  Created by George Termentzoglou on 5/13/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Likers : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *likersIdentifier;
@property (nonatomic, strong) NSString *lastname;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imagePath;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
