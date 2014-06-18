//
//  Beeep.m
//
//  Created by George Termentzoglou on 5/13/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "Beeep.h"
#import "BeeepInfo.h"


NSString *const kBeeepUserId = @"user_id";
NSString *const kBeeepBeeepInfo = @"beeep_info";


@interface Beeep ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Beeep

@synthesize userId = _userId;
@synthesize beeepInfo = _beeepInfo;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.userId = [self objectOrNilForKey:kBeeepUserId fromDictionary:dict];
            self.beeepInfo = [BeeepInfo modelObjectWithDictionary:[dict objectForKey:kBeeepBeeepInfo]];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.userId forKey:kBeeepUserId];
    [mutableDict setValue:[self.beeepInfo dictionaryRepresentation] forKey:kBeeepBeeepInfo];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.userId = [aDecoder decodeObjectForKey:kBeeepUserId];
    self.beeepInfo = [aDecoder decodeObjectForKey:kBeeepBeeepInfo];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_userId forKey:kBeeepUserId];
    [aCoder encodeObject:_beeepInfo forKey:kBeeepBeeepInfo];
}

- (id)copyWithZone:(NSZone *)zone
{
    Beeep *copy = [[Beeep alloc] init];
    
    if (copy) {

        copy.userId = [self.userId copyWithZone:zone];
        copy.beeepInfo = [self.beeepInfo copyWithZone:zone];
    }
    
    return copy;
}


@end
