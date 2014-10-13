//
//  BeeepInfoActivity.m
//
//  Created by   on 10/13/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "BeeepInfoActivity.h"



NSString *const kBeeepInfoActivityUserActivity = @"user";
NSString *const kBeeepInfoActivityEventActivity = @"event";
NSString *const kBeeepInfoActivityBeeepActivity = @"beeep";


@interface BeeepInfoActivity ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation BeeepInfoActivity

@synthesize userActivity = _userActivity;
@synthesize eventActivity = _eventActivity;
@synthesize beeepActivity = _beeepActivity;


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
    NSObject *receivedUserActivity = [dict objectForKey:kBeeepInfoActivityUserActivity];
    NSMutableArray *parsedUserActivity = [NSMutableArray array];
    if ([receivedUserActivity isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedUserActivity) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedUserActivity addObject:[UserActivity modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedUserActivity isKindOfClass:[NSDictionary class]]) {
       [parsedUserActivity addObject:[UserActivity modelObjectWithDictionary:(NSDictionary *)receivedUserActivity]];
    }

    self.userActivity = [NSArray arrayWithArray:parsedUserActivity];
    NSObject *receivedEventActivity = [dict objectForKey:kBeeepInfoActivityEventActivity];
    NSMutableArray *parsedEventActivity = [NSMutableArray array];
    if ([receivedEventActivity isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedEventActivity) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedEventActivity addObject:[EventActivity modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedEventActivity isKindOfClass:[NSDictionary class]]) {
       [parsedEventActivity addObject:[EventActivity modelObjectWithDictionary:(NSDictionary *)receivedEventActivity]];
    }

    self.eventActivity = [NSArray arrayWithArray:parsedEventActivity];
    NSObject *receivedBeeepActivity = [dict objectForKey:kBeeepInfoActivityBeeepActivity];
    NSMutableArray *parsedBeeepActivity = [NSMutableArray array];
    if ([receivedBeeepActivity isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedBeeepActivity) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedBeeepActivity addObject:[BeeepActivity modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedBeeepActivity isKindOfClass:[NSDictionary class]]) {
       [parsedBeeepActivity addObject:[BeeepActivity modelObjectWithDictionary:(NSDictionary *)receivedBeeepActivity]];
    }

    self.beeepActivity = [NSArray arrayWithArray:parsedBeeepActivity];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    NSMutableArray *tempArrayForUserActivity = [NSMutableArray array];
    for (NSObject *subArrayObject in self.userActivity) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForUserActivity addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForUserActivity addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForUserActivity] forKey:kBeeepInfoActivityUserActivity];
    NSMutableArray *tempArrayForEventActivity = [NSMutableArray array];
    for (NSObject *subArrayObject in self.eventActivity) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForEventActivity addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForEventActivity addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForEventActivity] forKey:kBeeepInfoActivityEventActivity];
    NSMutableArray *tempArrayForBeeepActivity = [NSMutableArray array];
    for (NSObject *subArrayObject in self.beeepActivity) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForBeeepActivity addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForBeeepActivity addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForBeeepActivity] forKey:kBeeepInfoActivityBeeepActivity];

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

    self.userActivity = [aDecoder decodeObjectForKey:kBeeepInfoActivityUserActivity];
    self.eventActivity = [aDecoder decodeObjectForKey:kBeeepInfoActivityEventActivity];
    self.beeepActivity = [aDecoder decodeObjectForKey:kBeeepInfoActivityBeeepActivity];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_userActivity forKey:kBeeepInfoActivityUserActivity];
    [aCoder encodeObject:_eventActivity forKey:kBeeepInfoActivityEventActivity];
    [aCoder encodeObject:_beeepActivity forKey:kBeeepInfoActivityBeeepActivity];
}

- (id)copyWithZone:(NSZone *)zone
{
    BeeepInfoActivity *copy = [[BeeepInfoActivity alloc] init];
    
    if (copy) {

        copy.userActivity = [self.userActivity copyWithZone:zone];
        copy.eventActivity = [self.eventActivity copyWithZone:zone];
        copy.beeepActivity = [self.beeepActivity copyWithZone:zone];
    }
    
    return copy;
}


@end
