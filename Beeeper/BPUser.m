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
    
    NSMutableArray *newNotifications;
    NSMutableArray *oldNotifications;
    BOOL newNotificationsFinished;
    BOOL oldNotificationsFinished;
    int page_new;
    int page_old;
    
    NSString *_userID;
}

@end

@implementation BPUser

static NSString *consumerKey = @"14ed757eefb1a284ba6f3e7e9989ec87052429ce1";
static NSString *consumerSecret = @"e92496b00f2abc454891c8d3c54017b8";

static BPUser *thisWebServices = nil;

-(id)init{
    self = [super init];
    if(self) {
        thisWebServices = self;
        oauth_callback = [self urlencode:@"beeeper://"];
        oauth_nonce = [self random32CharacterString];
        oauth_nonce_accessToken = [self random32CharacterString];
        oauth_signature_method = @"HMAC_SHA1";
        scope = @"randomScope";
        xoauth_displayname = @"RandomName";
        oauth_timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 3;
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
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Referer" value:@"t6FDJXLQnVKLYgZjaqhuiDIO7CxeK+bF+FGJorEBRB55k89C+qAxIyUKYrnTlLLJeEkHYwakO/ZYWVi8m370wQ=="];
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username

    self.completed = compbloc;
    
    [request setRequestMethod:@"POST"];
    
    [request addPostValue:[info objectForKey:@"email"] forKey:@"email"];

    [request addPostValue:[info objectForKey:@"name"] forKey:@"name"];

    [request addPostValue:[info objectForKey:@"lastname"] forKey:@"lastname"];

    [request addPostValue:[info objectForKey:@"timezone"] forKey:@"timezone"];

    [request addPostValue:[info objectForKey:@"password"] forKey:@"password"];

    [request addPostValue:[info objectForKey:@"city"] forKey:@"city"];

    [request addPostValue:[info objectForKey:@"state"] forKey:@"state"];

    [request addPostValue:[info objectForKey:@"country"] forKey:@"country"];

    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [[request UserInfo]setObject:info forKey:@"info"];
    
    [request setDidFinishSelector:@selector(signupFinished:)];
    
    [request setDidFailSelector:@selector(signupFailed:)];
    
    [request startAsynchronous];

}

-(void)signupFinished:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
   
    @try {
        NSDictionary *info = [[request UserInfo]objectForKey:@"info"];
        [self loginUser:[info objectForKey:@"email"] password:[info objectForKey:@"password"] completionBlock:^(BOOL completed,NSString *user){
            if (completed) {
                self.completed(completed,user);
            }
        }];
    }
    @catch (NSException *exception) {
        self.completed(NO,nil);
    }
    @finally {
        
    }
    
}

-(void)signupFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
}

#pragma mark - User settings

-(void)setUserSettings:(NSDictionary *)settings WithCompletionBlock:(completed)compbloc{
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/user/update_profile"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    self.setUserSettingsCompleted = compbloc;
    
    [request setRequestMethod:@"POST"];
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    for (NSString *key in settings.allKeys) {
       @try {
           id object = [settings objectForKey:key];
           [request addPostValue:object forKey:key];
           [postValues addObject:[NSDictionary dictionaryWithObject:[self urlencode:object] forKey:key]];
  
        }
        @catch (NSException *exception) {
            [request addPostValue:@"0" forKey:key];
            [postValues addObject:[NSDictionary dictionaryWithObject:@"0" forKey:key]];
        }
        @finally {
            
        }
    }
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerPOSTRequest:requestURL.absoluteString values:postValues]];
    
    [request setTimeOutSeconds:30.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(setUserSettingsFinished:)];
    
    [request setDidFailSelector:@selector(setUserSettingsFailed:)];
    
    [request startAsynchronous];

}

-(void)setUserSettingsFinished:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    if ([responseString isEqualToString:@"[success]"]) {
        self.setUserSettingsCompleted(YES,nil);
        [self updateUser];
    }
    else{
        self.setUserSettingsCompleted(NO,nil);
    }

}

-(void)setUserSettingsFailed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    self.setUserSettingsCompleted(NO,nil);
}

#pragma mark - FB Signup

