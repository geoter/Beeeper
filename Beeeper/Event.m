//
//  Event.m
//
//  Created by George Termentzoglou on 5/13/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "Event.h"


NSString *const kEventLocked = @"locked";
NSString *const kEventLikesCount = @"likes_count";
NSString *const kEventSource = @"source";
NSString *const kEventLocation = @"location";
NSString *const kEventImageUrl = @"image_url";
NSString *const kEventFingerprint = @"fingerprint";
NSString *const kEventTitle = @"title";
NSString *const kEventDescription = @"description";
NSString *const kEventTimestamp = @"timestamp";
NSString *const kEventLoc = @"loc";
NSString *const kEventUrl = @"url";


@interface Event ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Event

@synthesize locked = _locked;
@synthesize likesCount = _likesCount;
@synthesize source = _source;
@synthesize location = _location;
@synthesize imageUrl = _imageUrl;
@synthesize fingerprint = _fingerprint;
@synthesize title = _title;
@synthesize eventDescription = _eventDescription;
@synthesize timestamp = _timestamp;
@synthesize loc = _loc;
@synthesize url = _url;


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
            self.locked = [[self objectOrNilForKey:kEventLocked fromDictionary:dict] doubleValue];
            self.likesCount = [[self objectOrNilForKey:kEventLikesCount fromDictionary:dict] doubleValue];
            self.source = [self objectOrNilForKey:kEventSource fromDictionary:dict];
            self.location = [self objectOrNilForKey:kEventLocation fromDictionary:dict];
            self.imageUrl = [self objectOrNilForKey:kEventImageUrl fromDictionary:dict];
            self.fingerprint = [self objectOrNilForKey:kEventFingerprint fromDictionary:dict];
            self.title = [self objectOrNilForKey:kEventTitle fromDictionary:dict];
            self.eventDescription = [self objectOrNilForKey:kEventDescription fromDictionary:dict];
            self.timestamp = [[self objectOrNilForKey:kEventTimestamp fromDictionary:dict] doubleValue];
            self.loc = [self objectOrNilForKey:kEventLoc fromDictionary:dict];
            self.url = [self objectOrNilForKey:kEventUrl fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.locked] forKey:kEventLocked];
    [mutableDict setValue:[NSNumber numberWithDouble:self.likesCount] forKey:kEventLikesCount];
    [mutableDict setValue:self.source forKey:kEventSource];
    [mutableDict setValue:self.location forKey:kEventLocation];
    [mutableDict setValue:self.imageUrl forKey:kEventImageUrl];
    [mutableDict setValue:self.fingerprint forKey:kEventFingerprint];
    [mutableDict setValue:self.title forKey:kEventTitle];
    [mutableDict setValue:self.eventDescription forKey:kEventDescription];
    [mutableDict setValue:[NSNumber numberWithDouble:self.timestamp] forKey:kEventTimestamp];
    NSMutableArray *tempArrayForLoc = [NSMutableArray array];
    for (NSObject *subArrayObject in self.loc) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForLoc addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForLoc addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLoc] forKey:kEventLoc];
    [mutableDict setValue:self.url forKey:kEventUrl];

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

    self.locked = [aDecoder decodeDoubleForKey:kEventLocked];
    self.likesCount = [aDecoder decodeDoubleForKey:kEventLikesCount];
    self.source = [aDecoder decodeObjectForKey:kEventSource];
    self.location = [aDecoder decodeObjectForKey:kEventLocation];
    self.imageUrl = [aDecoder decodeObjectForKey:kEventImageUrl];
    self.fingerprint = [aDecoder decodeObjectForKey:kEventFingerprint];
    self.title = [aDecoder decodeObjectForKey:kEventTitle];
    self.eventDescription = [aDecoder decodeObjectForKey:kEventDescription];
    self.timestamp = [aDecoder decodeDoubleForKey:kEventTimestamp];
    self.loc = [aDecoder decodeObjectForKey:kEventLoc];
    self.url = [aDecoder decodeObjectForKey:kEventUrl];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_locked forKey:kEventLocked];
    [aCoder encodeDouble:_likesCount forKey:kEventLikesCount];
    [aCoder encodeObject:_source forKey:kEventSource];
    [aCoder encodeObject:_location forKey:kEventLocation];
    [aCoder encodeObject:_imageUrl forKey:kEventImageUrl];
    [aCoder encodeObject:_fingerprint forKey:kEventFingerprint];
    [aCoder encodeObject:_title forKey:kEventTitle];
    [aCoder encodeObject:_eventDescription forKey:kEventDescription];
    [aCoder encodeDouble:_timestamp forKey:kEventTimestamp];
    [aCoder encodeObject:_loc forKey:kEventLoc];
    [aCoder encodeObject:_url forKey:kEventUrl];
}

- (id)copyWithZone:(NSZone *)zone
{
    Event *copy = [[Event alloc] init];
    
    if (copy) {

        copy.locked = self.locked;
        copy.likesCount = self.likesCount;
        copy.source = [self.source copyWithZone:zone];
        copy.location = [self.location copyWithZone:zone];
        copy.imageUrl = [self.imageUrl copyWithZone:zone];
        copy.fingerprint = [self.fingerprint copyWithZone:zone];
        copy.title = [self.title copyWithZone:zone];
        copy.eventDescription = [self.eventDescription copyWithZone:zone];
        copy.timestamp = self.timestamp;
        copy.loc = [self.loc copyWithZone:zone];
        copy.url = [self.url copyWithZone:zone];
    }
    
    return copy;
}


@end
