//
//  PreventBackup.m
//  Anoopam Mission
//
//  Created by Darshit Zalavadiya on 10/11/16.
//  Copyright © 2016 Darshit Zalavadiya. All rights reserved.
//

#import "PreventBackup.h"

@implementation PreventBackup

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
//        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
//    NSLog(@"prevent backup method called without error");
    return success;
}

@end
