//
//  NSString+Trimming.m
//  Beeeper
//
//  Created by GreekMinds on 12/29/14.
//  Copyright (c) 2014 Beeeper. All rights reserved.
//

#import "NSString+Trimming.h"

@implementation NSString (Trimming)

-(NSString *) stringByTrimmingWhitespaceFromFront
{
    const char *cStringValue = [self UTF8String];
    
    int i;
    for (i = 0; cStringValue[i] != '\0' && isspace(cStringValue[i]); i++);
    
    return [self substringFromIndex:i];
}

@end
