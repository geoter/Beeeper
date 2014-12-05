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
    int all_events_page;
    int search_events_page;
    int requestEmptyResultsCounter;

    NSString *order;
    NSOperationQueue *operationQueue;
    NSString *events_Search_keyword;
}
@end

@implementation EventWS
@synthesize pageLimit;

-(id)init{
    self = [super init];
    if(self) {
        thisWebServices = self;
        pageLimit = 10;
        all_events_page = 0;
        order = @"ASC";
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 3;
        requestEmptyResultsCounter = 0;

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
    
        
        NSMutableArray *postValues = [NSMutableArray array];
        
        [postValues addObject:[NSDictionary dictionaryWithObject:[[DTO sharedDTO] urlencode:[[DTO sharedDTO] urlencode:commentText]] forKey:@"comment"]];
        [postValues addObject:[NSDictionary dictionaryWithObject:user_id forKey:@"user"]];
        [postValues addObject:[NSDictionary dictionaryWithObject:beeep_id forKey:@"beeep_id"]];
    
        
        NSMutableDictionary *postValuesDict = [NSMutableDictionary dictionary];
        
        [postValuesDict setObject:[[DTO sharedDTO] urlencode:commentText] forKey:@"comment"];
        [postValuesDict setObject:user_id forKey:@"user"];
        [postValuesDict setObject:beeep_id forKey:@"beeep_id"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager.requestSerializer setValue:[[BPUser sharedBP] headerPOSTRequest:requestURL.absoluteString values:postValues] forHTTPHeaderField:@"Authorization"];
        
        [manager POST:requestURL.absoluteString parameters:postValuesDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self postCommentFinished:[operation responseString]];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",operation);
            [self postCommentFailed:error.localizedDescription];
        }];
        


    }
    @catch (NSException *exception) {
        
         [[DTO sharedDTO]addBugLog:@"postComment CATCH" where:@"EventWS/postComment" json:commentText];
        
        self.comment_completed(NO,@"postComment CATCH");
    }
    @finally {
    
    }
    
}

-(void)postCommentFinished:(id)request{
     NSString *responseString = request;
    
    @try {
        
        if ([responseString rangeOfString:@"success"].location != NSNotFound) {
            self.comment_completed(YES,nil);
        }
        else{
            
            [[DTO sharedDTO]addBugLog:@"postCommentFinished but not success" where:@"EVENTSWS/postCommentFinished" json:responseString];
            self.comment_completed(YES,nil);
        }
        
    }
    @catch (NSException *exception) {
        
        [[DTO sharedDTO]addBugLog:@"postCommentFinished NOT Finished" where:@"EVENTSWS/postCommentFinished" json:responseString];
        
        self.comment_completed(NO,@"postCommentFinished CATCH");
    }
    @finally {
        
    }

}

-(void)postCommentFailed:(id)request{
    NSString *responseString = request;
    
    [[DTO sharedDTO]addBugLog:@"postCommentFailed" where:@"EventWS/postCommentFailed" json:responseString];
    
    self.comment_completed(NO,[NSString stringWithFormat:@"postCommentFailed: %@",responseString]);
}


-(void)postComment:(NSString *)commentText Event:(NSString *)fingerprint  WithCompletionBlock:(completed)compbloc{
    
    self.comment_completed = compbloc;
    
    @try {
        
        NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/event/comment/add"];
        
        NSMutableArray *postValues = [NSMutableArray array];
        
        [postValues addObject:[NSDictionary dictionaryWithObject:[[DTO sharedDTO] urlencode:commentText] forKey:@"comment"]];
        [postValues addObject:[NSDictionary dictionaryWithObject:[[DTO sharedDTO] urlencode:fingerprint] forKey:@"fingerprint"]];
        
        
        NSMutableDictionary *postValuesDict = [NSMutableDictionary dictionary];
        
        [postValuesDict setObject:commentText forKey:@"comment"];
        [postValuesDict setObject:fingerprint forKey:@"fingerprint"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager.requestSerializer setValue:[[BPUser sharedBP] headerPOSTRequest:requestURL.absoluteString values:postValues] forHTTPHeaderField:@"Authorization"];
        
        [manager POST:requestURL.absoluteString parameters:postValuesDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [self postEventCommentFinished:[operation responseString]];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",operation);
            [self postEventCommentFailed:error.localizedDescription];
        }];
    }
    @catch (NSException *exception) {
        self.comment_completed(NO,[NSString stringWithFormat:@"postComment Event Catch"]);
    }
    @finally {
        
    }
    
}

