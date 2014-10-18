//
//  BeeepActivity.m
//
//  Created by   on 10/13/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "BeeepActivity.h"



NSString *const kBeeepActivityEventTime = @"event_time";
NSString *const kBeeepActivityBeeepsActivity = @"beeeps";
NSString *const kBeeepActivityInvalidatePush = @"invalidatePush";
NSString *const kBeeepActivityUserId = @"user_id";


@interface BeeepActivity ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation BeeepActivity

@synthesize eventTime = _eventTime;
@synthesize beeepsActivity = _beeepsActivity;
@synthesize invalidatePush = _invalidatePush;
@synthesize userId = _userId;


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
            self.eventTime = [[self objectOrNilForKey:kBeeepActivityEventTime fromDictionary:dict] doubleValue];
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
            self.invalidatePush = [self objectOrNilForKey:kBeeepActivityInvalidatePush fromDictionary:dict];
            self.userId = [self objectOrNilForKey:kBeeepActivityUserId fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.eventTime] forKey:kBeeepActivityEventTime];
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
    NSMutableArray *tempArrayForInvalidatePush = [NSMutableArray array];
    for (NSObject *subArrayObject in self.invalidatePush) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForInvalidatePush addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForInvalidatePush addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForInvalidatePush] forKey:kBeeepActivityInvalidatePush];
    [mutableDict setValue:self.userId forKey:kBeeepActivityUserId];

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

    self.eventTime = [aDecoder decodeDoubleForKey:kBeeepActivityEventTime];
    self.beeepsActivity = [aDecoder decodeObjectForKey:kBeeepActivityBeeepsActivity];
    self.invalidatePush = [aDecoder decodeObjectForKey:kBeeepActivityInvalidatePush];
    self.userId = [aDecoder decodeObjectForKey:kBeeepActivityUserId];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_eventTime forKey:kBeeepActivityEventTime];
    [aCoder encodeObject:_beeepsActivity forKey:kBeeepActivityBeeepsActivity];
    [aCoder encodeObject:_invalidatePush forKey:kBeeepActivityInvalidatePush];
    [aCoder encodeObject:_userId forKey:kBeeepActivityUserId];
}

- (id)copyWithZone:(NSZone *)zone
{
    BeeepActivity *copy = [[BeeepActivity alloc] init];
    
    if (copy) {

        copy.eventTime = self.eventTime;
        copy.beeepsActivity = [self.beeepsActivity copyWithZone:zone];
        copy.invalidatePush = [self.invalidatePush copyWithZone:zone];
        copy.userId = [self.userId copyWithZone:zone];
    }
    
    return copy;
}


@end
