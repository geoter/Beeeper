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
    int page;
    int pageLimit;

    NSString *order;
    NSOperationQueue *operationQueue;

}
@end

@implementation BPTimeline

-(id)init{
    self = [super init];
    if(self) {
        thisWebServices = self;
        page = 0;
        pageLimit = 50;
        order = @"ASC";
        operationQueue = [[NSOperationQueue alloc] init];
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


-(void)getTimelineForUserID:(NSString *)user_id option:(int)option WithCompletionBlock:(completed)compbloc{
    
    
    NSTimeInterval timeStamp = [[NSDate date]timeIntervalSince1970];
    
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/beeep/lookup"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/beeep/lookup?"];

   
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"from=%f",timeStamp]];
    [array addObject:[NSString stringWithFormat:@"limit=%d",pageLimit]];
    [array addObject:[NSString stringWithFormat:@"order=%@",(option == Upcoming)?@"ASC":@"DESC"]];
    [array addObject:[NSString stringWithFormat:@"page=%d",page]];
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
    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];
    
    NSArray *beeeps = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    NSMutableArray *bs = [NSMutableArray array];
    
    for (NSDictionary *b in beeeps) {
        Timeline_Object *beeep = [Timeline_Object modelObjectWithDictionary:b];

        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:beeep];
        [operationQueue addOperation:invocationOperation];
        
        [bs addObject:beeep];
    }
    
    self.completed(YES,bs);
}

-(void)timelineFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:NULL];

    self.completed(NO,nil);
}

-(void)downloadImage:(Timeline_Object *)tml{
    
    NSString *extension = [[tml.event.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
    
    NSString *imageName = [NSString stringWithFormat:@"%@.%@",[tml.event.imageUrl MD5],extension];
    
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
        UIImage * result;
        NSData * localData = [NSData dataWithContentsOfURL:[NSURL URLWithString:tml.event.imageUrl]];
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
