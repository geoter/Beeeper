//
//  BPUser.m
//  Beeeper
//
//  Created by George Termentzoglou on 3/15/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "BPUser.h"

#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>
#import "Base64Transcoder.h"
#import "Activity_Object.h"

@interface BPUser ()
{
    NSString *_username;
    NSString *_password;
    NSString *_fbid;
    NSString *_twitterid;
    NSString *imageToUpdate;
    
    //Request Token
    NSString *oauth_callback;
    NSString *oauth_nonce;
    NSString *oauth_signature_method;
    NSString *scope;
    NSString *xoauth_displayname;
    NSString *oauth_timestamp;
    NSString *signature;
    
    //Authorize
    NSString *oauth_token;
    NSString *oauth_token_secret;
    NSString *verifier;
    NSString *signature_accessToken;
    NSString *oauth_nonce_accessToken;
    NSString *oauth_timestamp_accessToken;
    
    NSString *accessToken;
    NSString *accessTokenSecret;
    
    NSOperationQueue *operationQueue;

//    int page_new;
//    int page_old;
    
    NSString *_userID;
    NSString *deviceToken;
    
    int serverTime;
    int oldestTimestamp;
}

@end

@implementation BPUser
@synthesize notifsPageLimit,badgeNumber=_badgeNumber;

static NSString *consumerKey = @"14ed757eefb1a284ba6f3e7e9989ec87052429ce1";
static NSString *consumerSecret = @"e92496b00f2abc454891c8d3c54017b8";

static BPUser *thisWebServices = nil;

-(id)init{
    self = [super init];
    if(self) {
        thisWebServices = self;
        oauth_callback = [[DTO sharedDTO] urlencode:@"beeeper://"];
        oauth_nonce = [self random32CharacterString];
        oauth_nonce_accessToken = [self random32CharacterString];
        oauth_signature_method = @"HMAC_SHA1";
        scope = @"randomScope";
        xoauth_displayname = @"RandomName";
        oauth_timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 3;
        notifsPageLimit = 10;
        serverTime = 0;
        oldestTimestamp = 0;
    }
    return(self);
    
    
}

+ (BPUser *)sharedBP{
    
    if (thisWebServices != nil) {
        return thisWebServices;
    }
    else{
        return [[BPUser alloc]init];
    }
    
    return nil;
}


#pragma mark - Signup

-(void)signUpUser:(NSDictionary *)info completionBlock:(completed)compbloc{
    
    NSURL *requestURL = [NSURL URLWithString:@"https://resources.beeeper.com/signup/"];
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username

    self.completed = compbloc;
    
    NSMutableDictionary *postValuesDict = [NSMutableDictionary dictionary];
    
    [postValuesDict setObject:[info objectForKey:@"email"] forKey:@"email"];
    
    [postValuesDict setObject:[info objectForKey:@"name"] forKey:@"name"];
    
    [postValuesDict setObject:[info objectForKey:@"timezone"] forKey:@"timezone"];
    
    [postValuesDict setObject:[info objectForKey:@"password"] forKey:@"password"];
    
    [postValuesDict setObject:[info objectForKey:@"city"] forKey:@"city"];
    
    [postValuesDict setObject:[info objectForKey:@"state"] forKey:@"state"];
    
    [postValuesDict setObject:[info objectForKey:@"country"] forKey:@"country"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:@"t6FDJXLQnVKLYgZjaqhuiDIO7CxeK+bF+FGJorEBRB55k89C+qAxIyUKYrnTlLLJeEkHYwakO/ZYWVi8m370wQ==" forHTTPHeaderField:@"Referer"];
    
    [manager POST:requestURL.absoluteString parameters:postValuesDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self signupFinished:[operation responseString] info:info];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self signupFailed:error.localizedDescription];
    }];

}

-(void)signupFinished:(id)request info:(NSDictionary *)info{
    
    NSString *responseString = request;
   
    @try {
        NSDictionary *info = info;
        
        [self loginUser:[info objectForKey:@"email"] password:[info objectForKey:@"password"] completionBlock:^(BOOL completed,NSString *user){
            if (completed) {
                self.completed(completed,user);
            }
        }];
    }
    @catch (NSException *exception) {
        self.completed(NO,[NSString stringWithFormat:@"signupFinished CATCH %@",responseString]);
    }
    @finally {
        
    }
    
}

-(void)signupFailed:(id)request{
    
    NSString *responseString = request;
    
    [[DTO sharedDTO]addBugLog:@"signupFailed" where:@"BPUser/signupFailed" json:responseString];
    
    self.completed(NO,@"signupFailed");
}

#pragma mark - User settings

-(void)setUserSettings:(NSDictionary *)settings WithCompletionBlock:(completed)compbloc{
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/user/update_profile"];
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    self.setUserSettingsCompleted = compbloc;
    
    NSMutableArray *postValues = [NSMutableArray array];
    NSMutableDictionary *postValuesDict = [NSMutableDictionary dictionary];

    for (NSString *key in settings.allKeys) {
       @try {
           id object = [settings objectForKey:key];
           
           if ([key isEqualToString:@"longitude"] || [key isEqualToString:@"latitude"]) {
               [postValuesDict setObject:[[DTO sharedDTO] urlencode:object] forKey:key];
               [postValues addObject:[NSDictionary dictionaryWithObject:[[DTO sharedDTO] urlencode:[[DTO sharedDTO] urlencode:object]] forKey:key]];
               continue;
           }
           
           [postValuesDict setObject:object forKey:key];
           [postValues addObject:[NSDictionary dictionaryWithObject:[[DTO sharedDTO] urlencode:object] forKey:key]];
  
        }
        @catch (NSException *exception) {
            [postValuesDict setObject:@"0" forKey:key];
            [postValues addObject:[NSDictionary dictionaryWithObject:@"0" forKey:key]];
        }
        @finally {
            
        }
    }
   
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[self headerPOSTRequest:requestURL.absoluteString values:postValues] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:requestURL.absoluteString parameters:postValuesDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self setUserSettingsFinished:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *response = operation.responseString;
        [self setUserSettingsFailed:operation.responseString];
    }];

}

-(void)setUserSettingsFinished:(id)request{
    
    NSString *responseString = request;
    
    if ([responseString rangeOfString:@"success"].location != NSNotFound) {
        self.setUserSettingsCompleted(YES,nil);
        [self updateUser];
    }
    else{
       
        [[DTO sharedDTO]addBugLog:@"else" where:@"BPUser/setUserSettingsFinished" json:responseString];
        
        NSDictionary * response = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
        
        NSArray *errors = [response objectForKey:@"errors"];

        NSDictionary *error = [errors firstObject];

        if (error != nil) {
                self.setUserSettingsCompleted(NO,[error objectForKey:@"message"]);
        }
    }

}

