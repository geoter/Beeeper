//
//  WhoFfo.m
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "WhoFfo.h"


NSString *const kWhoFfoId = @"id";
NSString *const kWhoFfoLastname = @"lastname";
NSString *const kWhoFfoName = @"name";
NSString *const kWhoFfoImagePath = @"image_path";


@interface WhoFfo ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation WhoFfo

@synthesize whoFfoIdentifier = _whoFfoIdentifier;
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
            self.whoFfoIdentifier = [self objectOrNilForKey:kWhoFfoId fromDictionary:dict];
            self.lastname = [self objectOrNilForKey:kWhoFfoLastname fromDictionary:dict];
            self.name = [self objectOrNilForKey:kWhoFfoName fromDictionary:dict];
            self.imagePath = [self objectOrNilForKey:kWhoFfoImagePath fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.whoFfoIdentifier forKey:kWhoFfoId];
    [mutableDict setValue:self.lastname forKey:kWhoFfoLastname];
    [mutableDict setValue:self.name forKey:kWhoFfoName];
    [mutableDict setValue:self.imagePath forKey:kWhoFfoImagePath];

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

    self.whoFfoIdentifier = [aDecoder decodeObjectForKey:kWhoFfoId];
    self.lastname = [aDecoder decodeObjectForKey:kWhoFfoLastname];
    self.name = [aDecoder decodeObjectForKey:kWhoFfoName];
    self.imagePath = [aDecoder decodeObjectForKey:kWhoFfoImagePath];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_whoFfoIdentifier forKey:kWhoFfoId];
    [aCoder encodeObject:_lastname forKey:kWhoFfoLastname];
    [aCoder encodeObject:_name forKey:kWhoFfoName];
    [aCoder encodeObject:_imagePath forKey:kWhoFfoImagePath];
}

- (id)copyWithZone:(NSZone *)zone
{
    WhoFfo *copy = [[WhoFfo alloc] init];
    
    if (copy) {

        copy.whoFfoIdentifier = [self.whoFfoIdentifier copyWithZone:zone];
        copy.lastname = [self.lastname copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
        copy.imagePath = [self.imagePath copyWithZone:zone];
    }
    
    return copy;
}


@end
