//
//  Suggestion_Object.m
//
//  Created by George Termentzoglou on 6/18/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "Suggestion_Object.h"
#import "Who.h"
#import "What_Suggest.h"


NSString *const kSuggestion_ObjectDid = @"did";
NSString *const kSuggestion_ObjectWho = @"who";
NSString *const kSuggestion_ObjectWhat = @"what";
NSString *const kSuggestion_ObjectHashTags = @"hash_tags";
NSString *const kSuggestion_ObjectLabel = @"label";
NSString *const kSuggestion_ObjectWhen = @"when";
NSString *const kSuggestion_ObjectBeeepersIds = @"beeepers_ids";


@interface Suggestion_Object ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Suggestion_Object

@synthesize did = _did;
@synthesize who = _who;
@synthesize what = _what;
@synthesize hashTags = _hashTags;
@synthesize label = _label;
@synthesize when = _when;
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
            self.did = [self objectOrNilForKey:kSuggestion_ObjectDid fromDictionary:dict];
            self.who = [Who modelObjectWithDictionary:[dict objectForKey:kSuggestion_ObjectWho]];
            self.what = [What_Suggest modelObjectWithDictionary:[dict objectForKey:kSuggestion_ObjectWhat]];
            self.hashTags = [self objectOrNilForKey:kSuggestion_ObjectHashTags fromDictionary:dict];
            self.label = [self objectOrNilForKey:kSuggestion_ObjectLabel fromDictionary:dict];
            self.when = [[self objectOrNilForKey:kSuggestion_ObjectWhen fromDictionary:dict] doubleValue];
            self.beeepersIds = [NSMutableArray arrayWithArray:[self objectOrNilForKey:kSuggestion_ObjectBeeepersIds fromDictionary:dict]];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.did forKey:kSuggestion_ObjectDid];
    [mutableDict setValue:[self.who dictionaryRepresentation] forKey:kSuggestion_ObjectWho];
    [mutableDict setValue:[self.what dictionaryRepresentation] forKey:kSuggestion_ObjectWhat];
    [mutableDict setValue:self.hashTags forKey:kSuggestion_ObjectHashTags];
    [mutableDict setValue:self.label forKey:kSuggestion_ObjectLabel];
    [mutableDict setValue:[NSNumber numberWithDouble:self.when] forKey:kSuggestion_ObjectWhen];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForBeeepersIds] forKey:kSuggestion_ObjectBeeepersIds];

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

    self.did = [aDecoder decodeObjectForKey:kSuggestion_ObjectDid];
    self.who = [aDecoder decodeObjectForKey:kSuggestion_ObjectWho];
    self.what = [aDecoder decodeObjectForKey:kSuggestion_ObjectWhat];
    self.hashTags = [aDecoder decodeObjectForKey:kSuggestion_ObjectHashTags];
    self.label = [aDecoder decodeObjectForKey:kSuggestion_ObjectLabel];
    self.when = [aDecoder decodeDoubleForKey:kSuggestion_ObjectWhen];
    self.beeepersIds = [aDecoder decodeObjectForKey:kSuggestion_ObjectBeeepersIds];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_did forKey:kSuggestion_ObjectDid];
    [aCoder encodeObject:_who forKey:kSuggestion_ObjectWho];
    [aCoder encodeObject:_what forKey:kSuggestion_ObjectWhat];
    [aCoder encodeObject:_hashTags forKey:kSuggestion_ObjectHashTags];
    [aCoder encodeObject:_label forKey:kSuggestion_ObjectLabel];
    [aCoder encodeDouble:_when forKey:kSuggestion_ObjectWhen];
    [aCoder encodeObject:_beeepersIds forKey:kSuggestion_ObjectBeeepersIds];
}

- (id)copyWithZone:(NSZone *)zone
{
    Suggestion_Object *copy = [[Suggestion_Object alloc] init];
    
    if (copy) {

        copy.did = [self.did copyWithZone:zone];
        copy.who = [self.who copyWithZone:zone];
        copy.what = [self.what copyWithZone:zone];
        copy.hashTags = [self.hashTags copyWithZone:zone];
        copy.label = [self.label copyWithZone:zone];
        copy.when = self.when;
        copy.beeepersIds = [self.beeepersIds copyWithZone:zone];
    }
    
    return copy;
}


@end
