//
//  GTSegmentedControl.h
//  Beeeper
//
//  Created by User on 4/4/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GTSegmentedControl : UIView
{
    NSArray *options;
    CGFloat height;
}

-(void)buttonClicked:(UIButton *)btn;

+(id)initWithOptions:(NSArray *)o size:(CGSize)s;

@end
