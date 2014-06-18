//
//  Comment.m
//
//  Created by George Termentzoglou on 5/13/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "Comment.h"


NSString *const kCommentUserId = @"user_id";
NSString *const kCommentComment = @"comment";
NSString *const kCommentTimestamp = @"timestamp";


@interface Comment ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Comment

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
            self.userId = [self objectOrNilForKey:kCommentUserId fromDictionary:dict];
            self.comment = [self objectOrNilForKey:kCommentComment fromDictionary:dict];
            self.timestamp = [[self objectOrNilForKey:kCommentTimestamp fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.userId forKey:kCommentUserId];
    [mutableDict setValue:self.comment forKey:kCommentComment];
    [mutableDict setValue:[NSNumber numberWithDouble:self.timestamp] forKey:kCommentTimestamp];

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

    self.userId = [aDecoder decodeObjectForKey:kCommentUserId];
    self.comment = [aDecoder decodeObjectForKey:kCommentComment];
    self.timestamp = [aDecoder decodeDoubleForKey:kCommentTimestamp];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_userId forKey:kCommentUserId];
    [aCoder encodeObject:_comment forKey:kCommentComment];
    [aCoder encodeDouble:_timestamp forKey:kCommentTimestamp];
}

- (id)copyWithZone:(NSZone *)zone
{
    Comment *copy = [[Comment alloc] init];
    
    if (copy) {

        copy.userId = [self.userId copyWithZone:zone];
        copy.comment = [self.comment copyWithZone:zone];
        copy.timestamp = self.timestamp;
    }
    
    return copy;
}


@end
