//
//  EventActivity.m
//
//  Created by   on 10/13/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "EventActivity.h"


NSString *const kEventActivityFingerprint = @"fingerprint";
NSString *const kEventActivityTitle = @"title";
NSString *const kEventActivityImageUrl = @"image_url";


@interface EventActivity ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation EventActivity

@synthesize fingerprint = _fingerprint;
@synthesize title = _title;
@synthesize imageUrl = _imageUrl;

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
            self.fingerprint = [self objectOrNilForKey:kEventActivityFingerprint fromDictionary:dict];
            self.title = [self objectOrNilForKey:kEventActivityTitle fromDictionary:dict];
            self.imageUrl = [self objectOrNilForKey:kEventActivityImageUrl fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.fingerprint forKey:kEventActivityFingerprint];
    [mutableDict setValue:self.title forKey:kEventActivityTitle];
    [mutableDict setValue:self.imageUrl forKey:kEventActivityImageUrl];

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

    self.fingerprint = [aDecoder decodeObjectForKey:kEventActivityFingerprint];
    self.title = [aDecoder decodeObjectForKey:kEventActivityTitle];
    self.imageUrl = [aDecoder decodeObjectForKey:kEventActivityImageUrl];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_fingerprint forKey:kEventActivityFingerprint];
    [aCoder encodeObject:_title forKey:kEventActivityTitle];
    [aCoder encodeObject:_imageUrl forKey:kEventActivityImageUrl];
}

- (id)copyWithZone:(NSZone *)zone
{
    EventActivity *copy = [[EventActivity alloc] init];
    
    if (copy) {

        copy.fingerprint = [self.fingerprint copyWithZone:zone];
        copy.title = [self.title copyWithZone:zone];
        copy.imageUrl = [self.imageUrl copyWithZone:zone];
    }
    
    return copy;
}


@end
