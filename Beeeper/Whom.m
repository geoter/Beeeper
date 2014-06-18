//
//  Whom.m
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "Whom.h"


NSString *const kWhomUsername = @"username";
NSString *const kWhomId = @"id";
NSString *const kWhomLastname = @"lastname";
NSString *const kWhomName = @"name";
NSString *const kWhomImagePath = @"image_path";


@interface Whom ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Whom

@synthesize username = _username;
@synthesize whomIdentifier = _whomIdentifier;
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
            self.username = [self objectOrNilForKey:kWhomUsername fromDictionary:dict];
            self.whomIdentifier = [self objectOrNilForKey:kWhomId fromDictionary:dict];
            self.lastname = [self objectOrNilForKey:kWhomLastname fromDictionary:dict];
            self.name = [self objectOrNilForKey:kWhomName fromDictionary:dict];
            self.imagePath = [self objectOrNilForKey:kWhomImagePath fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.username forKey:kWhomUsername];
    [mutableDict setValue:self.whomIdentifier forKey:kWhomId];
    [mutableDict setValue:self.lastname forKey:kWhomLastname];
    [mutableDict setValue:self.name forKey:kWhomName];
    [mutableDict setValue:self.imagePath forKey:kWhomImagePath];

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

    self.username = [aDecoder decodeObjectForKey:kWhomUsername];
    self.whomIdentifier = [aDecoder decodeObjectForKey:kWhomId];
    self.lastname = [aDecoder decodeObjectForKey:kWhomLastname];
    self.name = [aDecoder decodeObjectForKey:kWhomName];
    self.imagePath = [aDecoder decodeObjectForKey:kWhomImagePath];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_username forKey:kWhomUsername];
    [aCoder encodeObject:_whomIdentifier forKey:kWhomId];
    [aCoder encodeObject:_lastname forKey:kWhomLastname];
    [aCoder encodeObject:_name forKey:kWhomName];
    [aCoder encodeObject:_imagePath forKey:kWhomImagePath];
}

- (id)copyWithZone:(NSZone *)zone
{
    Whom *copy = [[Whom alloc] init];
    
    if (copy) {

        copy.username = [self.username copyWithZone:zone];
        copy.whomIdentifier = [self.whomIdentifier copyWithZone:zone];
        copy.lastname = [self.lastname copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
        copy.imagePath = [self.imagePath copyWithZone:zone];
    }
    
    return copy;
}


@end
