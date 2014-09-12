//
//  EventWS.m
//  Beeeper
//
//  Created by George on 5/16/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "EventWS.h"
#import "Event_Search.h"
#import "Event_Show_Object.h"

static EventWS *thisWebServices = nil;

@interface EventWS ()
{
    int pageLimit;
    int all_events_page;
    int search_events_page;
    NSString *order;
    NSOperationQueue *operationQueue;
    NSString *events_Search_keyword;
}
@end

@implementation EventWS

-(id)init{
    self = [super init];
    if(self) {
        thisWebServices = self;
        pageLimit = 15;
        all_events_page = 0;
        order = @"ASC";
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 3;

    }
    return(self);
}

+ (EventWS *)sharedBP{
    
    if (thisWebServices != nil) {
        return thisWebServices;
    }
    else{
        return [[EventWS alloc]init];
    }
    
    return nil;
}

#pragma mark - Comment

-(void)postComment:(NSString *)commentText BeeepId:(NSString *)beeep_id user:(NSString *)user_id WithCompletionBlock:(completed)compbloc{
    
    self.comment_completed = compbloc;
    
    @try {
        
        NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/beeep/comment/add"];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
        
        NSMutableArray *postValues = [NSMutableArray array];
        
        [postValues addObject:[NSDictionary dictionaryWithObject:[self urlencode:commentText] forKey:@"comment"]];
        [postValues addObject:[NSDictionary dictionaryWithObject:user_id forKey:@"user"]];
        [postValues addObject:[NSDictionary dictionaryWithObject:beeep_id forKey:@"beeep_id"]];
        
        [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerPOSTRequest:requestURL.absoluteString values:postValues]];
        
        [request addPostValue:commentText forKey:@"comment"];
        [request addPostValue:user_id forKey:@"user"];
        [request addPostValue:beeep_id forKey:@"beeep_id"];
        
        [request setRequestMethod:@"POST"];
        
        [request setTimeOutSeconds:7.0];
        
        [request setDelegate:self];
        
        [request setDidFinishSelector:@selector(postCommentFinished:)];
        
        [request setDidFailSelector:@selector(postCommentFailed:)];
        
        [request startAsynchronous];

    }
    @catch (NSException *exception) {
        self.comment_completed(NO,nil);
    }
    @finally {
    
    }
    
}

-(void)postCommentFinished:(ASIHTTPRequest *)request{
     NSString *responseString = [request responseString];
    self.comment_completed(YES,nil);
}

-(void)postCommentFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    self.comment_completed(NO,nil);
}


-(void)postComment:(NSString *)commentText Event:(NSString *)fingerprint  WithCompletionBlock:(completed)compbloc{
    
    self.comment_completed = compbloc;
    
    @try {
        
        NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/event/comment/add"];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
        
        NSMutableArray *postValues = [NSMutableArray array];
        
        [postValues addObject:[NSDictionary dictionaryWithObject:[self urlencode:commentText] forKey:@"comment"]];
        [postValues addObject:[NSDictionary dictionaryWithObject:[self urlencode:fingerprint] forKey:@"fingerprint"]];
        
        [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerPOSTRequest:requestURL.absoluteString values:postValues]];
        
        [request addPostValue:commentText forKey:@"comment"];
        [request addPostValue:fingerprint forKey:@"fingerprint"];
        
        [request setRequestMethod:@"POST"];
        
        [request setTimeOutSeconds:7.0];
        
        [request setDelegate:self];
        
        [request setDidFinishSelector:@selector(postEventCommentFinished:)];
        
        [request setDidFailSelector:@selector(postEventCommentFailed:)];
        
        [request startAsynchronous];
        
    }
    @catch (NSException *exception) {
        self.comment_completed(NO,nil);
    }
    @finally {
        
    }
    
}

-(void)postEventCommentFinished:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    self.comment_completed(YES,nil);
}

-(void)postEventCommentFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    self.comment_completed(NO,nil);
}


#pragma mark - Like

