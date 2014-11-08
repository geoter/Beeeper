//
//  BPSuggestions.m
//  Beeeper
//
//  Created by George on 6/17/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "BPSuggestions.h"
#import "Event_Show_Object.h"

static BPSuggestions *thisWebServices = nil;

@interface BPSuggestions ()
{
    int page;
    
    NSOperationQueue *operationQueue;
    int requestFailedCounter;
    int requestEmptyResultsCounter;
}
@end


@implementation BPSuggestions
@synthesize pageLimit,loadNextPage;

-(id)init{
    self = [super init];
    if(self) {
        thisWebServices = self;
        page = 0;
        pageLimit = 10;
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 3;
        requestFailedCounter = 0;
        requestEmptyResultsCounter = 0;
        loadNextPage = YES;
    }
    return(self);
}

+ (BPSuggestions *)sharedBP{
    
    if (thisWebServices != nil) {
        return thisWebServices;
    }
    else{
        return [[BPSuggestions alloc]init];
    }
    
    return nil;
}

-(void)getLocalSuggestions:(completed)compbloc{
    
    self.localCompleted = compbloc;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"suggestions-%@",[[BPUser sharedBP].user objectForKey:@"id"]]];
    NSString *json =  [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    [self parseLocalResponseString:json WithCompletionBlock:compbloc];
}

-(void)nextSuggestionsResetWithCompletionBlock:(completed)compbloc{
    
    page--;
    
    [self nextSuggestionsWithCompletionBlock:compbloc];
    
}

-(void)nextSuggestionsWithCompletionBlock:(completed)compbloc{
    
    page++;
    
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/user/suggestions"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/user/suggestions?"];
    
    
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
    
    self.completed = compbloc;
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:20.0];
    
    [request setDelegate:self];
    
    //[[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(suggestionsFinished:)];
    
    [request setDidFailSelector:@selector(suggestionsFailed:)];
    
    [request startAsynchronous];
    
}

#pragma mark - Badge

-(void)clearSuggestionsBadgeWithCompletionBlock:(completed)compbloc{
  
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/user/clearsugbadge"];
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSURL *requestURL = [NSURL URLWithString:URL];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerGETRequest:URL values:array]];
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    self.suggestBadgeCompleted = compbloc;
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:20.0];
    
    [request setDelegate:self];
    
    //[[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(suggestionsBadgeClearFinished:)];
    
    [request setDidFailSelector:@selector(suggestionsBadgeClearFailed:)];
    
    [request startAsynchronous];
}

-(void)suggestionsBadgeClearFinished:(ASIHTTPRequest *)request{
    
    @try {
        NSString *responseString = [request responseString];
        NSDictionary *badgeDict = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
        
        if ([badgeDict objectForKey:@"badge_num"]) {
            self.suggestBadgeCompleted(YES,[badgeDict objectForKey:@"badge_num"]);
        }
    }
    @catch (NSException *exception) {
        self.suggestBadgeCompleted(NO,nil);
    }
    @finally {
        
    }
    
}

-(void)suggestionsBadgeClearFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    self.suggestBadgeCompleted(NO,nil);
}

-(void)getSuggestionsBadgeWithCompletionBlock:(completed)compbloc{
   
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/user/getsugbadge"];
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSURL *requestURL = [NSURL URLWithString:URL];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerGETRequest:URL values:array]];
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    self.suggestBadgeCompleted = compbloc;
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:20.0];
    
    [request setDelegate:self];
    
    //[[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(suggestionsBadgeFinished:)];
    
    [request setDidFailSelector:@selector(suggestionsBadgeFailed:)];
    
    [request startAsynchronous];
    
}

-(void)suggestionsBadgeFinished:(ASIHTTPRequest *)request{
    
    @try {
        NSString *responseString = [request responseString];
        NSDictionary *badgeDict = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
        
        if ([badgeDict objectForKey:@"badge_num"]) {
            self.suggestBadgeCompleted(YES,[badgeDict objectForKey:@"badge_num"]);
        }
    }
    @catch (NSException *exception) {
        self.suggestBadgeCompleted(NO,nil);
    }
    @finally {
        
    }

}

-(void)suggestionsBadgeFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    self.suggestBadgeCompleted(NO,nil);
}

#pragma mark - Suggestions