-(void)signUpSocialUser:(NSDictionary *)info completionBlock:(completed)compbloc{
    
    NSURL *requestURL = [NSURL URLWithString:@"https://resources.beeeper.com/signup/"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
   
    [request addRequestHeader:@"Referer" value:@"t6FDJXLQnVKLYgZjaqhuiDIO7CxeK+bF+FGJorEBRB55k89C+qAxIyUKYrnTlLLJeEkHYwakO/ZYWVi8m370wQ=="];
    
    for (NSString *key in info.allKeys) {
        NSString *value = [info objectForKey:key];
        [request addPostValue:value forKey:key];
    }
    
    self.fbSignUpCompleted = compbloc;
    
    [request setRequestMethod:@"POST"];

    [[request UserInfo]setObject:info forKey:@"info"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(fbSignupReceived:)];
    
    [request setDidFailSelector:@selector(fbSignupFailed:)];
    
    [request startAsynchronous];
    
}

-(void)fbSignupReceived:(ASIHTTPRequest *)request{
 
  //  NSString *responseString = [request responseString];

    NSString *responseString = @"{\"id\":\"1404730445.521045345363001\",\"username\":\"maromm\",\"email\":\"maria.maraki.mario.maro@hotmail.com\",\"name\":\"maria\",\"lastname\":\"\",\"timezone\":\"180\",\"password\":\"8cb2237d0679ca88db6464eac60da96345513964\",\"locked\":\"0\",\"city\":\"cholargos\",\"state\":\"athens\",\"country\":\"greece\",\"long\":\"37.9978\",\"lat\":\"23.7926\",\"last_login\":\"\",\"sex\":\"\",\"fbid\":\"\",\"twid\":\"\",\"fbtoken\":"",\"twtoken\":"",\"active\":\"0\",\"image_path\":\"\",\"about\":\"\",\"website\":\"\",\"se_on\":\"1\"}";
    
    NSDictionary * response = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
   
    @try {
       NSArray *errors = [response objectForKey:@"errors"];
        
      NSDictionary *error = [errors firstObject];
        
        if (error != nil) {
            self.fbSignUpCompleted(NO,[error objectForKey:@"message"]);
        }
        else{
            NSDictionary *info = [[request UserInfo]objectForKey:@"info"];
            [self loginUser:[info objectForKey:@"email"] password:[info objectForKey:@"password"] completionBlock:^(BOOL completed,NSString *user){
                if (completed) {
                    self.fbSignUpCompleted(completed,user);
                }
                else{
                    self.fbSignUpCompleted(NO,nil);
                }
            }];
        }
        
    }
    @catch (NSException *exception) {
        self.fbSignUpCompleted(NO,nil);

    }
    @finally {

    }
    
}

-(void)fbSignupFailed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    self.fbSignUpCompleted(NO,nil);
    
}

#pragma mark - Login

-(void)loginTwitterUser:(NSString *)twitterid completionBlock:(completed)compbloc{
    
    _fbid = nil; //just in case
    _twitterid = twitterid;
    self.completed = compbloc;
    [self getRequestToken];
}

-(void)loginFacebookUser:(NSString *)fbid completionBlock:(completed)compbloc{
    
    _twitterid = nil; //just in case
    _fbid = fbid;
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

-(void)updateUser{
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/user/verify"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Authorization" value:[self headerGETRequest:requestURL.absoluteString values:nil]];
    
    [request setRequestMethod:@"GET"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(updateUserReceived:)];
    
    [request setDidFailSelector:@selector(updateUserFailed:)];
    
    [request startAsynchronous];
    
}

-(void)updateUserReceived:(ASIHTTPRequest *)request{
    
    NSString *responseString = [[request responseString] stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    
    if (responseString.length == 0) {
               return;
    }
    responseString = [[responseString substringToIndex:[responseString length]-1]substringFromIndex:1];
    
    NSArray *responseArray = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    self.user = responseArray.firstObject;
    
    //if user added new image erase the old one
    
    NSString *imageName = [NSString stringWithFormat:@"%@",[[[BPUser sharedBP].user objectForKey:@"image_path"] MD5]];
    
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
        [[NSFileManager defaultManager]removeItemAtPath:localPath error:NULL];
    }

}

