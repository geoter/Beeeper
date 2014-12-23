//
//  BPTimeline.m
//  Beeeper
//
//  Created by George Termentzoglou on 4/8/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "BPTimeline.h"
#import "Timeline_Object.h"

static BPTimeline *thisWebServices = nil;

@interface BPTimeline ()
{
    int timeline_page;
    int pageLimit;
    NSString *userID;
    NSString *order;
    NSOperationQueue *operationQueue;
    int option;
    int requestEmptyResultsCounter;
    NSTimeInterval timeStamp;
}
@end

@implementation BPTimeline

-(id)init{
    self = [super init];
    if(self) {
        thisWebServices = self;
        timeline_page = 0;
        pageLimit = 10;
        order = @"ASC";
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 3;
        requestEmptyResultsCounter = 0;
    }
    return(self);
}

+ (BPTimeline *)sharedBP{
    
    if (thisWebServices != nil) {
        return thisWebServices;
    }
    else{
        return [[BPTimeline alloc]init];
    }
    
    return nil;
}

-(void)getLocalTimelineUserID:(NSString *)user_id option:(int)option WithCompletionBlock:(completed)compbloc{
    
    self.localCompleted = compbloc;
    userID = user_id;
    order = (option == Upcoming)?@"ASC":@"DESC";

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"timeline-%@-%@",user_id,order]];
    NSString *json =  [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    [self parseLocalResponseString:json WithCompletionBlock:compbloc];

}

-(void)nextPageTimelineForUserID:(NSString *)user_id option:(int)optionn WithCompletionBlock:(completed)compbloc{
 
    order = (option == Upcoming || optionn == -1)?@"ASC":@"DESC";
    userID = user_id;
    
    timeline_page++;
    
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/beeep/lookup"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/beeep/lookup?"];
    
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"from=%f",timeStamp]];
    [array addObject:[NSString stringWithFormat:@"limit=%d",pageLimit]];
    [array addObject:[NSString stringWithFormat:@"order=%@",order]];
    [array addObject:[NSString stringWithFormat:@"page=%d",timeline_page]];
    [array addObject:[NSString stringWithFormat:@"user=%@",user_id]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    

    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    self.completed = compbloc;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerGETRequest:URL values:array] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:URLwithVars parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self nextTimelineFinished:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self nextTimelineFailed:error.localizedDescription];
    }];

}

-(void)getTimelineForUserID:(NSString *)user_id option:(int)optionn timeStamp:(NSTimeInterval)time WithCompletionBlock:(completed)compbloc{
    
    timeline_page = 0;
    requestEmptyResultsCounter = 0;
    
    order = (optionn == Upcoming || optionn == -1)?@"ASC":@"DESC";
    userID = user_id;
    option = optionn;
    
    timeStamp = (time == 0)?[[NSDate date]timeIntervalSince1970]:time;
    
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/beeep/lookup"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/beeep/lookup?"];

   
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"from=%f",timeStamp]];
    [array addObject:[NSString stringWithFormat:@"limit=%d",pageLimit]];
    [array addObject:[NSString stringWithFormat:@"order=%@",order]];
    [array addObject:[NSString stringWithFormat:@"page=%d",timeline_page]];
    [array addObject:[NSString stringWithFormat:@"user=%@",user_id]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    self.completed = compbloc;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerGETRequest:URL values:array] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:URLwithVars parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self timelineFinished:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self timelineFailed:error.localizedDescription];
    }];
    
}

-(void)timelineFinished:(id)request{

    @try {

        NSString *responseString = request;
      
        NSArray *beeeps = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
        
        if ([beeeps isKindOfClass:[NSArray class]]) {
            
            requestEmptyResultsCounter = 0;
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"timeline-%@-%@",userID,order]];
            NSError *error;
            
            BOOL succeed = [responseString writeToFile:filePath
                                            atomically:YES encoding:NSUTF8StringEncoding error:&error];
            
            [self parseResponseString:responseString WithCompletionBlock:self.completed];
        }
        else{
            
            [[DTO sharedDTO]addBugLog:@"![beeeps isKindOfClass:[NSArray class]]" where:@"BPTimeline/timelineFinished" json:responseString];
            
            requestEmptyResultsCounter++;
            timeline_page --;
            
            if (requestEmptyResultsCounter <= 10) {
                [self nextPageTimelineForUserID:userID option:option WithCompletionBlock:self.completed];
            }
            else{
                [self timelineFailed:request];
            }
        }

    }
    @catch (NSException *exception) {
         [self timelineFailed:request];
    }
    @finally {
        
    }
}

