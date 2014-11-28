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
    
    NSMutableDictionary *postValuesDict = [NSMutableDictionary dictionary];
    [postValuesDict setObject:[[DTO sharedDTO] urlencode:fingerprint] forKey:@"fingerprint"];
    [postValuesDict setObject:beeep_time forKey:@"beeep_time"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerPOSTRequest:requestURL.absoluteString values:[NSMutableArray arrayWithObject:postValuesDict]] forHTTPHeaderField:@"Authorization"];
    
    [postValuesDict setObject:fingerprint forKey:@"fingerprint"];
    
    [manager POST:requestURL.absoluteString parameters:postValuesDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self beeepCreateFinished:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        [self beeepCreateFailed:error.localizedDescription];
    }];


}

-(void)beeepCreateFinished:(id)request{
    NSString *responseString = request;
    
    
    @try {
        NSDictionary *dict = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
        if ([dict objectForKey:@"beeep"]) {
            
            //invalidate push
            [self invalidateBeeep:[dict objectForKey:@"beeep"]];
            self.completed(YES,dict);
        }
        else{
            
             [[DTO sharedDTO]addBugLog:@"[dict objectForKey:@beeep] == nil" where:@"BPCreate/beeepCreateFinished" json:responseString];
            
            NSDictionary *dict = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
            
            NSArray *errors = [dict objectForKey:@"errors"];
            
            NSDictionary *error = [errors firstObject];
            
            if (error != nil) {
                self.completed(NO,error);
            }

            
            
        }
    }
    @catch (NSException *exception) {
        
        [[DTO sharedDTO]addBugLog:@"catch" where:@"BPCreate/beeepCreateFinished" json:responseString];
        
        self.completed(NO,@"beeepCreateFinished Catch error");
    }
    @finally {
 
    }

}

-(void)beeepCreateFailed:(id)request{
  
    NSString *responseString = request;
    
    [[DTO sharedDTO]addBugLog:@"beeepCreateFailed" where:@"BPCreate/beeepCreateFailed" json:responseString];
    
    self.completed(NO,nil);
    
}

-(void)beeepDelete:(NSString *)fingerprint timestamp:(NSString *)timestamp weight:(NSString *)weight completionBlock:(completed)compbloc{

    self.completed = compbloc;
    
    NSString *postStr = [NSString stringWithFormat:@"{\"fingerprint\":\"%@\",\"timestamp\":\"%@\",\"weight\":\"%@\"}",fingerprint,timestamp,weight];
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/beeep/delete"];
    
    NSMutableDictionary *postValuesDict = [NSMutableDictionary dictionary];
    [postValuesDict setObject:postStr forKey:@"beeep"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerPOSTRequest:requestURL.absoluteString values:[NSMutableArray arrayWithObject:postValuesDict]] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:requestURL.absoluteString parameters:postValuesDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            
            NSString *responseString = [operation responseString];
            
            self.completed(([responseString rangeOfString:@"success"].location != NSNotFound),responseString);
        }
        @catch (NSException *exception) {
            self.completed(NO,nil);
        }
        @finally {
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *responseString = [operation responseString];
        self.completed(NO,nil);
    }];

}



