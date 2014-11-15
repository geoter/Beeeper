//
//  BeeepInfo.m
//
//  Created by George Termentzoglou on 5/13/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "BeeepInfo.h"
#import "Likes.h"
#import "Comments.h"


NSString *const kBeeepInfoEventTime = @"event_time";
NSString *const kBeeepInfoLikes = @"likes";
NSString *const kBeeepInfoTimestamp = @"timestamp";
NSString *const kBeeepInfoWeight = @"weight";
NSString *const kBeeepInfoComments = @"comments";
NSString *const kBeeepInfoFingerprint = @"fingerprint";


@interface BeeepInfo ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation BeeepInfo

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
            self.eventTime = [self objectOrNilForKey:kBeeepInfoEventTime fromDictionary:dict];
    NSObject *receivedLikes = [dict objectForKey:kBeeepInfoLikes];
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
            self.timestamp = [self objectOrNilForKey:kBeeepInfoTimestamp fromDictionary:dict];
            self.weight = [self objectOrNilForKey:kBeeepInfoWeight fromDictionary:dict];
    NSObject *receivedComments = [dict objectForKey:kBeeepInfoComments];
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

    self.comments = [NSMutableArray arrayWithArray:parsedComments];
            self.fingerprint = [self objectOrNilForKey:kBeeepInfoFingerprint fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.eventTime forKey:kBeeepInfoEventTime];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLikes] forKey:kBeeepInfoLikes];
    [mutableDict setValue:self.timestamp forKey:kBeeepInfoTimestamp];
    [mutableDict setValue:self.weight forKey:kBeeepInfoWeight];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForComments] forKey:kBeeepInfoComments];
    [mutableDict setValue:self.fingerprint forKey:kBeeepInfoFingerprint];

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

    self.eventTime = [aDecoder decodeObjectForKey:kBeeepInfoEventTime];
    self.likes = [aDecoder decodeObjectForKey:kBeeepInfoLikes];
    self.timestamp = [aDecoder decodeObjectForKey:kBeeepInfoTimestamp];
    self.weight = [aDecoder decodeObjectForKey:kBeeepInfoWeight];
    self.comments = [aDecoder decodeObjectForKey:kBeeepInfoComments];
    self.fingerprint = [aDecoder decodeObjectForKey:kBeeepInfoFingerprint];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_eventTime forKey:kBeeepInfoEventTime];
    [aCoder encodeObject:_likes forKey:kBeeepInfoLikes];
    [aCoder encodeObject:_timestamp forKey:kBeeepInfoTimestamp];
    [aCoder encodeObject:_weight forKey:kBeeepInfoWeight];
    [aCoder encodeObject:_comments forKey:kBeeepInfoComments];
    [aCoder encodeObject:_fingerprint forKey:kBeeepInfoFingerprint];
}

- (id)copyWithZone:(NSZone *)zone
{
    BeeepInfo *copy = [[BeeepInfo alloc] init];
    
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
