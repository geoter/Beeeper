//
//  Activity_Object.m
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "Activity_Object.h"



NSString *const kActivity_ObjectWhom = @"whom";
NSString *const kActivity_ObjectDid = @"did";
NSString *const kActivity_ObjectBeeepInfoActivity = @"beeep_info";
NSString *const kActivity_ObjectWho = @"who";
NSString *const kActivity_ObjectEventActivity = @"event";
NSString *const kActivity_ObjectWhat = @"what";
NSString *const kActivity_ObjectWhen = @"when";


@interface Activity_Object ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Activity_Object

@synthesize whom = _whom;
@synthesize did = _did;
@synthesize beeepInfoActivity = _beeepInfoActivity;
@synthesize who = _who;
@synthesize eventActivity = _eventActivity;
@synthesize what = _what;
@synthesize when = _when;


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
    NSObject *receivedWhom = [dict objectForKey:kActivity_ObjectWhom];
    NSMutableArray *parsedWhom = [NSMutableArray array];
    if ([receivedWhom isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedWhom) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedWhom addObject:[Whom modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedWhom isKindOfClass:[NSDictionary class]]) {
       [parsedWhom addObject:[Whom modelObjectWithDictionary:(NSDictionary *)receivedWhom]];
    }

    self.whom = [NSArray arrayWithArray:parsedWhom];
            self.did = [self objectOrNilForKey:kActivity_ObjectDid fromDictionary:dict];
            self.beeepInfoActivity = [BeeepInfoActivity modelObjectWithDictionary:[dict objectForKey:kActivity_ObjectBeeepInfoActivity]];
    NSObject *receivedWho = [dict objectForKey:kActivity_ObjectWho];
    NSMutableArray *parsedWho = [NSMutableArray array];
    if ([receivedWho isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedWho) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedWho addObject:[Who modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedWho isKindOfClass:[NSDictionary class]]) {
       [parsedWho addObject:[Who modelObjectWithDictionary:(NSDictionary *)receivedWho]];
    }

    self.who = [NSArray arrayWithArray:parsedWho];
    NSObject *receivedEventActivity = [dict objectForKey:kActivity_ObjectEventActivity];
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
            self.what = [self objectOrNilForKey:kActivity_ObjectWhat fromDictionary:dict];
            self.when = [[self objectOrNilForKey:kActivity_ObjectWhen fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    NSMutableArray *tempArrayForWhom = [NSMutableArray array];
    for (NSObject *subArrayObject in self.whom) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForWhom addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForWhom addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForWhom] forKey:kActivity_ObjectWhom];
    [mutableDict setValue:self.did forKey:kActivity_ObjectDid];
    [mutableDict setValue:[self.beeepInfoActivity dictionaryRepresentation] forKey:kActivity_ObjectBeeepInfoActivity];
    NSMutableArray *tempArrayForWho = [NSMutableArray array];
    for (NSObject *subArrayObject in self.who) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForWho addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForWho addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForWho] forKey:kActivity_ObjectWho];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForEventActivity] forKey:kActivity_ObjectEventActivity];
    [mutableDict setValue:self.what forKey:kActivity_ObjectWhat];
    [mutableDict setValue:[NSNumber numberWithDouble:self.when] forKey:kActivity_ObjectWhen];

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

    self.whom = [aDecoder decodeObjectForKey:kActivity_ObjectWhom];
    self.did = [aDecoder decodeObjectForKey:kActivity_ObjectDid];
    self.beeepInfoActivity = [aDecoder decodeObjectForKey:kActivity_ObjectBeeepInfoActivity];
    self.who = [aDecoder decodeObjectForKey:kActivity_ObjectWho];
    self.eventActivity = [aDecoder decodeObjectForKey:kActivity_ObjectEventActivity];
    self.what = [aDecoder decodeObjectForKey:kActivity_ObjectWhat];
    self.when = [aDecoder decodeDoubleForKey:kActivity_ObjectWhen];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_whom forKey:kActivity_ObjectWhom];
    [aCoder encodeObject:_did forKey:kActivity_ObjectDid];
    [aCoder encodeObject:_beeepInfoActivity forKey:kActivity_ObjectBeeepInfoActivity];
    [aCoder encodeObject:_who forKey:kActivity_ObjectWho];
    [aCoder encodeObject:_eventActivity forKey:kActivity_ObjectEventActivity];
    [aCoder encodeObject:_what forKey:kActivity_ObjectWhat];
    [aCoder encodeDouble:_when forKey:kActivity_ObjectWhen];
}

- (id)copyWithZone:(NSZone *)zone
{
    Activity_Object *copy = [[Activity_Object alloc] init];
    
    if (copy) {

        copy.whom = [self.whom copyWithZone:zone];
        copy.did = [self.did copyWithZone:zone];
        copy.beeepInfoActivity = [self.beeepInfoActivity copyWithZone:zone];
        copy.who = [self.who copyWithZone:zone];
        copy.eventActivity = [self.eventActivity copyWithZone:zone];
        copy.what = [self.what copyWithZone:zone];
        copy.when = self.when;
    }
    
    return copy;
}


@end
