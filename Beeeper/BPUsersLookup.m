//
//  BPUsersLookup.m
//  Beeeper
//
//  Created by George on 5/14/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "BPUsersLookup.h"

@implementation BPUsersLookup
static BPUsersLookup *thisWebServices = nil;

-(id)init{
    self = [super init];
    if(self) {
        thisWebServices = self;
        operationQueue = [[NSOperationQueue alloc] init];
    }
    return(self);
}

+ (BPUsersLookup *)sharedBP{
    
    if (thisWebServices != nil) {
        return thisWebServices;
    }
    else{
        return [[BPUsersLookup alloc]init];
    }
    
    return nil;
}



-(void)usersLookup:(NSArray *)users_ids completionBlock:(completed)compbloc{
  
    self.completed = compbloc;
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/user/lookup"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    NSMutableString *idsJSON = [[NSMutableString alloc]initWithString:@"["];
    
    if (users_ids.count >0 && [[users_ids firstObject] isKindOfClass:[NSString class]]) {
        for (NSString *user_id in users_ids) {
            [idsJSON appendFormat:@"\"%@\",",user_id];
        }
    }
    else{
        for (NSDictionary *user in users_ids) {
            [idsJSON appendFormat:@"\"%@\",",[user objectForKey:@"id"]];
        }
    }
    
    [idsJSON deleteCharactersInRange:NSMakeRange([idsJSON length]-1, 1)];
    [idsJSON appendString:@"]"];
    NSString *idsJSONEncoded = [self urlencode:idsJSON];
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerPOSTRequest:requestURL.absoluteString values:[NSMutableArray arrayWithObject:[NSDictionary dictionaryWithObject:idsJSONEncoded forKey:@"users"]]]];
    
    [request addPostValue:idsJSON forKey:@"users"];
    
    [request setRequestMethod:@"POST"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(userLookupFinished:)];
    
    [request setDidFailSelector:@selector(userLookupFailed:)];
    
    [request startAsynchronous];

}

-(void)userLookupFinished:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];

    NSArray *usersArray = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    NSMutableArray *users = [NSMutableArray array];

    for (NSString *u in usersArray) {
        NSArray *userArray = [u objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
        NSDictionary *user = [userArray firstObject];
        [users addObject:user];
        
        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:user];
        [operationQueue addOperation:invocationOperation];

    }
    
    self.completed(YES,users);
}

-(void)userLookupFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    self.completed(NO,nil);
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

-(void)downloadImage:(NSDictionary *)user{
    
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *imagePath = [user objectForKey:@"image_path"];
    
    NSString *extension = [[imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
    
    NSString *imageName = [NSString stringWithFormat:@"%@.%@",[imagePath MD5],extension];
    
    NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
        UIImage * result;
        NSData * localData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]];
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
