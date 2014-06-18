//
//  CommentsActivity.m
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "CommentsActivity.h"


NSString *const kCommentsActivityUserId = @"user_id";
NSString *const kCommentsActivityComment = @"comment";
NSString *const kCommentsActivityTimestamp = @"timestamp";


@interface CommentsActivity ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation CommentsActivity

@synthesize userId = _userId;
@synthesize comment = _comment;
@synthesize timestamp = _timestamp;


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
            self.userId = [self objectOrNilForKey:kCommentsActivityUserId fromDictionary:dict];
            self.comment = [self objectOrNilForKey:kCommentsActivityComment fromDictionary:dict];
            self.timestamp = [[self objectOrNilForKey:kCommentsActivityTimestamp fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.userId forKey:kCommentsActivityUserId];
    [mutableDict setValue:self.comment forKey:kCommentsActivityComment];
    [mutableDict setValue:[NSNumber numberWithDouble:self.timestamp] forKey:kCommentsActivityTimestamp];

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

    self.userId = [aDecoder decodeObjectForKey:kCommentsActivityUserId];
    self.comment = [aDecoder decodeObjectForKey:kCommentsActivityComment];
    self.timestamp = [aDecoder decodeDoubleForKey:kCommentsActivityTimestamp];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_userId forKey:kCommentsActivityUserId];
    [aCoder encodeObject:_comment forKey:kCommentsActivityComment];
    [aCoder encodeDouble:_timestamp forKey:kCommentsActivityTimestamp];
}

- (id)copyWithZone:(NSZone *)zone
{
    CommentsActivity *copy = [[CommentsActivity alloc] init];
    
    if (copy) {

        copy.userId = [self.userId copyWithZone:zone];
        copy.comment = [self.comment copyWithZone:zone];
        copy.timestamp = self.timestamp;
    }
    
    return copy;
}


@end
