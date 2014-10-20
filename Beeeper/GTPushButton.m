//
//  GTPushButton.m
//  Beeeper
//
//  Created by GreekMinds on 10/7/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "GTPushButton.h"

@implementation GTPushButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
   
    [super drawRect:rect];
   
    if (self.selectionColor == nil) {
        self.selectionColor = [UIColor colorWithRed:225/255.0 green:226/255.0 blue:226/255.0 alpha:1];
    }
    
    [self setBackgroundImage:[self imageWithColor:self.selectionColor] forState:UIControlStateHighlighted];
    
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.1 animations:^{
        self.backgroundColor = [UIColor colorWithRed:225/255.0 green:226/255.0 blue:226/255.0 alpha:1];
    }];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.1 animations:^{
        self.backgroundColor = [UIColor whiteColor];
    }];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.1 animations:^{
        self.backgroundColor = [UIColor whiteColor];
    }];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
   
    [UIView animateWithDuration:0.1 animations:^{
        self.backgroundColor = [UIColor whiteColor];
    }];
}*/

@end
