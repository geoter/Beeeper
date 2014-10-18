//
//  Event_Search.m
//
//  Created by George Termentzoglou on 7/21/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "Event_Search.h"
#import "BeeepedBy.h"
#import "Comments.h"

NSString *const kEvent_SearchDescription = @"description";
NSString *const kEvent_SearchComments = @"comments";
NSString *const kEvent_SearchFingerprint = @"fingerprint";
NSString *const kEvent_SearchTimestamp = @"timestamp";
NSString *const kEvent_SearchImageUrl = @"image_url";
NSString *const kEvent_SearchLikes = @"likes";
NSString *const kEvent_SearchUrl = @"url";
NSString *const kEvent_SearchSource = @"source";
NSString *const kEvent_SearchTitle = @"title";
NSString *const kEvent_SearchLocation = @"location";
NSString *const kEvent_SearchBeeepedBy = @"beeeped_by";
NSString *const kEvent_SearchLocked = @"locked";
NSString *const kEvent_SearchHashTags = @"hash_tags";
NSString *const kEvent_SearchLoc = @"loc";
NSString *const kEvent_SearchLikesCount = @"likes_count";


@interface Event_Search ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Event_Search

@synthesize internalBaseClassDescription = _internalBaseClassDescription;
@synthesize comments = _comments;
@synthesize fingerprint = _fingerprint;
@synthesize timestamp = _timestamp;
@synthesize imageUrl = _imageUrl;
@synthesize likes = _likes;
@synthesize url = _url;
@synthesize source = _source;
@synthesize title = _title;
@synthesize location = _location;
@synthesize beeepedBy = _beeepedBy;
@synthesize locked = _locked;
@synthesize hashTags = _hashTags;
@synthesize loc = _loc;
@synthesize likesCount = _likesCount;


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
            self.internalBaseClassDescription = [self objectOrNilForKey:kEvent_SearchDescription fromDictionary:dict];

        NSObject *receivedComments = [dict objectForKey:kEvent_SearchComments];
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

            self.fingerprint = [self objectOrNilForKey:kEvent_SearchFingerprint fromDictionary:dict];
            self.timestamp = [[self objectOrNilForKey:kEvent_SearchTimestamp fromDictionary:dict] doubleValue];
            self.imageUrl = [self objectOrNilForKey:kEvent_SearchImageUrl fromDictionary:dict];
            self.likes = [self objectOrNilForKey:kEvent_SearchLikes fromDictionary:dict];
            self.url = [self objectOrNilForKey:kEvent_SearchUrl fromDictionary:dict];
            self.source = [self objectOrNilForKey:kEvent_SearchSource fromDictionary:dict];
            self.title = [self objectOrNilForKey:kEvent_SearchTitle fromDictionary:dict];
            self.location = [self objectOrNilForKey:kEvent_SearchLocation fromDictionary:dict];
    NSObject *receivedBeeepedBy = [dict objectForKey:kEvent_SearchBeeepedBy];
    NSMutableArray *parsedBeeepedBy = [NSMutableArray array];
    if ([receivedBeeepedBy isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedBeeepedBy) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedBeeepedBy addObject:[BeeepedBy modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedBeeepedBy isKindOfClass:[NSDictionary class]]) {
       [parsedBeeepedBy addObject:[BeeepedBy modelObjectWithDictionary:(NSDictionary *)receivedBeeepedBy]];
    }

    self.beeepedBy = [NSArray arrayWithArray:parsedBeeepedBy];
            self.locked = [[self objectOrNilForKey:kEvent_SearchLocked fromDictionary:dict] doubleValue];
            self.hashTags = [self objectOrNilForKey:kEvent_SearchHashTags fromDictionary:dict];
            self.loc = [self objectOrNilForKey:kEvent_SearchLoc fromDictionary:dict];
            self.likesCount = [[self objectOrNilForKey:kEvent_SearchLikesCount fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.internalBaseClassDescription forKey:kEvent_SearchDescription];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForComments] forKey:kEvent_SearchComments];
    [mutableDict setValue:self.fingerprint forKey:kEvent_SearchFingerprint];
    [mutableDict setValue:[NSNumber numberWithDouble:self.timestamp] forKey:kEvent_SearchTimestamp];
    [mutableDict setValue:self.imageUrl forKey:kEvent_SearchImageUrl];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLikes] forKey:kEvent_SearchLikes];
    [mutableDict setValue:self.url forKey:kEvent_SearchUrl];
    [mutableDict setValue:self.source forKey:kEvent_SearchSource];
    [mutableDict setValue:self.title forKey:kEvent_SearchTitle];
    [mutableDict setValue:self.location forKey:kEvent_SearchLocation];
    NSMutableArray *tempArrayForBeeepedBy = [NSMutableArray array];
    for (NSObject *subArrayObject in self.beeepedBy) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForBeeepedBy addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForBeeepedBy addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForBeeepedBy] forKey:kEvent_SearchBeeepedBy];
    [mutableDict setValue:[NSNumber numberWithDouble:self.locked] forKey:kEvent_SearchLocked];
    [mutableDict setValue:self.hashTags forKey:kEvent_SearchHashTags];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLoc] forKey:kEvent_SearchLoc];
    [mutableDict setValue:[NSNumber numberWithDouble:self.likesCount] forKey:kEvent_SearchLikesCount];

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

    self.internalBaseClassDescription = [aDecoder decodeObjectForKey:kEvent_SearchDescription];
    self.comments = [aDecoder decodeObjectForKey:kEvent_SearchComments];
    self.fingerprint = [aDecoder decodeObjectForKey:kEvent_SearchFingerprint];
    self.timestamp = [aDecoder decodeDoubleForKey:kEvent_SearchTimestamp];
    self.imageUrl = [aDecoder decodeObjectForKey:kEvent_SearchImageUrl];
    self.likes = [aDecoder decodeObjectForKey:kEvent_SearchLikes];
    self.url = [aDecoder decodeObjectForKey:kEvent_SearchUrl];
    self.source = [aDecoder decodeObjectForKey:kEvent_SearchSource];
    self.title = [aDecoder decodeObjectForKey:kEvent_SearchTitle];
    self.location = [aDecoder decodeObjectForKey:kEvent_SearchLocation];
    self.beeepedBy = [aDecoder decodeObjectForKey:kEvent_SearchBeeepedBy];
    self.locked = [aDecoder decodeDoubleForKey:kEvent_SearchLocked];
    self.hashTags = [aDecoder decodeObjectForKey:kEvent_SearchHashTags];
    self.loc = [aDecoder decodeObjectForKey:kEvent_SearchLoc];
    self.likesCount = [aDecoder decodeDoubleForKey:kEvent_SearchLikesCount];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_internalBaseClassDescription forKey:kEvent_SearchDescription];
    [aCoder encodeObject:_comments forKey:kEvent_SearchComments];
    [aCoder encodeObject:_fingerprint forKey:kEvent_SearchFingerprint];
    [aCoder encodeDouble:_timestamp forKey:kEvent_SearchTimestamp];
    [aCoder encodeObject:_imageUrl forKey:kEvent_SearchImageUrl];
    [aCoder encodeObject:_likes forKey:kEvent_SearchLikes];
    [aCoder encodeObject:_url forKey:kEvent_SearchUrl];
    [aCoder encodeObject:_source forKey:kEvent_SearchSource];
    [aCoder encodeObject:_title forKey:kEvent_SearchTitle];
    [aCoder encodeObject:_location forKey:kEvent_SearchLocation];
    [aCoder encodeObject:_beeepedBy forKey:kEvent_SearchBeeepedBy];
    [aCoder encodeDouble:_locked forKey:kEvent_SearchLocked];
    [aCoder encodeObject:_hashTags forKey:kEvent_SearchHashTags];
    [aCoder encodeObject:_loc forKey:kEvent_SearchLoc];
    [aCoder encodeDouble:_likesCount forKey:kEvent_SearchLikesCount];
}

- (id)copyWithZone:(NSZone *)zone
{
    Event_Search *copy = [[Event_Search alloc] init];
    
    if (copy) {

        copy.internalBaseClassDescription = [self.internalBaseClassDescription copyWithZone:zone];
        copy.comments = [self.comments copyWithZone:zone];
        copy.fingerprint = [self.fingerprint copyWithZone:zone];
        copy.timestamp = self.timestamp;
        copy.imageUrl = [self.imageUrl copyWithZone:zone];
        copy.likes = [self.likes copyWithZone:zone];
        copy.url = [self.url copyWithZone:zone];
        copy.source = [self.source copyWithZone:zone];
        copy.title = [self.title copyWithZone:zone];
        copy.location = [self.location copyWithZone:zone];
        copy.beeepedBy = [self.beeepedBy copyWithZone:zone];
        copy.locked = self.locked;
        copy.hashTags = [self.hashTags copyWithZone:zone];
        copy.loc = [self.loc copyWithZone:zone];
        copy.likesCount = self.likesCount;
    }
    
    return copy;
}

@end
