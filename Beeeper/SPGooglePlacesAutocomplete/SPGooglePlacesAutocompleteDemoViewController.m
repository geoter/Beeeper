//
//  SPGooglePlacesAutocompleteDemoViewController.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "SPGooglePlacesAutocompleteDemoViewController.h"
#import "SPGooglePlacesAutocomplete.h"
#import <GoogleMaps/GoogleMaps.h>

@interface SPGooglePlacesAutocompleteDemoViewController ()
{

    GMSMapView *mapView_;
    SVPlacemark *placeMrk;

}
@end

@implementation SPGooglePlacesAutocompleteDemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] initWithApiKey:@"AIzaSyAFsaDn7vyI8pS53zBgYRxu0HfRwYqH-9E"];
        shouldBeginEditing = YES;
    }
    return self;
}

- (void)viewDidLoad {
    
    self.title = @"Find Location";
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_bold"] style:UIBarButtonItemStyleBordered target:self action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];

    
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
    }
    
        // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    
    mapView_.myLocationEnabled = YES;
    self.searchDisplayController.searchBar.placeholder = @"Search City";
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    CLLocation *userloc = [DTO sharedDTO].userLocation;
    float latitude = 37.9810702;
    float longitude = 23.7375054;
    if (userloc != nil) {
        latitude = userloc.coordinate.latitude;
        longitude = userloc.coordinate.longitude;
    }
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude
                                                            longitude:longitude
                                                                 zoom:6];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 22, self.view.frame.size.width, self.view.frame.size.height) camera:camera];
    [self.view addSubview:mapView_];
    [self.view bringSubviewToFront:self.searchDisplayController.searchBar];

}

-(void)goBack{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)donePressed{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"LocationSettingsSelected" object:nil userInfo:[NSDictionary dictionaryWithObject:placeMrk forKey:@"LocationObject"]];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload {


    [super viewDidUnload];
}


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchResultPlaces count];
}

- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath {
    return searchResultPlaces[indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SPGooglePlacesAutocompleteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
    cell.textLabel.text = [self placeAtIndexPath:indexPath].name;
    
    
    return cell;
}

-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)recenterMapToPlacemark:(SVPlacemark *)placemark {
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude,placemark.location.coordinate.longitude);
    
    float radius = 25*500; //radius in meters (25km)
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, radius*2, radius*2);
    
    CLLocationCoordinate2D  northEast = CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta/2, region.center.longitude - region.span.longitudeDelta/2);
    CLLocationCoordinate2D  southWest = CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta/2, region.center.longitude + region.span.longitudeDelta/2);
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.icon = [UIImage imageNamed:(@"marker.png")];
    marker.position = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
    bounds = [bounds includingCoordinate:marker.position];
    bounds = [bounds includingCoordinate:northEast];
    bounds = [bounds includingCoordinate:southWest];
    
    marker.map = mapView_;
    
    [mapView_ animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:30.0f]];
}

- (void)addPlacemarkAnnotationToMap:(SVPlacemark *)placemark addressString:(NSString *)address {
    
    [mapView_ clear];
    
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
//    marker.title = @"You are here";
    marker.map = mapView_;

}

- (void)dismissSearchControllerWhileStayingActive {
    // Animate out the table view.
    NSTimeInterval animationDuration = 0.3;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    self.searchDisplayController.searchResultsTableView.alpha = 0.0;
    [UIView commitAnimations];
    
    [self.searchDisplayController.searchBar resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
    SPGooglePlacesAutocompletePlace *place = [self placeAtIndexPath:indexPath];

    [self.searchDisplayController setActive:NO];

    
    [place resolveToPlacemark:^(SVPlacemark *placemark, NSString *addressString, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not map selected Place"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        } else if (placemark) {
            
            UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Save"
                                                                            style:UIBarButtonItemStyleDone target:self action:@selector(donePressed) ];
            
            self.navigationItem.rightBarButtonItem = rightButton;

            
            placeMrk = placemark;
            
            [self addPlacemarkAnnotationToMap:placemark addressString:addressString];
            [self recenterMapToPlacemark:placemark];
            [self dismissSearchControllerWhileStayingActive];
            [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }];
}

#pragma mark -
#pragma mark UISearchDisplayDelegate

- (void)handleSearchForSearchString:(NSString *)searchString {
    
    
    searchQuery.input = searchString;
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not fetch Places"
                                                            message:error.localizedDescription
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        } else {

            searchResultPlaces = places;
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self handleSearchForSearchString:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}



#pragma mark -
#pragma mark UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![searchBar isFirstResponder]) {
        // User tapped the 'clear' button.
        shouldBeginEditing = NO;
        [self.searchDisplayController setActive:NO];
        [mapView_ clear];
    }
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (shouldBeginEditing) {
        // Animate in the table view.
        
        
        NSTimeInterval animationDuration = 0.3;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        
        self.searchDisplayController.searchResultsTableView.alpha = 0.8;
        [UIView commitAnimations];
        
        [self.searchDisplayController.searchBar setShowsCancelButton:YES animated:YES];
    }
    BOOL boolToReturn = shouldBeginEditing;
    shouldBeginEditing = YES;
    return boolToReturn;
}

#pragma mark -
#pragma mark MKMapView Delegate


@end