-(void)setUserSettingsFailed:(id)request{
    
    NSString *responseString = request;
    
    [[DTO sharedDTO]addBugLog:@"setUserSettingsFailed" where:@"BPUser/setUserSettingsFailed" json:responseString];
    
    self.setUserSettingsCompleted(NO,[NSString stringWithFormat:@"setUserSettingsFailed: %@",responseString]);
}

#pragma mark - FB Signup

-(void)signUpSocialUser:(NSDictionary *)info completionBlock:(completed)compbloc{
    
    NSURL *requestURL = [NSURL URLWithString:@"https://resources.beeeper.com/signup/"];
    
    NSMutableDictionary *postValuesDict = [NSMutableDictionary dictionary];
    
    for (NSString *key in info.allKeys) {
        
        NSString *value = [info objectForKey:key];
        [postValuesDict setObject:value forKey:key];
    }
    
    self.fbSignUpCompleted = compbloc;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:@"t6FDJXLQnVKLYgZjaqhuiDIO7CxeK+bF+FGJorEBRB55k89C+qAxIyUKYrnTlLLJeEkHYwakO/ZYWVi8m370wQ==" forHTTPHeaderField:@"Referer"];
    
    [manager POST:requestURL.absoluteString parameters:postValuesDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self fbSignupReceived:[operation responseString] info:info];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self fbSignupFailed:error.localizedDescription];
    }];
    
}

-(void)fbSignupReceived:(id)request info:(NSDictionary *)info{
 
    NSString *responseString = request;

    //NSString *responseString = @"{\"id\":\"1404730445.521045345363001\",\"username\":\"maromm\",\"email\":\"maria.maraki.mario.maro@hotmail.com\",\"name\":\"maria\",\"lastname\":\"\",\"timezone\":\"180\",\"password\":\"8cb2237d0679ca88db6464eac60da96345513964\",\"locked\":\"0\",\"city\":\"cholargos\",\"state\":\"athens\",\"country\":\"greece\",\"long\":\"37.9978\",\"lat\":\"23.7926\",\"last_login\":\"\",\"sex\":\"\",\"fbid\":\"\",\"twid\":\"\",\"fbtoken\":"",\"twtoken\":"",\"active\":\"0\",\"image_path\":\"\",\"about\":\"\",\"website\":\"\",\"se_on\":\"1\"}";
    
    NSDictionary * response = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
   
    @try {
       NSArray *errors = [response objectForKey:@"errors"];
        
      NSDictionary *error = [errors firstObject];
        
        if (error != nil) {
           
            [[DTO sharedDTO]addBugLog:@"error != nil" where:@"BPUser/fbSignupReceived" json:responseString];
            
            self.fbSignUpCompleted(NO,[error objectForKey:@"message"]);
        }
        else if (([response isKindOfClass:[NSString class]] || response == nil)){
            //error message
            self.fbSignUpCompleted(NO,[responseString stringByReplacingOccurrencesOfString:@"\"" withString:@""]);
        }
        else{
            NSDictionary *info = [[request UserInfo]objectForKey:@"info"];
            [self loginUser:[info objectForKey:@"email"] password:[info objectForKey:@"password"] completionBlock:^(BOOL completed,NSString *user){
                if (completed) {
                    self.fbSignUpCompleted(completed,user);
                }
                else{
                    @try {
                        
                        NSDictionary *errorDict = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
                        
                        NSArray *errors = [errorDict objectForKey:@"errors"];
                        
                        NSDictionary *error = [errors firstObject];
                        
                        self.fbSignUpCompleted(NO,[error objectForKey:@"message"]);
                    }
                    @catch (NSException *exception) {
                        self.fbSignUpCompleted(NO,@"fbSignupReceived Completed == NO");
                    }
                }
            }];
        }
        
    }
    @catch (NSException *exception) {
        
        [[DTO sharedDTO]addBugLog:@"@catch" where:@"BPUser/fbSignupReceived" json:responseString];
        
        self.fbSignUpCompleted(NO,@"fbSignupReceived catch");

    }
    @finally {

    }
    
}

-(void)fbSignupFailed:(id)request{
    
    NSString *responseString = request;
    
    [[DTO sharedDTO]addBugLog:@"fbSignupFailed" where:@"BPUser/fbSignupFailed" json:responseString];
    
    self.fbSignUpCompleted(NO,[NSString stringWithFormat:@"Facebook Signup Failed: \n%@",responseString]);
    
}

#pragma mark - Login

-(void)loginTwitterUser:(NSDictionary *)values completionBlock:(completed)compbloc{
    
    _fbid = nil; //just in case
    _twitterid = [values objectForKey:@"id"];
    imageToUpdate = [values objectForKey:@"image"];
    
    self.completed = compbloc;
    [self getRequestToken];
}

-(void)loginFacebookUser:(NSMutableDictionary *)values completionBlock:(completed)compbloc{
    
    _twitterid = nil; //just in case
    _fbid = [values objectForKey:@"id"];
    imageToUpdate = [values objectForKey:@"image"];
    self.completed = compbloc;
    [self getRequestToken];
}

-(void)loginUser:(NSString *)username password:(NSString *)password completionBlock:(completed)compbloc{

    _fbid = nil; //just in case
    _twitterid = nil; //just in case
    
    _username = username;
    _password = password;
    
    self.completed = compbloc;
    [self getRequestToken];
}

#pragma mark - USER

-(void)sendDemoPush:(int)seconts{

    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/send/push"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSString stringWithFormat:@"%d",seconts] forKey:@"seconds"];
    [dict setObject:[NSString stringWithFormat:@"1412187300.867656"] forKey:@"weight"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[self headerPOSTRequest:requestURL.absoluteString values:[NSMutableArray arrayWithObject:dict]] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:requestURL.absoluteString parameters:dict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self demoPushReceived:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self demoPushFailed:error.localizedDescription];
    }];

}

-(void)demoPushReceived:(id)request{
    
    NSString *responseString = request;
    NSLog(@"Demo Push:%@",responseString);
}

-(void)demoPushFailed:(id)request{
    
    NSString *responseString = request;
        NSLog(@"Demo Push Error:%@",responseString);
}


-(void)setDeviceToken:(NSData *)token{
    
    NSString *str = [NSString stringWithFormat:@"Device Token=%@",token];
    
    //remove spaces from token
    str = [str stringByReplacingOccurrencesOfString:@" "
                                         withString:@""];
    
    //remove "DeviceToken=<"
    str = [str stringByReplacingOccurrencesOfString:@"DeviceToken=<"
                                         withString:@""];
    
    //remove ">"
    str = [str stringByReplacingOccurrencesOfString:@">"
                                         withString:@""];
    
    deviceToken = [NSString stringWithString:str];

}

