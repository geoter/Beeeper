//
//  BPLogin.h
//  BeeeperOAuth
//
//  Created by George Termentzoglou on 2/26/14.
//  Copyright (c) 2014 George Termentzoglou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^completed)(BOOL,id);

@interface BPLogin : NSObject


@property (copy) void(^completed)(BOOL,id);

-(void)loginUser:(NSString *)username password:(NSString *)password completionBlock:(completed)compbloc;
-(void)loginFacebookUser:(NSString *)fbid completionBlock:(completed)compbloc;

- (id)init;
+ (BPLogin *)sharedBPLogin;

@end
