//
//  UserActivity.m
//
//  Created by   on 10/13/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "UserActivity.h"


NSString *const kUserActivityUsername = @"username";
NSString *const kUserActivityId = @"id";
NSString *const kUserActivityLastname = @"lastname";
NSString *const kUserActivityName = @"name";
NSString *const kUserActivityImagePath = @"image_path";


@interface UserActivity ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation UserActivity

@synthesize username = _username;
@synthesize userActivityIdentifier = _userActivityIdentifier;
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
            self.username = [self objectOrNilForKey:kUserActivityUsername fromDictionary:dict];
            self.userActivityIdentifier = [self objectOrNilForKey:kUserActivityId fromDictionary:dict];
            self.lastname = [self objectOrNilForKey:kUserActivityLastname fromDictionary:dict];
            self.name = [self objectOrNilForKey:kUserActivityName fromDictionary:dict];
            self.imagePath = [self objectOrNilForKey:kUserActivityImagePath fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.username forKey:kUserActivityUsername];
    [mutableDict setValue:self.userActivityIdentifier forKey:kUserActivityId];
    [mutableDict setValue:self.lastname forKey:kUserActivityLastname];
    [mutableDict setValue:self.name forKey:kUserActivityName];
    [mutableDict setValue:self.imagePath forKey:kUserActivityImagePath];

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

    self.username = [aDecoder decodeObjectForKey:kUserActivityUsername];
    self.userActivityIdentifier = [aDecoder decodeObjectForKey:kUserActivityId];
    self.lastname = [aDecoder decodeObjectForKey:kUserActivityLastname];
    self.name = [aDecoder decodeObjectForKey:kUserActivityName];
    self.imagePath = [aDecoder decodeObjectForKey:kUserActivityImagePath];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_username forKey:kUserActivityUsername];
    [aCoder encodeObject:_userActivityIdentifier forKey:kUserActivityId];
    [aCoder encodeObject:_lastname forKey:kUserActivityLastname];
    [aCoder encodeObject:_name forKey:kUserActivityName];
    [aCoder encodeObject:_imagePath forKey:kUserActivityImagePath];
}

- (id)copyWithZone:(NSZone *)zone
{
    UserActivity *copy = [[UserActivity alloc] init];
    
    if (copy) {

        copy.username = [self.username copyWithZone:zone];
        copy.userActivityIdentifier = [self.userActivityIdentifier copyWithZone:zone];
        copy.lastname = [self.lastname copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
        copy.imagePath = [self.imagePath copyWithZone:zone];
    }
    
    return copy;
}


@end
