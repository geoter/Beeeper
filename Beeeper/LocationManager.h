//
//  LocationManager.h
//  GPSActivity
//
//  Created by George Termentzoglou on 1/15/12.
//  Copyright (c) 2012 AUEB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@protocol LocationManagerDelegate 
@required
- (void)locationUpdate:(CLLocation *)location;
- (void)locationError:(NSError *)error;
@optional
- (void)locationDisabled;
- (void)saveData:(CLLocation *)location date:(NSDate *) date timeElapsed:(double) elapsed;
@end

@interface LocationManager : NSObject <CLLocationManagerDelegate> {
    
    CLLocationManager *locationManager;
    int locationsCounter;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) id<LocationManagerDelegate>  delegate;
@property (nonatomic, assign) float timeDifference;
@property (nonatomic, assign) int signalsCounter;


@property (nonatomic, retain) NSDate *lastSavedTimestamp;
@property (nonatomic, retain) NSDate *firstSavedTimestamp;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

-(void)startTracking;

-(void)stopTracking;

@end
