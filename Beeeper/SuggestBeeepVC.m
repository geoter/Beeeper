//
//  SuggestBeeepVC.m
//  Beeeper
//
//  Created by User on 3/27/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "SuggestBeeepVC.h"

@interface SuggestBeeepVC ()
{
    NSMutableArray *people;
    NSMutableDictionary *pendingImagesDict;
    NSMutableArray *selectedIndexes;
}
@end

@implementation SuggestBeeepVC

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
    // Do any additional setup after loading the view.
    [self adjustFonts];
    
    selectedIndexes = [NSMutableArray array];
    pendingImagesDict = [NSMutableDictionary dictionary];
    
    UIColor *color = [UIColor lightTextColor];
    self.searchTxtF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search by name" attributes:@{NSForegroundColorAttributeName: color}];
    
    [[BPUser sharedBP]getFollowersForUser:[[BPUser sharedBP].user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){
        
        if (completed) {
            people = [NSMutableArray arrayWithArray:objs];
            [self.tableV reloadData];
        }
    }];

}

-(void)adjustFonts{
    UILabel *lbl = (id)[self.containerV viewWithTag:1];
    lbl.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];

    lbl = (id)[self.containerV viewWithTag:2];
    lbl.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closePressed:(id)sender {
    [self hide];
}

-(void)showInView:(UIView *)v{
    
    self.view.frame = v.bounds;
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.containerV.frame = CGRectMake(0, self.view.frame.size.height+self.containerV.frame.size.height, self.containerV.frame.size.width-30, self.containerV.frame.size.height);
    
    [v addSubview:self.view];
    
    [UIView animateWithDuration:0.7f
                     animations:^
     {
         self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
         self.containerV.frame = CGRectMake(0, self.view.frame.size.height-self.containerV.frame.size.height, self.containerV.frame.size.width+30, self.containerV.frame.size.height);
     }
                     completion:^(BOOL finished)
     {

     }
     ];
}

-(void)hide{
    
    [UIView animateWithDuration:0.7f
                     animations:^
     {
         self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
         self.containerV.frame = CGRectMake(0, self.view.frame.size.height+self.containerV.frame.size.height, self.containerV.frame.size.width+30, self.containerV.frame.size.height);
     }
                     completion:^(BOOL finished)
     {
         [self removeFromParentViewController];
         [self.view removeFromSuperview];
     }
     ];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return people.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIImageView *userImage = (id)[cell viewWithTag:1];
    UILabel *nameLbl = (id)[cell viewWithTag:2];
    UIImageView *tickedV = (id)[cell viewWithTag:3];
    
    NSDictionary *user = [people objectAtIndex:indexPath.row];
    
    nameLbl.text = [[NSString stringWithFormat:@"%@ %@",[user objectForKey:@"name"],[user objectForKey:@"lastname"]] capitalizedString];
    

    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *imagePath = [user objectForKey:@"image_path"];
    
    NSString *extension = [[imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
    
    NSString *imageName = [NSString stringWithFormat:@"%@.%@",[imagePath MD5],extension];
    
    NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
        userImage.backgroundColor = [UIColor clearColor];
        userImage.image = nil;
        UIImage *img = [UIImage imageWithContentsOfFile:localPath];
        userImage.image = img;
    }
    else{
        userImage.image = nil;
        [pendingImagesDict setObject:indexPath forKey:imageName];
        
        NSString *extension = [[imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        
        NSString *imageName = [NSString stringWithFormat:@"%@.%@",[imagePath MD5],extension];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(imageDownloadFinished:) name:[imageName MD5] object:nil];
        
        [[DTO sharedDTO]downloadImageFromURL:imagePath];
    }
    
    if ([selectedIndexes indexOfObject:indexPath] != NSNotFound) {
        [tickedV setImage:[UIImage imageNamed:@"selection0cirlce-suggestit"]];
    }
    else{
        [tickedV setImage:[UIImage imageNamed:@"empty-selection0cirlce-suggestit"]];
    }

    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *tickedV = (id)[cell viewWithTag:3];
    
    if ([selectedIndexes indexOfObject:indexPath] == NSNotFound) {
        [selectedIndexes addObject:indexPath];
        tickedV.alpha = 0;
        tickedV.hidden = NO;
 
        [UIView animateWithDuration:0.0f
                     animations:^
     {
         tickedV.alpha = 0;
     }
                     completion:^(BOOL finished)
     {
         [tickedV setImage:[UIImage imageNamed:@"selection0cirlce-suggestit"]];
         
         [UIView animateWithDuration:0.0f
                          animations:^
          {
              tickedV.alpha = 1;
          }
                          completion:^(BOOL finished)
          {
          }
          ];
     }
     ];
        
    }
    else{
        [selectedIndexes removeObject:indexPath];
        
        [UIView animateWithDuration:0.0f
                         animations:^
         {
             tickedV.alpha = 0;
         }
                         completion:^(BOOL finished)
         {
             [tickedV setImage:[UIImage imageNamed:@"empty-selection0cirlce-suggestit"]];
            
             [UIView animateWithDuration:0.0f
                              animations:^
              {
                  tickedV.alpha = 1;
              }
                              completion:^(BOOL finished)
              {
                  
              }
              ];

         }
         ];

    }
}

-(void)imageDownloadFinished:(NSNotification *)notif{
    
    NSString *imageName  = [notif.userInfo objectForKey:@"imageName"];
    
    NSArray* rowsToReload = [NSArray arrayWithObjects:[pendingImagesDict objectForKey:imageName], nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
        [pendingImagesDict removeObjectForKey:imageName];
    });
    
}


@end
