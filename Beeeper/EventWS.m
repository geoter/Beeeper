//
//  EventWS.m
//  Beeeper
//
//  Created by George on 5/16/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "EventWS.h"

static EventWS *thisWebServices = nil;

@implementation EventWS

-(id)init{
    self = [super init];
    if(self) {
        thisWebServices = self;
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

-(void)postCommentFinished:(ASIHTTPRequest *)request{
     NSString *responseString = [request responseString];
    self.comment_completed(YES,nil);
}

-(void)postCommentFailed:(ASIHTTPRequest *)request{
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
    
    [postValues addObject:[NSDictionary dictionaryWithObject:fingerprint forKey:@"fingerprint"]];
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerPOSTRequest:URL.absoluteString values:postValues]];
    
    [request addPostValue:fingerprint forKey:@"fingerprint"];
    
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
    
    [postValues addObject:[NSDictionary dictionaryWithObject:fingerprint forKey:@"fingerprint"]];
    
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
