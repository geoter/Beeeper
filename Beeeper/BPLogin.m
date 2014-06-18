//
//  BPLogin.m
//  BeeeperOAuth
//
//  Created by George Termentzoglou on 2/26/14.
//  Copyright (c) 2014 George Termentzoglou. All rights reserved.
//

#import "BPLogin.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>
#import "Base64Transcoder.h"

@interface BPLogin ()
{
    NSString *_username;
    NSString *_password;
    NSString *_fbid;
    
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
}

@end

@implementation BPLogin

static NSString *consumerKey = @"14ed757eefb1a284ba6f3e7e9989ec87052429ce1";
static NSString *consumerSecret = @"e92496b00f2abc454891c8d3c54017b8";

static BPLogin *thisWebServices = nil;

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
    }
    return(self);
    
    
}

+ (BPLogin *)sharedBPLogin{
    
    if (thisWebServices != nil) {
        return thisWebServices;
    }
    else{
        return [[BPLogin alloc]init];
    }
    
    return nil;
}

-(void)loginFacebookUser:(NSString *)fbid completionBlock:(completed)compbloc{
    
    _fbid = fbid;
    self.completed = compbloc;
    [self getRequestToken];
}

-(void)loginUser:(NSString *)username password:(NSString *)password completionBlock:(completed)compbloc{
    
    _username = username;
    _password = password;
    
    self.completed = compbloc;
    [self getRequestToken];
}

-(void)getUser{
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/user/verify"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Authorization" value:[self headerGETRequest:requestURL.absoluteString]];

    [request setRequestMethod:@"GET"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(userInfoReceived:)];
    
    [request setDidFailSelector:@selector(userInfoFailed:)];
    
    [request startAsynchronous];

}

-(void)userInfoReceived:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    self.completed(YES,responseString);
}

-(void)userInfoFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
}

#pragma mark - GET POST requests

-(NSString *)headerGETRequest:(NSString *)link{
    
    NSURL *requestURL = [NSURL URLWithString:link];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *nonce = [self random32CharacterString];
    
    NSString *headerString = [NSString stringWithFormat:@"OAuth realm=\"\", oauth_signature_method=\"%@\", oauth_signature=\"%@\", oauth_nonce=\"%@\", oauth_timestamp=\"%@\", oauth_token=\"%@\",oauth_consumer_key=\"%@\", oauth_version=\"%@\"",oauth_signature_method,[self GETRequestSignature:link timeStamp:timestamp nonce:nonce],nonce,timestamp,accessToken,consumerKey,@"1.0"];
    
    return headerString;

}

-(NSString *)GETRequestSignature:(NSString *)link timeStamp:(NSString *)timestamp nonce:(NSString *)nonce{
    
    NSString *domain = link;
    NSString *unencodedStr = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_token=%@&oauth_version=1.0",consumerKey,nonce,oauth_signature_method,timestamp,accessToken];
    NSString *key;
    
    key = [NSString stringWithFormat:@"%@&%@",[self urlencode:[NSString stringWithFormat:@"%@",consumerSecret]],[self urlencode:[NSString stringWithFormat:@"%@",accessTokenSecret]]];
    
    NSString *encodedStr = [self encodeWithHmacsha1:[NSString stringWithFormat:@"GET&%@&%@",[self urlencode:domain],[self urlencode:unencodedStr]] key:key];
    
    return encodedStr;
}


#pragma mark - Request Token

-(void)getRequestToken{
    
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
        [request addPostValue:_fbid forKey:@"fbid"];
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
