//
//  Friendsfeed_Object.m
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "Friendsfeed_Object.h"



NSString *const kFriendsfeed_ObjectWhoFfo = @"who";
NSString *const kFriendsfeed_ObjectEventFfo = @"event";
NSString *const kFriendsfeed_ObjectWhen = @"when";
NSString *const kFriendsfeed_ObjectBeeepFfo = @"beeep";


@interface Friendsfeed_Object ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Friendsfeed_Object

@synthesize whoFfo = _whoFfo;
@synthesize eventFfo = _eventFfo;
@synthesize when = _when;
@synthesize beeepFfo = _beeepFfo;


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
            self.whoFfo = [WhoFfo modelObjectWithDictionary:[dict objectForKey:kFriendsfeed_ObjectWhoFfo]];
            self.eventFfo = [EventFfo modelObjectWithDictionary:[dict objectForKey:kFriendsfeed_ObjectEventFfo]];
            self.when = [[self objectOrNilForKey:kFriendsfeed_ObjectWhen fromDictionary:dict] doubleValue];
            self.beeepFfo = [BeeepFfo modelObjectWithDictionary:[dict objectForKey:kFriendsfeed_ObjectBeeepFfo]];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[self.whoFfo dictionaryRepresentation] forKey:kFriendsfeed_ObjectWhoFfo];
    [mutableDict setValue:[self.eventFfo dictionaryRepresentation] forKey:kFriendsfeed_ObjectEventFfo];
    [mutableDict setValue:[NSNumber numberWithDouble:self.when] forKey:kFriendsfeed_ObjectWhen];
    [mutableDict setValue:[self.beeepFfo dictionaryRepresentation] forKey:kFriendsfeed_ObjectBeeepFfo];

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

    self.whoFfo = [aDecoder decodeObjectForKey:kFriendsfeed_ObjectWhoFfo];
    self.eventFfo = [aDecoder decodeObjectForKey:kFriendsfeed_ObjectEventFfo];
    self.when = [aDecoder decodeDoubleForKey:kFriendsfeed_ObjectWhen];
    self.beeepFfo = [aDecoder decodeObjectForKey:kFriendsfeed_ObjectBeeepFfo];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_whoFfo forKey:kFriendsfeed_ObjectWhoFfo];
    [aCoder encodeObject:_eventFfo forKey:kFriendsfeed_ObjectEventFfo];
    [aCoder encodeDouble:_when forKey:kFriendsfeed_ObjectWhen];
    [aCoder encodeObject:_beeepFfo forKey:kFriendsfeed_ObjectBeeepFfo];
}

- (id)copyWithZone:(NSZone *)zone
{
    Friendsfeed_Object *copy = [[Friendsfeed_Object alloc] init];
    
    if (copy) {

        copy.whoFfo = [self.whoFfo copyWithZone:zone];
        copy.eventFfo = [self.eventFfo copyWithZone:zone];
        copy.when = self.when;
        copy.beeepFfo = [self.beeepFfo copyWithZone:zone];
    }
    
    return copy;
}


@end
