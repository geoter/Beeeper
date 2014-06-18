//
//  Beeeps.m
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "Beeeps.h"

NSString *const kBeeepsEventTime = @"event_time";
NSString *const kBeeepsLikes = @"likes";
NSString *const kBeeepsTimestamp = @"timestamp";
NSString *const kBeeepsWeight = @"weight";
NSString *const kBeeepsComments = @"comments";
NSString *const kBeeepsFingerprint = @"fingerprint";


@interface Beeeps ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Beeeps

@synthesize eventTime = _eventTime;
@synthesize likes = _likes;
@synthesize timestamp = _timestamp;
@synthesize weight = _weight;
@synthesize comments = _comments;
@synthesize fingerprint = _fingerprint;


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
            self.eventTime = [self objectOrNilForKey:kBeeepsEventTime fromDictionary:dict];
    NSObject *receivedLikes = [dict objectForKey:kBeeepsLikes];
    NSMutableArray *parsedLikes = [NSMutableArray array];
    if ([receivedLikes isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedLikes) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedLikes addObject:[Likes modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedLikes isKindOfClass:[NSDictionary class]]) {
       [parsedLikes addObject:[Likes modelObjectWithDictionary:(NSDictionary *)receivedLikes]];
    }

    self.likes = [NSArray arrayWithArray:parsedLikes];
            self.timestamp = [self objectOrNilForKey:kBeeepsTimestamp fromDictionary:dict];
            self.weight = [self objectOrNilForKey:kBeeepsWeight fromDictionary:dict];
    NSObject *receivedComments = [dict objectForKey:kBeeepsComments];
    NSMutableArray *parsedComments = [NSMutableArray array];
    if ([receivedComments isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedComments) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedComments addObject:[Comments modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedComments isKindOfClass:[NSDictionary class]]) {
       [parsedComments addObject:[Comments modelObjectWithDictionary:(NSDictionary *)receivedComments]];
    }

    self.comments = [NSArray arrayWithArray:parsedComments];
            self.fingerprint = [self objectOrNilForKey:kBeeepsFingerprint fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.eventTime forKey:kBeeepsEventTime];
    NSMutableArray *tempArrayForLikes = [NSMutableArray array];
    for (NSObject *subArrayObject in self.likes) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForLikes addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForLikes addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLikes] forKey:kBeeepsLikes];
    [mutableDict setValue:self.timestamp forKey:kBeeepsTimestamp];
    [mutableDict setValue:self.weight forKey:kBeeepsWeight];
    NSMutableArray *tempArrayForComments = [NSMutableArray array];
    for (NSObject *subArrayObject in self.comments) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForComments addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForComments addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForComments] forKey:kBeeepsComments];
    [mutableDict setValue:self.fingerprint forKey:kBeeepsFingerprint];

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

    self.eventTime = [aDecoder decodeObjectForKey:kBeeepsEventTime];
    self.likes = [aDecoder decodeObjectForKey:kBeeepsLikes];
    self.timestamp = [aDecoder decodeObjectForKey:kBeeepsTimestamp];
    self.weight = [aDecoder decodeObjectForKey:kBeeepsWeight];
    self.comments = [aDecoder decodeObjectForKey:kBeeepsComments];
    self.fingerprint = [aDecoder decodeObjectForKey:kBeeepsFingerprint];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_eventTime forKey:kBeeepsEventTime];
    [aCoder encodeObject:_likes forKey:kBeeepsLikes];
    [aCoder encodeObject:_timestamp forKey:kBeeepsTimestamp];
    [aCoder encodeObject:_weight forKey:kBeeepsWeight];
    [aCoder encodeObject:_comments forKey:kBeeepsComments];
    [aCoder encodeObject:_fingerprint forKey:kBeeepsFingerprint];
}

- (id)copyWithZone:(NSZone *)zone
{
    Beeeps *copy = [[Beeeps alloc] init];
    
    if (copy) {

        copy.eventTime = [self.eventTime copyWithZone:zone];
        copy.likes = [self.likes copyWithZone:zone];
        copy.timestamp = [self.timestamp copyWithZone:zone];
        copy.weight = [self.weight copyWithZone:zone];
        copy.comments = [self.comments copyWithZone:zone];
        copy.fingerprint = [self.fingerprint copyWithZone:zone];
    }
    
    return copy;
}


@end
