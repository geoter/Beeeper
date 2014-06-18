//
//  Commenter.m
//
//  Created by George Termentzoglou on 5/13/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "Commenter.h"


NSString *const kCommenterId = @"id";
NSString *const kCommenterLastname = @"lastname";
NSString *const kCommenterName = @"name";
NSString *const kCommenterImagePath = @"image_path";


@interface Commenter ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Commenter

@synthesize commenterIdentifier = _commenterIdentifier;
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
            self.commenterIdentifier = [self objectOrNilForKey:kCommenterId fromDictionary:dict];
            self.lastname = [self objectOrNilForKey:kCommenterLastname fromDictionary:dict];
            self.name = [self objectOrNilForKey:kCommenterName fromDictionary:dict];
            self.imagePath = [self objectOrNilForKey:kCommenterImagePath fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.commenterIdentifier forKey:kCommenterId];
    [mutableDict setValue:self.lastname forKey:kCommenterLastname];
    [mutableDict setValue:self.name forKey:kCommenterName];
    [mutableDict setValue:self.imagePath forKey:kCommenterImagePath];

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

    self.commenterIdentifier = [aDecoder decodeObjectForKey:kCommenterId];
    self.lastname = [aDecoder decodeObjectForKey:kCommenterLastname];
    self.name = [aDecoder decodeObjectForKey:kCommenterName];
    self.imagePath = [aDecoder decodeObjectForKey:kCommenterImagePath];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_commenterIdentifier forKey:kCommenterId];
    [aCoder encodeObject:_lastname forKey:kCommenterLastname];
    [aCoder encodeObject:_name forKey:kCommenterName];
    [aCoder encodeObject:_imagePath forKey:kCommenterImagePath];
}

- (id)copyWithZone:(NSZone *)zone
{
    Commenter *copy = [[Commenter alloc] init];
    
    if (copy) {

        copy.commenterIdentifier = [self.commenterIdentifier copyWithZone:zone];
        copy.lastname = [self.lastname copyWithZone:zone];
        copy.name = [self.name copyWithZone:zone];
        copy.imagePath = [self.imagePath copyWithZone:zone];
    }
    
    return copy;
}


@end