-(void)postEventCommentFinished:(id)request{
    
    NSString *responseString = request;
    
    @try {
        
        if ([responseString rangeOfString:@"success"].location != NSNotFound) {
            self.comment_completed(YES,nil);
        }
        else{
            
            [[DTO sharedDTO]addBugLog:@"postEventCommentFinished but not success" where:@"EVENTSWS/postEventCommentFinished" json:responseString];
            self.comment_completed(YES,nil);
        }
        
    }
    @catch (NSException *exception) {
        
        [[DTO sharedDTO]addBugLog:@"postEventComment NOT Finished" where:@"EVENTSWS/postEventCommentFinished" json:responseString];
        
        self.comment_completed(NO,@"postEventCommentFinished CATCH");
    }
    @finally {
        
    }
    
}

-(void)postEventCommentFailed:(id)request{
    NSString *responseString = request;
    
    [[DTO sharedDTO]addBugLog:@"postEventCommentFailed" where:@"EventWS/postEventCommentFailed" json:responseString];
    
     self.comment_completed(NO,[NSString stringWithFormat:@"postEventCommentFailed: %@",responseString]);
}


#pragma mark - Like

-(void)likeBeeep:(NSString *)beeepID user:(NSString *)userID WithCompletionBlock:(completed)compbloc{

    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/beeep/like"];
    
    self.like_beeep_completed = compbloc;
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    [postValues addObject:[NSDictionary dictionaryWithObject:userID forKey:@"user"]];
    [postValues addObject:[NSDictionary dictionaryWithObject:beeepID forKey:@"beeep_id"]];
    
    NSMutableDictionary *postValuesDict = [NSMutableDictionary dictionary];
    
    [postValuesDict setObject:userID forKey:@"user"];
    [postValuesDict setObject:beeepID forKey:@"beeep_id"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerPOSTRequest:URL.absoluteString values:postValues] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:URL.absoluteString parameters:postValuesDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self like_Beeep_Received:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self like_Beeep_Failed:error.localizedDescription];
    }];


}


-(void)like_Beeep_Received:(id)request{
    
    NSString *responseString = request;
    
    NSDictionary *response = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    
    @try {
        if ([response objectForKey:@"success"]) {
            self.like_beeep_completed(YES,nil);
        }
        else{
            [[DTO sharedDTO]addBugLog:@"else" where:@"EventWS/like_Beeep_Received" json:responseString];
            
            self.like_beeep_completed(NO,response);
        }
    }
    @catch (NSException *exception) {
        self.like_beeep_completed(NO,[NSString stringWithFormat:@"like_Beeep_Received Catch: %@",responseString]);
    }
    @finally {
        
    }

}

-(void)like_Beeep_Failed :(id)request{
    
    NSString *responseString = request;
    
    [[DTO sharedDTO]addBugLog:@"like_Beeep_Failed" where:@"EventWS/like_Beeep_Failed" json:responseString];
    
    self.like_beeep_completed(NO,[NSString stringWithFormat:@"like_Beeep_Failed: %@",responseString]);
    
}

-(void)unlikeBeeep:(NSString *)beeepID user:(NSString *)userID WithCompletionBlock:(completed)compbloc{
   
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/beeep/unlike"];
    
    self.like_beeep_completed = compbloc;
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    [postValues addObject:[NSDictionary dictionaryWithObject:userID forKey:@"user"]];
    [postValues addObject:[NSDictionary dictionaryWithObject:beeepID forKey:@"beeep_id"]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerPOSTRequest:URL.absoluteString values:postValues] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:URL.absoluteString parameters:@{@"user":userID,@"beeep_id":beeepID} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self unlike_Beeep_Received:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self unlike_Beeep_Failed:error.localizedDescription];
    }];
    
}


-(void)unlike_Beeep_Received:(id)request{
    
    NSString *responseString = request;
    
    NSDictionary *response = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    @try {
        if ([responseString rangeOfString:@"success"].location != NSNotFound) {
            self.like_beeep_completed(YES,nil);
        }
        else{
            
            [[DTO sharedDTO]addBugLog:@"else" where:@"EventWS/unlike_Beeep_Received" json:responseString];
            
            self.like_beeep_completed(NO,[NSString stringWithFormat:@"unlike_Beeep_Received else: %@",responseString]);
        }
    }
    @catch (NSException *exception) {
        
        [[DTO sharedDTO]addBugLog:@"catch" where:@"EventWS/unlike_Beeep_Received" json:responseString];
        
        self.like_beeep_completed(NO,[NSString stringWithFormat:@"unlike_Beeep_Received catch: %@",responseString]);
    }
    @finally {
        
    }
    
}

