//
//  DTO.m
//  TruckBird
//
//  Created by George Termentzoglou on 7/4/13.
//  Copyright (c) 2013 George Termentzoglou. All rights reserved.
//

#import "DTO.h"
#import "Beeep_Object.h"

static DTO *thisDTO = nil;

@interface DTO ()
{
    NSOperationQueue *operationQueue;
    NSMutableArray *pendingUrls;
}
@property(nonatomic,strong) NSString *notifBeeepID;
@end

@implementation DTO


-(id)init{
    self = [super init];
    if(self) {
        thisDTO = self;
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 3;
        pendingUrls = [NSMutableArray array];
    }
    return(self);
    
    
}

+ (DTO *)sharedDTO{
    
    if (thisDTO != nil) {
        return thisDTO;
    }
    else{
        return [[DTO alloc]init];
    }
    
    return nil;
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


- (void)downloadImageFromURL:(NSString *)url{
    
    if ([pendingUrls indexOfObject:url] == NSNotFound) {
        [pendingUrls addObject:url];
        
        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImageInBackgroundFromURL:) object:url];
        [operationQueue addOperation:invocationOperation];
    }
}

-(void)downloadImageInBackgroundFromURL:(NSString *)url{

   // NSString *extension = [[url.lastPathComponent componentsSeparatedByString:@"."] lastObject];
    
    NSString *imageName = [NSString stringWithFormat:@"%@",[url MD5]];
    
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
        UIImage * result;
        NSData * localData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[DTO sharedDTO]fixLink:url]]];
        result = [UIImage imageWithData:localData];
        [self saveImage:result withFileName:imageName inDirectory:localPath];
        
        [pendingUrls removeObject:url];
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

- (NSString *)fixLink:(NSString *)link{
   
    @try {
        
        link = [link stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        
        if ([[link substringToIndex:2]isEqualToString:@"//"]) {
            NSString *fixedLink = [NSString stringWithFormat:@"http://%@",[link substringFromIndex:2]];
            return fixedLink;
        }
        return link;

    }
    @catch (NSException *exception) {
         return link;
    }
    @finally {
        
    }
}

- (void)setNotificationBeeepID:(NSString *)beeep_id{
    self.notifBeeepID = beeep_id;
}
    
- (NSString *)getNotificationBeeepID{
    return self.notifBeeepID;
}

-(void)getBeeep:(NSString *)beeep_id WithCompletionBlock:(completed)compbloc{
    
    NSMutableString *URL = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/beeep/show"];
    NSMutableString *URLwithVars = [[NSMutableString alloc]initWithString:@"https://api.beeeper.com/1/beeep/show?"];
    
    NSString *fingerprint;
    
    NSString *my_id = [[BPUser sharedBP].user objectForKey:@"id"];
    
    fingerprint = beeep_id;
    
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:[NSString stringWithFormat:@"beeep_id=%@",fingerprint]];
    [array addObject:[NSString stringWithFormat:@"user=%@",my_id]];
    
    for (NSString *str in array) {
        [URLwithVars appendFormat:@"%@",str];
        
        if (str != array.lastObject) {
            [URLwithVars appendString:@"&"];
        }
    }
    
    NSURL *requestURL = [NSURL URLWithString:URLwithVars];
    
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:requestURL];
    
    [request addRequestHeader:@"Authorization" value:[[BPUser sharedBP] headerGETRequest:URL values:array]];
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    [request setRequestMethod:@"GET"];
    
    //[request addPostValue:[info objectForKey:@"sex"] forKey:@"sex"];
    
    [request setTimeOutSeconds:13.0];
    
    [request setDelegate:self];
    
    //[[request UserInfo]setObject:info forKey:@"info"];
    
    [request setCompletionBlock:^{
        
        @try {
            
            NSString *responseString = [request responseString];
            id eventObject = [responseString objectFromJSONStringWithParseOptions:JKParseOptionUnicodeNewlines];
            
            NSArray *eventArray;
            
            if ([eventObject isKindOfClass:[NSDictionary class]]) {
                Beeep_Object *beeep = [Beeep_Object modelObjectWithDictionary:eventObject];
                compbloc(YES,beeep);
                
            }
            else if ([eventObject isKindOfClass:[NSArray class]]){
                eventArray = eventObject;
                Beeep_Object *beeep = [Beeep_Object modelObjectWithDictionary:[eventArray firstObject]];
                compbloc(YES,beeep);
            }
            else{
                compbloc(NO,[NSString stringWithFormat:@"DTO Beeepfinished but failed: %@",responseString]);
            }

        }
        @catch (NSException *exception) {
            compbloc(NO,nil);
        }
        @finally {
            
        }
        
    }];
    
    [request setFailedBlock:^{
        NSString *responseString = [request responseString];
        compbloc(NO,nil);
    }];
    
    [request startAsynchronous];
    
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
