//
//  BPCreate.m
//  Beeeper
//
//  Created by George on 5/22/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "BPCreate.h"
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonDigest.h>
#import "Base64Transcoder.h"

@implementation BPCreate
static BPCreate *thisWebServices = nil;

-(id)init{
    self = [super init];
    if(self) {
        thisWebServices = self;
        operationQueue = [[NSOperationQueue alloc] init];
    }
    return(self);
}

+ (BPCreate *)sharedBP{
    
    if (thisWebServices != nil) {
        return thisWebServices;
    }
    else{
        return [[BPCreate alloc]init];
    }
    
    return nil;
}



-(void)beeepCreate:(NSString *)fingerprint beeep_time:(NSString *)beeep_time completionBlock:(completed)compbloc{
   
    self.completed = compbloc;
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/beeep/create"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    NSMutableDictionary *postValues = [[NSMutableDictionary alloc]init];

    [postValues setObject:[self urlencode:fingerprint] forKey:@"fingerprint"];
    [postValues setObject:beeep_time forKey:@"beeep_time"];
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerPOSTRequest:requestURL.absoluteString values:[NSMutableArray arrayWithObject:postValues]]];
    
    [request addPostValue:fingerprint forKey:@"fingerprint"];
    [request addPostValue:beeep_time forKey:@"beeep_time"];
    
    [request setRequestMethod:@"POST"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(beeepCreateFinished:)];
    
    [request setDidFailSelector:@selector(beeepCreateFailed:)];
    
    [request startAsynchronous];

}

-(void)beeepCreateFinished:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    
    
    @try {
        NSDictionary *dict = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
        if ([dict objectForKey:@"beeep"]) {
            
            //invalidate push
            [self invalidateBeeep:[dict objectForKey:@"beeep"]];
            self.completed(YES,dict);
        }
        else{
            
            NSDictionary *dict = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
            
            NSArray *errors = [dict objectForKey:@"errors"];
            
            NSDictionary *error = [errors firstObject];
            
            if (error != nil) {
                self.completed(NO,error);
            }

            
            
        }
    }
    @catch (NSException *exception) {
        self.completed(NO,@"beeepCreateFinished Catch error");
    }
    @finally {
 
    }

}

-(void)beeepCreateFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    
    self.completed(NO,nil);
    
}

-(void)beeepDelete:(NSString *)fingerprint timestamp:(NSString *)timestamp weight:(NSString *)weight completionBlock:(completed)compbloc{

    self.completed = compbloc;
    
    NSString *postStr = [NSString stringWithFormat:@"{\"fingerpring\":\"%@\",\"timestamp\":\"%@\",\"weight\":\"%@\"}",fingerprint,timestamp,weight];
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/beeep/delete"];
    
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    NSMutableDictionary *postValues = [[NSMutableDictionary alloc]init];
    
    [postValues setObject:[self urlencode:postStr] forKey:@"beeep"];
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerPOSTRequest:requestURL.absoluteString values:[NSMutableArray arrayWithObject:postValues]]];
    
    [request addPostValue:postStr forKey:@"beeep"];
    
    [request setRequestMethod:@"POST"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];

    [request setCompletionBlock:^{
        
        @try {
            
            NSString *responseString = [request responseString];
            NSArray *beeepers = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
            
            self.completed(YES,beeepers);
        }
        @catch (NSException *exception) {
            self.completed(NO,nil);
        }
        @finally {
            
        }
        
    }];
    
    [request setFailedBlock:^{
        NSString *responseString = [request responseString];
        self.completed(NO,nil);
    }];

    
    [request startAsynchronous];

}



