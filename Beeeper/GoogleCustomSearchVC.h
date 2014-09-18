//
//  GoogleCustomSearchVC.h
//  Beeeper
//
//  Created by George on 9/17/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoogleCustomSearchVC : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIView *topV;
@property (nonatomic,strong) NSString *initialText;
@end
