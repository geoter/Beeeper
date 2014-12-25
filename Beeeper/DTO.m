//
//  DTO.m
//  TruckBird
//
//  Created by George Termentzoglou on 7/4/13.
//  Copyright (c) 2013 George Termentzoglou. All rights reserved.
//

#import "DTO.h"
#import "Beeep_Object.h"
#import "BPSuggestions.h"
#import "UIImage+StackBlur.h"

static DTO *thisDTO = nil;

@interface DTO ()
{
    NSOperationQueue *operationQueue;
    NSMutableArray *pendingUrls;
    
    BOOL wasInternetReachable;
    
    int notificationsBadge;
}
@end

@implementation DTO
@synthesize databaseName,databasePath;

-(id)init{
    self = [super init];
    if(self) {
        thisDTO = self;
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 3;
        pendingUrls = [NSMutableArray array];
        
        //get device locale if no language selected,Default for GR,EN is english
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentDir = [documentPaths objectAtIndex:0];
        
        self.databaseName = @"beeeper_log.sqlite3";
        
        self.databasePath = [documentDir stringByAppendingPathComponent:[NSString stringWithFormat:@"beeeper_log.sqlite3"]];
        
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

-(NSString *)sigmaTelikoCorrection:(NSString *)originalString{
   
    NSError *error = NULL;
    NSRegularExpressionOptions regexOptions = 0;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"σ\\s" options:regexOptions error:&error];
    
    if (error)
    {
        NSLog(@"Couldn't create regex with given string and options");
    }
    
    NSRange range = NSMakeRange(0, originalString.length);
    NSString *afterText = [regex stringByReplacingMatchesInString:originalString options:0 range:range withTemplate:@"ς "];
    
    NSString *lastChar = [afterText substringFromIndex:[afterText length] - 1];
    
    if([lastChar isEqualToString:@"σ"]){
       NSRange lastComma = [afterText rangeOfString:lastChar options:NSBackwardsSearch];
        
        if(lastComma.location != NSNotFound) {
            afterText = [afterText stringByReplacingCharactersInRange:lastComma
                                               withString:@"ς"];
        }
    }
    return afterText;

}

- (NSString *)urlencode:(NSString *)str {
    CFStringRef safeString =
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef)str,
                                            NULL,
                                            CFSTR("/%&=?$#+-~@<>|\*,()[]{}^!:;'"),
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

- (void)setApplicationBadge:(int)number{
    
    if (number == 0) {
//        self.suggestionBadgeNumber = 0;
        notificationsBadge = 0;
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:number];
}

- (void)saveSuggestionsBadge:(int)number{

    [[NSNotificationCenter defaultCenter]postNotificationName:@"SuggestionsBadgeUpdated" object:nil];
    
    self.suggestionBadgeNumber = number;
   
    [self setApplicationBadge:notificationsBadge];
    //    [self setApplicationBadge:self.suggestionBadgeNumber+notificationsBadge];
}


- (void)saveNotificationsBadge:(int)number{
    
    notificationsBadge = number;

    [self setApplicationBadge:notificationsBadge];
    
    //[self setApplicationBadge:self.suggestionBadgeNumber+notificationsBadge];
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
        NSLog(@"%@",link);
        
        return link;

    }
    @catch (NSException *exception) {
         return link;
    }
    @finally {
        
    }
}

- (void)setDeeepLinkEventFingerprint:(NSString *)fingerprint{
  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:@"Settings.plist"];
    NSMutableDictionary *mySettingsPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:finalPath];
    
    if (fingerprint) {
        [mySettingsPlist setObject:fingerprint forKey:@"deepLinkingEvent"];
        [mySettingsPlist writeToFile:finalPath atomically: YES];
    }
    else{
        [mySettingsPlist removeObjectForKey:@"deepLinkingEvent"];
        [mySettingsPlist writeToFile:finalPath atomically: YES];
    }
}

- (NSString *)getDeeepLinkEventFingerprint{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:@"Settings.plist"];
    NSMutableDictionary *mySettingsPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:finalPath];
    
    @try {
        NSString *beeep = [mySettingsPlist objectForKey:@"deepLinkingEvent"];
        return beeep;
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
        
    }
}

#pragma mark - PUSH Notifications

- (void)setNotificationBeeepID:(NSString *)beeep_id{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:@"Settings.plist"];
    NSMutableDictionary *mySettingsPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:finalPath];
    
    if (beeep_id) {
       [mySettingsPlist setObject:beeep_id forKey:@"beeep_push"];
        [mySettingsPlist writeToFile:finalPath atomically: YES];
    }
    else{
        [mySettingsPlist removeObjectForKey:@"beeep_push"];
        [mySettingsPlist writeToFile:finalPath atomically: YES];
    }
    
}
    