-(void)sendDeviceToken{
    
    if (deviceToken == nil) {
        return;
    }
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/user/update/IOS/id"];
   
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:deviceToken forKey:@"deviceToken"];
    
    NSMutableDictionary *postValuesDict = [NSMutableDictionary dictionary];
    
    [postValuesDict setObject:deviceToken forKey:@"deviceToken"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[self headerPOSTRequest:requestURL.absoluteString values:[NSMutableArray arrayWithObject:dict]] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:requestURL.absoluteString parameters:postValuesDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self sendDeviceTokenReceived:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self sendDeviceTokenFailed:error.localizedDescription];
    }];
}

-(void)sendDeviceTokenReceived:(id)request{
    
    NSString *responseString = request;

}

-(void)sendDeviceTokenFailed:(id)request{
    
    NSString *responseString = request;
    
}

-(void)updateUser{
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/user/verify"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[self headerGETRequest:requestURL.absoluteString values:nil] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:requestURL.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self updateUserReceived:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self updateUserFailed:error.localizedDescription];
    }];
    
}

-(void)updateUserReceived:(id)request{
  
    @try {
       
        NSString *responseString = [request stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
        
        if (responseString.length == 0) {
            
            [[DTO sharedDTO]addBugLog:@"responseString.length == 0" where:@"BPUser/updateUserReceived" json:responseString];
            return;
        }
        responseString = [[responseString substringToIndex:[responseString length]-1]substringFromIndex:1];
        
        NSArray *responseArray = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
        self.user = [NSMutableDictionary dictionaryWithDictionary:responseArray.firstObject];
        
        //if user added new image erase the old one
        
        NSString *imageName = [NSString stringWithFormat:@"%@",[[[BPUser sharedBP].user objectForKey:@"image_path"] MD5]];
        
        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
        
        if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
            [[NSFileManager defaultManager]removeItemAtPath:localPath error:NULL];
        }
  
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
   

}

-(void)updateUserFailed:(id)request{
    NSString *responseString = request;
    
    [[DTO sharedDTO]addBugLog:@"updateUserFailed" where:@"BPUser/updateUserFailed" json:responseString];
}


-(void)getUser{
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/user/verify"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[self headerGETRequest:requestURL.absoluteString values:nil] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:requestURL.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self userInfoReceived:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self userInfoFailed:error.localizedDescription];
    }];
    
}

-(void)userInfoReceived:(id)request{
   
    NSString *responseString = [request stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];

    if (responseString.length == 0) {
        
        [[DTO sharedDTO]addBugLog:@"responseString.length == 0" where:@"BPUser/userInfoReceived" json:responseString];
        
        self.completed(NO,nil);
        return;
    }
    responseString = [[responseString substringToIndex:[responseString length]-1]substringFromIndex:1];
    
    NSArray *responseArray = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    if (![responseArray isKindOfClass:[NSArray class]]) {
        
        [[DTO sharedDTO]addBugLog:@"responseArray == nil" where:@"BPUser/userInfoReceived" json:responseString];
        
        self.completed(NO,nil);
        return;
    }
    
    self.user = [NSMutableDictionary dictionaryWithDictionary:responseArray.firstObject];

    NSLog(@"Login With ID: %@",[self.user objectForKey:@"id"]);
    NSLog(@"Login With EMAIL: %@",[self.user objectForKey:@"email"]);
    
    self.completed(YES,responseString);
}

-(void)userInfoFailed:(id)request{
    NSString *responseString = request;
    
    [[DTO sharedDTO]addBugLog:@"userInfoFailed" where:@"BPUser/userInfoFailed" json:responseString];
    
    self.completed(NO,nil);
}

#pragma mark - Follow

-(void)getLocalFollowersForUser:(NSString *)user_id WithCompletionBlock:(completed)compbloc{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"followers-%@",user_id]];
    NSString *json =  [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSArray *users = [json objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
//    for (NSDictionary *user in users) {
//        NSString *imagePath = [user objectForKey:@"image_path"];
//        [[DTO sharedDTO]downloadImageFromURL:imagePath];
//    }
    
    compbloc(YES,users);


}

-(void)getLocalFollowingForUser:(NSString *)user_id WithCompletionBlock:(completed)compbloc{
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"following-%@",user_id]];
    NSString *json =  [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSArray *users = [json objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
//    for (NSDictionary *user in users) {
//        NSString *imagePath = [user objectForKey:@"image_path"];
//        [[DTO sharedDTO]downloadImageFromURL:imagePath];
//    }
    
    compbloc(YES,users);

}


-(void)getFollowersForUser:(NSString *)user_id WithCompletionBlock:(completed)compbloc{
  
    if (user_id == nil) {
        user_id = [[BPUser sharedBP].user objectForKey:@"id"];
    }
    _userID = user_id;
    
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/followers/show"];
    
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/followers/show?"];
    
    NSDictionary *dict = [BPUser sharedBP].user;
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"user=%@",user_id]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    self.followers_completed = compbloc;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[self headerGETRequest:URL.absoluteString values:array] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:URLwithVars parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self followersReceived:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self followersFailed:error.localizedDescription];
    }];
}


-(void)getFollowersWithCompletionBlock:(completed)compbloc{
    
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/followers/show"];
    
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/followers/show?"];
    
    NSDictionary *dict = [BPUser sharedBP].user;
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"user=%@",[[BPUser sharedBP].user objectForKey:@"id"]]];
    [array addObject:[NSString stringWithFormat:@"limit=%d",5]];
    [array addObject:[NSString stringWithFormat:@"page=%d",0]];
    
    _userID = [[BPUser sharedBP].user objectForKey:@"id"];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    self.followers_completed = compbloc;

    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[self headerGETRequest:URL.absoluteString values:nil] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:requestURL.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self followersReceived:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self followersFailed:error.localizedDescription];
    }];


}

-(void)followersReceived:(id)request{

    NSString *responseString = request;
    
    NSArray *users = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    if ([users isKindOfClass:[NSArray class]]) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"followers-%@",_userID]];
        NSError *error;
        
        BOOL succeed = [responseString writeToFile:filePath
                                        atomically:YES encoding:NSUTF8StringEncoding error:&error];
       
        NSMutableArray *mutablePeople = [NSMutableArray array];
        
        for (NSMutableDictionary *user in users) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:user];
            [mutablePeople addObject:dict];
        }
        
        self.followers_completed(YES,mutablePeople);
    }
    else{
        
        [[DTO sharedDTO]addBugLog:@"users.count == 0" where:@"BPUser/followersReceived->followersFailed" json:responseString];
        
        [self followersFailed:request];
    }
    
}

-(void)followersFailed:(id)request{
    
    NSString *responseString = request;
    
  //  [[DTO sharedDTO]addBugLog:@"followersFailed" where:@"BPUser/followersFailed" json:responseString];
    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];
    
    self.followers_completed(NO,nil);
}

