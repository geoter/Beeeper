//
//  Likers.m
//
//  Created by George Termentzoglou on 5/13/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "Likers.h"


NSString *const kLikersId = @"id";
NSString *const kLikersLastname = @"lastname";
NSString *const kLikersName = @"name";
NSString *const kLikersImagePath = @"image_path";


@interface Likers ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Likers

@synthesize likersIdentifier = _likersIdentifier;
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
            self.likersIdentifier = [self objectOrNilForKey:kLikersId fromDictionary:dict];
            self.lastname = [self objectOrNilForKey:kLikersLastname fromDictionary:dict];
            self.name = [self objectOrNilForKey:kLikersName fromDictionary:dict];
            self.imagePath = [self objectOrNilForKey:kLikersImagePath fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.likersIdentifier forKey:kLikersId];
    [mutableDict setValue:self.lastname forKey:kLikersLastname];
    [mutableDict setValue:self.name forKey:kLikersName];
    [mutableDict setValue:self.imagePath forKey:kLikersImagePath];

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

    self.likersIdentifier = [aDecoder decodeObjectForKey:kLikersId];
    self.lastname = [aDecoder decodeObjectForKey:kLikersLastname];
    self.name = [aDecoder decodeObjectForKey:kLikersName];
    self.imagePath = [aDecoder decodeObjectForKey:kLikersImagePath];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_likersIdentifier forKey:kLikersId];
    [aCoder encodeObject:_lastname forKey:kLikersLastname];
    [aCoder encodeObject:_name forKey:kLikersName];
    [aCoder encodeObject:_imagePath forKey:kLikersImagePath];
}

- (id)copyWithZone:(NSZone *)zone
{
    Likers *copy = [[Likers alloc] init];
    
    if (copy) {

        copy.likersIdentifier = [self.likersIdentifier copyWithZone:zone];
        copy.lastname = [self.lastname copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
        copy.imagePath = [self.imagePath copyWithZone:zone];
    }
    
    return copy;
}


@end
