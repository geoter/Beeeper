//
//  DTO.m
//  TruckBird
//
//  Created by George Termentzoglou on 7/4/13.
//  Copyright (c) 2013 George Termentzoglou. All rights reserved.
//

#import "DTO.h"

static DTO *thisDTO = nil;

@implementation DTO


-(id)init{
    self = [super init];
    if(self) {
        thisDTO = self;
    }
    return(self);
    
    
}

+ (DTO *)sharedDTO{
    
    if (thisDTO != nil) {
        return thisDTO;
    }
    else{
        return [[DTO alloc]init];
    }
    
    return nil;
}

- (void)downloadImageFromURL:(NSString *)url{
    
    NSString *extension = [[url.lastPathComponent componentsSeparatedByString:@"."] lastObject];
    
    NSString *imageName = [NSString stringWithFormat:@"%@.%@",[url MD5],extension];
    
    NSString * documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *localPath = [documentsDirectoryPath stringByAppendingPathComponent:imageName];
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:localPath]) {
        UIImage * result;
        NSData * localData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        result = [UIImage imageWithData:localData];
        [self saveImage:result withFileName:imageName inDirectory:localPath];
    }
}

-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName inDirectory:(NSString *)directoryPath {
    
    if ([imageName rangeOfString:@"n/a"].location != NSNotFound) {
        return;
    }
    
    if ([[imageName lowercaseString] rangeOfString:@".png"].location != NSNotFound) {
        [UIImagePNGRepresentation(image) writeToFile:directoryPath options:NSAtomicWrite error:nil];
        NSLog(@"Saved Image: %@",imageName);
        
    } else {
        BOOL write = [UIImageJPEGRepresentation(image, 1) writeToFile:directoryPath options:NSAtomicWrite error:nil];
        NSLog(@"Saved Image: %@ - %d",directoryPath,write);
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:[imageName MD5] object:nil userInfo:[NSDictionary dictionaryWithObject:imageName forKey:@"imageName"]];
}


@end