-(void)getFollowingForUser:(NSString *)user_id WithCompletionBlock:(completed)compbloc{
    
    if (user_id == nil) {
        user_id = [[BPUser sharedBP].user objectForKey:@"id"];
    }
    _userID = user_id;
    
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/following/show"];
    
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/following/show?"];
    
    NSDictionary *dict = [BPUser sharedBP].user;
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"user=%@",user_id]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    self.following_completed = compbloc;
    
    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[self headerGETRequest:URL.absoluteString values:array] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:requestURL.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self followingReceived:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self followingFailed:error.localizedDescription];
    }];

}


-(void)getFollowingWithCompletionBlock:(completed)compbloc{
    
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/following/show"];
    
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/following/show?"];

    NSDictionary *dict = [BPUser sharedBP].user;
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"user=%@",_userID]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    self.following_completed = compbloc;
    
    NSURL *requestURL = [NSURL URLWithString:URLwithVars];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[self headerGETRequest:URL.absoluteString values:array] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:requestURL.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self followingReceived:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self followingFailed:error.localizedDescription];
    }];
    
}

-(void)followingReceived:(id)request{
    
    NSString *responseString = request;
    
    NSArray *users = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];

    if ([users isKindOfClass:[NSArray class]]) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"following-%@",_userID]];
        NSError *error;
        
        BOOL succeed = [responseString writeToFile:filePath
                                        atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        
        NSMutableArray *mutablePeople = [NSMutableArray array];
        
        for (NSMutableDictionary *user in users) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:user];
            [mutablePeople addObject:dict];
        }
        
        self.following_completed(YES,mutablePeople);
    }
    else{
        
        [[DTO sharedDTO]addBugLog:@"users.count == 0" where:@"BPUser/followingReceived->followingFailed" json:responseString];
        
        [self followingFailed:request];
    }
    
    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];

    
}

-(void)followingFailed:(id)request{
    
    NSString *responseString = request;
    
   // [[DTO sharedDTO]addBugLog:@"followingFailed" where:@"BPUser/followingFailed" json:responseString];
    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];
    
    self.following_completed(NO,nil);
}



-(void)checkIfFollowing:(NSString *)other_user_id WithCompletionBlock:(completed)compbloc{
    
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/followers/is"];
    
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/followers/is?"];
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"user=%@",other_user_id]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    self.is_following_completed = compbloc;
    
    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[self headerGETRequest:URL.absoluteString values:array] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:requestURL.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self isfollowingFinished:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self isfollowingFailed:error.localizedDescription];
    }];

}

-(void)isfollowingFinished:(id)request{
    NSString *responseString = request;
    self.is_following_completed(YES,responseString);
}


-(void)isfollowingFailed:(id)request{
    NSString *responseString = request;
    self.is_following_completed(NO,nil);
    
}

-(void)follow:(NSString *)userID WithCompletionBlock:(completed)compbloc{
    
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/followers/create"];
    
    self.completed = compbloc;
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    [postValues addObject:[NSDictionary dictionaryWithObject:userID forKey:@"user"]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerPOSTRequest:URL.absoluteString values:postValues] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:URL.absoluteString parameters:@{@"user":userID} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self follow_user_Received:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self follow_user_Failed:error.localizedDescription];
    }];


}

-(void)follow_user_Received:(id)request{
    
    NSString *responseString = request;
    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];
    
    self.completed(YES,nil);
    
    //For timeline
    
    [[BPUser sharedBP]getFollowingForUser:[[BPUser sharedBP].user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){}];
    
}

-(void)follow_user_Failed:(id)request{
    
    NSString *responseString = request;
    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];
    
    self.completed(NO,nil);
}

-(void)unfollow:(NSString *)userID WithCompletionBlock:(completed)compbloc{
  
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/following/stop"];
    
    self.completed = compbloc;
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    [postValues addObject:[NSDictionary dictionaryWithObject:userID forKey:@"user"]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerPOSTRequest:URL.absoluteString values:postValues] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:URL.absoluteString parameters:@{@"user":userID} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self unfollow_user_Received:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self unfollow_user_Failed:error.localizedDescription];
    }];

    
}

-(void)unfollow_user_Received:(id)request{
    
    NSString *responseString = request;
    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];
    
    self.completed(YES,nil);
    
    
    //For timeline
    [[BPUser sharedBP]getFollowingForUser:[[BPUser sharedBP].user objectForKey:@"id"] WithCompletionBlock:^(BOOL completed,NSArray *objs){}];
    
}

-(void)unfollow_user_Failed:(id)request{
    
    NSString *responseString = request;
    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];
    
    self.completed(NO,nil);
}

#pragma mark - Notifications LOCAL

-(void)getLocalNotifications:(completed)compbloc{
    
    self.localNotificationsCompleted= compbloc;
   
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"notifications-%@",[[BPUser sharedBP].user objectForKey:@"id"]]];
        NSMutableArray *notifs =  [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:filePath]];
        compbloc(YES,notifs);
    
    }
    @catch (NSException *exception) {
        compbloc(NO,nil);
    }
        @finally {
        
    }
}

#pragma mark - Notifications FIRST

-(void)getNotificationsWithCompletionBlock:(notifications_completed)compbloc{
    
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/notification/show"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/notification/show?"];
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"limit=%d",notifsPageLimit]];
    [array addObject:[NSString stringWithFormat:@"time=%d",(int)[[NSDate date] timeIntervalSince1970]]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    self.notifications_completed = compbloc;
    
    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerGETRequest:URL.absoluteString values:array] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:URLwithVars parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self notificationsReceived:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self notificationsFailed:error.localizedDescription];
    }];
    
}


