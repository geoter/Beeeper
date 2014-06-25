//
//  BeeepedBy.m
//
//  Created by   on 6/25/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "BeeepedBy.h"


NSString *const kBeeepedById = @"id";
NSString *const kBeeepedByLastname = @"lastname";
NSString *const kBeeepedByName = @"name";
NSString *const kBeeepedByImagePath = @"image_path";


@interface BeeepedBy ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation BeeepedBy

@synthesize beeepedByIdentifier = _beeepedByIdentifier;
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
            self.beeepedByIdentifier = [self objectOrNilForKey:kBeeepedById fromDictionary:dict];
            self.lastname = [self objectOrNilForKey:kBeeepedByLastname fromDictionary:dict];
            self.name = [self objectOrNilForKey:kBeeepedByName fromDictionary:dict];
            self.imagePath = [self objectOrNilForKey:kBeeepedByImagePath fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.beeepedByIdentifier forKey:kBeeepedById];
    [mutableDict setValue:self.lastname forKey:kBeeepedByLastname];
    [mutableDict setValue:self.name forKey:kBeeepedByName];
    [mutableDict setValue:self.imagePath forKey:kBeeepedByImagePath];

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

    self.beeepedByIdentifier = [aDecoder decodeObjectForKey:kBeeepedById];
    self.lastname = [aDecoder decodeObjectForKey:kBeeepedByLastname];
    self.name = [aDecoder decodeObjectForKey:kBeeepedByName];
    self.imagePath = [aDecoder decodeObjectForKey:kBeeepedByImagePath];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_beeepedByIdentifier forKey:kBeeepedById];
    [aCoder encodeObject:_lastname forKey:kBeeepedByLastname];
    [aCoder encodeObject:_name forKey:kBeeepedByName];
    [aCoder encodeObject:_imagePath forKey:kBeeepedByImagePath];
}

- (id)copyWithZone:(NSZone *)zone
{
    BeeepedBy *copy = [[BeeepedBy alloc] init];
    
    if (copy) {

        copy.beeepedByIdentifier = [self.beeepedByIdentifier copyWithZone:zone];
        copy.lastname = [self.lastname copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
        copy.imagePath = [self.imagePath copyWithZone:zone];
    }
    
    return copy;
}


@end