- (NSString *)getNotificationBeeepID{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:@"Settings.plist"];
    NSMutableDictionary *mySettingsPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:finalPath];
   
    @try {
        NSString *beeep = [mySettingsPlist objectForKey:@"beeep_push"];
        return beeep;
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
        
    }
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
    
    //email,name,lastname,timezone,password,city,state,country,sex
    //fbid,twid,active,locked,lastlogin,image_path,username
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager.requestSerializer setValue:[[BPUser sharedBP] headerGETRequest:URL values:array] forHTTPHeaderField:@"Authorization"];
    
    [manager GET:URLwithVars parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @try {
            
            NSString *responseString = [operation responseString];
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
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",operation);
        NSString *responseString = [operation responseString];
        compbloc(NO,nil);
    }];

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

#pragma mark - Database

/*-(void)uploadBugFile{
    
     [self createAndCheckDatabase];

    NSString *appFile = databasePath;
    
    NSURL *url = [NSURL URLWithString:@"https://api.elasticemail.com/attachments/upload"];
    
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];

    [request addPostValue:@"5c718e43-3ceb-47d5-ad45-fc9f8ad86d6d" forKey:@"username"];
    [request addPostValue:@"5c718e43-3ceb-47d5-ad45-fc9f8ad86d6d" forKey:@"api_key"];
    [request addPostValue:@"hello@beeeper.com" forKey:@"from"];
    [request addPostValue:@"Beeeper" forKey:@"from_name"];
    [request addPostValue:@"georgeterme@gmail.com;" forKey:@"to"];
    [request addPostValue:appFile forKey:@"file"];
    [request setFile:appFile forKey:@"file"];
    
    [request setCompletionBlock:^{
    
        NSString *responseString = [request responseString];
        
        if ([responseString rangeOfString:@"error"].location != NSNotFound) {
            [[TabbarVC sharedTabbar]showAlert:@"Bug Log Failed" text:@"Uploading failed"];
        }
        else{
            [self sendBugLog:responseString];
        }
        
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        
        [[TabbarVC sharedTabbar]showAlert:@"Bug Log Failed" text:@"error.localizedDescription"];
        
        NSLog(@"Upload Error: %@", error.localizedDescription);
    }];
    
    [request startAsynchronous];
        
}

- (void)sendBugLog:(NSString *)responseString{
    
    NSURL *url = [NSURL URLWithString:@"https://api.elasticemail.com/mailer/send"];
    
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request addPostValue:@"5c718e43-3ceb-47d5-ad45-fc9f8ad86d6d" forKey:@"username"];
    [request addPostValue:@"5c718e43-3ceb-47d5-ad45-fc9f8ad86d6d" forKey:@"api_key"];
    [request addPostValue:@"hello@beeeper.com" forKey:@"from"];
    [request addPostValue:@"Beeeper" forKey:@"from_name"];
    [request addPostValue:@"Bugs Report iOS" forKey:@"subject"];
    [request addPostValue:@"This is a bugs report sent from the app." forKey:@"body_text"];
    [request addPostValue:@"georgeterme@gmail.com" forKey:@"to"];
    [request addPostValue:responseString forKey:@"attachments"];
    
    
    [request setCompletionBlock:^{
        
        NSString *responseString = [request responseString];
        
        [[TabbarVC sharedTabbar]showAlert:@"Bus Log sent" text:@"Thank you for your feedback! We hope you will not need to use this feature again!"];
        
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        
        [[TabbarVC sharedTabbar]showAlert:@"Bug Log Failed" text:@"error.localizedDescription"];
        
        NSLog(@"Upload Error: %@", error.localizedDescription);
    }];
    
    [request startAsynchronous];
}*/

- (BOOL)addBugLog:(NSString *)what where:(NSString *)where json:(NSString *)json{

    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if(status == NotReachable && wasInternetReachable)
    {
      wasInternetReachable = NO;
      [[TabbarVC sharedTabbar]showAlert:@"No Internet Connection or Connection Lost/Weak" text:@"Please make sure you are connected to the Internet."];
        return NO;
    }
    else{
        wasInternetReachable = YES;
    }
    
    return YES;
    
    NSLog(@"ADDED BUGGG!!!!!!!!!!!!!!!!: %@-%@-%@",what,where,json);
    
    FMDatabase *db = [self getDatabase];
    
    NSMutableString *query = [NSMutableString stringWithString:@"INSERT INTO errors ("];
    
    //insert only those on table
    NSString *tableColumnsSQL = [NSString stringWithFormat:@"pragma table_info('errors')"];
    FMResultSet *columns = [db executeQuery:tableColumnsSQL];
    
    while ([columns next]) {
        NSDictionary *dict = [columns resultDictionary];
        [query appendFormat:@"'%@',",[dict objectForKey:@"name"]];
    }
    
    [query deleteCharactersInRange:NSMakeRange(query.length-1, 1)];
    [query appendString:@") VALUES ("];
    
    [query appendFormat:@"%f,",[[NSDate date] timeIntervalSince1970]];
    [query appendFormat:@"'%@',",what];
    [query appendFormat:@"'%@',",where];
    [query appendFormat:@"'%@',",([json isKindOfClass:[NSString class]] && json != nil)?json:@""];
    
    NSString *model = [[UIDevice currentDevice] model];
    NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
    
    [query appendFormat:@"'%@',",model];
    [query appendFormat:@"'%@'",iOSVersion];
    [query appendString:@");"];
    
    BOOL success =  [db executeUpdate:query,nil];
    
    [db close];

    return success;
}

