//
//  DataBase.h
//  Anoopam Mission
//
//  Created by Darshit Zalavadiya on 10/11/16.
//  Copyright © 2016 Darshit Zalavadiya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "sqlite3.h"

@interface DataBase : NSObject
{
   sqlite3 *database;
}
+ (void) copyDatabaseIfNeeded;
+(void) moveDatabase;
+ (NSString *) getDBPath;
+(DataBase*)sharedInstance;
-(void)CreateTable:(NSString *)Query;
-(void)insertData:(NSString *)sqlQuery;
-(BOOL)CheckTableExist:(NSString *)tablename;
-(NSString *)Createtablestring:(NSArray *)allkey;
-(BOOL)checkColum:(NSString*)columName inTable:(NSString*)table;
-(BOOL)createColum:(NSString*)columName inTable:(NSString*)table;
-(NSMutableDictionary*)getUser:(NSString*)query;
-(NSMutableArray*)getDataFor:(NSString*)query;
-(BOOL)performTaskWithQuery:(NSString *)Query;
-(BOOL)deleteData:(NSString *)Query;
-(NSString*)getQueryForInsertWith:(NSDictionary*)entry colums:(NSArray*)colums;

@end
