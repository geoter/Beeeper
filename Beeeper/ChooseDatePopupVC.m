//
//  ChooseDatePopupVC.m
//  Beeeper
//
//  Created by GreekMinds on 10/28/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "ChooseDatePopupVC.h"
#import "CalendarView.h"

@interface ChooseDatePopupVC ()<CalendarViewDelegate>
{
    CalendarView *calendar;
}
@end

@implementation ChooseDatePopupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapg = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(releaseMe:)];
    [self.view addGestureRecognizer:tapg];
    
    self.expandableV.roundedCorners = TKRoundedCornerNone;
    self.expandableV.cornerRadius = 6;
    self.expandableV.borderWidth = 0;

    self.optionsV.roundedCorners = TKRoundedCornerNone;
    self.optionsV.cornerRadius = 6;
    self.optionsV.borderWidth = 0;
    
    UIImage *blurredImg = [[DTO sharedDTO]convertViewToBlurredImage:self.superviewToBlur withRadius:7];
    self.blurredImageV.image = blurredImg;
    
}

-(void)viewWillAppear:(BOOL)animated{
   
    [super viewWillAppear:animated];
    
    switch (self.option) {
        case 0:
            self.optionLabel.text = [NSString stringWithFormat:@"Upcoming"];
            break;
        case 1:
            self.optionLabel.text = [NSString stringWithFormat:@"Past"];
            break;
        case 2:
            self.optionLabel.text = [NSString stringWithFormat:@"Choose Date"];
            break;
        default:
            break;
    }
    
    [self.optionLabel sizeToFit];
    self.optionLabel.center = CGPointMake(self.optionLabel.superview.center.x,self.optionLabel.center.y);

    UIImageView *arrow = self.arrowIcon;
    arrow.center = self.optionLabel.center;
    arrow.frame = CGRectMake(self.optionLabel.frame.origin.x+self.optionLabel.frame.size.width+3, arrow.frame.origin.y, arrow.frame.size.width, arrow.frame.size.height);
    
    for(UIButton *btn in self.optionsV.subviews){
        
        if (![btn isKindOfClass:[UIButton class]]) {
            continue;
        }
        
        if(btn.tag != self.option){
            [btn setTitleColor:[UIColor colorWithRed:137/255.0 green:137/255.0 blue:137/255.0 alpha:1] forState:UIControlStateNormal];
        }
        else{
            [btn setTitleColor:[UIColor colorWithRed:240/255.0 green:208/255.0 blue:0/255.0 alpha:1] forState:UIControlStateNormal];
            self.tickIcon.center = CGPointMake(self.tickIcon.center.x, btn.center.y);
        }
    }
    
    [UIView animateWithDuration:0.4f
                     animations:^
     {
         self.popupBGV.alpha = 1;
     }
                     completion:^(BOOL finished)
     {
         
     }
     ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)selection:(UIButton *)sender {
    
    for(UIButton *btn in self.optionsV.subviews){
        if (![btn isKindOfClass:[UIButton class]]) {
            continue;
        }
        if(btn != sender){
            [btn setTitleColor:[UIColor colorWithRed:137/255.0 green:137/255.0 blue:137/255.0 alpha:1] forState:UIControlStateNormal];
        }
        else{
            [btn setTitleColor:[UIColor colorWithRed:240/255.0 green:208/255.0 blue:0/255.0 alpha:1] forState:UIControlStateNormal];
        }
    }
    
    
    self.option = (int)sender.tag;

   
    [UIView animateWithDuration:0.1f
                     animations:^
     {
         self.tickIcon.alpha = 0;
     }
                     completion:^(BOOL finished)
     {
         self.tickIcon.center = CGPointMake(self.tickIcon.center.x, sender.center.y);
         
         [UIView animateWithDuration:0.1f
                          animations:^
          {
              self.tickIcon.alpha = 1;
              
              switch (sender.tag) {
                  case 0:
                      self.optionLabel.text = [NSString stringWithFormat:@"Upcoming"];
                      break;
                  case 1:
                      self.optionLabel.text = [NSString stringWithFormat:@"Past"];
                      break;
                  case 2:
                      self.optionLabel.text = [NSString stringWithFormat:@"Choose Date"];
                      break;
                  default:
                      break;
              }
              
              [self.optionLabel sizeToFit];
              self.optionLabel.center = CGPointMake(self.optionLabel.superview.center.x,self.optionLabel.center.y);
              
              UIImageView *arrow = self.arrowIcon;
              arrow.center = self.optionLabel.center;
              arrow.frame = CGRectMake(self.optionLabel.frame.origin.x+self.optionLabel.frame.size.width+3, arrow.frame.origin.y, arrow.frame.size.width, arrow.frame.size.height);
          }
                          completion:^(BOOL finished)
          {
              if (sender.tag == 2) {
                  [self showCalendar];
              }
              else{
                  [self.delegate datePopupIndexOptionSelected:(int)sender.tag];
              }
          }];

     }
     ];
    
   
}

-(void)showCalendar{
    
    self.optionsV.alpha = 0;
    [self.view bringSubviewToFront:self.expandableV];
    
    CalendarView *cv = [[CalendarView alloc] initWithPosition:0.0 y:12.0];
    [cv setMode:1];
    cv.calendarDelegate = self;
    cv.center = CGPointMake(self.expandableV.center.x, cv.center.y);
    [self.expandableV addSubview:cv];

    UIView *lineV = [[UIView alloc]initWithFrame:CGRectMake(cv.frame.origin.x+5, 42, cv.frame.size.width-10, 1)];
    lineV.backgroundColor = [ UIColor colorWithRed:232/255.0 green:234/255.0 blue:235/255.0 alpha:1];

    [self.expandableV addSubview:lineV];
    
    [UIView animateWithDuration:0.4f
                     animations:^
     {
      
         self.expandableV.frame = CGRectMake(0, self.expandableV.frame.origin.y, self.expandableV.frame.size.width, cv.frame.size.height+15);
     }
                     completion:^(BOOL finished)
     {
           self.optionsV.alpha = 0; 
     }
     ];
}

#pragma mark - Calendar Delegate

- (void)didChangeCalendarDate:(NSDate *)date{
    NSLog(@"%@",date);
    self.selectedDate = date;
}

- (void)didDoubleTapCalendar:(NSDate *)date withType:(NSInteger)type{
        NSLog(@"%@",date);
    self.selectedDate = date;
    [self.delegate datePopupIndexOptionSelected:2];
}

-(void)releaseMe:(UITapGestureRecognizer *)tagG{
    [self.delegate datePopupIndexOptionSelected:-10];
}
@end
