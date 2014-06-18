//
//  MyDateTimePicker.m
//  iHotel
//
//  Created by George Termentzoglou on 9/22/13.
//  Copyright (c) 2013 George Termentzoglou. All rights reserved.
//

#import "MyDateTimePicker.h"

#define MyDateTimePickerPickerHeight 216
#define MyDateTimePickerToolbarHeight 44

@interface MyDateTimePicker()

@property (nonatomic, assign, readwrite) UIDatePicker *picker;
@property (nonatomic, assign) CGRect originalFrame;

- (void) donePressed;

@end


@implementation MyDateTimePicker

@synthesize picker = _picker;
@synthesize originalFrame = _originalFrame;

- (id) initWithFrame: (CGRect) frame {
    if ((self = [super initWithFrame: frame])) {
        self.originalFrame = frame;
        self.backgroundColor = [UIColor clearColor];
        
        CGFloat width = self.bounds.size.width;
        UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame: CGRectMake(0, 0, width, MyDateTimePickerPickerHeight)];
        [self addSubview: picker];
        
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.frame = CGRectMake(0, MyDateTimePickerPickerHeight, width, MyDateTimePickerToolbarHeight);
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
        doneButton.backgroundColor = [UIColor colorWithRed:250/255.0 green:217/255.0 blue:0 alpha:1];
        [doneButton addTarget:self action:@selector(donePressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:doneButton];
        
        self.picker = picker;
    }
    return self;
}

- (void) setMode: (UIDatePickerMode) mode {
    self.picker.datePickerMode = mode;
}

- (void) donePressed {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"DatePickerDone" object:nil];
}

-(NSDate *)date{
    return self.picker.date;
}

- (void) setHidden: (BOOL) hidden animated: (BOOL) animated {
    CGRect newFrame = self.originalFrame;
    newFrame.origin.y += hidden ? 260 : -260;
    if (animated) {
        [UIView beginAnimations: @"animateDateTimePicker" context: nil];
        [UIView setAnimationDuration: 0.5];
        [UIView setAnimationCurve: UIViewAnimationCurveLinear];
        
        self.frame = newFrame;
        
        [UIView commitAnimations];
    } else {
        self.frame = newFrame;
        if (hidden) {
            [self removeFromSuperview];
        }
    }
}

@end
