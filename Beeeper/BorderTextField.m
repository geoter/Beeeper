//
//  BorderTextField.m
//  Beeeper
//
//  Created by George on 6/30/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "BorderTextField.h"

@implementation BorderTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 0);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 0);
}

@end