-(FMDatabase *)getDatabase{
    
    [self createAndCheckDatabase];
    
    FMDatabase *db = [FMDatabase databaseWithPath:databasePath];
    
    [db open];
    
    return db;
}

-(void) createAndCheckDatabase
{
    BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:databasePath];
    
    if(success) return;
    
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseName];
    
    [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
}

#pragma mark -  Suggestions

-(void)getSuggestions{
    
    [[BPSuggestions sharedBP]getSuggestionsBadgeWithCompletionBlock:^(BOOL completed,id count){
        if (completed) {
            self.suggestionBadgeNumberFinished = YES;
            [[DTO sharedDTO]saveSuggestionsBadge:[count intValue]];
        }
    }];
    
    [self performSelector:@selector(getSuggestions) withObject:nil afterDelay:10];
}

-(void)clearSuggestions{
    
    [[BPSuggestions sharedBP]clearSuggestionsBadgeWithCompletionBlock:^(BOOL completed,id count){
        if (completed) {
            
            [[DTO sharedDTO]saveSuggestionsBadge:0];
            
            self.suggestionBadgeNumberFinished = YES;
            
        }
    }];

}


-(UIImage *)convertViewToBlurredImage:(UIView *)view withRadius: (CGFloat)blurRadius{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *blurredImg = [image stackBlur:blurRadius];
    return blurredImg;
}

#pragma mark - Notifications

- (void)setWeightForPush:(NSString *)weight caseStr:(NSString *)caseStr{
  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:@"Settings.plist"];
    NSMutableDictionary *mySettingsPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:finalPath];
    
    if (weight) {
       
        [mySettingsPlist setObject:weight forKey:@"WeightPush"];
        [mySettingsPlist setObject:caseStr forKey:@"WeightPushCase"];
        [mySettingsPlist writeToFile:finalPath atomically: YES];
        
        [self setFingerprintForPush:nil caseStr:nil];
        [self setUserIDforPush:nil];
    }
    else{
        [mySettingsPlist removeObjectForKey:@"WeightPush"];
        [mySettingsPlist removeObjectForKey:@"WeightPushCase"];
        [mySettingsPlist writeToFile:finalPath atomically: YES];
    }
}

- (NSDictionary *)getWeightAndCaseForPush{
  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:@"Settings.plist"];
    NSMutableDictionary *mySettingsPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:finalPath];
    
    @try {
        NSString *fingerprint = [mySettingsPlist objectForKey:@"WeightPush"];
        NSString *caseStr = [mySettingsPlist objectForKey:@"WeightPushCase"];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[fingerprint,caseStr] forKeys:@[@"WeightPush",@"WeightPushCase"]];
        
        return dict;
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
        
    }
}

- (void)setFingerprintForPush:(NSString *)fingerprint caseStr:(NSString *)caseStr{
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:@"Settings.plist"];
    NSMutableDictionary *mySettingsPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:finalPath];
    
    if (fingerprint) {
        [mySettingsPlist setObject:fingerprint forKey:@"FingerprintPush"];
        [mySettingsPlist setObject:caseStr forKey:@"FingerprintPushCase"];
        [mySettingsPlist writeToFile:finalPath atomically: YES];
        
        [self setWeightForPush:nil caseStr:nil];
        [self setUserIDforPush:nil];
    }
    else{
        [mySettingsPlist removeObjectForKey:@"FingerprintPush"];
        [mySettingsPlist removeObjectForKey:@"FingerprintPushCase"];
        [mySettingsPlist writeToFile:finalPath atomically: YES];
    }
}

- (NSDictionary *)getFingerprintAndCaseForPush{
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:@"Settings.plist"];
    NSMutableDictionary *mySettingsPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:finalPath];
    
    @try {
        NSString *fingerprint = [mySettingsPlist objectForKey:@"FingerprintPush"];
        NSString *caseStr = [mySettingsPlist objectForKey:@"FingerprintPushCase"];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[fingerprint,caseStr] forKeys:@[@"FingerprintPush",@"FingerprintPushCase"]];
        
        return dict;
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
        
    }
    
}

- (void)setUserIDforPush:(NSString *)user_id{
  
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:@"Settings.plist"];
    NSMutableDictionary *mySettingsPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:finalPath];
    
    if (user_id != nil) {
        [mySettingsPlist setObject:user_id forKey:@"User_id_PUSH"];
        [mySettingsPlist writeToFile:finalPath atomically: YES];
    }
    else{
        [mySettingsPlist removeObjectForKey:@"User_id_PUSH"];
        [mySettingsPlist writeToFile:finalPath atomically: YES];
    }

}

- (NSString *)getUserIDForPush{
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *finalPath = [documentsDirectory stringByAppendingPathComponent:@"Settings.plist"];
    NSMutableDictionary *mySettingsPlist = [[NSMutableDictionary alloc] initWithContentsOfFile:finalPath];
    
    @try {
        NSString *fingerprint = [mySettingsPlist objectForKey:@"User_id_PUSH"];
        
        return fingerprint;
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
        
    }

}



@end
