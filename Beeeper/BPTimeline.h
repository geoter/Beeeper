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

-(void)getTimelineForUserID:(NSString *)user_id option:(int)option WithCompletionBlock:(completed)compbloc;

@property (copy) void(^completed)(BOOL,id);

- (id)init;
+ (BPTimeline *)sharedBP;

@end
