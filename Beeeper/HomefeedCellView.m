//
//  HomefeedCellView.m
//  Beeeper
//
//  Created by GreekMinds on 10/14/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "HomefeedCellView.h"

@implementation HomefeedCellView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    self.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    self.layer.shadowOpacity = 0.7;
    self.layer.shadowOffset = CGSizeMake(0, 0.1);
    self.layer.shadowRadius = 0.8;
    [self.layer setShadowPath:[[UIBezierPath
                                  bezierPathWithRect:self.bounds] CGPath]];
    
//    CGContextRef currentContext = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(currentContext);
//    CGContextSetShadowWithColor(currentContext, CGSizeMake(0, 0.1), 0.8, [[UIColor colorWithWhite:0.667  alpha:0.7] CGColor]);
//    CGContextSetFillColorWithColor(currentContext, [UIColor redColor].CGColor);
//    CGContextRestoreGState(currentContext);


}


@end
