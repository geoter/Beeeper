//
//  BPActivity.m
//  Beeeper
//
//  Created by George Termentzoglou on 6/10/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "BPActivity.h"
#import "Beeep_Object.h"
#import "Event_Show_Object.h"

static BPActivity *thisWebServices = nil;

@interface BPActivity ()
{
    int page;
    
    NSOperationQueue *operationQueue;
    int requestFailedCounter;
}
@end

@implementation BPActivity
@synthesize pageLimit;

-(id)init{
    self = [super init];
    if(self) {
        thisWebServices = self;
        page = 0;
        pageLimit = 10;
        operationQueue = [[NSOperationQueue alloc] init];
        requestFailedCounter = 0;
    }
    return(self);
}

+ (BPActivity *)sharedBP{
    
    if (thisWebServices != nil) {
        return thisWebServices;
    }
    else{
        return [[BPActivity alloc]init];
    }
    
    return nil;
}

#pragma mark - Activity

-(void)getLocalActivityWithCompletionBlock:(completed)compbloc{
    self.local_activity_completed = compbloc;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"activity-%@",[[BPUser sharedBP].user objectForKey:@"id"]]];
    NSString *json =  [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    [self parseLocalResponseString:json WithCompletionBlock:compbloc];

}

-(void)nextPageActivityWithCompletionBlock:(completed)compbloc{
    
    page ++;
    
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/activity/show"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/activity/show?"];
    
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"limit=%d",pageLimit]];
    [array addObject:[NSString stringWithFormat:@"page=%d",page]];
    
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
    
    self.activity_completed = compbloc;
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:20.0];
    
    [request setDelegate:self];
    
    //    [[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(activityFinished:)];
    
    [request setDidFailSelector:@selector(activityFailed:)];
    
    [request startAsynchronous];

}

-(void)getActivityWithCompletionBlock:(completed)compbloc{
    
    page = 0;
    
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/activity/show"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/activity/show?"];
    
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"limit=%d",pageLimit]];
    [array addObject:[NSString stringWithFormat:@"page=%d",page]];
    
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
    
    self.activity_completed = compbloc;
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:20.0];
    
    [request setDelegate:self];
    
    //    [[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(activityFinished:)];
    
    [request setDidFailSelector:@selector(activityFailed:)];
    
    [request startAsynchronous];
    
}

-(void)activityFinished:(ASIHTTPRequest *)request{
    
    requestFailedCounter = 0;
    
    NSString *responseString = [request responseString];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
    
    NSArray *beeeps = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];

    if ([beeeps isKindOfClass:[NSArray class]]) {
      
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"activity-%@",[[BPUser sharedBP].user objectForKey:@"id"]]];
        NSError *error;
        
        BOOL succeed = [responseString writeToFile:filePath
                                        atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        
        [self parseResponseString:responseString WithCompletionBlock:self.activity_completed];
    }
    else{
        
        [[DTO sharedDTO]addBugLog:@"beeeps.count == 0" where:@"bpactivity/activityFinished ->sending to activityFailed" json:responseString];
        
        [self activityFailed:request];
    }

}

-(void)activityFailed:(ASIHTTPRequest *)request{
    
    NSLog(@"FAILES REQUEST->ACTIVITY");

    NSString *responseString  = [request responseString];
    requestFailedCounter++;
    
     [[DTO sharedDTO]addBugLog:@"activityFailed" where:@"bpactivity/activityFailed" json:responseString];
    
    if (requestFailedCounter < 10) {
        [self getActivityWithCompletionBlock:self.activity_completed];
    }
    else{
        self.activity_completed(NO,@"activityFailed");
    }
    
}

