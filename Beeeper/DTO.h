//
//  DTO.h
//  iHotel
//
//  Created by George Termentzoglou on 10/2/13.
//  Copyright (c) 2013 George Termentzoglou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Beeep_Object.h"
#import "EventVC.h"

typedef void(^completed)(BOOL,id);

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
- (void)setNotificationBeeepID:(NSString *)beeep_id;
- (NSString *)getNotificationBeeepID;
- (void)getBeeep:(NSString *)beeep_id WithCompletionBlock:(completed)compbloc;
- (UIImage *)imageWithColor:(UIColor *)color;
- (NSString *)urlencode:(NSString *)str;
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