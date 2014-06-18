//
//  AddEventVC.h
//  Beeeper
//
//  Created by User on 2/20/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddEventVC : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollV;
@property (weak, nonatomic) IBOutlet UIScrollView *imagesScrollV;
@property (weak, nonatomic) IBOutlet UIPageControl *imagesPageControl;

- (IBAction)imageSelected:(id)sender;

@end
