//
//  BPSuggestions.h
//  Beeeper
//
//  Created by George on 6/17/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Suggestion_Object.h"

typedef void(^completed)(BOOL,id);

@interface BPSuggestions : NSObject

-(void)getSuggestionsWithCompletionBlock:(completed)compbloc;
-(void)getLocalSuggestions:(completed)compbloc;
-(void)suggestEvent:(NSString *)fingerprint toUsers:(NSArray *)user_ids withCompletionBlock:(completed)compbloc;

@property (copy) void(^completed)(BOOL,id);
@property (copy) completed localCompleted;
@property (copy) completed suggestEventCompleted;

- (id)init;
+ (BPSuggestions *)sharedBP;

@end