-(void)eventCreate:(NSDictionary *)values completionBlock:(completed)compbloc{

    self.completed = compbloc;
    
    @try {

        valuesDict = [NSMutableDictionary dictionaryWithDictionary:values];
        
        NSArray *fingerprint_keys = [NSArray arrayWithObjects:@"title",@"timestamp",@"station", nil];
        //fingerprint -> title,timestamp,venue
       // NSMutableArray *array = [NSMutableArray array];
        NSMutableString *fingerPrint_Input = [[NSMutableString alloc]init];
        
        for (NSString *key in values.allKeys) {

            if ([fingerprint_keys indexOfObject:key] != NSNotFound) {
                NSString *value = [values objectForKey:key];
                NSLog(@"%@->%@",key,value );
                
                NSString *str = [NSString stringWithFormat:@"%@",[value lowercaseString]];
                [fingerPrint_Input appendString:str];
                //[array addObject:str];

            }
        }
        
        NSSortDescriptor * sortDesc = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
       // [array sortUsingDescriptors:[NSArray arrayWithObject:sortDesc]];
        
        id fingerprint = [self encodeWithHmacsha256:fingerPrint_Input];
        
        fingerprint = [self base64forData:[fingerprint dataUsingEncoding:NSUTF8StringEncoding]];
        
        [valuesDict setObject:[[DTO sharedDTO] urlencode:fingerprint] forKey:@"fingerprint"];
        
        NSURL *requestURL = [NSURL URLWithString:@"https://api.beeeper.com/1/event/create"];
        
        NSMutableArray *postValues = [[NSMutableArray alloc]init];
        NSMutableDictionary *postValuesDict = [NSMutableDictionary dictionary];
        
        [postValues addObject:[NSDictionary dictionaryWithObject:[[DTO sharedDTO] urlencode:fingerprint] forKey:@"fingerprint"]];
        [postValuesDict setObject:fingerprint forKey:@"fingerprint"];

        for (NSString *key in values.allKeys) {
            
            if ([key isEqualToString:@"title"] || [key isEqualToString:@"station"]) {
                NSString *title = [[DTO sharedDTO] urlencode:[values objectForKey:key]];
                
                [postValues addObject:[NSDictionary dictionaryWithObject:[[DTO sharedDTO] urlencode:title] forKey:key]];
                [postValuesDict setObject:title forKey:key];

            }
            else{
                [postValues addObject:[NSDictionary dictionaryWithObject:[[DTO sharedDTO] urlencode:[values objectForKey:key]] forKey:key]];
                [postValuesDict setObject:[values objectForKey:key] forKey:key];
            }
        }
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [manager.requestSerializer setValue:[[BPUser sharedBP] headerPOSTRequest:requestURL.absoluteString values:postValues] forHTTPHeaderField:@"Authorization"];
        
        [manager POST:requestURL.absoluteString parameters:postValuesDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self eventCreateFinished:[operation responseString]];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSString *responseString = [operation responseString];
            [self eventCreateFailed:[operation responseString]];
        }];


    }
    @catch (NSException *exception) {
        self.completed(NO,@"eventCreate CATCH");
    }
    @finally {
        
    }
}

-(void)eventCreateFinished:(id)request{
    
    NSString *responseString = request;
    
    @try {
        NSDictionary *dict = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
        
        if ([[dict allKeys] containsObject:@"errors"]) {
          
             [[DTO sharedDTO]addBugLog:@"errors" where:@"BPCreate/eventCreateFinished" json:responseString];
           
            @try {
                NSDictionary *errorDict = [[dict objectForKey:@"errors"] firstObject];
                
                self.completed(NO,[errorDict objectForKey:@"message"]);
   
            }
            @catch (NSException *exception) {
                
                self.completed(NO,nil);

            }
            @finally {
                
            }
            return;
        }
        
        NSString *imgUrl = [dict objectForKey:@"image_url"];
        imgUrl = [[DTO sharedDTO] urlencode:imgUrl];
        
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
        self.completed(NO,@"Event could not be created. Please try again");
    }
    @finally {
    
    }
}

-(void)eventCreateFailed:(id)request{

    NSString *responseString = request;

    [[DTO sharedDTO]addBugLog:@"eventCreateFailed" where:@"BPCreate/eventCreateFailed" json:responseString];
    
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
    
    NSMutableDictionary *postValues = [[NSMutableDictionary alloc]init];
    
    [postValues setObject:[NSString stringWithFormat:@"1"] forKey:@"invalidatePUSH"];
    [postValues setObject:weight forKey:@"beeep_id"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerPOSTRequest:requestURL.absoluteString values:[NSMutableArray arrayWithObject:postValues]] forHTTPHeaderField:@"Authorization"];
    
    [manager POST:requestURL.absoluteString parameters:@{@"invalidatePUSH":@"1",@"beeep_id":weight} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self invalidateFinished:[operation responseString]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *responseString = [operation responseString];
        [self invalidateFailed:[operation responseString]];
    }];

}

-(void)invalidateFinished:(id)request{
    NSString *responseString = request;

}

-(void)invalidateFailed:(id)request{
    NSString *responseString = request;
    
}

- (NSString*)base64forData:(NSData*)theData {
    
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    
    NSInteger i,i2;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        for (i2=0; i2<3; i2++) {
            value <<= 8;
            if (i+i2 < length) {
                value |= (0xFF & input[i+i2]);
            }
        }
        
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
}


@end
