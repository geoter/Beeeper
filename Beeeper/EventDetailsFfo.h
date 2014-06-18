//
//  EventDetailsFfo.h
//
//  Created by George Termentzoglou on 6/11/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface EventDetailsFfo : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) double locked;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *fingerprint;
@property (nonatomic, strong) NSString *eventDetailsFfoDescription;
@property (nonatomic, assign) double timestamp;
@property (nonatomic, strong) NSArray *loc;
@property (nonatomic, strong) NSString *url;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