-(void)getSuggestionsWithCompletionBlock:(completed)compbloc{
  
    loadNextPage = YES;
    requestEmptyResultsCounter = 0;
    page = 0;
    
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/user/suggestions"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/user/suggestions?"];
    
    
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
    
    self.completed = compbloc;
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:20.0];
    
    [request setDelegate:self];
    
    //[[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(suggestionsFinished:)];
    
    [request setDidFailSelector:@selector(suggestionsFailed:)];
    
    [request startAsynchronous];
    
}

-(void)suggestionsFinished:(ASIHTTPRequest *)request{
    
    requestFailedCounter = 0;
    
    NSString *responseString = [request responseString];
    
    NSArray *beeeps = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];

    if ([beeeps isKindOfClass:[NSArray class]]) {
        
        loadNextPage = YES;
        
        [self parseResponseString:responseString WithCompletionBlock:self.completed];
    }
    else{
        requestEmptyResultsCounter++;
        page --;
        
        [[DTO sharedDTO]addBugLog:@"![beeeps isKindOfClass:[NSArray class]]" where:@"suggestionsFinished" json:responseString];
        
        if (requestEmptyResultsCounter <= 10) {
            loadNextPage = YES;
            [self nextSuggestionsWithCompletionBlock:self.completed];
        }
        else{
            loadNextPage = NO;
            self.completed(NO,nil);
        }
    }
    
    

    
}


-(void)suggestionsFailed:(ASIHTTPRequest *)request{
    
    NSLog(@"FAILES REQUEST->SUGGESTIONS");
    
    requestFailedCounter++;
    
    @try {
        NSString *responseString = [request responseString];
        
        [[DTO sharedDTO]addBugLog:@"suggestionsFailed" where:@"suggestionsFailed" json:responseString];
        
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:NULL];

    }
    @catch (NSException *exception) {
        [[DTO sharedDTO]addBugLog:@"suggestionsFailed" where:@"suggestionsFailed" json:@""];
    }
    @finally {
        
        if (requestFailedCounter < 10) {
            [self getSuggestionsWithCompletionBlock:self.completed];
        }
        else{
            self.completed(NO,@"suggestionsFailed");
        }
   
    }
}

-(void)parseResponseString:(NSString *)responseString WithCompletionBlock:(completed)compbloc{
    
    if (responseString == nil) {
        [[DTO sharedDTO]addBugLog:@"responseString == nil" where:@"suggestions/parseResponseString" json:@""];
        compbloc(NO,@"Response is nil");
    }
    
    NSArray *beeeps = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    if (responseString.length == 0 || beeeps == nil) { //something went wrong
       
        NSLog(@"Empty");
        [[DTO sharedDTO]addBugLog:@"responseString.length == 0 || beeeps == nil" where:@"suggestions/parseResponseString" json:responseString];
         page--;
        
        [self nextSuggestionsWithCompletionBlock:self.completed];
        return;
    }
    else if (beeeps.count == 0){
        
        if (requestEmptyResultsCounter < 3) {
            
            requestEmptyResultsCounter ++;
            
            [self nextSuggestionsWithCompletionBlock:self.completed];
        }
        else{
            loadNextPage = NO;
            self.completed(YES,nil);
        }

        return;
    }
    
    //    responseString = [responseString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    //    responseString = [responseString stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
    //    responseString = [responseString stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
    
    NSMutableArray *bs = [NSMutableArray array];
    
    for (NSDictionary *b in beeeps) {
        
        Suggestion_Object *activity = [Suggestion_Object modelObjectWithDictionary:b];
        
//        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:activity];
//        [operationQueue addOperation:invocationOperation];
        if (activity.what.title != nil) {
           [bs addObject:activity];
        }
        else{
          [[DTO sharedDTO]addBugLog:@"activity.what.title == nil" where:@"suggestions/parseResponseString" json:[b description]];
        }
        
    }
    
    requestEmptyResultsCounter = 0;
    
    if (page == 0) {
       
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"suggestions-%@",[[BPUser sharedBP].user objectForKey:@"id"]]];
        NSError *error;
        
        BOOL succeed = [responseString writeToFile:filePath
                                        atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    
    self.completed(YES,bs);

}

-(void)parseLocalResponseString:(NSString *)responseString WithCompletionBlock:(completed)compbloc{
    
    NSArray *beeeps = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    if (responseString.length == 0 || beeeps == nil) { //something went wrong
        self.localCompleted(NO,nil);
        return;
    }
    
    //    responseString = [responseString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    //    responseString = [responseString stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
    //    responseString = [responseString stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
    
    NSMutableArray *bs = [NSMutableArray array];
    
    for (NSDictionary *b in beeeps) {
        
        Suggestion_Object *activity = [Suggestion_Object modelObjectWithDictionary:b];
        
        if (activity.what.title != nil) {
            [bs addObject:activity];
        }
    }
    
    self.localCompleted(YES,bs);
    
}