-(void)likeBeeep:(NSString *)beeepID user:(NSString *)userID WithCompletionBlock:(completed)compbloc{

    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/beeep/like"];
    
    self.like_beeep_completed = compbloc;
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:URL];
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    [postValues addObject:[NSDictionary dictionaryWithObject:userID forKey:@"user"]];
    [postValues addObject:[NSDictionary dictionaryWithObject:beeepID forKey:@"beeep_id"]];
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerPOSTRequest:URL.absoluteString values:postValues]];
    
    [request addPostValue:userID forKey:@"user"];
    [request addPostValue:beeepID forKey:@"beeep_id"];
    
    [request setRequestMethod:@"POST"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(like_Beeep_Received:)];
    
    [request setDidFailSelector:@selector(like_Beeep_Failed:)];
    
    [request startAsynchronous];

}


-(void)like_Beeep_Received:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    NSDictionary *response = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    
    @try {
        if ([response objectForKey:@"success"]) {
            self.like_beeep_completed(YES,nil);
        }
        else{
            self.like_beeep_completed(NO,response);
        }
    }
    @catch (NSException *exception) {
        self.like_beeep_completed(NO,response);
    }
    @finally {
        
    }

}

-(void)like_Beeep_Failed :(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    self.like_beeep_completed(NO,nil);
    
}

-(void)unlikeBeeep:(NSString *)beeepID user:(NSString *)userID WithCompletionBlock:(completed)compbloc{
   
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/beeep/unlike"];
    
    self.like_beeep_completed = compbloc;
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:URL];
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    [postValues addObject:[NSDictionary dictionaryWithObject:userID forKey:@"user"]];
    [postValues addObject:[NSDictionary dictionaryWithObject:beeepID forKey:@"beeep_id"]];
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerPOSTRequest:URL.absoluteString values:postValues]];
    
    [request addPostValue:userID forKey:@"user"];
    [request addPostValue:beeepID forKey:@"beeep_id"];
    
    [request setRequestMethod:@"POST"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(unlike_Beeep_Received:)];
    
    [request setDidFailSelector:@selector(unlike_Beeep_Failed:)];
    
    [request startAsynchronous];
    
}


-(void)unlike_Beeep_Received:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    NSDictionary *response = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    
    @try {
        if ([response objectForKey:@"success"]) {
            self.like_beeep_completed(YES,nil);
        }
        else{
            self.like_beeep_completed(NO,nil);
        }
    }
    @catch (NSException *exception) {
        self.like_beeep_completed(NO,nil);
    }
    @finally {
        
    }
    
}

-(void)unlike_Beeep_Failed :(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    self.like_beeep_completed(NO,nil);
    
}

#pragma mark - Like Event

-(void)likeEvent:(NSString *)fingerprint WithCompletionBlock:(completed)compbloc{
  
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/event/like"];
    
    self.like_event_completed = compbloc;
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:URL];
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    [postValues addObject:[NSDictionary dictionaryWithObject:[self urlencode:fingerprint] forKey:@"fingerprint"]];
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerPOSTRequest:URL.absoluteString values:postValues]];
    
    [request addPostValue:[self urlencode:fingerprint] forKey:@"fingerprint"];
    
    [request setRequestMethod:@"POST"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(like_Event_Received:)];
    
    [request setDidFailSelector:@selector(like_Event_Failed:)];
    
    [request startAsynchronous];

}

-(void)like_Event_Received:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    NSDictionary *response = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    @try {
        if ([response objectForKey:@"success"]) {
            self.like_event_completed(YES,nil);
        }
        else{
            self.like_event_completed(NO,nil);
        }
    }
    @catch (NSException *exception) {
        self.like_event_completed(NO,nil);
    }
    @finally {
        
    }
    
}

-(void)like_Event_Failed :(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    self.like_event_completed(NO,nil);
    
}


