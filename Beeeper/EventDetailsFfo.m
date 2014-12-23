//
//  EventDetailsFfo.m
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "EventDetailsFfo.h"


NSString *const kEventDetailsFfoLocked = @"locked";
NSString *const kEventDetailsFfoSource = @"source";
NSString *const kEventDetailsFfoLocation = @"location";
NSString *const kEventDetailsFfoImageUrl = @"image_url";
NSString *const kEventDetailsFfoTitle = @"title";
NSString *const kEventDetailsFfoFingerprint = @"fingerprint";
NSString *const kEventDetailsFfoDescription = @"description";
NSString *const kEventDetailsFfoTimestamp = @"timestamp";
NSString *const kEventDetailsFfoLoc = @"loc";
NSString *const kEventDetailsFfoUrl = @"url";


@interface EventDetailsFfo ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation EventDetailsFfo

@synthesize locked = _locked;
@synthesize source = _source;
@synthesize location = _location;
@synthesize imageUrl = _imageUrl;
@synthesize title = _title;
@synthesize fingerprint = _fingerprint;
@synthesize eventDetailsFfoDescription = _eventDetailsFfoDescription;
@synthesize timestamp = _timestamp;
@synthesize loc = _loc;
@synthesize url = _url;

-(NSString *)title{
    return [[DTO sharedDTO]sigmaTelikoCorrection:_title];
}

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
            self.locked = [[self objectOrNilForKey:kEventDetailsFfoLocked fromDictionary:dict] doubleValue];
            self.source = [self objectOrNilForKey:kEventDetailsFfoSource fromDictionary:dict];
            self.location = [self objectOrNilForKey:kEventDetailsFfoLocation fromDictionary:dict];
            self.imageUrl = [self objectOrNilForKey:kEventDetailsFfoImageUrl fromDictionary:dict];
            self.title = [self objectOrNilForKey:kEventDetailsFfoTitle fromDictionary:dict];
            self.fingerprint = [self objectOrNilForKey:kEventDetailsFfoFingerprint fromDictionary:dict];
            self.eventDetailsFfoDescription = [self objectOrNilForKey:kEventDetailsFfoDescription fromDictionary:dict];
            self.timestamp = [[self objectOrNilForKey:kEventDetailsFfoTimestamp fromDictionary:dict] doubleValue];
            self.loc = [self objectOrNilForKey:kEventDetailsFfoLoc fromDictionary:dict];
            self.url = [self objectOrNilForKey:kEventDetailsFfoUrl fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.locked] forKey:kEventDetailsFfoLocked];
    [mutableDict setValue:self.source forKey:kEventDetailsFfoSource];
    [mutableDict setValue:self.location forKey:kEventDetailsFfoLocation];
    [mutableDict setValue:self.imageUrl forKey:kEventDetailsFfoImageUrl];
    [mutableDict setValue:self.title forKey:kEventDetailsFfoTitle];
    [mutableDict setValue:self.fingerprint forKey:kEventDetailsFfoFingerprint];
    [mutableDict setValue:self.eventDetailsFfoDescription forKey:kEventDetailsFfoDescription];
    [mutableDict setValue:[NSNumber numberWithDouble:self.timestamp] forKey:kEventDetailsFfoTimestamp];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForLoc] forKey:kEventDetailsFfoLoc];
    [mutableDict setValue:self.url forKey:kEventDetailsFfoUrl];

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

    self.locked = [aDecoder decodeDoubleForKey:kEventDetailsFfoLocked];
    self.source = [aDecoder decodeObjectForKey:kEventDetailsFfoSource];
    self.location = [aDecoder decodeObjectForKey:kEventDetailsFfoLocation];
    self.imageUrl = [aDecoder decodeObjectForKey:kEventDetailsFfoImageUrl];
    self.title = [aDecoder decodeObjectForKey:kEventDetailsFfoTitle];
    self.fingerprint = [aDecoder decodeObjectForKey:kEventDetailsFfoFingerprint];
    self.eventDetailsFfoDescription = [aDecoder decodeObjectForKey:kEventDetailsFfoDescription];
    self.timestamp = [aDecoder decodeDoubleForKey:kEventDetailsFfoTimestamp];
    self.loc = [aDecoder decodeObjectForKey:kEventDetailsFfoLoc];
    self.url = [aDecoder decodeObjectForKey:kEventDetailsFfoUrl];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_locked forKey:kEventDetailsFfoLocked];
    [aCoder encodeObject:_source forKey:kEventDetailsFfoSource];
    [aCoder encodeObject:_location forKey:kEventDetailsFfoLocation];
    [aCoder encodeObject:_imageUrl forKey:kEventDetailsFfoImageUrl];
    [aCoder encodeObject:_title forKey:kEventDetailsFfoTitle];
    [aCoder encodeObject:_fingerprint forKey:kEventDetailsFfoFingerprint];
    [aCoder encodeObject:_eventDetailsFfoDescription forKey:kEventDetailsFfoDescription];
    [aCoder encodeDouble:_timestamp forKey:kEventDetailsFfoTimestamp];
    [aCoder encodeObject:_loc forKey:kEventDetailsFfoLoc];
    [aCoder encodeObject:_url forKey:kEventDetailsFfoUrl];
}

- (id)copyWithZone:(NSZone *)zone
{
    EventDetailsFfo *copy = [[EventDetailsFfo alloc] init];
    
    if (copy) {

        copy.locked = self.locked;
        copy.source = [self.source copyWithZone:zone];
        copy.location = [self.location copyWithZone:zone];
        copy.imageUrl = [self.imageUrl copyWithZone:zone];
        copy.title = [self.title copyWithZone:zone];
        copy.fingerprint = [self.fingerprint copyWithZone:zone];
        copy.eventDetailsFfoDescription = [self.eventDetailsFfoDescription copyWithZone:zone];
        copy.timestamp = self.timestamp;
        copy.loc = [self.loc copyWithZone:zone];
        copy.url = [self.url copyWithZone:zone];
    }
    
    return copy;
}


@end
