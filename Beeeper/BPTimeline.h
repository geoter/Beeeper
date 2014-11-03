//
//  BPTimeline.h
//  Beeeper
//
//  Created by George Termentzoglou on 4/8/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Upcoming 0
#define Past 1

typedef void(^completed)(BOOL,id);

@interface BPTimeline : NSObject

-(void)getTimelineForUserID:(NSString *)user_id option:(int)option timeStamp:(NSTimeInterval)time WithCompletionBlock:(completed)compbloc;
-(void)getLocalTimelineUserID:(NSString *)user_id option:(int)option WithCompletionBlock:(completed)compbloc;
-(void)nextPageTimelineForUserID:(NSString *)user_id option:(int)option WithCompletionBlock:(completed)compbloc;

@property (copy) void(^completed)(BOOL,id);
@property (copy) completed localCompleted;

- (id)init;
+ (BPTimeline *)sharedBP;

@end
