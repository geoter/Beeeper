//
//  What.h
//
//  Created by George Termentzoglou on 6/18/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface What_Suggest : NSObject <NSCoding, NSCopying>

@property (nonatomic, assign) id whatDescription;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) NSString *fingerprint;
@property (nonatomic, assign) double timestamp;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSArray *likes;
@property (nonatomic, assign) id url;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, assign) double locked;
@property (nonatomic, strong) NSArray *loc;
@property (nonatomic, assign) double likesCount;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;


@end