-(void)parseResponseString:(NSString *)responseString WithCompletionBlock:(completed)compbloc{
    
    if (responseString == nil) {
        
        [[DTO sharedDTO]addBugLog:@"responseString == nil" where:@"bpactivity/parseResponseString" json:responseString];
        
        compbloc(NO,@"Response String is NIL");
    }

    NSArray *beeeps = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    if (responseString.length == 0 || beeeps == nil) { //something went wrong
        NSLog(@"Empty");
        
         [[DTO sharedDTO]addBugLog:@"responseString.length == 0 || beeeps == nil" where:@"bpactivity/parseResponseString" json:responseString];
        
        [self getActivityWithCompletionBlock:self.activity_completed];
        return;
    }
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
    
    NSMutableArray *bs = [NSMutableArray array];
    
    for (id b in beeeps) {

        Activity_Object *activity;
        
        if ([b isKindOfClass:[NSString class]]) {
            NSDictionary *activity_item = [b objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
            
            activity = [Activity_Object modelObjectWithDictionary:activity_item];
        }
        else{
            activity = [Activity_Object modelObjectWithDictionary:b];
        }
        
//        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:activity];
//        [operationQueue addOperation:invocationOperation];
        
        [bs addObject:activity];
    }
    
    if (bs.count == 0) {
        [[DTO sharedDTO]addBugLog:@"bs.count == 0" where:@"bpactivity/parseResponseString" json:responseString];
    }
    
    compbloc(YES,bs);
}

-(void)parseLocalResponseString:(NSString *)responseString WithCompletionBlock:(completed)compbloc{
    
    
    NSArray *beeeps = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    if (responseString.length == 0 || beeeps == nil || beeeps.count == 0) { //something went wrong
        
         compbloc(NO,nil);
        return;
    }
    
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
    
    NSMutableArray *bs = [NSMutableArray array];
    
    for (id b in beeeps) {
        
        Activity_Object *activity;
        
        if ([b isKindOfClass:[NSString class]]) {
            NSDictionary *activity_item = [b objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
            
            activity = [Activity_Object modelObjectWithDictionary:activity_item];
        }
        else{
            activity = [Activity_Object modelObjectWithDictionary:b];
        }
        //        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:activity];
        //        [operationQueue addOperation:invocationOperation];
        
        [bs addObject:activity];
    }
    
    compbloc(YES,bs);
}
#pragma mark - Event

-(void)getEventFromFingerprint:(NSString *)fingerprint WithCompletionBlock:(completed)compbloc{
    
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/show?"];
     
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"fingerprint=%@",[[DTO sharedDTO] urlencode:[[DTO sharedDTO] urlencode:fingerprint]]]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    self.event_completed = compbloc;
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:20.0];
    
    [request setDelegate:self];
    
    //[[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(eventReceived:)];
    
    [request setDidFailSelector:@selector(eventFailed:)];
    
    [request startAsynchronous];
    
}


-(void)getEvent:(Activity_Object *)activityObj WithCompletionBlock:(completed)compbloc{
    
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/show?"];
    NSString *fingerprint = [[activityObj.eventActivity firstObject]valueForKeyPath:@"fingerprint"];
    
    if (fingerprint == nil) {
        EventActivity *event = [activityObj.beeepInfoActivity.eventActivity firstObject];
        fingerprint = event.fingerprint;
    }
    
    fingerprint = [fingerprint stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
   
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"fingerprint=%@",[[DTO sharedDTO] urlencode:[[DTO sharedDTO] urlencode:fingerprint]]]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    self.event_completed = compbloc;
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:20.0];
    
    [request setDelegate:self];
    
    //[[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(eventReceived:)];
    
    [request setDidFailSelector:@selector(eventFailed:)];
    
    [request startAsynchronous];
    
}

-(void)eventReceived:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    id eventObject = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    NSArray *eventArray;
    
    if ([eventObject isKindOfClass:[NSDictionary class]]) {

         Event_Show_Object *event = [Event_Show_Object modelObjectWithDictionary:eventObject];
        self.event_completed(YES,event);
    }
    else if ([eventObject isKindOfClass:[NSArray class]]){
        eventArray = eventObject;
        
        if (eventArray.count > 0 ) {
            Event_Show_Object *event = [Event_Show_Object modelObjectWithDictionary:eventArray.firstObject];
            self.event_completed(YES,event);
        }
        else{
            [[DTO sharedDTO]addBugLog:@"eventArray.count == 0" where:@"bpactivity/eventReceived" json:responseString];
            
            self.event_completed(NO,[NSString stringWithFormat:@"eventReceived but failed in [NSArray class]: %@",responseString]);
        }
    }
    else{
        [[DTO sharedDTO]addBugLog:@"else" where:@"bpactivity/eventReceived" json:responseString];
        
        self.event_completed(NO,[NSString stringWithFormat:@"eventReceived but failed in else: %@",responseString]);
    }
    
   
    
}

-(void)eventFailed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    [[DTO sharedDTO]addBugLog:@"eventFailed" where:@"bpactivity/eventFailed" json:responseString];
    self.event_completed(NO,nil);
}



