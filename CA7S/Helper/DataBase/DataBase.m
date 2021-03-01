//
//  DataBase.m
//  Anoopam Mission
//
//  Created by Darshit Zalavadiya on 10/11/16.
//  Copyright © 2016 Darshit Zalavadiya. All rights reserved.
//

#import "DataBase.h"
#import "PreventBackup.h"
#import "NSUtil.h"

#define DB_NAME      @"ca7s.sqlite"

@implementation DataBase

static DataBase *dataBase = nil;
static bool isLocked;

+ (DataBase*)sharedInstance {
    if (dataBase == nil) {
        dataBase = [[super allocWithZone:NULL] init];
        [self copyDatabaseIfNeeded];
    }
    
    return dataBase;
}

+ (void) copyDatabaseIfNeeded
{
    //Using NSFileManager we can perform many file system operations.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *dbPath = [DataBase getDBPath];
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if(!success) {
        
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_NAME];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        
        if (!success)
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

+ (NSString *) getDBPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSURL *pathURL= [NSURL fileURLWithPath:[documentsDir stringByAppendingPathComponent:DB_NAME]];
    [PreventBackup addSkipBackupAttributeToItemAtURL:pathURL];
    NSLog(@"DataBasePath %@",pathURL);
    return [documentsDir stringByAppendingPathComponent:DB_NAME];
}

+(void) moveDatabase
{
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DB_NAME];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"NewDB"]) {
        [fileManager removeItemAtPath:writableDBPath error:nil];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NewDB"];
    }
    
    success = [fileManager fileExistsAtPath:writableDBPath];
    
    if (success)
    {
        return;
    }
    
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_NAME];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success)
    {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}


