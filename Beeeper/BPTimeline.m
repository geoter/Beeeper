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
    
    [self parseResponseString:json WithCompletionBlock:compbloc];

}

-(void)nextPageTimelineForUserID:(NSString *)user_id option:(int)option WithCompletionBlock:(completed)compbloc{
 
    order = (option == Upcoming)?@"ASC":@"DESC";
    userID = user_id;
    
    timeline_page++;
    
    NSTimeInterval timeStamp = [[NSDate date]timeIntervalSince1970];
    
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
    
    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerGETRequest:URL values:array]];
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    self.completed = compbloc;
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    //    [[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(timelineFinished:)];
    
    [request setDidFailSelector:@selector(timelineFailed:)];
    
    [request startAsynchronous];

}

-(void)getTimelineForUserID:(NSString *)user_id option:(int)option WithCompletionBlock:(completed)compbloc{
    
    timeline_page = 0;
    
    order = (option == Upcoming)?@"ASC":@"DESC";
    userID = user_id;
    
    NSTimeInterval timeStamp = [[NSDate date]timeIntervalSince1970];
    
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
    
    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerGETRequest:URL values:array]];
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    self.completed = compbloc;
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
//    [[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(timelineFinished:)];
    
    [request setDidFailSelector:@selector(timelineFailed:)];
    
    [request startAsynchronous];
    
}

-(void)timelineFinished:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"timeline-%@-%@",userID,order]];
    NSError *error;
    
    BOOL succeed = [responseString writeToFile:filePath
                                    atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    [self parseResponseString:responseString WithCompletionBlock:self.completed];
}

-(void)parseResponseString:(NSString *)responseString WithCompletionBlock:(completed)compbloc{
   
    if (responseString == nil) {
        compbloc(NO,nil);
        timeline_page--;
    }
    
    NSArray *beeeps = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    NSMutableArray *bs = [NSMutableArray array];
    
    for (NSDictionary *b in beeeps) {
        Timeline_Object *beeep = [Timeline_Object modelObjectWithDictionary:b];
        
        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:beeep];
        [operationQueue addOperation:invocationOperation];
        
        [bs addObject:beeep];
    }
    
    compbloc(YES,bs);
}

-(void)timelineFailed:(ASIHTTPRequest *)request{
   
    @try {
        NSString *responseString = [request responseString];
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:NULL];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        timeline_page--;
        self.completed(NO,nil);
    }
   
}

-(void)downloadImage:(Timeline_Object *)tml{
    
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
}

@end