-(void)notificationsReceived:(id)request{
    
    NSString *responseString = request;
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
    
    
    NSArray *notificationsArray = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    if (![notificationsArray isKindOfClass:[NSArray class]]) {
        [[DTO sharedDTO]addBugLog:@"![notificationsArray isKindOfClass:[NSArray class]]->notifictionsFailed" where:@"BPUser/notificationsReceived" json:responseString];
        [self notificationsFailed:nil];
        return;
    }
    
    NSMutableArray *bs = [NSMutableArray array];
    
    for (id b in notificationsArray) {
        
        NSDictionary *activity_item;
        
        if ([b isKindOfClass:[NSString class]]) {
            activity_item  = [b objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
        }
        else{
            activity_item = b;
        }
        
        if (activity_item.allKeys.count == 1) {
           
            @try {
                if ([activity_item.allKeys.firstObject isEqualToString:@"notification_time"]) {
                    serverTime = [[NSString stringWithFormat:@"%@",[activity_item objectForKey:@"notification_time"]] intValue];
                }
                else{
//                    NSString *badge = [NSString stringWithFormat:@"%@",[activity_item objectForKey:@"badge_number"]];
//                    self.badgeNumber = badge.intValue;
                }
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
        else{
            Activity_Object *notification = [Activity_Object modelObjectWithDictionary:activity_item];
            [bs addObject:notification];
        }
    }
    
    @try {
       
        NSArray *timeStamps = [bs valueForKey:@"when"];
        
        float xmin = MAXFLOAT;
        for (NSString *num in timeStamps) {
            double x = num.doubleValue;
            if (x < xmin){
                oldestTimestamp = x;
                xmin = x;
            }
        }
    }
    @catch (NSException *exception) {
         [[DTO sharedDTO]addBugLog:@"@catch" where:@"BPUser/notificationsReceived" json:responseString];
    }
    @finally {
        
    }
    
    
    self.notifications_completed(YES,bs);
    
}

-(void)notificationsFailed:(id)request{
    
    NSString *responseString = request;
    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];
    
//    if (page_new>0) {
//        page_new--;
//    }
    
    [[DTO sharedDTO]addBugLog:@"notificationsFailed" where:@"BPUser/notificationsFailed" json:responseString];
    
    self.notifications_completed(NO,@"Request failed.Please slide to reload.");
    
}

#pragma mark - Notifications NEXT Pages

-(void)nextNotificationsWithCompletionBlock:(notifications_completed)compbloc{
    
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/notification/show"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/notification/show?"];
    
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"limit=%d",notifsPageLimit]];
    [array addObject:[NSString stringWithFormat:@"time=%d",(int)oldestTimestamp]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    self.next_notifications_completed = compbloc;
    
    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerGETRequest:URL.absoluteString values:array] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:URLwithVars parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self nextNotificationsReceived:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self nextNotificationsFailed:error.localizedDescription];
    }];

    
}

-(void)nextNotificationsReceived:(id)request{
    
    NSString *responseString = request;
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
    
    NSArray *notificationsArray = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    if (![notificationsArray isKindOfClass:[NSArray class]]) {
        [[DTO sharedDTO]addBugLog:@"![notificationsArray isKindOfClass:[NSArray class]]" where:@"BPUser/nextNotificationsReceived" json:responseString];
        [self nextNotificationsFailed:nil];
        return;
    }
    
    NSMutableArray *bs = [NSMutableArray array];
    
    for (id b in notificationsArray) {
        
        NSDictionary *activity_item;
        
        if ([b isKindOfClass:[NSString class]]) {
            activity_item  = [b objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
        }
        else{
            activity_item = b;
        }
        
        if (activity_item.allKeys.count == 1) {
           
            @try {
                if ([activity_item.allKeys.firstObject isEqualToString:@"notification_time"]) {
                    serverTime = [[NSString stringWithFormat:@"%@",[activity_item objectForKey:@"notification_time"]] intValue];
                }
                else{
//                    NSString *badge = [NSString stringWithFormat:@"%@",[activity_item objectForKey:@"badge_number"]];
//                    self.badgeNumber = badge.intValue;
                }
            }
            @catch (NSException *exception) {
                
            }
            @finally {
                
            }
        }
        else{
            Activity_Object *notification = [Activity_Object modelObjectWithDictionary:activity_item];
            [bs addObject:notification];
        }
    }
    
    @try {
        
        NSArray *timeStamps = [bs valueForKey:@"when"];
        
        float xmin = MAXFLOAT;
        for (NSString *num in timeStamps) {
            double x = num.doubleValue;
            if (x < xmin){
                oldestTimestamp = x;
                xmin = x;
            }
        }
    }
    @catch (NSException *exception) {
         [[DTO sharedDTO]addBugLog:@"@catch" where:@"BPUser/nextNotificationsReceived" json:responseString];
    }
    @finally {
        
    }

    self.next_notifications_completed(YES,bs);
}

-(void)nextNotificationsFailed:(id)request{
    
    NSString *responseString = request;
    
    [[DTO sharedDTO]addBugLog:@"nextNotificationsFailed" where:@"BPUser/nextNotificationsFailed" json:responseString];
    
    self.next_notifications_completed(NO,nil);
    
}

#pragma mark - New Notifs

-(void)newNotificationsWithCompletionBlock:(notifications_completed)compbloc{
    
    self.newNotificationsCompleted = compbloc;
    
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/notification/shownew?"];
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/notification/shownew"];
    
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"limit=%d",notifsPageLimit]];
    [array addObject:[NSString stringWithFormat:@"time=%d",(int)serverTime]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerGETRequest:URL.absoluteString values:array] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:URLwithVars parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self newNotificationsReceived:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self newNotificationsFailed:error.localizedDescription];
    }];
    

}

-(void)newNotificationsReceived:(id)request{
    
    NSString *responseString = request;
    
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
    
    
    NSArray *notificationsArray = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    NSMutableArray *bs = [NSMutableArray array];
    
    for (id b in notificationsArray) {
        
        NSDictionary *activity_item;
        
        if ([b isKindOfClass:[NSString class]]) {
            activity_item  = [b objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
        }
        else{
            activity_item = b;
        }
        
        if (activity_item.allKeys.count == 1) {
           
            @try {
                if ([activity_item.allKeys.firstObject isEqualToString:@"notification_time"]) {
                   serverTime = [[NSString stringWithFormat:@"%@",[activity_item objectForKey:@"notification_time"]] intValue];
                }
                else{
                    NSString *badge = [NSString stringWithFormat:@"%@",[activity_item objectForKey:@"badge_number"]];
                    if(badge.intValue != -1){
                        self.badgeNumber = badge.intValue;
                        [[DTO sharedDTO]saveNotificationsBadge:badge.intValue];
                    }
                }
            }
            @catch (NSException *exception) {

            }
            @finally {
                
            }
        }
        else{
            Activity_Object *notification = [Activity_Object modelObjectWithDictionary:activity_item];
            [bs addObject:notification];
        }
    }

    if (bs.count == 0) {//comment out because its too frequent and normal to get 0 when not more
        //[[DTO sharedDTO]addBugLog:@"bs.count == 0" where:@"BPUser/newNotificationsReceived" json:responseString];
    }
    
    self.newNotificationsCompleted(YES,bs);
}

-(void)newNotificationsFailed:(id)request{
    
    NSString *responseString = request;
    
    //[[DTO sharedDTO]addBugLog:@"newNotificationsFailed" where:@"BPUser/newNotificationsFailed" json:responseString];
    
    self.newNotificationsCompleted(NO,nil);
    
}


#pragma mark - Notifs BADGE Clear

-(void)clearBadgeWithCompletionBlock:(clearBadge_completed)compbloc{

    if (self.badgeNumber == 0) {
        return;
    }
    
    self.clearBadge_completed = compbloc;
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/notification/clearbadge"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerGETRequest:URL.absoluteString values:postValues] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:URL.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            NSString *response = operation.responseString;
            
            if ([response rangeOfString:@"success"].location != NSNotFound) {
                
                [[DTO sharedDTO]setApplicationBadge:(int)[UIApplication sharedApplication].applicationIconBadgeNumber-self.badgeNumber];
                
                self.badgeNumber = 0;
                self.clearBadge_completed(YES);
            }
            else{
                self.clearBadge_completed(NO);
            }
            
        }
        @catch (NSException *exception) {
            self.clearBadge_completed(NO);
        }
        @finally {
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

          self.clearBadge_completed(NO);
    }];
}

