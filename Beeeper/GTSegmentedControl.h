//
//  GTSegmentedControl.h
//  Beeeper
//
//  Created by User on 4/4/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GTSegmentedControlDelegate <NSObject>
-(void)selectedSegmentAtIndex:(int)index;
@end

@interface GTSegmentedControl : UIView
{
    NSArray *options;
    CGFloat height;
}

@property (nonatomic,weak) id delegate;

-(void)buttonClicked:(UIButton *)btn;

+(id)initWithOptions:(NSArray *)o size:(CGSize)s selectedIndex:(int)index;

@end
