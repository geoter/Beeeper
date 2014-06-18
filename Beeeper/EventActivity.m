//
//  EventActivity.m
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "EventActivity.h"


NSString *const kEventActivityTitle = @"title";
NSString *const kEventActivityFingerprint = @"fingerprint";
NSString *const kEventActivityImageUrl = @"image_url";


@interface EventActivity ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation EventActivity

@synthesize title = _title;
@synthesize fingerprint = _fingerprint;
@synthesize imageUrl = _imageUrl;


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
            self.title = [self objectOrNilForKey:kEventActivityTitle fromDictionary:dict];
            self.fingerprint = [self objectOrNilForKey:kEventActivityFingerprint fromDictionary:dict];
            self.imageUrl = [self objectOrNilForKey:kEventActivityImageUrl fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.title forKey:kEventActivityTitle];
    [mutableDict setValue:self.fingerprint forKey:kEventActivityFingerprint];
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

    self.title = [aDecoder decodeObjectForKey:kEventActivityTitle];
    self.fingerprint = [aDecoder decodeObjectForKey:kEventActivityFingerprint];
    self.imageUrl = [aDecoder decodeObjectForKey:kEventActivityImageUrl];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_title forKey:kEventActivityTitle];
    [aCoder encodeObject:_fingerprint forKey:kEventActivityFingerprint];
    [aCoder encodeObject:_imageUrl forKey:kEventActivityImageUrl];
}

- (id)copyWithZone:(NSZone *)zone
{
    EventActivity *copy = [[EventActivity alloc] init];
    
    if (copy) {

        copy.title = [self.title copyWithZone:zone];
        copy.fingerprint = [self.fingerprint copyWithZone:zone];
        copy.imageUrl = [self.imageUrl copyWithZone:zone];
    }
    
    return copy;
}


@end
