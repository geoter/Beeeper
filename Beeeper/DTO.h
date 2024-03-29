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
#import "FMDatabase.h"

typedef void(^completed)(BOOL,id);

@interface DTO : NSObject <NSCoding>

+(DTO *)sharedDTO;
-(id)init;
-(void)save;
+(DTO *)load;

@property(nonatomic,strong) CLLocation *userLocation;
@property(nonatomic,strong) CLPlacemark *userPlace;
@property (nonatomic,assign) int suggestionBadgeNumber;
@property (nonatomic,assign) BOOL suggestionBadgeNumberFinished;
@property (nonatomic,strong) NSString *databaseName;
@property (nonatomic,strong) NSString *databasePath;

- (void)setApplicationBadge:(int)number;
- (void)saveSuggestionsBadge:(int)number;
- (void)saveNotificationsBadge:(int)number;

- (void)getSuggestions;
- (void)clearSuggestions;

- (void)uploadBugFile;
- (void)sendBugLog;
- (BOOL)addBugLog:(NSString *)what where:(NSString *)where json:(NSString *)json;
- (NSString *)fixLink:(NSString *)link;
- (void)downloadImageFromURL:(NSString *)url;
+ (BOOL)isInternetReachable;

- (BOOL)hasShownWalkthrough;
@property (nonatomic,assign) BOOL hasShownWalkthrough;

- (NSString *)sigmaTelikoCorrection:(NSString *)originalString;

- (void)setDeeepLinkEventFingerprint:(NSString *)fingerprint;
- (NSString *)getDeeepLinkEventFingerprint;

- (void)getBeeep:(NSString *)beeep_id WithCompletionBlock:(completed)compbloc;
- (UIImage *)imageWithColor:(UIColor *)color;
- (NSString *)urlencode:(NSString *)str;
- (UIImage *)convertViewToBlurredImage:(UIView *)view withRadius: (CGFloat)blurRadius;

-(UIStoryboard *)storyboardWithNameDeviceSpecific:(NSString *)storyboardID;


#pragma mark - PUSH

- (void)setWeightForPush:(NSString *)weight caseStr:(NSString *)caseStr;
- (NSDictionary *)getWeightAndCaseForPush;

- (void)setFingerprintForPush:(NSString *)fingerprint caseStr:(NSString *)caseStr;
- (NSDictionary *)getFingerprintAndCaseForPush;

- (void)setUserIDforPush:(NSString *)user_id;
- (NSString *)getUserIDForPush;

@end


@interface NSString(UnicodeEncode)
-(NSString *)unicodeEncode;
@end

@implementation NSString(UnicodeEncode)

-(NSString *)unicodeEncode{
    
    NSString *convertedString = [self mutableCopy];
    
    CFStringRef transform = CFSTR("Any-Hex/Java");
    CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
    return convertedString;
    
   /* NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *decodevalue = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
    
    return decodevalue;*/
    
    /*
    const char *cString=[self UTF8String];
    NSData *data = [NSData dataWithBytes:cString length:strlen(cString)];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
     */
    
   /* NSString *convertedString = [self mutableCopy];
    
    CFStringRef transform = CFSTR("Any-Hex/Java");
    CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
    return convertedString;*/
}

@end