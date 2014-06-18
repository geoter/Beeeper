//
//  BPCreate.h
//  Beeeper
//
//  Created by George on 5/22/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^completed)(BOOL,id);

@interface BPCreate : NSObject
{
    NSOperationQueue *operationQueue;
    NSMutableDictionary *valuesDict;
}

@property (copy) void(^completed)(BOOL,id);
- (id)init;
+ (BPCreate *)sharedBP;


-(void)beeepCreate:(NSString *)fingerprint beeep_time:(NSString *)beeep_time completionBlock:(completed)compbloc;
-(void)eventCreate:(NSDictionary *)values completionBlock:(completed)compbloc;

@end
