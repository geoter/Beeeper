//
//  MyDateTimePicker.h
//  iHotel
//
//  Created by George Termentzoglou on 9/22/13.
//  Copyright (c) 2013 George Termentzoglou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyDateTimePicker : UIView {
}

@property (nonatomic, assign, readonly) UIDatePicker *picker;

-(NSDate *)date;
- (void) setMode: (UIDatePickerMode) mode;
- (void) setHidden: (BOOL) hidden animated: (BOOL) animated;

@end