-(void)unlikeEvent:(NSString *)fingerprint WithCompletionBlock:(completed)compbloc{
    
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/event/unlike"];
    
    self.like_event_completed = compbloc;
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:URL];
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    [postValues addObject:[NSDictionary dictionaryWithObject:[self urlencode:fingerprint] forKey:@"fingerprint"]];
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerPOSTRequest:URL.absoluteString values:postValues]];
    
    [request addPostValue:fingerprint forKey:@"fingerprint"];
    
    [request setRequestMethod:@"POST"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(unlike_Event_Received:)];
    
    [request setDidFailSelector:@selector(unlike_Event_Failed:)];
    
    [request startAsynchronous];
    
}

-(void)unlike_Event_Received:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    NSDictionary *response = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    @try {
        if ([response objectForKey:@"success"]) {
            self.like_event_completed(YES,nil);
        }
        else{
            self.like_event_completed(NO,nil);
        }
    }
    @catch (NSException *exception) {
        self.like_event_completed(NO,nil);
    }
    @finally {
        
    }
    
}

-(void)unlike_Event_Failed :(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    self.like_event_completed(NO,nil);
    
}

#pragma mark - Search

-(void)searchKeyword:(NSString *)keyword WithCompletionBlock:(completed)compbloc{
    
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/search"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/search?"];
    
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"title=%@",keyword]];
    
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
    
    self.searchKeyword_completed = compbloc;
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    //    [[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(searchKeywordFinished:)];
    
    [request setDidFailSelector:@selector(searchKeywordFailed:)];
    
    [request startAsynchronous];

}

-(void)searchKeywordFinished:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    NSArray *keywords = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    self.searchKeyword_completed(YES,keywords);
}

-(void)searchKeywordFailed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    self.searchKeyword_completed(NO,nil);
}

#pragma mark - Search events

-(void)searchEvent:(NSString *)keyword WithCompletionBlock:(completed)compbloc{
    
    events_Search_keyword = keyword;
    
    search_events_page = 0;
    
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/lookup"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/lookup?"];
    
    
    NSTimeInterval timeStamp = [[NSDate date]timeIntervalSince1970];
    
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"query=%@",keyword]];
    [array addObject:[NSString stringWithFormat:@"limit=%d",pageLimit]];
    [array addObject:[NSString stringWithFormat:@"order=%@",order]];
    [array addObject:[NSString stringWithFormat:@"page=%d",search_events_page]];
    
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
    
    self.searchEvent_completed = compbloc;
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    //    [[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(searchEventFinished:)];
    
    [request setDidFailSelector:@selector(searchEventFailed:)];
    
    [request startAsynchronous];
    
}

-(void)searchEventFinished:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    NSArray *eventsArray = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    NSMutableArray *events = [NSMutableArray array];
    
    if (eventsArray.count ==0) {
        self.searchEvent_completed(NO,nil);
        return;
    }
    
    for (NSDictionary *event in eventsArray) {
        Event_Search *e = [Event_Search modelObjectWithDictionary:event];
        
        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:e];
        [operationQueue addOperation:invocationOperation];
        
        [events addObject:e];
    }

    
    self.searchEvent_completed(YES,events);
}

-(void)searchEventFailed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    self.searchEvent_completed(NO,nil);
}

-(void)nextSearchEventsWithCompletionBlock:(completed)compbloc{
    
    search_events_page ++;
    
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/lookup"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/lookup?"];
    
    
    NSTimeInterval timeStamp = [[NSDate date]timeIntervalSince1970];
    
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"query=%@",events_Search_keyword]];
    [array addObject:[NSString stringWithFormat:@"limit=%d",pageLimit]];
    [array addObject:[NSString stringWithFormat:@"order=%@",order]];
    [array addObject:[NSString stringWithFormat:@"page=%d",search_events_page]];
    
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
    
    self.searchEvent_completed = compbloc;
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    //    [[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(searchEventFinished:)];
    
    [request setDidFailSelector:@selector(searchEventFailed:)];
    
    [request startAsynchronous];
}

#pragma mark - Homefeed

