//
//  SPGooglePlacesAutocompleteDemoViewController.h
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import <MapKit/MapKit.h>

@class SPGooglePlacesAutocompleteQuery;

@interface SPGooglePlacesAutocompleteDemoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, MKMapViewDelegate> {
    NSArray *searchResultPlaces;
    SPGooglePlacesAutocompleteQuery *searchQuery;
    MKPointAnnotation *selectedPlaceAnnotation;
    
    BOOL shouldBeginEditing;
}

@end
