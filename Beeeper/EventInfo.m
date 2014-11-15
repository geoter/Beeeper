//
//  EventInfo.m
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "EventInfo.h"
#import "Comments.h"

NSString *const kEventInfoLocked = @"locked";
NSString *const kEventInfoSource = @"source";
NSString *const kEventInfoComments = @"comments";
NSString *const kEventInfoLocation = @"location";
NSString *const kEventInfoImageUrl = @"image_url";
NSString *const kEventInfoTitle = @"title";
NSString *const kEventInfoFingerprint = @"fingerprint";
NSString *const kEventInfoDescription = @"description";
NSString *const kEventInfoTimestamp = @"timestamp";
NSString *const kEventInfoLoc = @"loc";
NSString *const kEventInfoUrl = @"url";
NSString *const kEventInfoLikesCount = @"likes_count";
NSString *const kEventInfoLikes = @"likes";


@interface EventInfo ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation EventInfo

@synthesize comments = _comments;
@synthesize locked = _locked;
@synthesize source = _source;
@synthesize location = _location;
@synthesize imageUrl = _imageUrl;
@synthesize title = _title;
@synthesize fingerprint = _fingerprint;
@synthesize eventInfoDescription = _eventInfoDescription;
@synthesize timestamp = _timestamp;
@synthesize loc = _loc;
@synthesize url = _url;
@synthesize likesCount = _likesCount;
@synthesize likes = _likes;

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
            self.locked = [[self objectOrNilForKey:kEventInfoLocked fromDictionary:dict] doubleValue];
            self.source = [self objectOrNilForKey:kEventInfoSource fromDictionary:dict];
            self.location = [self objectOrNilForKey:kEventInfoLocation fromDictionary:dict];
            self.imageUrl = [self objectOrNilForKey:kEventInfoImageUrl fromDictionary:dict];
            self.title = [self objectOrNilForKey:kEventInfoTitle fromDictionary:dict];
            self.fingerprint = [self objectOrNilForKey:kEventInfoFingerprint fromDictionary:dict];
            self.eventInfoDescription = [self objectOrNilForKey:kEventInfoDescription fromDictionary:dict];
            self.timestamp = [[self objectOrNilForKey:kEventInfoTimestamp fromDictionary:dict] doubleValue];
            self.loc = [self objectOrNilForKey:kEventInfoLoc fromDictionary:dict];
            self.url = [self objectOrNilForKey:kEventInfoUrl fromDictionary:dict];
            self.likesCount = [[self objectOrNilForKey:kEventInfoLikesCount fromDictionary:dict] doubleValue];
            self.likes = [self objectOrNilForKey:kEventInfoLikes fromDictionary:dict];
        
        NSObject *receivedComments = [dict objectForKey:kEventInfoComments];
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
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.locked] forKey:kEventInfoLocked];
    [mutableDict setValue:self.source forKey:kEventInfoSource];
    [mutableDict setValue:self.location forKey:kEventInfoLocation];
    [mutableDict setValue:self.imageUrl forKey:kEventInfoImageUrl];
    [mutableDict setValue:self.title forKey:kEventInfoTitle];
    [mutableDict setValue:self.fingerprint forKey:kEventInfoFingerprint];
    [mutableDict setValue:self.eventInfoDescription forKey:kEventInfoDescription];
    [mutableDict setValue:[NSNumber numberWithDouble:self.timestamp] forKey:kEventInfoTimestamp];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLoc] forKey:kEventInfoLoc];
    [mutableDict setValue:self.url forKey:kEventInfoUrl];
    [mutableDict setValue:[NSNumber numberWithDouble:self.likesCount] forKey:kEventInfoLikesCount];
    
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLikes] forKey:kEventInfoLikes];
    
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForComments] forKey:kEventInfoComments];
    
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

    self.locked = [aDecoder decodeDoubleForKey:kEventInfoLocked];
    self.source = [aDecoder decodeObjectForKey:kEventInfoSource];
    self.location = [aDecoder decodeObjectForKey:kEventInfoLocation];
    self.imageUrl = [aDecoder decodeObjectForKey:kEventInfoImageUrl];
    self.title = [aDecoder decodeObjectForKey:kEventInfoTitle];
    self.fingerprint = [aDecoder decodeObjectForKey:kEventInfoFingerprint];
    self.eventInfoDescription = [aDecoder decodeObjectForKey:kEventInfoDescription];
    self.timestamp = [aDecoder decodeDoubleForKey:kEventInfoTimestamp];
    self.loc = [aDecoder decodeObjectForKey:kEventInfoLoc];
    self.url = [aDecoder decodeObjectForKey:kEventInfoUrl];
    self.likesCount = [aDecoder decodeDoubleForKey:kEventInfoLikesCount];
    self.likes = [aDecoder decodeObjectForKey:kEventInfoLikes];
    self.comments = [aDecoder decodeObjectForKey:kEventInfoComments];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_comments forKey:kEventInfoComments];
    [aCoder encodeObject:_likes forKey:kEventInfoLikes];
    [aCoder encodeDouble:_locked forKey:kEventInfoLocked];
    [aCoder encodeObject:_source forKey:kEventInfoSource];
    [aCoder encodeObject:_location forKey:kEventInfoLocation];
    [aCoder encodeObject:_imageUrl forKey:kEventInfoImageUrl];
    [aCoder encodeObject:_title forKey:kEventInfoTitle];
    [aCoder encodeObject:_fingerprint forKey:kEventInfoFingerprint];
    [aCoder encodeObject:_eventInfoDescription forKey:kEventInfoDescription];
    [aCoder encodeDouble:_timestamp forKey:kEventInfoTimestamp];
    [aCoder encodeObject:_loc forKey:kEventInfoLoc];
    [aCoder encodeObject:_url forKey:kEventInfoUrl];
    [aCoder encodeDouble:_likesCount forKey:kEventInfoLikesCount];
}

- (id)copyWithZone:(NSZone *)zone
{
    EventInfo *copy = [[EventInfo alloc] init];
    
    if (copy) {
       
        copy.comments = [self.comments copyWithZone:zone];
        copy.locked = self.locked;
        copy.source = [self.source copyWithZone:zone];
        copy.location = [self.location copyWithZone:zone];
        copy.imageUrl = [self.imageUrl copyWithZone:zone];
        copy.title = [self.title copyWithZone:zone];
        copy.fingerprint = [self.fingerprint copyWithZone:zone];
        copy.eventInfoDescription = [self.eventInfoDescription copyWithZone:zone];
        copy.timestamp = self.timestamp;
        copy.loc = [self.loc copyWithZone:zone];
        copy.url = [self.url copyWithZone:zone];
         copy.likesCount = self.likesCount;
         copy.likes = [self.likes copyWithZone:zone];
    }
    
    return copy;
}


@end
