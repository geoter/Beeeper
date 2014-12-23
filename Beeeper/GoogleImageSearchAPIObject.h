//
//  GoogleImageSearchAPIObject.h
//
//  Created by   on 12/23/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface GoogleImageSearchAPIObject : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong) NSString *titleNoFormatting;
@property (nonatomic, strong) NSString *contentNoFormatting;
@property (nonatomic, strong) NSString *width;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *originalContextUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *tbUrl;
@property (nonatomic, strong) NSString *gsearchResultClass;
@property (nonatomic, strong) NSString *imageId;
@property (nonatomic, strong) NSString *height;
@property (nonatomic, strong) NSString *tbWidth;
@property (nonatomic, strong) NSString *tbHeight;
@property (nonatomic, strong) NSString *unescapedUrl;
@property (nonatomic, strong) NSString *visibleUrl;
@property (nonatomic, strong) NSString *content;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
