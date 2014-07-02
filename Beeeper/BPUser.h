//
//  BPUser.h
//  Beeeper
//
//  Created by George Termentzoglou on 3/15/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^completed)(BOOL,id);
typedef void(^followers_completed)(BOOL,id);
typedef void(^following_completed)(BOOL,id);
typedef void(^is_following_completed)(BOOL,id);
typedef void(^notifications_completed)(BOOL,id,id);

@interface BPUser : NSObject

@property (copy) void(^completed)(BOOL,id);
@property (copy) void(^followers_completed)(BOOL,id);
@property (copy) void(^following_completed)(BOOL,id);
@property (copy) void(^is_following_completed)(BOOL,id);
@property (copy) void(^notifications_completed)(BOOL,id,id);
@property (copy) completed fbSignUpCompleted;
@property (copy) completed localNotificationsCompleted;
@property (copy) completed newNotificationsCompleted;
@property (copy) completed oldNotificationsCompleted;
@property (copy) completed getEmailSettingsCompleted;
@property (copy) completed setEmailSettingsCompleted;
@property (copy) completed setUserSettingsCompleted;

@property (nonatomic,strong) NSDictionary *user;

#pragma mark - Login

-(NSString *)headerGETRequest:(NSString *)link values:(NSMutableArray *)values;
-(NSString *)headerPOSTRequest:(NSString *)link values:(NSMutableArray *)values;

-(void)loginUser:(NSString *)username password:(NSString *)password completionBlock:(completed)compbloc;
-(void)loginFacebookUser:(NSString *)fbid completionBlock:(completed)compbloc;
-(void)loginTwitterUser:(NSString *)twitterid completionBlock:(completed)compbloc;

-(void)signUpUser:(NSDictionary *)info completionBlock:(completed)compbloc;
-(void)signUpSocialUser:(NSDictionary *)info completionBlock:(completed)compbloc;

-(void)getFollowersWithCompletionBlock:(completed)compbloc;
-(void)getFollowersForUser:(NSString *)user_id WithCompletionBlock:(completed)compbloc;

-(void)getFollowingWithCompletionBlock:(completed)compbloc;
-(void)getFollowingForUser:(NSString *)user_id WithCompletionBlock:(completed)compbloc;

-(void)checkIfFollowing:(NSString *)other_user_id WithCompletionBlock:(completed)compbloc;
-(void)follow:(NSString *)userID WithCompletionBlock:(completed)compbloc;
-(void)unfollow:(NSString *)userID WithCompletionBlock:(completed)compbloc;

-(void)getLocalNotifications:(completed)compbloc;
-(void)getNotificationsWithCompletionBlock:(notifications_completed)compbloc;
-(void)getNewNotificationsWithCompletionBlock:(completed)compbloc;
-(void)nextNotificationsWithCompletionBlock:(notifications_completed)compbloc;

-(void)getEmailSettingsWithCompletionBlock:(completed)compbloc;
-(void)setEmailSettings:(NSDictionary *)settingsDict WithCompletionBlock:(completed)compbloc;

-(void)setUserSettings:(NSDictionary *)settings WithCompletionBlock:(completed)compbloc;

-(void)getUser;

- (id)init;
+ (BPUser *)sharedBP;

@end
