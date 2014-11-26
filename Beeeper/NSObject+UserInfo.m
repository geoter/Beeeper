//
//  NSObject+UserInfo.m
//  
//
//  Created by George on 2/12/13.
//  Copyright (c) 2013 George Termentzoglou. All rights reserved.
//

#import "NSObject+UserInfo.h"

#import <objc/runtime.h>

@implementation NSObject (UserInfo)

- (NSMutableDictionary*) UserInfo
{
	static const char* objectUserInfoKey = "objectUserInfoKey";
    
	NSMutableDictionary* objectUserInfo = objc_getAssociatedObject(self, objectUserInfoKey);
    
	if(objectUserInfo == nil)
	{
		objectUserInfo = [[NSMutableDictionary alloc] init];
		objc_setAssociatedObject(self, objectUserInfoKey, objectUserInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);	//	Retains here, the objc runtime will release it for us on [self dealloc]
	}
    
	return objectUserInfo;
}

@end