-(void)updateUserFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
}


-(void)getUser{
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/user/verify"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Authorization" value:[self headerGETRequest:requestURL.absoluteString values:nil]];
    
    [request setRequestMethod:@"GET"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(userInfoReceived:)];
    
    [request setDidFailSelector:@selector(userInfoFailed:)];
    
    [request startAsynchronous];
    
}

-(void)userInfoReceived:(ASIHTTPRequest *)request{
   
    NSString *responseString = [[request responseString] stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];

    if (responseString.length == 0) {
        self.completed(NO,nil);
        return;
    }
    responseString = [[responseString substringToIndex:[responseString length]-1]substringFromIndex:1];
    
    NSArray *responseArray = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    self.user = responseArray.firstObject;
    
    self.completed(YES,responseString);
}

-(void)userInfoFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    self.completed(NO,nil);
}

#pragma mark - Follow

-(void)getLocalFollowersForUser:(NSString *)user_id WithCompletionBlock:(completed)compbloc{

    self.localFollowersCompleted= compbloc;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"followers-%@",user_id]];
    NSString *json =  [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSArray *users = [json objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    for (NSDictionary *user in users) {
        NSString *imagePath = [user objectForKey:@"image_path"];
        [[DTO sharedDTO]downloadImageFromURL:imagePath];
    }
    
    self.localFollowersCompleted(YES,users);


}

-(void)getLocalFollowingForUser:(NSString *)user_id WithCompletionBlock:(completed)compbloc{
    
    self.localFollowingCompleted= compbloc;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"following-%@",user_id]];
    NSString *json =  [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSArray *users = [json objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    for (NSDictionary *user in users) {
        NSString *imagePath = [user objectForKey:@"image_path"];
        [[DTO sharedDTO]downloadImageFromURL:imagePath];
    }
    
    self.localFollowingCompleted(YES,users);

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
    
    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Authorization" value:[self headerGETRequest:URL.absoluteString values:array]];
    
    [request setRequestMethod:@"GET"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(followersReceived:)];
    
    [request setDidFailSelector:@selector(followersFailed:)];
    
    [request startAsynchronous];

}


-(void)getFollowersWithCompletionBlock:(completed)compbloc{
    
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/followers/show"];
    
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/followers/show?"];
    
    NSDictionary *dict = [BPUser sharedBP].user;
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"user=%@",[[BPUser sharedBP].user objectForKey:@"id"]]];
    
    _userID = [[BPUser sharedBP].user objectForKey:@"id"];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    self.followers_completed = compbloc;

    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Authorization" value:[self headerGETRequest:URL.absoluteString values:array]];
    
    [request setRequestMethod:@"GET"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(followersReceived:)];
    
    [request setDidFailSelector:@selector(followersFailed:)];
    
    [request startAsynchronous];

}

-(void)followersReceived:(ASIHTTPRequest *)request{

    
    NSString *responseString = [request responseString];

    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"followers-%@",_userID]];
    NSError *error;
    BOOL success  = [responseString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];
    
    NSArray *users = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    for (NSDictionary *user in users) {
        NSString *imagePath = [user objectForKey:@"image_path"];
        [[DTO sharedDTO]downloadImageFromURL:imagePath];
    }
    
    self.followers_completed(YES,users);

}

-(void)followersFailed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
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
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Authorization" value:[self headerGETRequest:URL.absoluteString values:array]];
    
    [request setRequestMethod:@"GET"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(followingReceived:)];
    
    [request setDidFailSelector:@selector(followingFailed:)];
    
    [request startAsynchronous];
    
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
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Authorization" value:[self headerGETRequest:URL.absoluteString values:array]];
    
    [request setRequestMethod:@"GET"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(followingReceived:)];
    
    [request setDidFailSelector:@selector(followingFailed:)];
    
    [request startAsynchronous];
    
}

-(void)followingReceived:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"following-%@",_userID]];
    NSError *error;
    
    BOOL succeed = [responseString writeToFile:filePath
                                    atomically:YES encoding:NSUTF8StringEncoding error:&error];
    

    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];
    
    NSArray *users = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    self.following_completed(YES,users);
    
}