#pragma mark - Notif Read

-(void)markNotificationRead:(NSString *)notif_id completionBlock:(markRead_completed)compbloc{
   
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/notification/markasread"];
    
    self.markRead_completed = compbloc;
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    [postValues addObject:[NSDictionary dictionaryWithObject:[[DTO sharedDTO] urlencode:[NSString stringWithFormat:@"%@",notif_id]] forKey:@"id"]];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerPOSTRequest:URL.absoluteString values:postValues] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:URL.absoluteString parameters:@{@"id":[NSString stringWithFormat:@"%@",notif_id]} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            
            NSString *responseString = [operation responseString];
            NSDictionary *responseDict = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
            
            NSArray *errors = [responseDict objectForKey:@"errors"];
            
            NSDictionary *error = [errors firstObject];
            
            if ([responseString rangeOfString:@"success"].location == NSNotFound) {
                self.markRead_completed(NO);
            }
            else{
                self.markRead_completed(YES);
            }
        }
        @catch (NSException *exception) {
            self.markRead_completed(YES);
        }
        @finally {
            
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        NSString *responseString = [operation responseString];
        self.markRead_completed(NO);
    }];

}

#pragma mark - Facebook

-(void)beeepersFromFB_IDs:(NSString *)idsJSON WithCompletionBlock:(completed)compbloc{
    
    self.beeepersFromFBCompleted = compbloc;
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    [postValues addObject:[NSDictionary dictionaryWithObject:[[DTO sharedDTO] urlencode:idsJSON] forKey:@"fb_list"]];
    
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/facebook/list"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerPOSTRequest:URL.absoluteString values:postValues] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:URL.absoluteString parameters:@{@"fb_list":idsJSON} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            
            NSString *responseString = [operation responseString];
            NSDictionary *beeepersDict = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
            
            NSMutableArray *beeepers = [NSMutableArray array];
            
            for (NSString *key in beeepersDict.allKeys) {
               
                NSDictionary *beeeper = [beeepersDict objectForKey:key];
                NSMutableDictionary *mutableBeeeper = [NSMutableDictionary dictionaryWithDictionary:beeeper];
                
                [beeepers addObject:mutableBeeeper];
            }
            
            if (beeepers.count == 0) {
                [[DTO sharedDTO]addBugLog:@"beeepers.count == 0" where:@"BPUser/beeepersFromFB_IDs" json:responseString];
            }
            
            self.beeepersFromFBCompleted(YES,beeepers);
        }
        @catch (NSException *exception) {
            self.beeepersFromFBCompleted(NO,nil);
        }
        @finally {
            
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      
        NSString *responseString = [operation responseString];
        
        [[DTO sharedDTO]addBugLog:@"request_failed" where:@"BPUser/beeepersFromFB_IDs" json:responseString];
        
        self.beeepersFromFBCompleted(NO,nil);
    }];
    
}

-(void)beeepersFromTW_IDs:(NSString *)idsJSON WithCompletionBlock:(completed)compbloc{
   
    self.beeepersFromTWCompleted = compbloc;
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    [postValues addObject:[NSDictionary dictionaryWithObject:[[DTO sharedDTO] urlencode:idsJSON] forKey:@"tw_list"]];
    
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/twitter/list"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerPOSTRequest:URL.absoluteString values:postValues] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:URL.absoluteString parameters:@{@"tw_list":idsJSON} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *responseString = [operation responseString];
        
        @try {
            
            NSArray *beeepers = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
            
            if (beeepers.count == 0) {
                [[DTO sharedDTO]addBugLog:@"beeepers.count == 0" where:@"BPUser/beeepersFromTW_IDs" json:responseString];
            }
            
            NSMutableArray *mutablePeople = [NSMutableArray array];
            
            for (NSMutableDictionary *user in beeepers) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:user];
                [mutablePeople addObject:dict];
            }
            
            self.beeepersFromTWCompleted(YES,mutablePeople);
        }
        @catch (NSException *exception) {
            
            [[DTO sharedDTO]addBugLog:@"@catch" where:@"BPUser/beeepersFromTW_IDs" json:responseString];
            
            self.beeepersFromTWCompleted(NO,nil);
        }
        @finally {
            
        }

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSString *responseString = [operation responseString];
        
        [[DTO sharedDTO]addBugLog:@"failed" where:@"BPUser/beeepersFromTW_IDs" json:responseString];
        
        self.beeepersFromTWCompleted(NO,nil);
    }];
}


#pragma mark - Download images

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
            
          //  NSString *extension = [[w.imagePath.lastPathComponent componentsSeparatedByString:@"."] lastObject];
            
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
            path = [path stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
            NSURL *URL = [NSURL URLWithString:[[DTO sharedDTO]fixLink:path]];
            NSData * localData = [NSData dataWithContentsOfURL:URL];
            result = [UIImage imageWithData:localData];
            [self saveImage:result withFileName:imageName inDirectory:localPath];
        }
        
    }
    
    if(actv.beeepInfoActivity.eventActivity != nil){
        
        EventActivity *event = [actv.beeepInfoActivity.eventActivity firstObject];
        
        NSString *path = event.imageUrl;
        
        //NSString *extension = [[path.lastPathComponent componentsSeparatedByString:@"."] lastObject];
        
        NSString *imageName = [NSString stringWithFormat:@"%@",[path MD5]];
        
        NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
        
        if (![[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
            UIImage * result;
            NSURL *URL = [NSURL URLWithString:[[DTO sharedDTO]fixLink:path]];
            NSData * localData = [NSData dataWithContentsOfURL:URL];
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


#pragma mark - Settings

-(void)getEmailSettingsWithCompletionBlock:(completed)compbloc{
   
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/user/notificationsettings"];
    
    self.getEmailSettingsCompleted = compbloc;
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerGETRequest:URL.absoluteString values:postValues] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:URL.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self getEmailSettings_Received:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self getEmailSettings_Failed:error.localizedDescription];
    }];

}

-(void)getEmailSettings_Received:(id)request{
    
    NSString *responseString = request;
    
    @try {
        NSArray *notifications = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
        if (notifications.count >0) {
            self.getEmailSettingsCompleted(YES,notifications);
        }
    }
    @catch (NSException *exception) {
           self.getEmailSettingsCompleted(NO,nil);
    }
    @finally {
        
    }

}


-(void)getEmailSettings_Failed:(id)request{
    
    NSString *responseString = request;
    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];
    
    self.getEmailSettingsCompleted(NO,nil);
}