-(void)nextAllEventsWithCompletionBlock:(completed)compbloc{
    
    all_events_page ++;
    
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/lookup"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/lookup?"];
    
    
    NSTimeInterval timeStamp = [[NSDate date]timeIntervalSince1970];
    
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"limit=%d",pageLimit]];
    [array addObject:[NSString stringWithFormat:@"order=%@",order]];
    [array addObject:[NSString stringWithFormat:@"page=%d",all_events_page]];
    
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
    
    self.get_All_Events_completed = compbloc;
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    //    [[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(getAllEventsFinished:)];
    
    [request setDidFailSelector:@selector(getAllEventsFailed:)];
    
    [request startAsynchronous];

}

-(void)getAllEventsWithCompletionBlock:(completed)compbloc{
    
    all_events_page = 0;
    
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/lookup"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/lookup?"];
    
    
    NSTimeInterval timeStamp = [[NSDate date]timeIntervalSince1970];
    
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"limit=%d",pageLimit]];
    [array addObject:[NSString stringWithFormat:@"order=%@",@"DATE"]];
    [array addObject:[NSString stringWithFormat:@"page=%d",all_events_page]];
    
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
    
    self.get_All_Events_completed = compbloc;
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    //    [[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(getAllEventsFinished:)];
    
    [request setDidFailSelector:@selector(getAllEventsFailed:)];
    
    [request startAsynchronous];
    
}

-(void)getAllEventsFinished:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"homefeed-%@",[[BPUser sharedBP].user objectForKey:@"id"]]];
    NSError *error;
    BOOL succeed = [responseString writeToFile:filePath
                                    atomically:YES encoding:NSUTF8StringEncoding error:&error];

    
    NSArray *eventsArray = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    NSMutableArray *events = [NSMutableArray array];
    
    if (eventsArray.count ==0) {
        self.get_All_Events_completed(NO,nil);
        return;
    }
    
    for (NSDictionary *event in eventsArray) {
        Event_Search *e = [Event_Search modelObjectWithDictionary:event];
        
        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:e];
        [operationQueue addOperation:invocationOperation];
        
        [events addObject:e];
    }
    
    
    self.get_All_Events_completed(YES,events);
}

-(void)getAllEventsFailed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    self.get_All_Events_completed(NO,nil);
}


-(void)getAllLocalEvents:(completed)compbloc{
    
    self.get_All_Local_Events_completed = compbloc;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"homefeed-%@",[[BPUser sharedBP].user objectForKey:@"id"]]];
    NSError *error;
    NSString *json =  [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSArray *eventsArray = [json objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    NSMutableArray *events = [NSMutableArray array];
    
    if (eventsArray.count ==0) {
        self.get_All_Local_Events_completed(NO,nil);
        return;
    }
    
    for (NSDictionary *event in eventsArray) {
        Event_Search *e = [Event_Search modelObjectWithDictionary:event];
        
        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:e];
        [operationQueue addOperation:invocationOperation];
        
        [events addObject:e];
    }
    
    
    self.get_All_Local_Events_completed(YES,events);

}

-(void)downloadImage:(Event_Search *)tml{
    
   // NSString *extension = [[tml.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
    
    NSString *imageName = [NSString stringWithFormat:@"%@",[tml.imageUrl MD5]];
    
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
        UIImage * result;
        NSData * localData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[DTO sharedDTO]fixLink:tml.imageUrl]]];
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


-(void)getEvent:(NSString *)fingerprint WithCompletionBlock:(completed)compbloc{
    
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/show?"];
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"fingerprint=%@",[self urlencode:[self urlencode:fingerprint]]]];
    
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
    
    self.getEvent_completed = compbloc;
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:7.0];
    
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
        self.getEvent_completed(YES,event);
    }
    else if ([eventObject isKindOfClass:[NSArray class]]){
        eventArray = eventObject;
        
        if (eventArray.count > 0 ) {
            Event_Show_Object *event = [Event_Show_Object modelObjectWithDictionary:eventArray.firstObject];
            self.getEvent_completed(YES,event);
        }
        else{
            self.getEvent_completed(NO,nil);
        }
    }
    else{
        self.getEvent_completed(NO,nil);
    }
    
    
    
}

-(void)eventFailed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    self.getEvent_completed(NO,nil);
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
