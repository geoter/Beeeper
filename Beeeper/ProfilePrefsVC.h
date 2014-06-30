//
//  ProfilePrefsVC.h
//  Beeeper
//
//  Created by User on 2/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class SPGooglePlacesAutocompleteQuery;
@interface ProfilePrefsVC : UIViewController{
    NSArray *searchResultPlaces;
    SPGooglePlacesAutocompleteQuery *searchQuery;
    MKPointAnnotation *selectedPlaceAnnotation;
    
    BOOL shouldBeginEditing;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollV;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UITextField *locationTxtF;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

- (IBAction)changeProfilePicture:(id)sender;
- (IBAction)changedGender:(id)sender;

@end
