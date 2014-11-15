//
//  What.m
//
//  Created by George Termentzoglou on 6/18/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "What_Suggest.h"



NSString *const kWhatDescription = @"description";
NSString *const kWhatComments = @"comments";
NSString *const kWhatFingerprint = @"fingerprint";
NSString *const kWhatTimestamp = @"timestamp";
NSString *const kWhatImageUrl = @"image_url";
NSString *const kWhatLikes = @"likes";
NSString *const kWhatUrl = @"url";
NSString *const kWhatSource = @"source";
NSString *const kWhatTitle = @"title";
NSString *const kWhatLocation = @"location";
NSString *const kWhatLocked = @"locked";
NSString *const kWhatLoc = @"loc";
NSString *const kWhatLikesCount = @"likes_count";


@interface What_Suggest ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation What_Suggest

@synthesize whatDescription = _whatDescription;
@synthesize comments = _comments;
@synthesize fingerprint = _fingerprint;
@synthesize timestamp = _timestamp;
@synthesize imageUrl = _imageUrl;
@synthesize likes = _likes;
@synthesize url = _url;
@synthesize source = _source;
@synthesize title = _title;
@synthesize location = _location;
@synthesize locked = _locked;
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
        self.whatDescription = [self objectOrNilForKey:kWhatDescription fromDictionary:dict];
        self.comments = [self objectOrNilForKey:kWhatComments fromDictionary:dict];
        self.fingerprint = [self objectOrNilForKey:kWhatFingerprint fromDictionary:dict];
        self.timestamp = [[self objectOrNilForKey:kWhatTimestamp fromDictionary:dict] doubleValue];
        self.imageUrl = [self objectOrNilForKey:kWhatImageUrl fromDictionary:dict];
        self.likes = [NSMutableArray arrayWithArray:[self objectOrNilForKey:kWhatLikes fromDictionary:dict]];
        self.url = [self objectOrNilForKey:kWhatUrl fromDictionary:dict];
        self.source = [self objectOrNilForKey:kWhatSource fromDictionary:dict];
        self.title = [self objectOrNilForKey:kWhatTitle fromDictionary:dict];
        self.location = [self objectOrNilForKey:kWhatLocation fromDictionary:dict];
        self.locked = [[self objectOrNilForKey:kWhatLocked fromDictionary:dict] doubleValue];
        self.loc = [self objectOrNilForKey:kWhatLoc fromDictionary:dict];
        self.likesCount = [[self objectOrNilForKey:kWhatLikesCount fromDictionary:dict] doubleValue];
        
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.whatDescription forKey:kWhatDescription];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForComments] forKey:kWhatComments];
    [mutableDict setValue:self.fingerprint forKey:kWhatFingerprint];
    [mutableDict setValue:[NSNumber numberWithDouble:self.timestamp] forKey:kWhatTimestamp];
    [mutableDict setValue:self.imageUrl forKey:kWhatImageUrl];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLikes] forKey:kWhatLikes];
    [mutableDict setValue:self.url forKey:kWhatUrl];
    [mutableDict setValue:self.source forKey:kWhatSource];
    [mutableDict setValue:self.title forKey:kWhatTitle];
    [mutableDict setValue:self.location forKey:kWhatLocation];
    [mutableDict setValue:[NSNumber numberWithDouble:self.locked] forKey:kWhatLocked];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLoc] forKey:kWhatLoc];
    [mutableDict setValue:[NSNumber numberWithDouble:self.likesCount] forKey:kWhatLikesCount];
    
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
    
    self.whatDescription = [aDecoder decodeObjectForKey:kWhatDescription];
    self.comments = [aDecoder decodeObjectForKey:kWhatComments];
    self.fingerprint = [aDecoder decodeObjectForKey:kWhatFingerprint];
    self.timestamp = [aDecoder decodeDoubleForKey:kWhatTimestamp];
    self.imageUrl = [aDecoder decodeObjectForKey:kWhatImageUrl];
    self.likes = [aDecoder decodeObjectForKey:kWhatLikes];
    self.url = [aDecoder decodeObjectForKey:kWhatUrl];
    self.source = [aDecoder decodeObjectForKey:kWhatSource];
    self.title = [aDecoder decodeObjectForKey:kWhatTitle];
    self.location = [aDecoder decodeObjectForKey:kWhatLocation];
    self.locked = [aDecoder decodeDoubleForKey:kWhatLocked];
    self.loc = [aDecoder decodeObjectForKey:kWhatLoc];
    self.likesCount = [aDecoder decodeDoubleForKey:kWhatLikesCount];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeObject:_whatDescription forKey:kWhatDescription];
    [aCoder encodeObject:_comments forKey:kWhatComments];
    [aCoder encodeObject:_fingerprint forKey:kWhatFingerprint];
    [aCoder encodeDouble:_timestamp forKey:kWhatTimestamp];
    [aCoder encodeObject:_imageUrl forKey:kWhatImageUrl];
    [aCoder encodeObject:_likes forKey:kWhatLikes];
    [aCoder encodeObject:_url forKey:kWhatUrl];
    [aCoder encodeObject:_source forKey:kWhatSource];
    [aCoder encodeObject:_title forKey:kWhatTitle];
    [aCoder encodeObject:_location forKey:kWhatLocation];
    [aCoder encodeDouble:_locked forKey:kWhatLocked];
    [aCoder encodeObject:_loc forKey:kWhatLoc];
    [aCoder encodeDouble:_likesCount forKey:kWhatLikesCount];
}

- (id)copyWithZone:(NSZone *)zone
{
    What_Suggest *copy = [[What_Suggest alloc] init];
    
    if (copy) {
        
        copy.whatDescription = [self.whatDescription copyWithZone:zone];
        copy.comments = [self.comments copyWithZone:zone];
        copy.fingerprint = [self.fingerprint copyWithZone:zone];
        copy.timestamp = self.timestamp;
        copy.imageUrl = [self.imageUrl copyWithZone:zone];
        copy.likes = [self.likes copyWithZone:zone];
        copy.url = [self.url copyWithZone:zone];
        copy.source = [self.source copyWithZone:zone];
        copy.title = [self.title copyWithZone:zone];
        copy.location = [self.location copyWithZone:zone];
        copy.locked = self.locked;
        copy.loc = [self.loc copyWithZone:zone];
        copy.likesCount = self.likesCount;
    }
    
    return copy;
}

@end