-(void)CreateTable:(NSString *)Query
{
    static sqlite3_stmt *statement;
    
    @try {
        NSLog(@"Query:%@",Query);
        NSString *databasePath = [DataBase getDBPath];
        const char *sqlStr = [Query UTF8String];
        
        
        if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        {
            if(sqlite3_prepare_v2(database, sqlStr, -1, &statement, NULL) != SQLITE_OK)
            {
                NSLog(@"Error while creating update statement. '%s'", sqlite3_errmsg(database));
                
            }else{
                NSLog(@"creating update statement sucessfull.'");
            }
            if(sqlite3_exec(database, sqlStr, NULL, NULL, NULL)!=SQLITE_OK)
                NSLog(@"Error while creating update statement. '%s'", sqlite3_errmsg(database));
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_finalize(statement);
        sqlite3_close(database);
        isLocked=false;
    }
}

-(BOOL)deleteData:(NSString *)Query{
    static sqlite3_stmt *statement;
    
    @try {
        NSLog(@"Query:%@",Query);
        NSString *databasePath = [DataBase getDBPath];
        const char *sqlStr = [Query UTF8String];
        
        
        if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        {
            if (sqlite3_prepare_v2(database, sqlStr, -1, &statement, NULL) == SQLITE_OK)
            {
                if(sqlite3_step(statement) == SQLITE_DONE)
                {
                    NSLog(@": step not ok:");
                }
                else
                {
                    NSLog(@": step not ok:");
                }
                sqlite3_finalize(statement);
            }
            else
            {
                NSLog(@": prepare failure:");
                NSLog(@"Error while creating update statement. '%s'", sqlite3_errmsg(database));
            }
            
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_finalize(statement);
        sqlite3_close(database);
        isLocked=false;
    }
    
}

-(void)insertData:(NSString *)sqlQuery
{
    sqlite3_stmt *compiledStatement;
    @try {
        NSString *databasePath = [DataBase getDBPath];
        sqlQuery=[sqlQuery stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        NSLog(@"%@",sqlQuery);
        
        if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        {
            const char *sqlStatement = [sqlQuery UTF8String];
            
            if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
            {
                if(sqlite3_step(compiledStatement) == SQLITE_DONE)
                    NSLog(@"DATABASE: Adding: Success");
                else
                    NSLog(@"Error while creating update statement. '%s'", sqlite3_errmsg(database));
            }
            else{
                NSLog(@"Error. Could not add Waypoint.");
                NSLog(@"Error while creating update statement. '%s'", sqlite3_errmsg(database));
            }
            
            
        }
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        sqlite3_finalize(compiledStatement);
        sqlite3_close(database);
        isLocked=false;
    }
    
    
}

-(BOOL)checkColum:(NSString*)columName inTable:(NSString*)table
{
    static sqlite3_stmt *existsStatement;
    @try
    {
        NSFileManager *fileManager =[NSFileManager defaultManager];
        BOOL success;
        
        NSString * theDBPath = [DataBase getDBPath];
        
        success = [fileManager fileExistsAtPath:theDBPath];
        if(!success)
        {
            NSLog(@"failed to find the file");
        }
        if(!(sqlite3_open([theDBPath UTF8String], &database)== SQLITE_OK))
        {
            NSLog(@"Error opening database");
        }
        
        const char *sql = [[NSString stringWithFormat:@"Select * from %@;",table] UTF8String];
        
        
        
        if (sqlite3_prepare_v2(database, sql, -1, &existsStatement, NULL) !=SQLITE_OK)
        {
            NSLog(@"failed to prepare statement");
        }
        else{
            int cols = sqlite3_column_count(existsStatement);
            for (int i=0; i<cols; i++) {
                if ( [[NSString stringWithUTF8String:(char*)sqlite3_column_name(existsStatement,
                                                                                i)] isEqualToString:columName]){
                    
                    return TRUE;
                }
            }
            
        }
        
    }
    @catch (NSException *e)
    {
        NSLog(@"An Exception occured at %@", [e reason]);
    }
    @finally {
        sqlite3_finalize(existsStatement);
        sqlite3_close(database);
        isLocked=false;
    }
    
    return FALSE;
    
}
-(BOOL)createColum:(NSString*)columName inTable:(NSString*)table
{
    static sqlite3_stmt *existsStatement;
    BOOL flage=FALSE;
    @try
    {
        
        NSFileManager *fileManager =[NSFileManager defaultManager];
        
        BOOL success;
        
        NSString * theDBPath = [DataBase getDBPath];
        
        success = [fileManager fileExistsAtPath:theDBPath];
        if(!success)
        {
            NSLog(@"failed to find the file");
        }
        if(!(sqlite3_open([theDBPath UTF8String], &database)== SQLITE_OK))
        {
            NSLog(@"Error opening database");
        }
        
        const char *sql = [[NSString stringWithFormat:@"ALTER TABLE \"%@\" ADD COLUMN \"%@\" TEXT;",table,columName] UTF8String];
        
        
        
        if (sqlite3_prepare_v2(database, sql, -1, &existsStatement, NULL) !=SQLITE_OK)
        {
            NSLog(@"failed to prepare statement");
        }
        if (sqlite3_step(existsStatement) == SQLITE_DONE)
        {
            flage= TRUE;
        }
        
    }
    @catch (NSException *e)
    {
        NSLog(@"An Exception occured at %@", [e reason]);
    }
    @finally {
        sqlite3_finalize(existsStatement);
        sqlite3_close(database);
        isLocked=false;
    }
    
    
    return flage;
    
}
-(BOOL)CheckTableExist:(NSString *)tablename
{
    static sqlite3_stmt *existsStatement;
    @try
    {
        NSFileManager *fileManager =[NSFileManager defaultManager];
        
        BOOL success;
        
        NSString * theDBPath = [DataBase getDBPath];
        
        success = [fileManager fileExistsAtPath:theDBPath];
        if(!success)
        {
            NSLog(@"failed to find the file");
        }
        if(!(sqlite3_open([theDBPath UTF8String], &database)== SQLITE_OK))
        {
            NSLog(@"Error opening database");
        }
        
        // const char *sql = [[NSString stringWithFormat:@"SELECT count(*) FROM sqlite_master WHERE type='table' AND name='%@'",tablename] UTF8String];
        const char *sql = [[NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@'",tablename] UTF8String];
        
        
        
        if (sqlite3_prepare_v2(database, sql, -1, &existsStatement, NULL) !=SQLITE_OK)
        {
            NSLog(@"failed to prepare statement");
        }
        
        if (sqlite3_step(existsStatement) == SQLITE_ROW)
        {
            sqlite3_close(database);
            return TRUE;
        }
    }
    @catch (NSException *e)
    {
        NSLog(@"An Exception occured at %@", [e reason]);
    } @finally {
        sqlite3_finalize(existsStatement);
        sqlite3_close(database);
        isLocked=false;
    }
    return FALSE;
}

//create table
-(NSString *)Createtablestring:(NSArray *)allkey
{
    NSString *primaryKey = @",PRIMARY KEY (";
    NSString *strtablestr = [[NSString alloc] init];
    NSMutableArray *arrPK = [[NSMutableArray alloc] init];
    for (int i = 0; i < [allkey count]; i++)
    {
        if (i != 0)
        {
            
            strtablestr = [NSString stringWithFormat:@"%@,",strtablestr];
        }
        if ([strtablestr length] > 0)
        {
            if ((([[[allkey objectAtIndex:i] lowercaseString] rangeOfString:@"id"].location != NSNotFound|| [[[allkey objectAtIndex:i] lowercaseString] rangeOfString:@"tab"].location != NSNotFound)) && [primaryKey isEqualToString:@",PRIMARY KEY ("] )
            {
                //                    if (!isPrimaryKeyAdded) {
                //                        strtablestr = [NSString stringWithFormat:@"%@ %@ TEXT PRIMARY KEY",strtablestr,[allkey objectAtIndex:i]];
                //                        isPrimaryKeyAdded=TRUE;
                //                    }else{
                //                        strtablestr = [NSString stringWithFormat:@"%@ %@ TEXT UNIQUE",strtablestr,[allkey objectAtIndex:i]];
                //                    }
                primaryKey = [NSString stringWithFormat:@"%@%@,",primaryKey,[allkey objectAtIndex:i]];;
                
            }
            
            if([[[allkey objectAtIndex:i] lowercaseString] isEqualToString:@"created"] || [[[allkey objectAtIndex:i] lowercaseString] rangeOfString:@"date"].location != NSNotFound){
                strtablestr = [NSString stringWithFormat:@"%@ %@ DATE ",strtablestr,[allkey objectAtIndex:i]];
            }
            else
            {
                strtablestr = [NSString stringWithFormat:@"%@ %@ TEXT ",strtablestr,[allkey objectAtIndex:i]];
            }
        }
        else
        {
            if ((([[[allkey objectAtIndex:i] lowercaseString] rangeOfString:@"id"].location != NSNotFound|| [[[allkey objectAtIndex:i] lowercaseString] rangeOfString:@"tab"].location != NSNotFound)) && [primaryKey isEqualToString:@",PRIMARY KEY ("])
            {
                //                    if (!isPrimaryKeyAdded) {
                //                        strtablestr = [NSString stringWithFormat:@"%@ %@ TEXT PRIMARY KEY",strtablestr,[allkey objectAtIndex:i]];
                //                        isPrimaryKeyAdded=TRUE;
                //                    }else{
                //                        strtablestr = [NSString stringWithFormat:@"%@ %@ TEXT UNIQUE",strtablestr,[allkey objectAtIndex:i]];
                //                    }
                //
                primaryKey = [NSString stringWithFormat:@"%@%@,",primaryKey,[allkey objectAtIndex:i]];;
            }
            
            if([[[allkey objectAtIndex:i] lowercaseString] isEqualToString:@"created"] || [[[allkey objectAtIndex:i] lowercaseString] rangeOfString:@"date"].location != NSNotFound){
                strtablestr = [NSString stringWithFormat:@"%@ %@ DATE ",strtablestr,[allkey objectAtIndex:i]];
            }
            else
            {
                strtablestr = [NSString stringWithFormat:@"%@ TEXT",[allkey objectAtIndex:i]];
            }
        }
        
        //        }
    }
    
    if (![primaryKey isEqualToString:@",PRIMARY KEY ("]) {
        strtablestr =[NSString stringWithFormat:@"%@ %@)",strtablestr,[primaryKey substringToIndex:primaryKey.length-1]];
        
    }
    //    primary key (ID, CODE)
    //    strtablestr = [NSString stringWithFormat:@"%@, REQObject VARCHAR",strtablestr];
    
    if ([arrPK count] > 1)
    {
        
        strtablestr = [strtablestr stringByReplacingOccurrencesOfString:@"PRIMARY KEY" withString:@"NOT NULL"];
        NSString *strPK;
        for (int k = 0; k < [arrPK count]; k++)
        {
            if (k == 0)
            {
                strPK = [arrPK objectAtIndex:k];
            }
            else
            {
                strPK = [NSString stringWithFormat:@"%@, %@", strPK, [arrPK objectAtIndex:k]];
            }
        }
        strtablestr =[NSString stringWithFormat: @"%@, PRIMARY KEY (%@)",strtablestr,strPK];
    }
    
    isLocked=false;
    return strtablestr;
}

-(NSString*)getQueryForInsertWith:(NSDictionary*)entry colums:(NSArray*)colums
{
    
    NSString *queryString = @"";
    @try {
        NSString *columName = @"";
        NSString *columValue = @"";
        
        for (NSString *colum in colums) {
            if ([entry valueForKey:colum])
            {
                columName = [NSString stringWithFormat:@"%@,%@",columName,colum];
                if ([[entry valueForKey:colum] isKindOfClass:[NSString class]]) {
                    columValue = [NSString stringWithFormat:@"%@,\"%@\"",columValue,[entry valueForKey:colum]];
                }
                else  if ([[entry valueForKey:colum] isKindOfClass:[NSNumber class]])
                {
                    columValue = [NSString stringWithFormat:@"%@,\"%ld\"",columValue,(long)[[entry valueForKey:colum] integerValue]];
                }
                
                else
                {
                    //                    NSString *strItemData =[entry valueForKey:colum];
                    //                    NSData *itemData= [strItemData dataUsingEncoding:NSUTF8StringEncoding];
                    //                    NSError *localError;
                    //                    NSDictionary *imgDetail =[NSJSONSerialization JSONObjectWithData:itemData options:0 error:&localError];
                    NSString *valueString =[NSString stringWithFormat:@"%@",[[entry valueForKey:colum] JSONString]];
                    valueString = [valueString stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
                    columValue = [NSString stringWithFormat:@"%@,\"%@\"",columValue,valueString];
                }
                
            }
        }
        columName = [columName substringFromIndex:1];
        columValue = [columValue substringFromIndex:1];
        queryString = [NSString stringWithFormat:@"(%@) VALUES(%@)",columName,columValue];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception %@",exception);
    }
    @finally {
        isLocked=false;
    }
    return queryString;
}

-(NSMutableDictionary*)getUser:(NSString*)query
{
    NSMutableDictionary *userDetail = [[NSMutableDictionary alloc] init];
    static sqlite3_stmt *statement;
    @try {
        NSLog(@"Query:-%@",query);
        NSFileManager *fileManager =[NSFileManager defaultManager];
        BOOL success;
        NSString * theDBPath = [DataBase getDBPath];
        success = [fileManager fileExistsAtPath:theDBPath];
        if(!success)
        {
            NSLog(@"failed to find the file");
        }
        if(!(sqlite3_open([theDBPath UTF8String], &database)== SQLITE_OK))
        {
            NSLog(@"Error opening database");
        }
        query = [query stringByReplacingOccurrencesOfString:@"#" withString:@"%"];
        const char *sql = [query UTF8String];
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) !=SQLITE_OK)
        {
            NSLog(@"failed to prepare statement");
        }
        
        
        while (sqlite3_step(statement) == SQLITE_ROW){
            int cols = sqlite3_column_count(statement);
            for (int i=0; i<cols; i++) {
                
                NSString *key =[NSString stringWithUTF8String:(char*) sqlite3_column_name(statement,                                                                                                  i)];
                NSString *value =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, i)];
                value = [value stringByReplacingOccurrencesOfString: @"\\'" withString:@"\""];
                [userDetail setValue:value forKey:key];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception%@",exception);
    }
    @finally {
        sqlite3_finalize(statement);
        sqlite3_close(database);
        isLocked=false;
    }
    return userDetail;
}

-(NSMutableArray*)getDataFor:(NSString*)query
{
    NSMutableArray *rowArray = [[NSMutableArray alloc] init];
    static sqlite3_stmt *statement;
    @try {
        NSLog(@"Query:-%@",query);
        NSFileManager *fileManager =[NSFileManager defaultManager];
        BOOL success;
        NSString * theDBPath = [DataBase getDBPath];
        success = [fileManager fileExistsAtPath:theDBPath];
        if(!success)
        {
            NSLog(@"failed to find the file");
        }
        if(!(sqlite3_open([theDBPath UTF8String], &database)== SQLITE_OK))
        {
            NSLog(@"Error opening database");
        }
        query = [query stringByReplacingOccurrencesOfString:@"#" withString:@"%"];
        const char *sql = [query UTF8String];
        
        if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) !=SQLITE_OK)
        {
            NSLog(@"failed to prepare statement");
        }
        while (sqlite3_step(statement) == SQLITE_ROW){
            NSMutableDictionary *rowObject = [[NSMutableDictionary alloc] init];
            int cols = sqlite3_column_count(statement);
            for (int i=0; i<cols; i++) {
                
                NSString *key =[NSString stringWithUTF8String:(char*) sqlite3_column_name(statement,                                                                                                  i)];
                NSString *value = @"";
                
                if ((char *) sqlite3_column_text(statement, i)!=NULL)
                {
                    value =[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, i)];
                }
                
                value = [value stringByReplacingOccurrencesOfString: @"\\'" withString:@"\""];
                [rowObject setValue:value forKey:key];
            }
            
            [rowArray addObject:rowObject];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception%@",exception);
    }
    @finally {
        sqlite3_finalize(statement);
        sqlite3_close(database);
        isLocked=false;
    }
    
    return rowArray;
}

-(BOOL)performTaskWithQuery:(NSString *)Query
{
    static sqlite3_stmt *statement;
    BOOL flag = false;
    @try {
        NSLog(@"Query:%@",Query);
        NSString *databasePath = [DataBase getDBPath];
        const char *sqlStr = [Query UTF8String];
        
        
        if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
        {
            if(sqlite3_prepare_v2(database, sqlStr, -1, &statement, NULL) != SQLITE_OK)
            {
                NSLog(@"Error while perform Query statement. '%s'", sqlite3_errmsg(database));
                
            }else{
                NSLog(@"Query perform sucessfull.'");
            }
            if(sqlite3_exec(database, sqlStr, NULL, NULL, NULL)!=SQLITE_OK){
                NSLog(@"Error while perform Query. '%s'", sqlite3_errmsg(database));
            }else{
                flag=TRUE;
            }
        }
        
        
    }
    @catch (NSException *exception)
    {
        
    }
    @finally
    {
        sqlite3_finalize(statement);
        sqlite3_close(database);
        isLocked=false;
    }
    
    return flag;
    
}
@end
