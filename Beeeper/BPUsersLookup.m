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
    
    userIDs = [NSArray arrayWithArray:users_ids];
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/user/lookup"];
    
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
    NSString *idsJSONEncoded = [[DTO sharedDTO] urlencode:idsJSON];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerPOSTRequest:requestURL.absoluteString values:[NSMutableArray arrayWithObject:[NSDictionary dictionaryWithObject:idsJSONEncoded forKey:@"users"]]] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:requestURL.absoluteString parameters:@{@"users":idsJSON} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self userLookupFinished:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self userLookupFailed:error.localizedDescription];
    }];

}

-(void)userLookupFinished:(id)request{
    
    @try {
        
        NSString *responseString = request;
        
        NSArray *usersArray = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
        
        if (![usersArray isKindOfClass:[NSArray class]]) {
            [[DTO sharedDTO]addBugLog:@"![usersArray isKindOfClass:[NSArray class]]" where:@"BPUsersLookup/userLookupFinished" json:responseString];
            [self userLookupFailed:request];
            
            return;
        }
        
        NSMutableArray *users = [NSMutableArray array];
        
        for (NSString *u in usersArray) {
            @try {
                NSArray *userArray = [u objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
                NSDictionary *user = [userArray firstObject];
                NSMutableDictionary *userMutable = [ NSMutableDictionary dictionaryWithDictionary:user];
                [users addObject:userMutable];
            }
            @catch (NSException *exception) {
                continue;
            }
            @finally {
                
            }
            
        }
        
        self.completed(YES,users);
    }
    @catch (NSException *exception) {
        self.completed(NO,@"");
    }
    @finally {
        
    }
    
}

-(void)userLookupFailed:(id)request{
   
    NSString *responseString = request;
    
    // [[DTO sharedDTO]addBugLog:@"userLookupFailed" where:@"BPUsersLookup/userLookupFailed" json:responseString];
    
    self.completed(NO,[NSString stringWithFormat:@"userLookupFailed: %@",responseString]);
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
    
    //NSString *extension = [[imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
    
    NSString *imageName = [NSString stringWithFormat:@"%@",[imagePath MD5]];
    
    NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
        UIImage * result;
        NSData * localData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[DTO sharedDTO]fixLink:imagePath]]];
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
