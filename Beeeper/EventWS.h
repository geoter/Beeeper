//
//  EventWS.h
//  Beeeper
//
//  Created by George on 5/16/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^completed)(BOOL,id);

@interface EventWS : NSObject

@property (copy) completed like_event_completed;
@property (copy) completed comment_completed;
@property (copy) void(^like_beeep_completed)(BOOL,id);

- (id)init;
+ (EventWS *)sharedBP;

-(void)postComment:(NSString *)commentText BeeepId:(NSString *)beeep_id user:(NSString *)user_id WithCompletionBlock:(completed)compbloc;
-(void)likeEvent:(NSString *)fingerprint WithCompletionBlock:(completed)compbloc;
-(void)unlikeEvent:(NSString *)fingerprint WithCompletionBlock:(completed)compbloc;
-(void)likeBeeep:(NSString *)beeepID user:(NSString *)userID WithCompletionBlock:(completed)compbloc;
-(void)unlikeBeeep:(NSString *)beeepID user:(NSString *)userID WithCompletionBlock:(completed)compbloc;
@end
