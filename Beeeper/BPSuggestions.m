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
    int pageLimit;
    
    NSOperationQueue *operationQueue;
    int requestFailedCounter;
}
@end


@implementation BPSuggestions

-(id)init{
    self = [super init];
    if(self) {
        thisWebServices = self;
        page = 0;
        pageLimit = 40;
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 3;
        requestFailedCounter = 0;
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
    
    [self parseResponseString:json WithCompletionBlock:compbloc];
}

-(void)getSuggestionsWithCompletionBlock:(completed)compbloc{
  
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
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    //[[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(suggestionsFinished:)];
    
    [request setDidFailSelector:@selector(suggestionsFailed:)];
    
    [request startAsynchronous];
    
}

-(void)suggestionsFinished:(ASIHTTPRequest *)request{
    
    requestFailedCounter = 0;
    
    NSString *responseString = [request responseString];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"suggestions-%@",[[BPUser sharedBP].user objectForKey:@"id"]]];
    NSError *error;
    
    BOOL succeed = [responseString writeToFile:filePath
                                    atomically:YES encoding:NSUTF8StringEncoding error:&error];

    
    [self parseResponseString:responseString WithCompletionBlock:self.completed];
    
}

-(void)suggestionsFailed:(ASIHTTPRequest *)request{
    
    NSLog(@"FAILES REQUEST->SUGGESTIONS");
    
    requestFailedCounter++;
    
    NSString *responseString = [request responseString];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:NULL];
    
    if (requestFailedCounter < 5) {
        [self getSuggestionsWithCompletionBlock:self.completed];
    }
    else{
        self.completed(NO,nil);
    }
    
}

-(void)parseResponseString:(NSString *)responseString WithCompletionBlock:(completed)compbloc{
    
    if (responseString == nil) {
        compbloc(NO,nil);
    }
    
    NSArray *beeeps = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    if (responseString.length == 0 || beeeps == nil) { //something went wrong
        NSLog(@"Empty");
        [self getSuggestionsWithCompletionBlock:self.completed];
        return;
    }
    
    //    responseString = [responseString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    //    responseString = [responseString stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
    //    responseString = [responseString stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
    
    NSMutableArray *bs = [NSMutableArray array];
    
    for (NSDictionary *b in beeeps) {
        
        Suggestion_Object *activity = [Suggestion_Object modelObjectWithDictionary:b];
        
        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:activity];
        [operationQueue addOperation:invocationOperation];
        
        [bs addObject:activity];
    }
    
    self.completed(YES,bs);

}

-(void)downloadImage:(Suggestion_Object *)object{
    
    @try {
            Who *w = object.who;
        
            NSString *extension = [[w.imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
            
            NSString *imageName = [NSString stringWithFormat:@"%@.%@",[w.imagePath MD5],extension];
            
            NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
            
            if (![[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
                UIImage * result;
                NSData * localData = [NSData dataWithContentsOfURL:[NSURL URLWithString:w.imagePath]];
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
            NSString *extension = [[what.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
            
            NSString *imageName = [NSString stringWithFormat:@"%@.%@",[what.imageUrl MD5],extension];
            
            NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
            
            if (![[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
                UIImage * result;
                NSData * localData = [NSData dataWithContentsOfURL:[NSURL URLWithString:what.imageUrl]];
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


@end