-(void)followingFailed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
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
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Authorization" value:[self headerGETRequest:URL.absoluteString values:array]];
    
    [request setRequestMethod:@"GET"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(isfollowingFinished:)];
    
    [request setDidFailSelector:@selector(isfollowingFailed:)];
    
    [request startAsynchronous];

}

-(void)isfollowingFinished:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    self.is_following_completed(YES,responseString);
}


-(void)isfollowingFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    self.is_following_completed(NO,nil);
    
}

-(void)follow:(NSString *)userID WithCompletionBlock:(completed)compbloc{
    
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/followers/create"];
    
    self.completed = compbloc;
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:URL];
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    [postValues addObject:[NSDictionary dictionaryWithObject:userID forKey:@"user"]];
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerPOSTRequest:URL.absoluteString values:postValues]];
    
    [request addPostValue:userID forKey:@"user"];
    
    [request setRequestMethod:@"POST"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(follow_user_Received:)];
    
    [request setDidFailSelector:@selector(follow_user_Failed:)];
    
    [request startAsynchronous];


}

-(void)follow_user_Received:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];
    
    self.completed(YES,nil);
    
}

-(void)follow_user_Failed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];
    
    self.completed(NO,nil);
}

-(void)unfollow:(NSString *)userID WithCompletionBlock:(completed)compbloc{
  
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/following/stop"];
    
    self.completed = compbloc;
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:URL];
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    [postValues addObject:[NSDictionary dictionaryWithObject:userID forKey:@"user"]];
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerPOSTRequest:URL.absoluteString values:postValues]];
    
    [request addPostValue:userID forKey:@"user"];
    
    [request setRequestMethod:@"POST"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(unfollow_user_Received:)];
    
    [request setDidFailSelector:@selector(unfollow_user_Failed:)];
    
    [request startAsynchronous];
    
}

-(void)unfollow_user_Received:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];
    
    self.completed(YES,nil);
    
}

-(void)unfollow_user_Failed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];
    
    self.completed(NO,nil);
}

#pragma mark - Notifications

-(void)getLocalNotifications:(completed)compbloc{
    
    self.localNotificationsCompleted= compbloc;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"notifications-%@",[[BPUser sharedBP].user objectForKey:@"id"]]];
    NSString *json =  [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    [self parseResponseString:json WithCompletionBlock:compbloc];
}

-(void)getNewNotificationsWithCompletionBlock:(completed)compbloc{
    
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/notification/show"];
    
    self.newNotificationsCompleted = compbloc;
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:URL];
    
    [request addRequestHeader:@"Authorization" value:[self headerGETRequest:URL.absoluteString values:nil]];
    
    [request setRequestMethod:@"GET"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(getNewNotificationsFinished:)];
    
    [request setDidFailSelector:@selector(getNewNotificationsFailed:)];
    
    [request startAsynchronous];

}

-(void)getNewNotificationsFinished:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    [self parseResponseString:responseString WithCompletionBlock:self.newNotificationsCompleted];
}

-(void)getNewNotificationsFailed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    self.newNotificationsCompleted(NO,nil);
}

-(void)parseResponseString:(NSString *)responseString WithCompletionBlock:(completed)compbloc{
    
    if (responseString == nil) {
        compbloc(NO,nil);
    }
    
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
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

        
        Activity_Object *notification = [Activity_Object modelObjectWithDictionary:activity_item];
        
        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:notification];
        [operationQueue addOperation:invocationOperation];
        
        [bs addObject:notification];
    }
    
    
    compbloc(YES,bs);
}

-(void)nextNotificationsWithCompletionBlock:(notifications_completed)compbloc{
    
    page_new ++;
    
    newNotifications = [NSMutableArray array];
    oldNotifications = [NSMutableArray array];
    newNotificationsFinished = NO;
    oldNotificationsFinished = NO;
    
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/notification/shownew"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/notification/shownew?"];
    
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"limit=%d",10]];
    [array addObject:[NSString stringWithFormat:@"page=%d",page_new]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    self.notifications_completed = compbloc;
    
    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Authorization" value:[self headerGETRequest:URL.absoluteString values:array]];
    
    [request setRequestMethod:@"GET"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(notificationsReceived:)];
    
    [request setDidFailSelector:@selector(notificationsFailed:)];
    
    [request startAsynchronous];
    
    [self nextOldNotificationsWithCompletionBlock:compbloc];
    
}


