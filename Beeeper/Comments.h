//
//  Comments.h
//
//  Created by George Termentzoglou on 5/13/14
//  Copyright (c) 2014 georgeterme@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comment.h"
#import "Commenter.h"


@interface Comments : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) Comment *comment;
@property (nonatomic, strong) Commenter *commenter;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
