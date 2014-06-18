//
//  BPActivity.h
//  Beeeper
//
//  Created by George Termentzoglou on 6/10/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Activity_Object.h"

typedef void(^completed)(BOOL,id);

@interface BPActivity : NSObject

-(void)getActivityWithCompletionBlock:(completed)compbloc;
-(void)getBeeepInfoFromActivity:(Activity_Object *)actObj WithCompletionBlock:(completed)compbloc;
-(void)getEvent:(Activity_Object *)activityObj WithCompletionBlock:(completed)compbloc;

@property (copy) completed beeep_completed;
@property (copy) completed event_completed;
@property (copy) completed activity_completed;

- (id)init;
+ (BPActivity *)sharedBP;
@end