-(void)getNotificationsWithCompletionBlock:(notifications_completed)compbloc{
   
    page_new = 0;
    
    newNotifications = [NSMutableArray array];
    oldNotifications = [NSMutableArray array];
    newNotificationsFinished = NO;
    oldNotificationsFinished = NO;
    
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/notification/shownew"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/notification/shownew?"];
    
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"limit=%d",10]];
    [array addObject:[NSString stringWithFormat:@"page=%d",page_new]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }

    self.notifications_completed = compbloc;
    
    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Authorization" value:[self headerGETRequest:URL.absoluteString values:array]];
    
    [request setRequestMethod:@"GET"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(notificationsReceived:)];
    
    [request setDidFailSelector:@selector(notificationsFailed:)];
    
    [request startAsynchronous];
    
}

-(void)notificationsReceived:(ASIHTTPRequest *)request{
   
    NSString *responseString = [request responseString];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
    
    
    NSArray *notificationsArray = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
    
    NSMutableArray *bs = [NSMutableArray array];
    
    if (notificationsArray.count < 10) {
        newNotificationsFinished = YES;
        [self getOldNotificationsWithCompletionBlock:self.notifications_completed];
        return;
    }
    
    for (id b in notificationsArray) {
        
        NSDictionary *activity_item;
        
        if ([b isKindOfClass:[NSString class]]) {
            activity_item  = [b objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
        }
        else{
            activity_item = b;
        }
        
        Activity_Object *notification = [Activity_Object modelObjectWithDictionary:activity_item];
        
        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:notification];
        [operationQueue addOperation:invocationOperation];
        
        [bs addObject:notification];
    }
    
    newNotificationsFinished = YES;
    [newNotifications addObjectsFromArray:bs];
    
    if (newNotificationsFinished && oldNotificationsFinished) {
        self.notifications_completed(YES,newNotifications,oldNotifications);    
    }
}

-(void)notificationsFailed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];
    
    newNotificationsFinished = YES;
    
    if (page_new>0) {
        page_new--;
    }
    
    if (newNotificationsFinished && oldNotificationsFinished) {
        self.notifications_completed(YES,newNotifications,oldNotifications);
    }
}
#pragma mark - Old Notifications

-(void)nextOldNotificationsWithCompletionBlock:(notifications_completed)compbloc{
    
    page_old ++;
    
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/notification/showold?"];
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/notification/showold"];
    
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"limit=%d",10]];
    [array addObject:[NSString stringWithFormat:@"page=%d",page_old]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    
    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Authorization" value:[self headerGETRequest:URL.absoluteString values:array]];
    
    [request setRequestMethod:@"GET"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(oldNotificationsReceived:)];
    
    [request setDidFailSelector:@selector(oldNotificationsFailed:)];
    
    [request startAsynchronous];
}


-(void)getOldNotificationsWithCompletionBlock:(notifications_completed)compbloc{

    page_old = 0;
    
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/notification/showold?"];
    NSURL *URL = [NSURL URLWithString:@"https://api.beeeper.com/1/notification/showold"];
    
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"limit=%d",10]];
    [array addObject:[NSString stringWithFormat:@"page=%d",page_old]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }

    
    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Authorization" value:[self headerGETRequest:URL.absoluteString values:array]];
    
    [request setRequestMethod:@"GET"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(oldNotificationsReceived:)];
    
    [request setDidFailSelector:@selector(oldNotificationsFailed:)];
    
    [request startAsynchronous];
}

