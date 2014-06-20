//
//  GTSegmentedControl.m
//  Beeeper
//
//  Created by User on 4/4/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "GTSegmentedControl.h"

@implementation GTSegmentedControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+(id)initWithOptions:(NSArray *)o size:(CGSize)s selectedIndex:(int)index{
   
    GTSegmentedControl *customView = [[[NSBundle mainBundle] loadNibNamed:@"GTSegmentedControl" owner:nil options:nil] lastObject];
    
    // make sure customView is not nil or the wrong class!
    if ([customView isKindOfClass:[GTSegmentedControl class]]){
        
  //      customView.layer.borderWidth = 1;
    //    customView.layer.borderColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:179/255.0 alpha:1].CGColor;
        customView.frame = CGRectMake(0, 0, s.width, s.height);
        
        CGFloat width = s.width/o.count;
        CGPoint selectionCenter;
        
        for (NSString *option in o) {
            int i = (int)[o indexOfObject:option];
            
            UIButton *optionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            optionBtn.frame = CGRectMake(i*width, 1, width, s.height-2);
            optionBtn.backgroundColor = [UIColor clearColor];
            optionBtn.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
            [optionBtn setTitle:option forState:UIControlStateNormal];
            [optionBtn setTitleColor:[UIColor colorWithRed:183/255.0 green:199/255.0 blue:214/255.0 alpha:1] forState:UIControlStateNormal];
            [optionBtn setTag:i];
            [optionBtn addTarget:customView action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [customView addSubview:optionBtn];
            
            if (i == index) {
                selectionCenter = optionBtn.center;
                [optionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
        
        UIView *selectionV = [[UIView alloc]initWithFrame:CGRectMake(0, 2, width-4, s.height-4)];
        selectionV.backgroundColor = [UIColor colorWithRed:250/255.0 green:203/255.0 blue:1/255.0 alpha:1];
        selectionV.center = selectionCenter;
        [customView addSubview:selectionV];
        selectionV.tag = 99;
        [customView sendSubviewToBack:selectionV];
        
        return customView;
    }
    else{
        return nil;
    }
}

-(void)buttonClicked:(UIButton *)btn{
    
    UIView *selectionV = [btn.superview viewWithTag:99];
    
    [UIView animateWithDuration:0.1f
                     animations:^
     {
         selectionV.alpha = 0;
     }
                     completion:^(BOOL finished)
     {
         selectionV.center = btn.center;
         [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
       
         [UIView animateWithDuration:0.1f
                          animations:^
          {
              selectionV.alpha = 1;
             
          }
                          completion:^(BOOL finished)
          {
              
          }
          ];
     }
     ];
    
    for (UIView *v in btn.superview.subviews) {
        if (v != btn && [v isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)v;
            [btn setTitleColor:[UIColor colorWithRed:183/255.0 green:199/255.0 blue:214/255.0 alpha:1] forState:UIControlStateNormal];
        }
    }
    
    [self.delegate selectedSegmentAtIndex:btn.tag];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*- (void)drawRect:(CGRect)rect
{

}
*/

@end
