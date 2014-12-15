//
//  Timeline_Object.m
//
//  Created by George Termentzoglou on 5/13/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "Timeline_Object.h"



NSString *const kTimeline_ObjectHashTags = @"hash_tags";
NSString *const kTimeline_ObjectBeeep = @"beeep";
NSString *const kTimeline_ObjectEvent = @"event";
NSString *const kTimeline_ObjectBeeepersIds = @"beeepers_ids";


@interface Timeline_Object ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Timeline_Object

@synthesize hashTags = _hashTags;
@synthesize beeep = _beeep;
@synthesize event = _event;
@synthesize beeepersIds = _beeepersIds;


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
            self.hashTags = [self objectOrNilForKey:kTimeline_ObjectHashTags fromDictionary:dict];
            self.beeep = [Beeep modelObjectWithDictionary:[dict objectForKey:kTimeline_ObjectBeeep]];
            self.event = [Event modelObjectWithDictionary:[dict objectForKey:kTimeline_ObjectEvent]];
            self.beeepersIds = [NSMutableArray arrayWithArray:[self objectOrNilForKey:kTimeline_ObjectBeeepersIds fromDictionary:dict]];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.hashTags forKey:kTimeline_ObjectHashTags];
    [mutableDict setValue:[self.beeep dictionaryRepresentation] forKey:kTimeline_ObjectBeeep];
    [mutableDict setValue:[self.event dictionaryRepresentation] forKey:kTimeline_ObjectEvent];
    NSMutableArray *tempArrayForBeeepersIds = [NSMutableArray array];
    for (NSObject *subArrayObject in self.beeepersIds) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForBeeepersIds addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForBeeepersIds addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForBeeepersIds] forKey:kTimeline_ObjectBeeepersIds];

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

    self.hashTags = [aDecoder decodeObjectForKey:kTimeline_ObjectHashTags];
    self.beeep = [aDecoder decodeObjectForKey:kTimeline_ObjectBeeep];
    self.event = [aDecoder decodeObjectForKey:kTimeline_ObjectEvent];
    self.beeepersIds = [aDecoder decodeObjectForKey:kTimeline_ObjectBeeepersIds];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_hashTags forKey:kTimeline_ObjectHashTags];
    [aCoder encodeObject:_beeep forKey:kTimeline_ObjectBeeep];
    [aCoder encodeObject:_event forKey:kTimeline_ObjectEvent];
    [aCoder encodeObject:_beeepersIds forKey:kTimeline_ObjectBeeepersIds];
}

- (id)copyWithZone:(NSZone *)zone
{
    Timeline_Object *copy = [[Timeline_Object alloc] init];
    
    if (copy) {

        copy.hashTags = [self.hashTags copyWithZone:zone];
        copy.beeep = [self.beeep copyWithZone:zone];
        copy.event = [self.event copyWithZone:zone];
        copy.beeepersIds = [self.beeepersIds copyWithZone:zone];
    }
    
    return copy;
}


@end
