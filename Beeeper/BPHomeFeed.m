//
//  BPHomeFeed.m
//  Beeeper
//
//  Created by George on 5/15/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "BPHomeFeed.h"
#import "Friendsfeed_Object.h"

static BPHomeFeed *thisWebServices = nil;

@interface BPHomeFeed ()
{
    int page;
    int pageLimit;
    int feedLength;
    NSString *order;
    int length;
    NSOperationQueue *operationQueue;
    
}
@end

@implementation BPHomeFeed

-(id)init{
    self = [super init];
    if(self) {
        thisWebServices = self;
        page = 0;
        pageLimit = 10;
        order = @"DATE";
        length = 0;
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 3;
    }
    return(self);
}

+ (BPHomeFeed *)sharedBP{
    
    if (thisWebServices != nil) {
        return thisWebServices;
    }
    else{
        return [[BPHomeFeed alloc]init];
    }
    
    return nil;
}

#pragma mark - Friends Feed

-(void)getLocalFriendsFeed:(completed)compbloc{
    
    self.localCompleted = compbloc;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"FriendsFeed-%@",[[BPUser sharedBP].user objectForKey:@"id"]]];
    NSString *json =  [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    [self parseResponseString:json WithCompletionBlock:compbloc];
}

-(void)getFriendsFeedWithCompletionBlock:(completed)compbloc{
    
    NSTimeInterval timeStamp = [[NSDate date]timeIntervalSince1970]/1000;
    
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/newsfeed/show"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/newsfeed/show?"];
    
    NSDictionary *dict = [BPUser sharedBP].user;
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"limit=%d",pageLimit]];
 //   [array addObject:[NSString stringWithFormat:@"length=%@",order]];
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
    
    //    [[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(friendsFeedFinished:)];
    
    [request setDidFailSelector:@selector(friendsFeedFailed:)];
    
    [request startAsynchronous];
    

}

-(void)friendsFeedFinished:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"FriendsFeed-%@",[[BPUser sharedBP].user objectForKey:@"id"]]];
    NSError *error;
    
    BOOL succeed = [responseString writeToFile:filePath
                              atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    [self parseResponseString:responseString WithCompletionBlock:self.completed];
}

-(void)parseResponseString:(NSString *)responseString WithCompletionBlock:(completed)compbloc{
    
    if (responseString == nil) {
        compbloc(NO,nil);
    }
    
    NSArray *beeeps = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    NSMutableArray *bs = [NSMutableArray array];
    
    for (NSDictionary *b in beeeps) {
        Friendsfeed_Object *ffo = [Friendsfeed_Object modelObjectWithDictionary:b];
        
        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:ffo];
        [operationQueue addOperation:invocationOperation];
        
        if ([beeeps indexOfObject:b] == beeeps.count-1) { //FEED LENGTH
            feedLength = [[NSString stringWithFormat:@"%@",[b objectForKey:@"feed_length"]] intValue];
        }
        else{
            [bs addObject:ffo];
        }
        
    }
    
    compbloc(YES,bs);
}


-(void)friendsFeedFailed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    NSArray *beeeps = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
}



-(void)downloadImage:(Friendsfeed_Object *)ffo{
    
    NSString *extension = [[ffo.eventFfo.eventDetailsFfo.imageUrl.lastPathComponent componentsSeparatedByString:@"."] lastObject];
    
    NSString *imageName = [NSString stringWithFormat:@"%@.%@",[ffo.eventFfo.eventDetailsFfo.imageUrl MD5],extension];
    
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
        UIImage * result;
        NSData * localData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ffo.eventFfo.eventDetailsFfo.imageUrl]];
        result = [UIImage imageWithData:localData];
        [self saveImage:result withFileName:imageName inDirectory:localPath];
    }

    //for Beeeped By user
    
    NSString *beeepedBy_imageName = [NSString stringWithFormat:@"%@.%@",[ffo.whoFfo.imagePath MD5],extension];
    
    NSString *beeepedBy_localPath = [documentsDirectoryPath stringByAppendingPathComponent:beeepedBy_imageName];
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:beeepedBy_localPath]) {
        UIImage * result;
        NSData * localData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ffo.whoFfo.imagePath]];
        result = [UIImage imageWithData:localData];
        [self saveImage:result withFileName:beeepedBy_imageName inDirectory:beeepedBy_localPath];
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
