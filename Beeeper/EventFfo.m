//
//  EventFfo.m
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "EventFfo.h"

NSString *const kEventFfoBeeepedBy = @"beeeped_by";
NSString *const kEventFfoEventDetailsFfo = @"event_details";
NSString *const kEventFfoHashTags = @"hash_tags";


@interface EventFfo ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation EventFfo

@synthesize beeepedBy = _beeepedBy;
@synthesize eventDetailsFfo = _eventDetailsFfo;
@synthesize hashTags = _hashTags;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (id) init
{
    if (self = [super init])
    {
        self.eventDetailsFfo = [[EventDetailsFfo alloc]init];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.beeepedBy = [self objectOrNilForKey:kEventFfoBeeepedBy fromDictionary:dict];
            self.eventDetailsFfo = [EventDetailsFfo modelObjectWithDictionary:[dict objectForKey:kEventFfoEventDetailsFfo]];
            self.hashTags = [self objectOrNilForKey:kEventFfoHashTags fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    NSMutableArray *tempArrayForBeeepedBy = [NSMutableArray array];
    for (NSObject *subArrayObject in self.beeepedBy) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForBeeepedBy addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForBeeepedBy addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForBeeepedBy] forKey:kEventFfoBeeepedBy];
    [mutableDict setValue:[self.eventDetailsFfo dictionaryRepresentation] forKey:kEventFfoEventDetailsFfo];
    [mutableDict setValue:self.hashTags forKey:kEventFfoHashTags];

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

    self.beeepedBy = [aDecoder decodeObjectForKey:kEventFfoBeeepedBy];
    self.eventDetailsFfo = [aDecoder decodeObjectForKey:kEventFfoEventDetailsFfo];
    self.hashTags = [aDecoder decodeObjectForKey:kEventFfoHashTags];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_beeepedBy forKey:kEventFfoBeeepedBy];
    [aCoder encodeObject:_eventDetailsFfo forKey:kEventFfoEventDetailsFfo];
    [aCoder encodeObject:_hashTags forKey:kEventFfoHashTags];
}

- (id)copyWithZone:(NSZone *)zone
{
    EventFfo *copy = [[EventFfo alloc] init];
    
    if (copy) {

        copy.beeepedBy = [self.beeepedBy copyWithZone:zone];
        copy.eventDetailsFfo = [self.eventDetailsFfo copyWithZone:zone];
        copy.hashTags = [self.hashTags copyWithZone:zone];
    }
    
    return copy;
}


@end
