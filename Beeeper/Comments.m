//
//  Comments.m
//
//  Created by George Termentzoglou on 5/13/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "Comments.h"
#import "Comment.h"
#import "Commenter.h"


NSString *const kCommentsComment = @"comment";
NSString *const kCommentsCommenter = @"commenter";


@interface Comments ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Comments

@synthesize comment = _comment;
@synthesize commenter = _commenter;


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
            self.comment = [Comment modelObjectWithDictionary:[dict objectForKey:kCommentsComment]];
            self.commenter = [Commenter modelObjectWithDictionary:[dict objectForKey:kCommentsCommenter]];
        
    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[self.comment dictionaryRepresentation] forKey:kCommentsComment];
    [mutableDict setValue:[self.commenter dictionaryRepresentation] forKey:kCommentsCommenter];

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

    self.comment = [aDecoder decodeObjectForKey:kCommentsComment];
    self.commenter = [aDecoder decodeObjectForKey:kCommentsCommenter];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_comment forKey:kCommentsComment];
    [aCoder encodeObject:_commenter forKey:kCommentsCommenter];
}

- (id)copyWithZone:(NSZone *)zone
{
    Comments *copy = [[Comments alloc] init];
    
    if (copy) {

        copy.comment = [self.comment copyWithZone:zone];
        copy.commenter = [self.commenter copyWithZone:zone];
    }
    
    return copy;
}


@end
