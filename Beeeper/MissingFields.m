//
//  MissingFields.m
//  Beeeper
//
//  Created by George on 6/22/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "MissingFields.h"

@interface MissingFields ()

@end

@implementation MissingFields

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    int i = 0;
    
    for (NSString *fieldName in self.fields) {
        NSString *fieldPlaceHolder = [self.fields objectForKey:fieldName];
        UITextField *textF = [[UITextField alloc]initWithFrame:CGRectMake(20, 50*i+50, 280, 40)];
        textF.textColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:177/255.0 alpha:1];
        textF.tag = i;
        textF.placeholder = fieldName;
        textF.backgroundColor = [UIColor clearColor];
        UIView *v = [[UIView alloc]initWithFrame:CGRectMake(20, textF.frame.origin.y+textF.frame.size.height+1, 280, 1)];
        v.backgroundColor = [UIColor colorWithRed:163/255.0 green:172/255.0 blue:177/255.0 alpha:1];
        v.tag = i;
        [self.scrollV addSubview:textF];
        [self.scrollV addSubview:v];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
