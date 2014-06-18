//
//  BPHomeFeed.h
//  Beeeper
//
//  Created by George on 5/15/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BPHomeFeed : NSObject
typedef void(^completed)(BOOL,id);

-(void)getHomeFeedWithCompletionBlock:(completed)compbloc;
-(void)getFriendsFeedWithCompletionBlock:(completed)compbloc;

@property (copy) void(^completed)(BOOL,id);

- (id)init;
+ (BPHomeFeed *)sharedBP;

@end
