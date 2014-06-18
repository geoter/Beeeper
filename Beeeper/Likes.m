//
//  Likes.m
//
//  Created by George Termentzoglou on 5/13/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "Likes.h"
#import "Likers.h"


NSString *const kLikesLikes = @"likes";
NSString *const kLikesLikers = @"likers";


@interface Likes ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Likes

@synthesize likes = _likes;
@synthesize likers = _likers;


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
            self.likes = [self objectOrNilForKey:kLikesLikes fromDictionary:dict];
            self.likers = [Likers modelObjectWithDictionary:[dict objectForKey:kLikesLikers]];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.likes forKey:kLikesLikes];
    [mutableDict setValue:[self.likers dictionaryRepresentation] forKey:kLikesLikers];

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

    self.likes = [aDecoder decodeObjectForKey:kLikesLikes];
    self.likers = [aDecoder decodeObjectForKey:kLikesLikers];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_likes forKey:kLikesLikes];
    [aCoder encodeObject:_likers forKey:kLikesLikers];
}

- (id)copyWithZone:(NSZone *)zone
{
    Likes *copy = [[Likes alloc] init];
    
    if (copy) {

        copy.likes = [self.likes copyWithZone:zone];
        copy.likers = [self.likers copyWithZone:zone];
    }
    
    return copy;
}


@end
