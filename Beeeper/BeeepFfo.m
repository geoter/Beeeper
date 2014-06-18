//
//  BeeepFfo.m
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "BeeepFfo.h"



NSString *const kBeeepFfoBeeeps = @"beeeps";
NSString *const kBeeepFfoUserId = @"user_id";
NSString *const kBeeepFfoEventTime = @"event_time";


@interface BeeepFfo ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation BeeepFfo

@synthesize beeeps = _beeeps;
@synthesize userId = _userId;
@synthesize eventTime = _eventTime;


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
    NSObject *receivedBeeeps = [dict objectForKey:kBeeepFfoBeeeps];
    NSMutableArray *parsedBeeeps = [NSMutableArray array];
    if ([receivedBeeeps isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedBeeeps) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedBeeeps addObject:[Beeeps modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedBeeeps isKindOfClass:[NSDictionary class]]) {
       [parsedBeeeps addObject:[Beeeps modelObjectWithDictionary:(NSDictionary *)receivedBeeeps]];
    }

    self.beeeps = [NSArray arrayWithArray:parsedBeeeps];
            self.userId = [self objectOrNilForKey:kBeeepFfoUserId fromDictionary:dict];
            self.eventTime = [[self objectOrNilForKey:kBeeepFfoEventTime fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    NSMutableArray *tempArrayForBeeeps = [NSMutableArray array];
    for (NSObject *subArrayObject in self.beeeps) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForBeeeps addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForBeeeps addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForBeeeps] forKey:kBeeepFfoBeeeps];
    [mutableDict setValue:self.userId forKey:kBeeepFfoUserId];
    [mutableDict setValue:[NSNumber numberWithDouble:self.eventTime] forKey:kBeeepFfoEventTime];

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

    self.beeeps = [aDecoder decodeObjectForKey:kBeeepFfoBeeeps];
    self.userId = [aDecoder decodeObjectForKey:kBeeepFfoUserId];
    self.eventTime = [aDecoder decodeDoubleForKey:kBeeepFfoEventTime];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_beeeps forKey:kBeeepFfoBeeeps];
    [aCoder encodeObject:_userId forKey:kBeeepFfoUserId];
    [aCoder encodeDouble:_eventTime forKey:kBeeepFfoEventTime];
}

- (id)copyWithZone:(NSZone *)zone
{
    BeeepFfo *copy = [[BeeepFfo alloc] init];
    
    if (copy) {

        copy.beeeps = [self.beeeps copyWithZone:zone];
        copy.userId = [self.userId copyWithZone:zone];
        copy.eventTime = self.eventTime;
    }
    
    return copy;
}


@end