-(void)downloadImage:(Suggestion_Object *)object{
    
    @try {
            Who *w = object.who;
        
       //     NSString *extension = [[w.imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
            
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
    @catch (NSException *exception) {
        NSLog(@"Who download image CRASHED");
    }
    @finally {
        
    }
    
    
    @try {
            What_Suggest *what = object.what;
            //NSString *extension = [[what.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
            
            NSString *imageName = [NSString stringWithFormat:@"%@",[what.imageUrl MD5]];
            
            NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
            
            if (![[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
                UIImage * result;
                NSData * localData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[DTO sharedDTO]fixLink:what.imageUrl]]];
                result = [UIImage imageWithData:localData];
                [self saveImage:result withFileName:imageName inDirectory:localPath];
            }
        
        
    }
    @catch (NSException *exception) {
        NSLog(@"WhoM download image CRASHED");
    }
    @finally {
        
    }
    
}

-(void)suggestEvent:(NSString *)fingerprint toUsers:(NSArray *)user_ids withCompletionBlock:(completed)compbloc{
    self.suggestEventCompleted = compbloc;
    
    @try {
        
        NSMutableString *users_JSON_array = [[NSMutableString alloc]initWithString:@"["];
        
        for (NSString *user_id in user_ids) {
            int i = [user_ids indexOfObject:user_id];
            if (i == user_ids.count - 1) {
                [users_JSON_array appendFormat:@"\"%@\"",user_id];
            }
            else{
                [users_JSON_array appendFormat:@"\"%@\",",user_id];
            }
        }
        
        [users_JSON_array appendString:@"]"];
        
        NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/event/suggest"];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
        
        NSMutableArray *postValues = [NSMutableArray array];
        
        [postValues addObject:[NSDictionary dictionaryWithObject:[[DTO sharedDTO] urlencode:users_JSON_array] forKey:@"who"]];
        [postValues addObject:[NSDictionary dictionaryWithObject:[[DTO sharedDTO] urlencode:fingerprint] forKey:@"what"]];
        
        [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerPOSTRequest:requestURL.absoluteString values:postValues]];
        
        [request addPostValue:users_JSON_array forKey:@"who"];
        [request addPostValue:fingerprint forKey:@"what"];
        
        [request setRequestMethod:@"POST"];
        
        [request setTimeOutSeconds:20.0];
        
        [request setDelegate:self];
        
        [request setDidFinishSelector:@selector(suggestEventFinished:)];
        
        [request setDidFailSelector:@selector(suggestEventFailed:)];
        
        [request startAsynchronous];
        
    }
    @catch (NSException *exception) {
        
        [[DTO sharedDTO]addBugLog:@"suggestEvent CATCH" where:@"suggestions/suggestEvent" json:[user_ids description]];
        
        self.suggestEventCompleted(NO,@"suggestEvent CATCH");
    }
    @finally {
        
    }
    
}

-(void)suggestEventFinished:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    @try {
        
        if ([responseString rangeOfString:@"success"].location != NSNotFound) {
            self.suggestEventCompleted(YES,nil);
        }
        else{
            
            [[DTO sharedDTO]addBugLog:@"suggestEventFinished but failed" where:@"suggestions/suggestEventFinished" json:responseString];
            
            self.suggestEventCompleted(NO,[NSString stringWithFormat:@"suggestEventFinished but failed: %@",responseString]);
        }

    }
    @catch (NSException *exception) {
        
        [[DTO sharedDTO]addBugLog:@"suggestEventFinished" where:@"suggestions/suggestEventFinished" json:responseString];
        
           self.suggestEventCompleted(NO,@"suggestEventFinished CATCH");
    }
    @finally {
        
    }
  }

-(void)suggestEventFailed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    [[DTO sharedDTO]addBugLog:@"suggestEventFailed" where:@"suggestions/suggestEventFailed" json:responseString];
    
    self.suggestEventCompleted(NO,@"suggestEventFailed");
    
}



-(void)saveImage:(UIImage *)image withFileName:(NSString *)imageName inDirectory:(NSString *)directoryPath {
    
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
