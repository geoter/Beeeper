//
//  BeeepsActivity.m
//
//  Created by   on 10/13/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "BeeepsActivity.h"
#import "CommentsActivity.h"


NSString *const kBeeepsActivityEventTime = @"event_time";
NSString *const kBeeepsActivityLikes = @"likes";
NSString *const kBeeepsActivityTimestamp = @"timestamp";
NSString *const kBeeepsActivityWeight = @"weight";
NSString *const kBeeepsActivityCommentsActivity = @"comments";
NSString *const kBeeepsActivityFingerprint = @"fingerprint";


@interface BeeepsActivity ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation BeeepsActivity

@synthesize eventTime = _eventTime;
@synthesize likes = _likes;
@synthesize timestamp = _timestamp;
@synthesize weight = _weight;
@synthesize commentsActivity = _commentsActivity;
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
            self.eventTime = [[self objectOrNilForKey:kBeeepsActivityEventTime fromDictionary:dict] doubleValue];
            self.likes = [self objectOrNilForKey:kBeeepsActivityLikes fromDictionary:dict];
            self.timestamp = [[self objectOrNilForKey:kBeeepsActivityTimestamp fromDictionary:dict] doubleValue];
            self.weight = [self objectOrNilForKey:kBeeepsActivityWeight fromDictionary:dict];
    NSObject *receivedCommentsActivity = [dict objectForKey:kBeeepsActivityCommentsActivity];
    NSMutableArray *parsedCommentsActivity = [NSMutableArray array];
    if ([receivedCommentsActivity isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedCommentsActivity) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedCommentsActivity addObject:[CommentsActivity modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedCommentsActivity isKindOfClass:[NSDictionary class]]) {
       [parsedCommentsActivity addObject:[CommentsActivity modelObjectWithDictionary:(NSDictionary *)receivedCommentsActivity]];
    }

    self.commentsActivity = [NSArray arrayWithArray:parsedCommentsActivity];
            self.fingerprint = [self objectOrNilForKey:kBeeepsActivityFingerprint fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.eventTime] forKey:kBeeepsActivityEventTime];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLikes] forKey:kBeeepsActivityLikes];
    [mutableDict setValue:[NSNumber numberWithDouble:self.timestamp] forKey:kBeeepsActivityTimestamp];
    [mutableDict setValue:self.weight forKey:kBeeepsActivityWeight];
    NSMutableArray *tempArrayForCommentsActivity = [NSMutableArray array];
    for (NSObject *subArrayObject in self.commentsActivity) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForCommentsActivity addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForCommentsActivity addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForCommentsActivity] forKey:kBeeepsActivityCommentsActivity];
    [mutableDict setValue:self.fingerprint forKey:kBeeepsActivityFingerprint];

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

    self.eventTime = [aDecoder decodeDoubleForKey:kBeeepsActivityEventTime];
    self.likes = [aDecoder decodeObjectForKey:kBeeepsActivityLikes];
    self.timestamp = [aDecoder decodeDoubleForKey:kBeeepsActivityTimestamp];
    self.weight = [aDecoder decodeObjectForKey:kBeeepsActivityWeight];
    self.commentsActivity = [aDecoder decodeObjectForKey:kBeeepsActivityCommentsActivity];
    self.fingerprint = [aDecoder decodeObjectForKey:kBeeepsActivityFingerprint];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_eventTime forKey:kBeeepsActivityEventTime];
    [aCoder encodeObject:_likes forKey:kBeeepsActivityLikes];
    [aCoder encodeDouble:_timestamp forKey:kBeeepsActivityTimestamp];
    [aCoder encodeObject:_weight forKey:kBeeepsActivityWeight];
    [aCoder encodeObject:_commentsActivity forKey:kBeeepsActivityCommentsActivity];
    [aCoder encodeObject:_fingerprint forKey:kBeeepsActivityFingerprint];
}

- (id)copyWithZone:(NSZone *)zone
{
    BeeepsActivity *copy = [[BeeepsActivity alloc] init];
    
    if (copy) {

        copy.eventTime = self.eventTime;
        copy.likes = [self.likes copyWithZone:zone];
        copy.timestamp = self.timestamp;
        copy.weight = [self.weight copyWithZone:zone];
        copy.commentsActivity = [self.commentsActivity copyWithZone:zone];
        copy.fingerprint = [self.fingerprint copyWithZone:zone];
    }
    
    return copy;
}


@end