-(void)unlike_Beeep_Failed :(id)request{
    
    NSString *responseString = request;
    
    [[DTO sharedDTO]addBugLog:@"unlike_Beeep_Failed" where:@"EventWS/unlike_Beeep_Failed" json:responseString];
    
    self.like_beeep_completed(NO,[NSString stringWithFormat:@"unlike_Beeep_Failed: %@",responseString]);
    
}

#pragma mark - Like Event

-(void)likeEvent:(NSString *)fingerprint WithCompletionBlock:(completed)compbloc{
  
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/event/like"];
    
    self.like_event_completed = compbloc;
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    [postValues addObject:[NSDictionary dictionaryWithObject:[[DTO sharedDTO] urlencode:fingerprint] forKey:@"fingerprint"]];
    
    NSMutableDictionary *postValuesDict = [NSMutableDictionary dictionary];
    
    [postValuesDict setObject:fingerprint forKey:@"fingerprint"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerPOSTRequest:URL.absoluteString values:postValues] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:URL.absoluteString parameters:postValuesDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self like_Event_Received:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self like_Event_Failed:error.localizedDescription];
    }];

}

-(void)like_Event_Received:(id)request{
    
    NSString *responseString = request;
    
    NSDictionary *response = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    @try {
        if ([responseString rangeOfString:@"success"].location != NSNotFound) {
            self.like_event_completed(YES,nil);
        }
        else{
            
            [[DTO sharedDTO]addBugLog:@"else" where:@"EventWS/like_Event_Received" json:responseString];
            
            self.like_event_completed(NO,[NSString stringWithFormat:@"like_Event_Received else: %@",responseString]);
        }
    }
    @catch (NSException *exception) {
        self.like_event_completed(NO,[NSString stringWithFormat:@"like_Event_Received Catch: %@",responseString]);
    }
    @finally {
        
    }
    
}

-(void)like_Event_Failed :(id)request{
    
    NSString *responseString = request;
    
    [[DTO sharedDTO]addBugLog:@"like_Event_Failed" where:@"EventWS/like_Event_Failed" json:responseString];
    
    self.like_event_completed(NO,[NSString stringWithFormat:@"like_Event_Failed: %@",responseString]);
    
}


-(void)unlikeEvent:(NSString *)fingerprint WithCompletionBlock:(completed)compbloc{
    
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/event/unlike"];
    
    self.like_event_completed = compbloc;
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    [postValues addObject:[NSDictionary dictionaryWithObject:[[DTO sharedDTO] urlencode:fingerprint] forKey:@"fingerprint"]];
    

    NSMutableDictionary *postValuesDict = [NSMutableDictionary dictionary];
    
    [postValuesDict setObject:fingerprint forKey:@"fingerprint"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerPOSTRequest:URL.absoluteString values:postValues] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:URL.absoluteString parameters:postValuesDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self unlike_Event_Received:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self unlike_Event_Failed:error.localizedDescription];
    }];
    
}

-(void)unlike_Event_Received:(id)request{
    
    NSString *responseString = request;
    
    NSDictionary *response = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    @try {
        if ([responseString rangeOfString:@"success"].location != NSNotFound) {
            self.like_event_completed(YES,nil);
        }
        else{
            
            [[DTO sharedDTO]addBugLog:@"else" where:@"EventWS/unlike_Event_Received" json:responseString];
            
            self.like_event_completed(NO,[NSString stringWithFormat:@"unlike_Event_Received else: %@",responseString]);
        }
    }
    @catch (NSException *exception) {
        
        [[DTO sharedDTO]addBugLog:@"@catch" where:@"EventWS/unlike_Event_Received" json:responseString];
        
        self.like_event_completed(NO,[NSString stringWithFormat:@"unlike_Event_Received catch: %@",responseString]);
    }
    @finally {
        
    }
    
}

-(void)unlike_Event_Failed :(id)request{
    
    NSString *responseString = request;
    
    [[DTO sharedDTO]addBugLog:@"unlike_Event_Failed" where:@"EventWS/unlike_Event_Failed" json:responseString];
    
    self.like_event_completed(NO,[NSString stringWithFormat:@"unlike_Event_Failed: %@",responseString]);
    
}

#pragma mark - Search

-(void)searchKeyword:(NSString *)keyword WithCompletionBlock:(completed)compbloc{
    
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/search"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/search?"];
    
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"title=%@",[[DTO sharedDTO] urlencode:keyword]]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    self.searchKeyword_completed = compbloc;

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerGETRequest:URL values:array] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:URLwithVars parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self searchKeywordFinished:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self searchKeywordFailed:error.localizedDescription];
    }];

}

