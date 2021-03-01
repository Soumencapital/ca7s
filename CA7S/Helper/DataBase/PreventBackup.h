//
//  PreventBackup.h
//  Anoopam Mission
//
//  Created by Darshit Zalavadiya on 10/11/16.
//  Copyright © 2016 Darshit Zalavadiya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreventBackup : NSObject
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
@end