-(void)oldNotificationsReceived:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
    responseString = [responseString stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];

    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"notifications-%@",[[BPUser sharedBP].user objectForKey:@"id"]]];
    NSError *error;
    
    BOOL succeed = [responseString writeToFile:filePath
                                    atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
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
        
        Activity_Object *notification = [Activity_Object modelObjectWithDictionary:activity_item];
        
        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImage:) object:notification];
        [operationQueue addOperation:invocationOperation];
        
        [bs addObject:notification];
    }
    
    oldNotificationsFinished = YES;
    [oldNotifications addObjectsFromArray:bs];
    
    if (newNotificationsFinished && oldNotificationsFinished) {
        self.notifications_completed(YES,newNotifications,oldNotifications);
    }
}

-(void)oldNotificationsFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    oldNotificationsFinished = YES;
    
    if (page_old>0) {
        page_old--;
    }
    
    if (newNotificationsFinished && oldNotificationsFinished) {
       self.notifications_completed(YES,newNotifications,oldNotifications);
    }
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
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:URL];
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerPOSTRequest:URL.absoluteString values:postValues]];
    
    [request setRequestMethod:@"POST"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(getEmailSettings_Received:)];
    
    [request setDidFailSelector:@selector(getEmailSettings_Failed:)];
    
    [request startAsynchronous];

}

-(void)getEmailSettings_Received:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
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


-(void)getEmailSettings_Failed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
    //responseString = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DemoJSON" ofType:@""] encoding:NSUTF8StringEncoding error:NULL];
    
    self.getEmailSettingsCompleted(NO,nil);
}

-(void)setEmailSettings:(NSDictionary *)settingsDict WithCompletionBlock:(completed)compbloc{
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/user/setnotificationsettings"];
    
    self.setEmailSettingsCompleted = compbloc;
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    NSMutableArray *postValues = [NSMutableArray array];
    
    for (NSString *key in settingsDict.allKeys) {
        NSString *value = [settingsDict objectForKey:key];
        [postValues addObject:[NSDictionary dictionaryWithObject:value forKey:key]];
    }
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerPOSTRequest:requestURL.absoluteString values:postValues]];
    
    for (NSString *key in settingsDict.allKeys) {
        NSString *value = [settingsDict objectForKey:key];
        [request addPostValue:value forKey:key];
    }
    
    [request setRequestMethod:@"POST"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];

    
    [request setDidFinishSelector:@selector(setEmailSettings_Received:)];
    
    [request setDidFailSelector:@selector(setEmailSettings_Failed:)];
    
    [request startAsynchronous];

}

-(void)setEmailSettings_Received:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
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


-(void)setEmailSettings_Failed:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
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
    
    key = [NSString stringWithFormat:@"%@&%@",[self urlencode:[NSString stringWithFormat:@"%@",consumerSecret]],[self urlencode:[NSString stringWithFormat:@"%@",accessTokenSecret]]];
    
    NSString *encodedStr = [self encodeWithHmacsha1:[NSString stringWithFormat:@"GET&%@&%@",[self urlencode:link],[self urlencode:domain]] key:key];
    
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
    
    key = [NSString stringWithFormat:@"%@&%@",[self urlencode:[NSString stringWithFormat:@"%@",consumerSecret]],[self urlencode:[NSString stringWithFormat:@"%@",accessTokenSecret]]];
    
    NSString *encodedStr = [self encodeWithHmacsha1:[NSString stringWithFormat:@"POST&%@&%@",[self urlencode:link],[self urlencode:domain]] key:key];
    
    return encodedStr;
}


#pragma mark - Request Token

-(void)getRequestToken{
    
    oauth_nonce = [self random32CharacterString];
    oauth_nonce_accessToken = [self random32CharacterString];
    oauth_timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/oAuth/request_token.php"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    
    NSString *headerString = [NSString stringWithFormat:@"OAuth realm=\"\", xoauth_displayname=\"%@\", oauth_callback=\"%@\", oauth_signature_method=\"%@\", oauth_signature=\"%@\", oauth_nonce=\"%@\", oauth_timestamp=\"%@\", oauth_consumer_key=\"%@\", oauth_version=\"%@\"",xoauth_displayname,oauth_callback,oauth_signature_method,[self signature],oauth_nonce,oauth_timestamp,consumerKey,@"1.0"];
    
    NSLog(@"%@",signature);
    
    [request addRequestHeader:@"Authorization" value:headerString];
    [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(requestTokenReceived:)];
    
    [request setDidFailSelector:@selector(requestTokenFailed:)];
    
    [request startAsynchronous];
}