-(void)searchKeywordFinished:(id)request{
    
    NSString *responseString = request;
    
    NSArray *keywords = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    if (keywords == 0) {
        [[DTO sharedDTO]addBugLog:@"keywords == 0" where:@"EventWS/searchKeywordFinished" json:responseString];
    }
    
    self.searchKeyword_completed(YES,keywords);
}

-(void)searchKeywordFailed:(id)request{
    
    NSString *responseString = request;
    
    [[DTO sharedDTO]addBugLog:@"searchKeywordFailed" where:@"EventWS/searchKeywordFailed" json:responseString];
    
    self.searchKeyword_completed(NO,[NSString stringWithFormat:@"searchKeywordFailed:%@",responseString]);
}

#pragma mark - Search events

-(void)searchEvent:(NSString *)keyword WithCompletionBlock:(completed)compbloc{
    
    events_Search_keyword = keyword;
    
    search_events_page = 0;
    
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/lookup"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/lookup?"];
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"query=%@",[[DTO sharedDTO] urlencode:keyword]]];
    [array addObject:[NSString stringWithFormat:@"limit=%d",pageLimit]];
    [array addObject:[NSString stringWithFormat:@"order=%@",order]];
    [array addObject:[NSString stringWithFormat:@"page=%d",search_events_page]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    self.searchEvent_completed = compbloc;
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerGETRequest:URL values:array] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:URLwithVars parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self searchEventFinished:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self searchEventFailed:error.localizedDescription];
    }];
    
}

-(void)searchEventFinished:(id)request{
    
    NSString *responseString = request;
    
    NSArray *eventsArray = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    NSMutableArray *events = [NSMutableArray array];
    
    if (eventsArray.count ==0) {
        
        [[DTO sharedDTO]addBugLog:@"eventsArray.count == 0" where:@"EventWS/searchEventFinished" json:responseString];
        
        self.searchEvent_completed(NO,[NSString stringWithFormat:@"Events == 0: %@",responseString]);
        return;
    }
    
    for (NSDictionary *event in eventsArray) {
        Event_Search *e = [Event_Search modelObjectWithDictionary:event];
        
//        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:e];
//        [operationQueue addOperation:invocationOperation];
        
        [events addObject:e];
    }

    
    self.searchEvent_completed(YES,events);
}

-(void)searchEventFailed:(id)request{
    
    NSString *responseString = request;
    
    [[DTO sharedDTO]addBugLog:@"searchEventFailed" where:@"EventWS/searchEventFailed" json:responseString];
    
    self.searchEvent_completed(NO,[NSString stringWithFormat:@"searchEventFailed: %@",responseString]);
}

-(void)nextSearchEventsWithCompletionBlock:(completed)compbloc{
    
    search_events_page ++;
    
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/lookup"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/lookup?"];
    
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
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    self.searchEvent_completed = compbloc;

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerGETRequest:URL values:array] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:URLwithVars parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self searchEventFinished:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self searchEventFailed:error.localizedDescription];
    }];
    
}

#pragma mark - Homefeed

-(void)getAllEventsWithCompletionBlock:(completed)compbloc{
    
    all_events_page = 0;
    requestEmptyResultsCounter = 0;

    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/lookup"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/lookup?"];
    
    
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
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    self.get_All_Events_completed = compbloc;
    
//    [request setResponseEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerGETRequest:URL values:array] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:URLwithVars parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self getAllEventsFinished:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self getAllEventsFailed:error.localizedDescription];
    }];
    
    
}

-(void)getAllEventsFinished:(id)request{
    
    NSString *responseString = request;
    
    NSArray *eventsArray = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    NSMutableArray *events = [NSMutableArray array];
    
    if (eventsArray.count == 0) {
        
        [[DTO sharedDTO]addBugLog:@"eventsArray.count == 0" where:@"EventWS/getAllEventsFinished" json:responseString];
        
        requestEmptyResultsCounter++;
        all_events_page --;
        
        if (requestEmptyResultsCounter == 2) {
            [self nextAllEventsWithCompletionBlock:self.get_All_Events_completed];
        }
        else{
            
            self.get_All_Events_completed(NO,[NSString stringWithFormat:@"getAllEventsFinished But eventsArray == 0: %@",responseString]);
        }
        return;
    }
    
    requestEmptyResultsCounter = 0;
    
    if(all_events_page == 0){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"homefeed-%@",[[BPUser sharedBP].user objectForKey:@"id"]]];
        NSError *error;
        BOOL succeed = [responseString writeToFile:filePath
                                        atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    
    for (NSDictionary *event in eventsArray) {
        Event_Search *e = [Event_Search modelObjectWithDictionary:event];
        
//        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:e];
//        [operationQueue addOperation:invocationOperation];
        
        [events addObject:e];
    }
    
    
    self.get_All_Events_completed(YES,events);
}