-(void)eventCreate:(NSDictionary *)values completionBlock:(completed)compbloc{

    self.completed = compbloc;
    
    @try {

        valuesDict = [NSMutableDictionary dictionaryWithDictionary:values];
        
        NSArray *fingerprint_keys = [NSArray arrayWithObjects:@"title",@"timestamp",@"station", nil];
        //fingerprint -> title,timestamp,venue
        NSMutableArray *array = [NSMutableArray array];
        NSMutableString *fingerPrint_Input = [[NSMutableString alloc]init];
        
        for (NSString *key in values.allKeys) {

            if ([fingerprint_keys indexOfObject:key] != NSNotFound) {
                NSString *value = [values objectForKey:key];
                NSLog(@"%@->%@",key,value );
                NSString *str = [NSString stringWithFormat:@"%@",[value lowercaseString]];
                [fingerPrint_Input appendString:str];
                [array addObject:str];
            }
        }
        
        NSSortDescriptor * sortDesc = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
        [array sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
        
        id fingerprint = [self encodeWithHmacsha256:fingerPrint_Input];
        
        [valuesDict setObject:[self urlencode:fingerprint] forKey:@"fingerprint"];
        
        NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/event/create"];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
        
        NSMutableArray *postValues = [[NSMutableArray alloc]init];
        
        [postValues addObject:[NSDictionary dictionaryWithObject:[self urlencode:fingerprint] forKey:@"fingerprint"]];

        for (NSString *key in values.allKeys) {
                [postValues addObject:[NSDictionary dictionaryWithObject:[self urlencode:[values objectForKey:key]] forKey:key]];
                [request setPostValue:[values objectForKey:key] forKey:key];
        }
        
        [request setPostValue:fingerprint forKey:@"fingerprint"];
        
        [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerPOSTRequest:requestURL.absoluteString values:postValues]];
        
        [request setRequestMethod:@"POST"];
        
        [request setTimeOutSeconds:7.0];
        
        [request setDelegate:self];
        
        [request setDidFinishSelector:@selector(eventCreateFinished:)];
        
        [request setDidFailSelector:@selector(eventCreateFailed:)];
        
        [request startAsynchronous];

    }
    @catch (NSException *exception) {
        self.completed(NO,@"eventCreate CATCH");
    }
    @finally {
        
    }
}

-(void)eventCreateFinished:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    
    @try {
        NSDictionary *dict = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
        
        if ([[dict allKeys] containsObject:@"errors"]) {
            self.completed(NO,nil);
            return;
        }
        
        NSString *imgUrl = [dict objectForKey:@"image_url"];
        imgUrl = [self urlencode:imgUrl];
        
        NSString *imageURL = [valuesDict objectForKey:@"image_url"];
        [valuesDict setObject:[dict objectForKey:@"fingerprint"] forKey:@"fingerprint"];
        [valuesDict setObject:[dict objectForKey:@"title"] forKey:@"title"];
        
        if (![imageURL isEqualToString:imgUrl]) {//event already exists
            self.completed(YES,@[valuesDict,@"The event you are trying to create already exists with a different photo."]);
        }
        else{
            self.completed(YES,valuesDict);
        }
    }
    @catch (NSException *exception) {
        self.completed(YES,@"eventCreateFinished CATCH");
    }
    @finally {
    
    }
}

-(void)eventCreateFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];

    self.completed(NO,@"eventCreateFailed");
}

- (id)encodeWithHmacsha256:(NSString *)data
{
//    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
//    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
//    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
//    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
//    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];

    unsigned char hashedCharacters[CC_SHA256_DIGEST_LENGTH];
    NSMutableData *passwordData = [[data dataUsingEncoding: NSUTF8StringEncoding] mutableCopy];
    
    CC_SHA256([passwordData bytes], [passwordData length], hashedCharacters);
    
    NSData *pwHashData = [[NSData alloc] initWithBytes:hashedCharacters length: sizeof hashedCharacters];
    NSString *base64String = [pwHashData base64EncodedStringWithOptions:0];
    
    return base64String;
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

-(void)invalidateBeeep:(NSString *)weight{
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/invalidate/push"];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    NSMutableDictionary *postValues = [[NSMutableDictionary alloc]init];
    
    [postValues setObject:[NSString stringWithFormat:@"1"] forKey:@"invalidatePUSH"];
    [postValues setObject:weight forKey:@"beeep_id"];
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerPOSTRequest:requestURL.absoluteString values:[NSMutableArray arrayWithObject:postValues]]];
    
    [request addPostValue:[NSString stringWithFormat:@"1"] forKey:@"invalidatePUSH"];
    [request addPostValue:weight forKey:@"beeep_id"];
    
    [request setRequestMethod:@"POST"];
    
    [request setTimeOutSeconds:7.0];
    
    [request setDelegate:self];
    
    [request setDidFinishSelector:@selector(invalidateFinished:)];
    
    [request setDidFailSelector:@selector(invalidateFailed:)];
    
    [request startAsynchronous];

}

-(void)invalidateFinished:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];

}

-(void)invalidateFailed:(ASIHTTPRequest *)request{
    NSString *responseString = [request responseString];
    
}

@end