-(void)requestTokenReceived:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    
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

-(void)requestTokenFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    self.completed(NO,nil);
}

-(NSString *)signature{
    
    NSString *domain = @"https://api.beeeper.com/oAuth/request_token.php";
    NSString *unencodedStr = [NSString stringWithFormat:@"oauth_callback=%@&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_version=1.0&xoauth_displayname=%@",oauth_callback,consumerKey,oauth_nonce,oauth_signature_method,oauth_timestamp,xoauth_displayname];
    NSString *key;
    
    key = [NSString stringWithFormat:@"%@&",[self urlencode:[NSString stringWithFormat:@"%@",consumerSecret]]];
    
    NSString *encodedStr = [self encodeWithHmacsha1:[NSString stringWithFormat:@"POST&%@&%@",[self urlencode:domain],[self urlencode:unencodedStr]] key:key];
    
    signature = encodedStr;
    
    return encodedStr;
}

#pragma mark - Authorize

-(void)authorize{
    
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.beeeper.com/oAuth/authorize.php?oauth_token=%@",oauth_token]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Referer" value:@"test"];
    
    if (_fbid) {
        [request addPostValue:[self urlencode:[NSString stringWithFormat:@"%@",_fbid]] forKey:@"fbid"];
    }
    else if (_twitterid){
        [request addPostValue:[self urlencode:[NSString stringWithFormat:@"%@",_twitterid]] forKey:@"twid"];
    }
    else{
        [request addPostValue:_username forKey:@"username"];
        [request addPostValue:_password forKey:@"password"];
    }
    
    
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(authorizationReceived:)];
    
    [request setDidFailSelector:@selector(authorizationFailed:)];
    
    [request startAsynchronous];
}

-(void)authorizationReceived:(ASIHTTPRequest *)request{
    
    @try {
        NSString *responseString = [request responseString];
        verifier = [[responseString componentsSeparatedByString:@":"] lastObject];
        
        [self getAccessToken];
    }
    @catch (NSException *exception) {
        self.completed(NO,nil);
    }
    @finally {
        
    }
}

-(void)authorizationFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    NSLog(@"ERROR: %@",responseString);
    self.completed(NO,nil);
}

#pragma mark - Access Token

-(void)getAccessToken{
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/oAuth/access_token.php"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    oauth_timestamp_accessToken = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    
    NSString *headerString = [NSString stringWithFormat:@"OAuth realm=\"\", oauth_verifier=\"%@\", oauth_signature_method=\"%@\", oauth_signature=\"%@\", oauth_nonce=\"%@\", oauth_timestamp=\"%@\", oauth_token=\"%@\",oauth_consumer_key=\"%@\", oauth_version=\"%@\"",verifier,oauth_signature_method,[self accessTokenSignature],oauth_nonce_accessToken,oauth_timestamp_accessToken,oauth_token,consumerKey,@"1.0"];
    
    
    [request addRequestHeader:@"Authorization" value:headerString];
    [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(accessTokenReceived:)];
    
    [request setDidFailSelector:@selector(accessTokenFailed:)];
    
    [request startAsynchronous];
    
}

-(void)accessTokenReceived:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    
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

-(void)accessTokenFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    self.completed(NO,nil);
}

-(NSString *)accessTokenSignature{
    
    NSString *domain = @"https://api.beeeper.com/oAuth/access_token.php";
    NSString *unencodedStr = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_token=%@&oauth_verifier=%@&oauth_version=1.0",consumerKey,oauth_nonce_accessToken,oauth_signature_method,oauth_timestamp_accessToken,oauth_token,verifier];
    NSString *key;
    
    key = [NSString stringWithFormat:@"%@&%@",[self urlencode:[NSString stringWithFormat:@"%@",consumerSecret]],[self urlencode:[NSString stringWithFormat:@"%@",oauth_token_secret]]];
    
    NSString *encodedStr = [self encodeWithHmacsha1:[NSString stringWithFormat:@"POST&%@&%@",[self urlencode:domain],[self urlencode:unencodedStr]] key:key];
    
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