-(void)getAllEventsFailed:(id)request{
    
    NSString *responseString = request;
    
    [[DTO sharedDTO]addBugLog:@"getAllEventsFailed" where:@"EventWS/getAllEventsFailed" json:responseString];
    
    self.get_All_Events_completed(NO,[NSString stringWithFormat:@"getAllEventsFailed: %@",responseString]);
}

#pragma mark - Homefeed Next

-(void)nextAllEventsWithCompletionBlock:(completed)compbloc{
    
    all_events_page ++;
    
    NSLog(@"Next Page: %d",all_events_page);
    
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

    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    self.get_All_Events_completed = compbloc;
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerGETRequest:URL values:array] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:URLwithVars parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self getNextAllEventsFinished:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self getNextAllEventsFailed:error.localizedDescription];
    }];
    
}

-(void)getNextAllEventsFinished:(id)request{
    
    NSString *responseString = request;
    
    NSArray *eventsArray = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    NSMutableArray *events = [NSMutableArray array];
    
    if (eventsArray.count ==0) {
        
        [[DTO sharedDTO]addBugLog:@"eventsArray.count ==0" where:@"EventWS/getNextAllEventsFinished" json:responseString];
        
        requestEmptyResultsCounter++;
        all_events_page --;
        
        if (requestEmptyResultsCounter < 2) {
            [self nextAllEventsWithCompletionBlock:self.get_All_Events_completed];
        }
        else{
            self.get_All_Events_completed(NO,[NSString stringWithFormat:@"getAllEventsFinished But eventsArray == 0: %@",responseString]);
        }
        
        return;
    }
    
    if(all_events_page == 0){
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"homefeed-%@",[[BPUser sharedBP].user objectForKey:@"id"]]];
        NSError *error;
        BOOL succeed = [responseString writeToFile:filePath
                                        atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    
    for (NSDictionary *event in eventsArray) {
        Event_Search *e = [Event_Search modelObjectWithDictionary:event];
        
        //        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:e];
        //        [operationQueue addOperation:invocationOperation];
        
        [events addObject:e];
    }
    
    
    self.get_All_Events_completed(YES,events);
}

-(void)getNextAllEventsFailed:(id)request{
    
    NSString *responseString = request;
    
    [[DTO sharedDTO]addBugLog:@"getNextAllEventsFailed" where:@"EventWS/getNextAllEventsFailed" json:responseString];
    
    self.get_All_Events_completed(NO,[NSString stringWithFormat:@"getAllEventsFailed: %@",responseString]);
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
        self.get_All_Local_Events_completed(NO,[NSString stringWithFormat:@""]);
        return;
    }
    
    for (NSDictionary *event in eventsArray) {
        Event_Search *e = [Event_Search modelObjectWithDictionary:event];
        
//        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:e];
//        [operationQueue addOperation:invocationOperation];
        
        [events addObject:e];
    }
    
    
    self.get_All_Local_Events_completed(YES,events);

}

/*
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
 */


-(void)getEvent:(NSString *)fingerprint WithCompletionBlock:(completed)compbloc{
    
    NSString *URL = @"https://api.beeeper.com/1/event/show";
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/event/show?"];
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"fingerprint=%@",[[DTO sharedDTO] urlencode:[[DTO sharedDTO] urlencode:fingerprint]]]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    self.getEvent_completed = compbloc;
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerGETRequest:URL values:array] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:URLwithVars parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self eventReceived:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self eventFailed:error.localizedDescription];
    }];
}

-(void)eventReceived:(id)request{
    
    NSString *responseString = request;
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
            
            [[DTO sharedDTO]addBugLog:@"eventArray.count == 0" where:@"EventWS/eventReceived" json:responseString];
            
            self.getEvent_completed(NO,nil);
        }
    }
    else{
        self.getEvent_completed(NO,nil);
    }
    
    
    
}

-(void)eventFailed:(id)request{
    
    NSString *responseString = request;
    
     [[DTO sharedDTO]addBugLog:@"eventFailed" where:@"EventWS/eventFailed" json:responseString];
    
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