-(void)timelineFailed:(id)request{
    
    timeline_page--;
    
    if (timeline_page < 0) {
        timeline_page = 0;
    }
    
    NSString *responseString = request;
    
   // [[DTO sharedDTO]addBugLog:@"timelineFailed" where:@"BPTimeline/timelineFailed" json:responseString];
    
    self.completed(NO,nil);
}

-(void)nextTimelineFinished:(id)request{
    
    NSString *responseString = request;
    
    [self parseResponseString:responseString WithCompletionBlock:self.completed];
}

-(void)nextTimelineFailed:(id)request{
    
    timeline_page--;

    NSString *responseString = request;
    
    [[DTO sharedDTO]addBugLog:@"nextTimelineFailed" where:@"BPTimeline/nextTimelineFailed" json:responseString];
    
    self.completed(NO,@"nextTimelineFailed");
}

-(void)parseLocalResponseString:(NSString *)responseString WithCompletionBlock:(completed)compbloc{
    
    if (responseString == nil) {
        compbloc(NO,nil);
        return;
    }
    
    NSArray *beeeps = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    NSMutableArray *bs = [NSMutableArray array];
    
    for (NSDictionary *b in beeeps) {
        
        Timeline_Object *beeep = [Timeline_Object modelObjectWithDictionary:b];
        
        [bs addObject:beeep];
    }
    
    
    compbloc(YES,bs);
}

-(void)parseResponseString:(NSString *)responseString WithCompletionBlock:(completed)compbloc{

    @try {
       NSArray *beeeps = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
       
       if (responseString == nil || responseString.length == 0 || ![beeeps isKindOfClass:[NSArray class]]) {
           
           [[DTO sharedDTO]addBugLog:@"responseString == nil" where:@"BPTimeline/parseResponseString" json:responseString];
           
           compbloc(NO,@"Response is nil");
           timeline_page--;
           
           [self nextPageTimelineForUserID:userID option:option WithCompletionBlock:compbloc];
       }
       
       NSMutableArray *bs = [NSMutableArray array];
       
       for (NSDictionary *b in beeeps) {
          
           Timeline_Object *beeep = [Timeline_Object modelObjectWithDictionary:b];
          
           [bs addObject:beeep];
       }
       
       compbloc(YES,bs);
    }
    @catch (NSException *exception) {
       compbloc(NO,nil);
    }
    @finally {
    
    }
   
}


/*-(void)downloadImage:(Timeline_Object *)tml{
    
   // NSString *extension = [[tml.event.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
    
    NSString *imageName = [NSString stringWithFormat:@"%@",[tml.event.imageUrl MD5]];
    
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
        UIImage * result;
        NSData * localData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[DTO sharedDTO]fixLink:tml.event.imageUrl]]];
        result = [UIImage imageWithData:localData];
        [self saveImage:result withFileName:imageName inDirectory:localPath];
    }
}

-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName inDirectory:(NSString *)directoryPath {
    
    if ([imageName rangeOfString:@"n/a"].location != NSNotFound) {
        return;
    }
    
    if ([[imageName lowercaseString] rangeOfString:@".png"].location != NSNotFound) {
        [UIImagePNGRepresentation(image) writeToFile:directoryPath options:NSAtomicWrite error:nil];
        NSLog(@"Saved Image: %@",imageName);
        
    } else {
        
        BOOL write = [UIImageJPEGRepresentation(image, 1) writeToFile:directoryPath options:NSAtomicWrite error:nil];
        NSLog(@"Saved Image: %@ - %d",directoryPath,write);
        
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:imageName object:nil userInfo:[NSDictionary dictionaryWithObject:imageName forKey:@"imageName"]];
}*/

@end
