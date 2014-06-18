//
//  Beeep_Object.m
//
//  Created by George Termentzoglou on 6/18/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "Beeep_Object.h"
#import "Comments.h"


NSString *const kBeeep_ObjectEventTime = @"event_time";
NSString *const kBeeep_ObjectLikes = @"likes";
NSString *const kBeeep_ObjectTimestamp = @"timestamp";
NSString *const kBeeep_ObjectWeight = @"weight";
NSString *const kBeeep_ObjectComments = @"comments";
NSString *const kBeeep_ObjectFingerprint = @"fingerprint";


@interface Beeep_Object ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Beeep_Object

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
            self.eventTime = [self objectOrNilForKey:kBeeep_ObjectEventTime fromDictionary:dict];
            self.likes = [self objectOrNilForKey:kBeeep_ObjectLikes fromDictionary:dict];
            self.timestamp = [self objectOrNilForKey:kBeeep_ObjectTimestamp fromDictionary:dict];
            self.weight = [self objectOrNilForKey:kBeeep_ObjectWeight fromDictionary:dict];
    NSObject *receivedComments = [dict objectForKey:kBeeep_ObjectComments];
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
            self.fingerprint = [self objectOrNilForKey:kBeeep_ObjectFingerprint fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.eventTime forKey:kBeeep_ObjectEventTime];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLikes] forKey:kBeeep_ObjectLikes];
    [mutableDict setValue:self.timestamp forKey:kBeeep_ObjectTimestamp];
    [mutableDict setValue:self.weight forKey:kBeeep_ObjectWeight];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForComments] forKey:kBeeep_ObjectComments];
    [mutableDict setValue:self.fingerprint forKey:kBeeep_ObjectFingerprint];

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

    self.eventTime = [aDecoder decodeObjectForKey:kBeeep_ObjectEventTime];
    self.likes = [aDecoder decodeObjectForKey:kBeeep_ObjectLikes];
    self.timestamp = [aDecoder decodeObjectForKey:kBeeep_ObjectTimestamp];
    self.weight = [aDecoder decodeObjectForKey:kBeeep_ObjectWeight];
    self.comments = [aDecoder decodeObjectForKey:kBeeep_ObjectComments];
    self.fingerprint = [aDecoder decodeObjectForKey:kBeeep_ObjectFingerprint];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_eventTime forKey:kBeeep_ObjectEventTime];
    [aCoder encodeObject:_likes forKey:kBeeep_ObjectLikes];
    [aCoder encodeObject:_timestamp forKey:kBeeep_ObjectTimestamp];
    [aCoder encodeObject:_weight forKey:kBeeep_ObjectWeight];
    [aCoder encodeObject:_comments forKey:kBeeep_ObjectComments];
    [aCoder encodeObject:_fingerprint forKey:kBeeep_ObjectFingerprint];
}

- (id)copyWithZone:(NSZone *)zone
{
    Beeep_Object *copy = [[Beeep_Object alloc] init];
    
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
