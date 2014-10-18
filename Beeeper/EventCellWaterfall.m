//
//  EventCellWaterfall.m
//  Beeeper
//
//  Created by User on 4/2/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "EventCellWaterfall.h"

@implementation EventCellWaterfall

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
            }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{

    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(currentContext);
    CGContextSetShadowWithColor(currentContext, CGSizeMake(0, 0.1), 0.8, [[UIColor colorWithWhite:0.667  alpha:0.7] CGColor]);
    CGContextSetFillColorWithColor(currentContext, [UIColor redColor].CGColor);
    CGContextRestoreGState(currentContext);
    
//    UIColor * shadowColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
//
//    CGContextRef currentContext = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(currentContext);
//    CGContextSetShadowWithColor(currentContext, CGSizeMake(0, 2), 3.0, shadowColor.CGColor);
//    [super drawRect: rect];
//    CGContextRestoreGState(currentContext);

  //    // cell.layer.cornerRadius = 8; // if you like rounded corners
//    self.layer.shadowOffset = CGSizeMake(0.0, 0.5);
//    self.layer.shadowRadius = 1.3;
//    self.layer.shadowOpacity = 0.3;
    //self.layer.masksToBounds = NO;
   // self.layer.borderColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:0.3].CGColor;
   // self.layer.borderWidth = 0.5;
}


/*
 cell.layer.masksToBounds = NO;
 // cell.layer.cornerRadius = 8; // if you like rounded corners
 cell.layer.shadowOffset = CGSizeMake(0.0, 0.5);
 cell.layer.shadowRadius = 1.3;
 cell.layer.shadowOpacity = 0.3;
 
 cell.layer.borderColor = [UIColor colorWithRed:35/255.0 green:44/255.0 blue:59/255.0 alpha:0.3].CGColor;
 cell.layer.borderWidth = 0.5;
 */

@end
