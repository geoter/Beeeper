//
//  LocationManager.m
//  GPSActivity
//
//  Created by George Termentzoglou on 1/15/12.
//  Copyright (c) 2012 AUEB. All rights reserved.
//


#import "LocationManager.h"

@implementation LocationManager

@synthesize locationManager;
@synthesize delegate;
@synthesize timeDifference;
@synthesize lastSavedTimestamp,firstSavedTimestamp;
@synthesize signalsCounter;

static LocationManager *thisWebServices = nil;

- (id) init {
    
    self = [super init];
    if (self != nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationsCounter = 0;
    }
    return self;
}

+ (LocationManager *)sharedLM{
    
    if (thisWebServices != nil) {
        return thisWebServices;
    }
    else{
        return [[LocationManager alloc]init];
    }
    
    return nil;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    
      //we dont filter accuracu because we recieve signal until the request is sent and we sent the best we have recieved
    
        locationsCounter++;
    
        if (locationsCounter > 1) { //to ensure that only one location reaches the delegate
            return;
        }
    
        [DTO sharedDTO].userLocation = newLocation;
    
        CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:[DTO sharedDTO].userLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            for (CLPlacemark * placemark in placemarks) {
                [DTO sharedDTO].userPlace = placemark;
                break;
            }
        }];
    
        [self.delegate locationUpdate:newLocation];
        
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if ([[error domain] isEqualToString: kCLErrorDomain] && [error code] == kCLErrorDenied) {
        // The user denied your app access to location information.
        [self.delegate locationDisabled];
    }
    else{
        [self.delegate locationError:error];
    }
    
    [self.locationManager stopUpdatingLocation];
}

-(void)startTracking{
    
    locationsCounter = 0;
    
    if([CLLocationManager locationServicesEnabled]){
        
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        
        [self.locationManager startUpdatingLocation];
    }
    else{
        [self.delegate locationDisabled];
    }
}

-(void)stopTracking{
    
    [self.locationManager stopUpdatingLocation];
}


@end
