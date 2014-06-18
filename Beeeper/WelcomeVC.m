//
//  WelcomeVC.m
//  Beeeper
//
//  Created by User on 3/7/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "WelcomeVC.h"

@interface WelcomeVC ()
{
    NSMutableArray *animatedBGImages;
    BOOL cancelAllAnimations;
    BOOL firstTime;
}
@end

@implementation WelcomeVC

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

    
    [[UINavigationBar appearance] setBarTintColor: [UIColor colorWithRed:250/255.0 green:217/255.0 blue:0 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    //Swipe to go back enable
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    

}

-(void)viewWillAppear:(BOOL)animated{

    firstTime = YES;
    
    cancelAllAnimations = NO;

    [self adjustFonts];
    
    
    [self loadGalleryAnimatedImages];
    
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    cancelAllAnimations = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super viewWillDisappear:animated];
}

-(void)adjustFonts{
    
    for(UIView *v in [self.view allSubViews])
    {
        if([v isKindOfClass:[UIButton class]])
        {
            ((UIButton*)v).titleLabel.font = [UIFont fontWithName:@"Roboto-Medium" size:16];
        }
    }

    
}

-(void)loadGalleryAnimatedImages{
    
    animatedBGImages = [NSMutableArray array];
    
    @try {
        for (int i = 0; i <= 2; i++) { //100 is just a big number
            NSString *photoName = [NSString stringWithFormat:@"welcome_screen_%d",i];
            
            NSString *path = [[NSBundle mainBundle] pathForResource:photoName ofType:@"png"];
            
            if ([UIImage imageWithContentsOfFile:path] != nil) {
                UIImage *image = [UIImage imageWithContentsOfFile:path];
                
                if (i == 1) {
                    [self.bgImage setImage:image];
                }
                
                
                [animatedBGImages addObject:image];
            }
        }
        
        
        
        if (animatedBGImages.count > 0) {
            [self performSelector:@selector(animateNextGalleryImage) withObject:nil afterDelay:(firstTime)?1:2.0];
            firstTime = NO;
        }
        
    }
    @catch (NSException *exception) {
        [self loadGalleryAnimatedImages];
    }
    @finally {
        
    }
}

-(void)animateNextGalleryImage{
    
    if (cancelAllAnimations) {
        return;
    }
    
    static int i = 1;
    
    UIImageView *galleryButton = self.bgImage;
    
    
    if (i == animatedBGImages.count) {
        i=0;
    }
    
    UIImage *trans_img;
    
    @try {
        trans_img = [animatedBGImages objectAtIndex:i];
    }
    @catch (NSException *exception) {
        i = 0;
        trans_img = [animatedBGImages objectAtIndex:i];
        NSLog(@"ESKASE");
    }
    @finally {
        
    }
    
    CATransition *transition = [CATransition animation];
    transition.duration = 2.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [galleryButton.layer addAnimation:transition forKey:nil];
    [galleryButton setImage:trans_img ];
    
    ++i;
    [self performSelector:@selector(animateNextGalleryImage) withObject:nil afterDelay:4.0];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)back:(UIStoryboardSegue *)segue{
    
}


- (IBAction)login:(id)sender {
    UIViewController *viewController = [[UIStoryboard storyboardWithName:@"Storyboard-No-AutoLayout" bundle:nil] instantiateViewControllerWithIdentifier:@"ChooseLoginVC"];
    [self.navigationController pushViewController:viewController animated:YES];
}
@end
