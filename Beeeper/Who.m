//
//  Who.m
//
//  Created by   on 10/13/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "Who.h"


NSString *const kWhoUsername = @"username";
NSString *const kWhoId = @"id";
NSString *const kWhoLastname = @"lastname";
NSString *const kWhoName = @"name";
NSString *const kWhoImagePath = @"image_path";


@interface Who ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Who

@synthesize username = _username;
@synthesize whoIdentifier = _whoIdentifier;
@synthesize lastname = _lastname;
@synthesize name = _name;
@synthesize imagePath = _imagePath;


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
            self.username = [self objectOrNilForKey:kWhoUsername fromDictionary:dict];
            self.whoIdentifier = [self objectOrNilForKey:kWhoId fromDictionary:dict];
            self.lastname = [self objectOrNilForKey:kWhoLastname fromDictionary:dict];
            self.name = [self objectOrNilForKey:kWhoName fromDictionary:dict];
            self.imagePath = [self objectOrNilForKey:kWhoImagePath fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.username forKey:kWhoUsername];
    [mutableDict setValue:self.whoIdentifier forKey:kWhoId];
    [mutableDict setValue:self.lastname forKey:kWhoLastname];
    [mutableDict setValue:self.name forKey:kWhoName];
    [mutableDict setValue:self.imagePath forKey:kWhoImagePath];

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

    self.username = [aDecoder decodeObjectForKey:kWhoUsername];
    self.whoIdentifier = [aDecoder decodeObjectForKey:kWhoId];
    self.lastname = [aDecoder decodeObjectForKey:kWhoLastname];
    self.name = [aDecoder decodeObjectForKey:kWhoName];
    self.imagePath = [aDecoder decodeObjectForKey:kWhoImagePath];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_username forKey:kWhoUsername];
    [aCoder encodeObject:_whoIdentifier forKey:kWhoId];
    [aCoder encodeObject:_lastname forKey:kWhoLastname];
    [aCoder encodeObject:_name forKey:kWhoName];
    [aCoder encodeObject:_imagePath forKey:kWhoImagePath];
}

- (id)copyWithZone:(NSZone *)zone
{
    Who *copy = [[Who alloc] init];
    
    if (copy) {

        copy.username = [self.username copyWithZone:zone];
        copy.whoIdentifier = [self.whoIdentifier copyWithZone:zone];
        copy.lastname = [self.lastname copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
        copy.imagePath = [self.imagePath copyWithZone:zone];
    }
    
    return copy;
}


@end
