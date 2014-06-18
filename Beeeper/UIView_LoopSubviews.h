//
//  UIView_LoopSubviews.h
//  Beeeper
//
//  Created by User on 3/7/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LoopSubviews)
- (NSMutableArray*) allSubViews;
@end

// UIView+viewRecursion.m
@implementation UIView (LoopSubviews)
- (NSMutableArray*)allSubViews
{
    NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:self];
    for (UIView *subview in self.subviews)
    {
        [arr addObjectsFromArray:(NSArray*)[subview allSubViews]];
    }
    return arr;
}
@end