-(void)getBeeepInfoFromActivity:(Activity_Object *)actObj WithCompletionBlock:(completed)compbloc{

    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/beeep/show"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/beeep/show?"];
    
    NSString *fingerprint;
    NSString *userID;
    
    if (actObj.eventActivity.count > 0) {
        EventActivity *event = [actObj.eventActivity firstObject];
        fingerprint = event.fingerprint;
    }
    else if (actObj.beeepInfoActivity.eventActivity.count > 0){
        BeeepActivity *event = [actObj.beeepInfoActivity.beeepActivity firstObject];
        userID = event.userId;
        fingerprint = [[event.beeepsActivity firstObject] valueForKeyPath:@"weight"];
    }
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"beeep_id=%@",fingerprint]];
    [array addObject:[NSString stringWithFormat:@"user=%@",userID]];
    
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
    
    self.beeep_completed = compbloc;
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:20.0];
    
    [request setDelegate:self];
    
    //[[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(beeepFromActivityFinished:)];
    
    [request setDidFailSelector:@selector(beeepFromActivityFailed:)];
    
    [request startAsynchronous];

}

-(void)beeepFromActivityFinished:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    id eventObject = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];

    NSArray *eventArray;
    
    if ([eventObject isKindOfClass:[NSDictionary class]]) {
        Beeep_Object *beeep = [Beeep_Object modelObjectWithDictionary:eventObject];
        self.beeep_completed(YES,beeep);

    }
    else if ([eventObject isKindOfClass:[NSArray class]]){
        eventArray = eventObject;
        Beeep_Object *beeep = [Beeep_Object modelObjectWithDictionary:[eventArray firstObject]];
        self.beeep_completed(YES,beeep);
    }
    else{
        
        [[DTO sharedDTO]addBugLog:@"else" where:@"bpactivity/beeepFromActivityFinished" json:responseString];
        
        self.beeep_completed(NO,[NSString stringWithFormat:@"BeeepFromActivityFinished but failed: %@",responseString]);
    }
   
}

-(void)beeepFromActivityFailed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    [[DTO sharedDTO]addBugLog:@"beeepFromActivityFailed" where:@"bpactivity/beeepFromActivityFailed" json:responseString];
    
    self.beeep_completed(NO,@"BeeepFromActivityFailed");
}





-(void)downloadImage:(Activity_Object *)actv{
    
    @try {
        for (Who *w in actv.who) {
            
     //       NSString *extension = [[w.imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
            
            NSString *imageName = [NSString stringWithFormat:@"%@",[w.imagePath MD5]];
            
            NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
            
            if (![[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
                UIImage * result;
                
                NSData * localData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[DTO sharedDTO]fixLink:w.imagePath]]];
                result = [UIImage imageWithData:localData];
                [self saveImage:result withFileName:imageName inDirectory:localPath];
            }
            
        }

    }
    @catch (NSException *exception) {
        NSLog(@"Who download image CRASHED");
    }
    @finally {
    
    }

    
    @try {
        for (Whom *w in actv.whom) {
            
            //NSString *extension = [[w.imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
            
            NSString *imageName = [NSString stringWithFormat:@"%@",[w.imagePath MD5]];
            
            NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
            
            if (![[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
                UIImage * result;
                NSData * localData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[DTO sharedDTO]fixLink:w.imagePath]]];
                result = [UIImage imageWithData:localData];
                [self saveImage:result withFileName:imageName inDirectory:localPath];
            }
            
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"WhoM download image CRASHED");
    }
    @finally {
        
    }
    
    if (actv.eventActivity != nil){
        
        EventActivity *event = [actv.eventActivity firstObject];
        
        NSString *path = event.imageUrl;
        
        //NSString *extension = [[path.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        
        NSString *imageName = [NSString stringWithFormat:@"%@",[path MD5]];
        
        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
        
        if (![[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
            UIImage * result;
            NSData * localData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[DTO sharedDTO]fixLink:path]]];
            result = [UIImage imageWithData:localData];
            [self saveImage:result withFileName:imageName inDirectory:localPath];
        }

    }
    
    if(actv.beeepInfoActivity.eventActivity != nil){
        
        EventActivity *event = [actv.beeepInfoActivity.eventActivity firstObject];
        
        NSString *path = event.imageUrl;
        
       // NSString *extension = [[path.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        
        NSString *imageName = [NSString stringWithFormat:@"%@",[path MD5]];
        
        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
        
        if (![[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
            UIImage * result;
            NSData * localData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[DTO sharedDTO]fixLink:path]]];
            result = [UIImage imageWithData:localData];
            [self saveImage:result withFileName:imageName inDirectory:localPath];
        }

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

- (NSString *)urlencode:(NSString *)str {
    CFStringRef safeString =
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef)str,
                                            NULL,
                                            CFSTR("/%&=?$#+-~@<>|\*,()[]{}^!:"),
                                            kCFStringEncodingUTF8);
    return [NSString stringWithFormat:@"%@", safeString];
}


@end
