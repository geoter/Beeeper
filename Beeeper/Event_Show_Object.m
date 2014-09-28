//
//  Event_Show_Object.m
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "Event_Show_Object.h"
#import "EventInfo.h"
#import "Comments.h"

NSString *const kEvent_Show_ObjectTinyUrl = @"tiny_url";
NSString *const kEvent_Show_ObjectHashTags = @"hash_tags";
NSString *const kEvent_Show_ObjectBeeepedBy = @"beeeped_by";
NSString *const kEvent_Show_ObjectEventInfo = @"0";
NSString *const kBaseClassComments = @"comments";

@interface Event_Show_Object ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Event_Show_Object

@synthesize tinyUrl = _tinyUrl;
@synthesize hashTags = _hashTags;
@synthesize beeepedBy = _beeepedBy;
@synthesize eventInfo = _eventInfo;
@synthesize comments = _comments;

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
            self.tinyUrl = [self objectOrNilForKey:kEvent_Show_ObjectTinyUrl fromDictionary:dict];
            self.hashTags = [self objectOrNilForKey:kEvent_Show_ObjectHashTags fromDictionary:dict];
            self.beeepedBy = [self objectOrNilForKey:kEvent_Show_ObjectBeeepedBy fromDictionary:dict];
            self.eventInfo = [EventInfo modelObjectWithDictionary:[dict objectForKey:kEvent_Show_ObjectEventInfo]];
        
            NSObject *receivedComments = [dict objectForKey:kBaseClassComments];
            NSMutableArray *parsedComments = [NSMutableArray array];
            if ([receivedComments isKindOfClass:[NSArray class]]) {
                for (NSDictionary *item in (NSArray *)receivedComments) {
                    if ([item isKindOfClass:[NSDictionary class]]) {
                        [parsedComments addObject:[Comments modelObjectWithDictionary:item]];
                    }
                }
            } else if ([receivedComments isKindOfClass:[NSDictionary class]]) {
                [parsedComments addObject:[Comments modelObjectWithDictionary:(NSDictionary *)receivedComments]];
            }
            
            self.comments = [NSArray arrayWithArray:parsedComments];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.tinyUrl forKey:kEvent_Show_ObjectTinyUrl];
    [mutableDict setValue:self.hashTags forKey:kEvent_Show_ObjectHashTags];
    [mutableDict setValue:self.beeepedBy forKey:kEvent_Show_ObjectBeeepedBy];
    [mutableDict setValue:[self.eventInfo dictionaryRepresentation] forKey:kEvent_Show_ObjectEventInfo];

    NSMutableArray *tempArrayForComments = [NSMutableArray array];
    for (NSObject *subArrayObject in self.comments) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForComments addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForComments addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForComments] forKey:kBaseClassComments];

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

    self.tinyUrl = [aDecoder decodeObjectForKey:kEvent_Show_ObjectTinyUrl];
    self.hashTags = [aDecoder decodeObjectForKey:kEvent_Show_ObjectHashTags];
    self.beeepedBy = [aDecoder decodeObjectForKey:kEvent_Show_ObjectBeeepedBy];
    self.eventInfo = [aDecoder decodeObjectForKey:kEvent_Show_ObjectEventInfo];
    self.comments = [aDecoder decodeObjectForKey:kBaseClassComments];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_tinyUrl forKey:kEvent_Show_ObjectTinyUrl];
    [aCoder encodeObject:_hashTags forKey:kEvent_Show_ObjectHashTags];
    [aCoder encodeObject:_beeepedBy forKey:kEvent_Show_ObjectBeeepedBy];
    [aCoder encodeObject:_eventInfo forKey:kEvent_Show_ObjectEventInfo];
    [aCoder encodeObject:_comments forKey:kBaseClassComments];
}

- (id)copyWithZone:(NSZone *)zone
{
    Event_Show_Object *copy = [[Event_Show_Object alloc] init];
    
    if (copy) {

        copy.tinyUrl = [self.tinyUrl copyWithZone:zone];
        copy.hashTags = [self.hashTags copyWithZone:zone];
        copy.beeepedBy = [self.beeepedBy copyWithZone:zone];
        copy.eventInfo = [self.eventInfo copyWithZone:zone];
        copy.comments = [self.comments copyWithZone:zone];
    }
    
    return copy;
}


@end
