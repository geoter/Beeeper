//
//  GoogleImageSearchAPIObject.m
//
//  Created by   on 12/23/14
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "GoogleImageSearchAPIObject.h"


NSString *const kGoogleImageSearchAPIObjectTitleNoFormatting = @"titleNoFormatting";
NSString *const kGoogleImageSearchAPIObjectContentNoFormatting = @"contentNoFormatting";
NSString *const kGoogleImageSearchAPIObjectWidth = @"width";
NSString *const kGoogleImageSearchAPIObjectUrl = @"url";
NSString *const kGoogleImageSearchAPIObjectOriginalContextUrl = @"originalContextUrl";
NSString *const kGoogleImageSearchAPIObjectTitle = @"title";
NSString *const kGoogleImageSearchAPIObjectTbUrl = @"tbUrl";
NSString *const kGoogleImageSearchAPIObjectGsearchResultClass = @"GsearchResultClass";
NSString *const kGoogleImageSearchAPIObjectImageId = @"imageId";
NSString *const kGoogleImageSearchAPIObjectHeight = @"height";
NSString *const kGoogleImageSearchAPIObjectTbWidth = @"tbWidth";
NSString *const kGoogleImageSearchAPIObjectTbHeight = @"tbHeight";
NSString *const kGoogleImageSearchAPIObjectUnescapedUrl = @"unescapedUrl";
NSString *const kGoogleImageSearchAPIObjectVisibleUrl = @"visibleUrl";
NSString *const kGoogleImageSearchAPIObjectContent = @"content";


@interface GoogleImageSearchAPIObject ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation GoogleImageSearchAPIObject

