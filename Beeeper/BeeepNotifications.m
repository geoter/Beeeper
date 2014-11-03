//
//  BeeepNotifications.m
//
//  Created by   on 10/31/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "BeeepNotifications.h"
#import "BeeepsActivity.h"


NSString *const kBeeepNotificationsEventTime = @"event_time";
NSString *const kBeeepNotificationsInvalidatePush = @"invalidatePush";
NSString *const kBeeepNotificationsBeeepObject = @"beeeps";
NSString *const kBeeepNotificationsUserId = @"user_id";


@interface BeeepNotifications ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation BeeepNotifications

@synthesize eventTime = _eventTime;
@synthesize invalidatePush = _invalidatePush;
@synthesize beeepObject = _beeepObject;
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
            self.eventTime = [[self objectOrNilForKey:kBeeepNotificationsEventTime fromDictionary:dict] doubleValue];
            self.invalidatePush = [self objectOrNilForKey:kBeeepNotificationsInvalidatePush fromDictionary:dict];
    NSObject *receivedBeeepObject = [dict objectForKey:kBeeepNotificationsBeeepObject];
    NSMutableArray *parsedBeeepObject = [NSMutableArray array];
    if ([receivedBeeepObject isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedBeeepObject) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedBeeepObject addObject:[BeeepsActivity modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedBeeepObject isKindOfClass:[NSDictionary class]]) {
       [parsedBeeepObject addObject:[BeeepsActivity modelObjectWithDictionary:(NSDictionary *)receivedBeeepObject]];
    }

    self.beeepObject = [NSArray arrayWithArray:parsedBeeepObject];
            self.userId = [self objectOrNilForKey:kBeeepNotificationsUserId fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.eventTime] forKey:kBeeepNotificationsEventTime];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForInvalidatePush] forKey:kBeeepNotificationsInvalidatePush];
    NSMutableArray *tempArrayForBeeepObject = [NSMutableArray array];
    for (NSObject *subArrayObject in self.beeepObject) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForBeeepObject addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForBeeepObject addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForBeeepObject] forKey:kBeeepNotificationsBeeepObject];
    [mutableDict setValue:self.userId forKey:kBeeepNotificationsUserId];

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

    self.eventTime = [aDecoder decodeDoubleForKey:kBeeepNotificationsEventTime];
    self.invalidatePush = [aDecoder decodeObjectForKey:kBeeepNotificationsInvalidatePush];
    self.beeepObject = [aDecoder decodeObjectForKey:kBeeepNotificationsBeeepObject];
    self.userId = [aDecoder decodeObjectForKey:kBeeepNotificationsUserId];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_eventTime forKey:kBeeepNotificationsEventTime];
    [aCoder encodeObject:_invalidatePush forKey:kBeeepNotificationsInvalidatePush];
    [aCoder encodeObject:_beeepObject forKey:kBeeepNotificationsBeeepObject];
    [aCoder encodeObject:_userId forKey:kBeeepNotificationsUserId];
}

- (id)copyWithZone:(NSZone *)zone
{
    BeeepNotifications *copy = [[BeeepNotifications alloc] init];
    
    if (copy) {

        copy.eventTime = self.eventTime;
        copy.invalidatePush = [self.invalidatePush copyWithZone:zone];
        copy.beeepObject = [self.beeepObject copyWithZone:zone];
        copy.userId = [self.userId copyWithZone:zone];
    }
    
    return copy;
}


@end