-(void)setEmailSettings:(NSDictionary *)settingsDict WithCompletionBlock:(completed)compbloc{
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/user/setnotificationsettings"];
    
    self.setEmailSettingsCompleted = compbloc;
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    for (NSString *key in settingsDict.allKeys) {
        NSString *value = [settingsDict objectForKey:key];
        [postValues addObject:[NSDictionary dictionaryWithObject:value forKey:key]];
    }
    
    NSMutableDictionary *postValuesDict = [NSMutableDictionary dictionary];
    
    for (NSString *key in settingsDict.allKeys) {
        NSString *value = [settingsDict objectForKey:key];
        [postValuesDict setObject:value forKey:key];
    }
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerPOSTRequest:requestURL.absoluteString values:postValues] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:requestURL.absoluteString parameters:postValuesDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self setEmailSettings_Received:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self setEmailSettings_Failed:error.localizedDescription];
    }];

}

-(void)setEmailSettings_Received:(id)request{
    
    NSString *responseString = request;
    
    @try {
        NSDictionary *notifications = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
        if (notifications.allKeys.count > 1) {
            self.setEmailSettingsCompleted(YES,notifications);
        }
    }
    @catch (NSException *exception) {
        self.setEmailSettingsCompleted(NO,nil);
    }
    @finally {
        
    }
    
}


-(void)setEmailSettings_Failed:(id)request{
    
    NSString *responseString = request;
    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];
    
    self.setEmailSettingsCompleted(NO,nil);
}


#pragma mark - GET POST requests

-(NSString *)headerGETRequest:(NSString *)link values:(NSMutableArray *)values{
    
    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *nonce = [self random32CharacterString];
    
    NSString *headerString = [NSString stringWithFormat:@"OAuth realm=\"\",oauth_signature_method=\"%@\",oauth_signature=\"%@\",oauth_nonce=\"%@\",oauth_timestamp=\"%@\",oauth_token=\"%@\",oauth_consumer_key=\"%@\",oauth_version=\"%@\"",oauth_signature_method,[self GETRequestSignature:link values:values timeStamp:timestamp nonce:nonce],nonce,timestamp,accessToken,consumerKey,@"1.0"];
    
    return headerString;
    
}

-(NSString *)GETRequestSignature:(NSString *)link values:(NSMutableArray *)values timeStamp:(NSString *)timestamp nonce:(NSString *)nonce{
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:values];
    
    NSMutableString *domain = [[NSMutableString alloc]init];
    
    NSString *unencodedStr = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_token=%@&oauth_version=1.0",consumerKey,nonce,oauth_signature_method,timestamp,accessToken];
    
    [array addObjectsFromArray:[unencodedStr componentsSeparatedByString:@"&"]];
    
    NSSortDescriptor * sortDesc = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
    [array sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
    
    for (NSString *str in array) {
        [domain appendFormat:@"%@",str];
        if (str != array.lastObject) {
            [domain appendString:@"&"];
        }
    }
    
    NSString *key;
    
    key = [NSString stringWithFormat:@"%@&%@",[[DTO sharedDTO] urlencode:[NSString stringWithFormat:@"%@",consumerSecret]],[[DTO sharedDTO] urlencode:[NSString stringWithFormat:@"%@",accessTokenSecret]]];
    
    NSString *encodedStr = [self encodeWithHmacsha1:[NSString stringWithFormat:@"GET&%@&%@",[[DTO sharedDTO] urlencode:link],[[DTO sharedDTO] urlencode:domain]] key:key];
    
    return encodedStr;
}


#pragma mark - GET POST requests

-(NSString *)headerPOSTRequest:(NSString *)link values:(NSMutableArray *)values{
    
    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *nonce = [self random32CharacterString];
    
    NSString *headerString = [NSString stringWithFormat:@"OAuth realm=\"\",oauth_signature_method=\"%@\",oauth_signature=\"%@\",oauth_nonce=\"%@\",oauth_timestamp=\"%@\",oauth_token=\"%@\",oauth_consumer_key=\"%@\",oauth_version=\"%@\"",oauth_signature_method,[self POSTRequestSignature:link values:values timeStamp:timestamp nonce:nonce],nonce,timestamp,accessToken,consumerKey,@"1.0"];
    
    return headerString;
    
}

-(NSString *)POSTRequestSignature:(NSString *)link values:(NSMutableArray *)values timeStamp:(NSString *)timestamp nonce:(NSString *)nonce{
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSMutableString *domain = [[NSMutableString alloc]init];
    
    NSString *unencodedStr = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_token=%@&oauth_version=1.0",consumerKey,nonce,oauth_signature_method,timestamp,accessToken];
    
    [array addObjectsFromArray:[unencodedStr componentsSeparatedByString:@"&"]];
    
    for (NSDictionary *dict in values) {
        NSArray *keys = [dict allKeys];
        
        for (NSString *key in keys) {
            NSString *value = [dict objectForKey:key];
            NSString *str = [NSString stringWithFormat:@"%@=%@",key,value];
            [array addObject:str];
        }
    }
    
    NSSortDescriptor * sortDesc = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
    [array sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
    
    for (NSString *str in array) {
        [domain appendFormat:@"%@",str];
        if (str != array.lastObject) {
            [domain appendString:@"&"];
        }
    }
    
    NSString *key;
    
    key = [NSString stringWithFormat:@"%@&%@",[[DTO sharedDTO] urlencode:[NSString stringWithFormat:@"%@",consumerSecret]],[[DTO sharedDTO] urlencode:[NSString stringWithFormat:@"%@",accessTokenSecret]]];
    
    NSString *encodedStr = [self encodeWithHmacsha1:[NSString stringWithFormat:@"POST&%@&%@",[[DTO sharedDTO] urlencode:link],[[DTO sharedDTO] urlencode:domain]] key:key];
    
    return encodedStr;
}


#pragma mark - Request Token

-(void)getRequestToken{
    
    oauth_nonce = [self random32CharacterString];
    oauth_nonce_accessToken = [self random32CharacterString];
    oauth_timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    
    NSString *headerString = [NSString stringWithFormat:@"OAuth realm=\"\", xoauth_displayname=\"%@\", oauth_callback=\"%@\", oauth_signature_method=\"%@\", oauth_signature=\"%@\", oauth_nonce=\"%@\", oauth_timestamp=\"%@\", oauth_consumer_key=\"%@\", oauth_version=\"%@\"",xoauth_displayname,oauth_callback,oauth_signature_method,[self signature],oauth_nonce,oauth_timestamp,consumerKey,@"1.0"];

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:headerString forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [manager POST:@"https://api.beeeper.com/oAuth/request_token.php" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        [self requestTokenReceived:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"%@",operation);
        [self requestTokenFailed:error];
    }];
}

