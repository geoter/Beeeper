//
//  BPUsersLookup.h
//  Beeeper
//
//  Created by George on 5/14/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^completed)(BOOL,id);

@interface BPUsersLookup : NSObject
{
   NSArray *userIDs;
   ASIFormDataRequest *request;
}

@property (copy) void(^completed)(BOOL,id);

- (id)init;
+ (BPUsersLookup *)sharedBP;

#pragma mark - User Lookup

-(void)usersLookup:(NSArray *)users_ids completionBlock:(completed)compbloc;

@end
