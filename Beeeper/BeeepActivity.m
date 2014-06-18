//
//  BeeepActivity.m
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import "BeeepActivity.h"



NSString *const kBeeepActivityUserId = @"user_id";
NSString *const kBeeepActivityBeeepsActivity = @"beeeps";
NSString *const kBeeepActivityEventTime = @"event_time";


@interface BeeepActivity ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation BeeepActivity

@synthesize userId = _userId;
@synthesize beeepsActivity = _beeepsActivity;
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
            self.userId = [self objectOrNilForKey:kBeeepActivityUserId fromDictionary:dict];
    NSObject *receivedBeeepsActivity = [dict objectForKey:kBeeepActivityBeeepsActivity];
    NSMutableArray *parsedBeeepsActivity = [NSMutableArray array];
    if ([receivedBeeepsActivity isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedBeeepsActivity) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedBeeepsActivity addObject:[BeeepsActivity modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedBeeepsActivity isKindOfClass:[NSDictionary class]]) {
       [parsedBeeepsActivity addObject:[BeeepsActivity modelObjectWithDictionary:(NSDictionary *)receivedBeeepsActivity]];
    }

    self.beeepsActivity = [NSArray arrayWithArray:parsedBeeepsActivity];
            self.eventTime = [[self objectOrNilForKey:kBeeepActivityEventTime fromDictionary:dict] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.userId forKey:kBeeepActivityUserId];
    NSMutableArray *tempArrayForBeeepsActivity = [NSMutableArray array];
    for (NSObject *subArrayObject in self.beeepsActivity) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForBeeepsActivity addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForBeeepsActivity addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForBeeepsActivity] forKey:kBeeepActivityBeeepsActivity];
    [mutableDict setValue:[NSNumber numberWithDouble:self.eventTime] forKey:kBeeepActivityEventTime];

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

    self.userId = [aDecoder decodeObjectForKey:kBeeepActivityUserId];
    self.beeepsActivity = [aDecoder decodeObjectForKey:kBeeepActivityBeeepsActivity];
    self.eventTime = [aDecoder decodeDoubleForKey:kBeeepActivityEventTime];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_userId forKey:kBeeepActivityUserId];
    [aCoder encodeObject:_beeepsActivity forKey:kBeeepActivityBeeepsActivity];
    [aCoder encodeDouble:_eventTime forKey:kBeeepActivityEventTime];
}

- (id)copyWithZone:(NSZone *)zone
{
    BeeepActivity *copy = [[BeeepActivity alloc] init];
    
    if (copy) {

        copy.userId = [self.userId copyWithZone:zone];
        copy.beeepsActivity = [self.beeepsActivity copyWithZone:zone];
        copy.eventTime = self.eventTime;
    }
    
    return copy;
}


@end