-(void)requestTokenReceived:(id)responseObject{
    
    NSString *responseString = responseObject;
    
    @try {
        NSArray *objects = [responseString componentsSeparatedByString:@"&"];
        oauth_token = [[[objects objectAtIndex:1] componentsSeparatedByString:@"="] lastObject];
        oauth_token_secret = [[[objects objectAtIndex:2] componentsSeparatedByString:@"="] lastObject];
        [self authorize];
    }
    @catch (NSException *exception) {
        self.completed(NO,nil);
    }
    @finally {
        
    }
}

-(void)requestTokenFailed:(NSError *)responseObject{

    NSString *errorStr = [responseObject localizedDescription];
    
    self.completed(NO,errorStr);
}

-(NSString *)signature{
    
    NSString *domain = @"https://api.beeeper.com/oAuth/request_token.php";
    NSString *unencodedStr = [NSString stringWithFormat:@"oauth_callback=%@&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_version=1.0&xoauth_displayname=%@",oauth_callback,consumerKey,oauth_nonce,oauth_signature_method,oauth_timestamp,xoauth_displayname];
    NSString *key;
    
    key = [NSString stringWithFormat:@"%@&",[[DTO sharedDTO] urlencode:[NSString stringWithFormat:@"%@",consumerSecret]]];
    
    NSString *encodedStr = [self encodeWithHmacsha1:[NSString stringWithFormat:@"POST&%@&%@",[[DTO sharedDTO] urlencode:domain],[[DTO sharedDTO] urlencode:unencodedStr]] key:key];
    
    signature = encodedStr;
    
    return encodedStr;
}

#pragma mark - Authorize

-(void)authorize{
    
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.beeeper.com/oAuth/authorize.php?oauth_token=%@",oauth_token]];

    NSMutableDictionary *postValuesDict = [NSMutableDictionary dictionary];
    
    if (_fbid) {
       
        [postValuesDict setObject:[[DTO sharedDTO] urlencode:[NSString stringWithFormat:@"%@",_fbid]] forKey:@"fbid"];
        if ([imageToUpdate isKindOfClass:[NSString class]] && imageToUpdate.length > 0) {
            [postValuesDict setObject:imageToUpdate forKey:@"image"];
        }
    }
    else if (_twitterid){
        
        [postValuesDict setObject:[[DTO sharedDTO] urlencode:[NSString stringWithFormat:@"%@",_twitterid]] forKey:@"twid"];
        if ([imageToUpdate isKindOfClass:[NSString class]] && imageToUpdate.length > 0) {
            [postValuesDict setObject:imageToUpdate forKey:@"image"];
        }
    }
    else{
        [postValuesDict setObject:_username forKey:@"username"];
        [postValuesDict setObject:_password forKey:@"password"];
    }
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:@"test" forHTTPHeaderField:@"Referer"];
    
    [manager POST:requestURL.absoluteString parameters:postValuesDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self authorizationReceived:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self authorizationFailed:[operation responseString]];
    }];
}

-(void)authorizationReceived:(id)request{
    
    @try {
        NSString *responseString = request;
        if ([responseString isKindOfClass:[NSString class]] && responseString.length > 0) {
            verifier = [[responseString componentsSeparatedByString:@":"] lastObject];
            
            [self getAccessToken];
        }
        else{
            self.completed(NO,@"Authorization failed. Response was empty");
        }
    }
    @catch (NSException *exception) {
        self.completed(NO,nil);
    }
    @finally {
        
    }
}

-(void)authorizationFailed:(id)request{
    NSString *responseString = request;
    NSLog(@"ERROR: %@",responseString);
    self.completed(NO,[NSString stringWithFormat:@"Authorization Failed: %@",responseString]);
}

#pragma mark - Access Token

-(void)getAccessToken{
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/oAuth/access_token.php"];
    
    oauth_timestamp_accessToken = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    
    NSString *headerString = [NSString stringWithFormat:@"OAuth realm=\"\", oauth_verifier=\"%@\", oauth_signature_method=\"%@\", oauth_signature=\"%@\", oauth_nonce=\"%@\", oauth_timestamp=\"%@\", oauth_token=\"%@\",oauth_consumer_key=\"%@\", oauth_version=\"%@\"",verifier,oauth_signature_method,[self accessTokenSignature],oauth_nonce_accessToken,oauth_timestamp_accessToken,oauth_token,consumerKey,@"1.0"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:headerString forHTTPHeaderField:@"Authorization"];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [manager POST:requestURL.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self accessTokenReceived:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self accessTokenFailed:error.localizedDescription];
    }];
    
}

-(void)accessTokenReceived:(id)request{
    
    NSString *responseString = request;
    
    @try {
        NSArray *objects = [responseString componentsSeparatedByString:@"&"];
        accessToken = [[[objects objectAtIndex:0] componentsSeparatedByString:@"="] lastObject];
        accessTokenSecret = [[[objects objectAtIndex:1] componentsSeparatedByString:@"="] lastObject];
        
        [self getUser];
    }
    @catch (NSException *exception) {
        self.completed(NO,nil);
    }
    @finally {
        
    }
}

-(void)accessTokenFailed:(id)request{
    NSString *responseString = request;
    self.completed(NO,responseString);
}

-(NSString *)accessTokenSignature{
    
    NSString *domain = @"https://api.beeeper.com/oAuth/access_token.php";
    NSString *unencodedStr = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_token=%@&oauth_verifier=%@&oauth_version=1.0",consumerKey,oauth_nonce_accessToken,oauth_signature_method,oauth_timestamp_accessToken,oauth_token,verifier];
    NSString *key;
    
    key = [NSString stringWithFormat:@"%@&%@",[[DTO sharedDTO] urlencode:[NSString stringWithFormat:@"%@",consumerSecret]],[[DTO sharedDTO] urlencode:[NSString stringWithFormat:@"%@",oauth_token_secret]]];
    
    NSString *encodedStr = [self encodeWithHmacsha1:[NSString stringWithFormat:@"POST&%@&%@",[[DTO sharedDTO] urlencode:domain],[[DTO sharedDTO] urlencode:unencodedStr]] key:key];
    
    signature_accessToken = encodedStr;
    
    return encodedStr;
}


#pragma mark  - Utilities methods

- (NSString *)encodeWithHmacsha1:(NSString *)data key:(NSString *)key
{
    NSData *secretData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [data dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
	CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);
    
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(result, 20, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSASCIIStringEncoding];
    
    return base64EncodedResult;
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

-(NSString *)random32CharacterString{
    static const int N = 32; // must be even
    
    uint8_t buf[N/2];
    char sbuf[N];
    arc4random_buf(buf, N/2);
    for (int i = 0; i < N/2; i += 1) {
        sprintf (sbuf + (i*2), "%02X", buf[i]);
    }
    return [[NSString alloc] initWithBytes:sbuf length:N encoding:NSASCIIStringEncoding];
}

@end

