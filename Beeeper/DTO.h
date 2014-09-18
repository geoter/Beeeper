//
//  DTO.h
//  iHotel
//
//  Created by George Termentzoglou on 10/2/13.
//  Copyright (c) 2013 George Termentzoglou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DTO : NSObject <NSCoding>

+(DTO *)sharedDTO;
-(id)init;
-(void)save;
+(DTO *)load;

@property(nonatomic,strong) CLLocation *userLocation;
@property(nonatomic,strong) CLPlacemark *userPlace;

- (NSString *)fixLink:(NSString *)link;
- (void)downloadImageFromURL:(NSString *)url;
+ (BOOL)isInternetReachable;

@end


@interface NSString(UnicodeEncode)
-(NSString *)unicodeEncode;
@end

@implementation NSString(UnicodeEncode)

-(NSString *)unicodeEncode{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *decodevalue = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    return decodevalue;
}

@end