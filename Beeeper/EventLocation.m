//
//  EventLocation.m
//
//  Created by George Termentzoglou on 5/13/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "EventLocation.h"


NSString *const kEventLocationAddress = @"address";
NSString *const kEventLocationCity = @"city";
NSString *const kEventLocationCountry = @"country";
NSString *const kEventLocationLongitude = @"longitude";
NSString *const kEventLocationVenueStation = @"venue_station";
NSString *const kEventLocationUtcoffset = @"utcoffset";
NSString *const kEventLocationLatitude = @"latitude";
NSString *const kEventLocationState = @"state";


@interface EventLocation ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation EventLocation

@synthesize address = _address;
@synthesize city = _city;
@synthesize country = _country;
@synthesize longitude = _longitude;
@synthesize venueStation = _venueStation;
@synthesize utcoffset = _utcoffset;
@synthesize latitude = _latitude;
@synthesize state = _state;


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
            self.address = [self objectOrNilForKey:kEventLocationAddress fromDictionary:dict];
            self.city = [self objectOrNilForKey:kEventLocationCity fromDictionary:dict];
            self.country = [self objectOrNilForKey:kEventLocationCountry fromDictionary:dict];
            self.longitude = [self objectOrNilForKey:kEventLocationLongitude fromDictionary:dict];
            self.venueStation = [self objectOrNilForKey:kEventLocationVenueStation fromDictionary:dict];
            self.utcoffset = [self objectOrNilForKey:kEventLocationUtcoffset fromDictionary:dict];
            self.latitude = [self objectOrNilForKey:kEventLocationLatitude fromDictionary:dict];
            self.state = [self objectOrNilForKey:kEventLocationState fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.address forKey:kEventLocationAddress];
    [mutableDict setValue:self.city forKey:kEventLocationCity];
    [mutableDict setValue:self.country forKey:kEventLocationCountry];
    [mutableDict setValue:self.longitude forKey:kEventLocationLongitude];
    [mutableDict setValue:self.venueStation forKey:kEventLocationVenueStation];
    [mutableDict setValue:self.utcoffset forKey:kEventLocationUtcoffset];
    [mutableDict setValue:self.latitude forKey:kEventLocationLatitude];
    [mutableDict setValue:self.state forKey:kEventLocationState];

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

    self.address = [aDecoder decodeObjectForKey:kEventLocationAddress];
    self.city = [aDecoder decodeObjectForKey:kEventLocationCity];
    self.country = [aDecoder decodeObjectForKey:kEventLocationCountry];
    self.longitude = [aDecoder decodeObjectForKey:kEventLocationLongitude];
    self.venueStation = [aDecoder decodeObjectForKey:kEventLocationVenueStation];
    self.utcoffset = [aDecoder decodeObjectForKey:kEventLocationUtcoffset];
    self.latitude = [aDecoder decodeObjectForKey:kEventLocationLatitude];
    self.state = [aDecoder decodeObjectForKey:kEventLocationState];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_address forKey:kEventLocationAddress];
    [aCoder encodeObject:_city forKey:kEventLocationCity];
    [aCoder encodeObject:_country forKey:kEventLocationCountry];
    [aCoder encodeObject:_longitude forKey:kEventLocationLongitude];
    [aCoder encodeObject:_venueStation forKey:kEventLocationVenueStation];
    [aCoder encodeObject:_utcoffset forKey:kEventLocationUtcoffset];
    [aCoder encodeObject:_latitude forKey:kEventLocationLatitude];
    [aCoder encodeObject:_state forKey:kEventLocationState];
}

- (id)copyWithZone:(NSZone *)zone
{
    EventLocation *copy = [[EventLocation alloc] init];
    
    if (copy) {

        copy.address = [self.address copyWithZone:zone];
        copy.city = [self.city copyWithZone:zone];
        copy.country = [self.country copyWithZone:zone];
        copy.longitude = [self.longitude copyWithZone:zone];
        copy.venueStation = [self.venueStation copyWithZone:zone];
        copy.utcoffset = [self.utcoffset copyWithZone:zone];
        copy.latitude = [self.latitude copyWithZone:zone];
        copy.state = [self.state copyWithZone:zone];
    }
    
    return copy;
}


@end