@synthesize titleNoFormatting = _titleNoFormatting;
@synthesize contentNoFormatting = _contentNoFormatting;
@synthesize width = _width;
@synthesize url = _url;
@synthesize originalContextUrl = _originalContextUrl;
@synthesize title = _title;
@synthesize tbUrl = _tbUrl;
@synthesize gsearchResultClass = _gsearchResultClass;
@synthesize imageId = _imageId;
@synthesize height = _height;
@synthesize tbWidth = _tbWidth;
@synthesize tbHeight = _tbHeight;
@synthesize unescapedUrl = _unescapedUrl;
@synthesize visibleUrl = _visibleUrl;
@synthesize content = _content;


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
            self.titleNoFormatting = [self objectOrNilForKey:kGoogleImageSearchAPIObjectTitleNoFormatting fromDictionary:dict];
            self.contentNoFormatting = [self objectOrNilForKey:kGoogleImageSearchAPIObjectContentNoFormatting fromDictionary:dict];
            self.width = [self objectOrNilForKey:kGoogleImageSearchAPIObjectWidth fromDictionary:dict];
            self.url = [self objectOrNilForKey:kGoogleImageSearchAPIObjectUrl fromDictionary:dict];
            self.originalContextUrl = [self objectOrNilForKey:kGoogleImageSearchAPIObjectOriginalContextUrl fromDictionary:dict];
            self.title = [self objectOrNilForKey:kGoogleImageSearchAPIObjectTitle fromDictionary:dict];
            self.tbUrl = [self objectOrNilForKey:kGoogleImageSearchAPIObjectTbUrl fromDictionary:dict];
            self.gsearchResultClass = [self objectOrNilForKey:kGoogleImageSearchAPIObjectGsearchResultClass fromDictionary:dict];
            self.imageId = [self objectOrNilForKey:kGoogleImageSearchAPIObjectImageId fromDictionary:dict];
            self.height = [self objectOrNilForKey:kGoogleImageSearchAPIObjectHeight fromDictionary:dict];
            self.tbWidth = [self objectOrNilForKey:kGoogleImageSearchAPIObjectTbWidth fromDictionary:dict];
            self.tbHeight = [self objectOrNilForKey:kGoogleImageSearchAPIObjectTbHeight fromDictionary:dict];
            self.unescapedUrl = [self objectOrNilForKey:kGoogleImageSearchAPIObjectUnescapedUrl fromDictionary:dict];
            self.visibleUrl = [self objectOrNilForKey:kGoogleImageSearchAPIObjectVisibleUrl fromDictionary:dict];
            self.content = [self objectOrNilForKey:kGoogleImageSearchAPIObjectContent fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.titleNoFormatting forKey:kGoogleImageSearchAPIObjectTitleNoFormatting];
    [mutableDict setValue:self.contentNoFormatting forKey:kGoogleImageSearchAPIObjectContentNoFormatting];
    [mutableDict setValue:self.width forKey:kGoogleImageSearchAPIObjectWidth];
    [mutableDict setValue:self.url forKey:kGoogleImageSearchAPIObjectUrl];
    [mutableDict setValue:self.originalContextUrl forKey:kGoogleImageSearchAPIObjectOriginalContextUrl];
    [mutableDict setValue:self.title forKey:kGoogleImageSearchAPIObjectTitle];
    [mutableDict setValue:self.tbUrl forKey:kGoogleImageSearchAPIObjectTbUrl];
    [mutableDict setValue:self.gsearchResultClass forKey:kGoogleImageSearchAPIObjectGsearchResultClass];
    [mutableDict setValue:self.imageId forKey:kGoogleImageSearchAPIObjectImageId];
    [mutableDict setValue:self.height forKey:kGoogleImageSearchAPIObjectHeight];
    [mutableDict setValue:self.tbWidth forKey:kGoogleImageSearchAPIObjectTbWidth];
    [mutableDict setValue:self.tbHeight forKey:kGoogleImageSearchAPIObjectTbHeight];
    [mutableDict setValue:self.unescapedUrl forKey:kGoogleImageSearchAPIObjectUnescapedUrl];
    [mutableDict setValue:self.visibleUrl forKey:kGoogleImageSearchAPIObjectVisibleUrl];
    [mutableDict setValue:self.content forKey:kGoogleImageSearchAPIObjectContent];

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

    self.titleNoFormatting = [aDecoder decodeObjectForKey:kGoogleImageSearchAPIObjectTitleNoFormatting];
    self.contentNoFormatting = [aDecoder decodeObjectForKey:kGoogleImageSearchAPIObjectContentNoFormatting];
    self.width = [aDecoder decodeObjectForKey:kGoogleImageSearchAPIObjectWidth];
    self.url = [aDecoder decodeObjectForKey:kGoogleImageSearchAPIObjectUrl];
    self.originalContextUrl = [aDecoder decodeObjectForKey:kGoogleImageSearchAPIObjectOriginalContextUrl];
    self.title = [aDecoder decodeObjectForKey:kGoogleImageSearchAPIObjectTitle];
    self.tbUrl = [aDecoder decodeObjectForKey:kGoogleImageSearchAPIObjectTbUrl];
    self.gsearchResultClass = [aDecoder decodeObjectForKey:kGoogleImageSearchAPIObjectGsearchResultClass];
    self.imageId = [aDecoder decodeObjectForKey:kGoogleImageSearchAPIObjectImageId];
    self.height = [aDecoder decodeObjectForKey:kGoogleImageSearchAPIObjectHeight];
    self.tbWidth = [aDecoder decodeObjectForKey:kGoogleImageSearchAPIObjectTbWidth];
    self.tbHeight = [aDecoder decodeObjectForKey:kGoogleImageSearchAPIObjectTbHeight];
    self.unescapedUrl = [aDecoder decodeObjectForKey:kGoogleImageSearchAPIObjectUnescapedUrl];
    self.visibleUrl = [aDecoder decodeObjectForKey:kGoogleImageSearchAPIObjectVisibleUrl];
    self.content = [aDecoder decodeObjectForKey:kGoogleImageSearchAPIObjectContent];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_titleNoFormatting forKey:kGoogleImageSearchAPIObjectTitleNoFormatting];
    [aCoder encodeObject:_contentNoFormatting forKey:kGoogleImageSearchAPIObjectContentNoFormatting];
    [aCoder encodeObject:_width forKey:kGoogleImageSearchAPIObjectWidth];
    [aCoder encodeObject:_url forKey:kGoogleImageSearchAPIObjectUrl];
    [aCoder encodeObject:_originalContextUrl forKey:kGoogleImageSearchAPIObjectOriginalContextUrl];
    [aCoder encodeObject:_title forKey:kGoogleImageSearchAPIObjectTitle];
    [aCoder encodeObject:_tbUrl forKey:kGoogleImageSearchAPIObjectTbUrl];
    [aCoder encodeObject:_gsearchResultClass forKey:kGoogleImageSearchAPIObjectGsearchResultClass];
    [aCoder encodeObject:_imageId forKey:kGoogleImageSearchAPIObjectImageId];
    [aCoder encodeObject:_height forKey:kGoogleImageSearchAPIObjectHeight];
    [aCoder encodeObject:_tbWidth forKey:kGoogleImageSearchAPIObjectTbWidth];
    [aCoder encodeObject:_tbHeight forKey:kGoogleImageSearchAPIObjectTbHeight];
    [aCoder encodeObject:_unescapedUrl forKey:kGoogleImageSearchAPIObjectUnescapedUrl];
    [aCoder encodeObject:_visibleUrl forKey:kGoogleImageSearchAPIObjectVisibleUrl];
    [aCoder encodeObject:_content forKey:kGoogleImageSearchAPIObjectContent];
}

- (id)copyWithZone:(NSZone *)zone
{
    GoogleImageSearchAPIObject *copy = [[GoogleImageSearchAPIObject alloc] init];
    
    if (copy) {

        copy.titleNoFormatting = [self.titleNoFormatting copyWithZone:zone];
        copy.contentNoFormatting = [self.contentNoFormatting copyWithZone:zone];
        copy.width = [self.width copyWithZone:zone];
        copy.url = [self.url copyWithZone:zone];
        copy.originalContextUrl = [self.originalContextUrl copyWithZone:zone];
        copy.title = [self.title copyWithZone:zone];
        copy.tbUrl = [self.tbUrl copyWithZone:zone];
        copy.gsearchResultClass = [self.gsearchResultClass copyWithZone:zone];
        copy.imageId = [self.imageId copyWithZone:zone];
        copy.height = [self.height copyWithZone:zone];
        copy.tbWidth = [self.tbWidth copyWithZone:zone];
        copy.tbHeight = [self.tbHeight copyWithZone:zone];
        copy.unescapedUrl = [self.unescapedUrl copyWithZone:zone];
        copy.visibleUrl = [self.visibleUrl copyWithZone:zone];
        copy.content = [self.content copyWithZone:zone];
    }
    
    return copy;
}


@end
