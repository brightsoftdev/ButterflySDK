//
//  Database.m
//  sql
//
//  Created by Denny Kwon on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Database.h"

static Database *_database;

@implementation Database

- (NSString *)createFilePath:(NSString *)fileName
{
	fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"+"];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
	return filePath;
}


+ (Database *)database
{
    if (_database==nil){
        _database = [[Database alloc] init];
    }
    else{
        NSLog(@"SINGLETON INSTANCE!");
    }
    return _database;
}

- (id)init
{
    self = [super init];
    if (self){
        NSString *sqLiteDb = [self createFilePath:kDatabase];
        
        if (sqlite3_open([sqLiteDb UTF8String], &_database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
        else{
            NSLog(@"DATABSE OPENED!");
        }
        
        // KEY is the UNESCAPED string ('), VALUE is the ESCAPED string (\')
        escapeCodes = [[NSDictionary alloc] initWithObjectsAndKeys:@"^", @"'", @"*", @"\"", nil];
        decodedMap = [[NSDictionary alloc] initWithObjectsAndKeys:@"'",  @"^", @"\"", @"*", nil];
    }
    return self;
}

- (BOOL)checkSaved:(NSString *)uniqueId
{
    BOOL saved = FALSE;
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM stations where uniqueId = %@", uniqueId];
    NSLog(@"QUERY: %@", query);
    sqlite3_stmt *statement;
    int status = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
    if (status == SQLITE_OK){
        NSLog(@"fetchByID: SQL SUCCESS");
        while (sqlite3_step(statement) == SQLITE_ROW) {
            saved = TRUE;
            char *idNum = (char *)sqlite3_column_text(statement, 0);
            char *nameChars = (char *)sqlite3_column_text(statement, 1);
            printf("%s == %s\n", idNum, nameChars);
        }
    }
    else { NSLog(@"SQL ERROR"); }
    return saved;
}



- (NSString *)fetchByID:(NSString *)uniqueId
{
    NSString *name = nil;
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM stations where uniqueId = %@", uniqueId];
    NSLog(@"QUERY: %@", query);
    
    sqlite3_stmt *statement;
    int status = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
    if (status == SQLITE_OK){
        
        NSLog(@"fetchByID: SQL SUCCESS");
        while (sqlite3_step(statement) == SQLITE_ROW) {
            char *idNum = (char *)sqlite3_column_text(statement, 0);
            char *nameChars = (char *)sqlite3_column_text(statement, 1);
            printf("%s == %s\n", idNum, nameChars);
            name = [[NSString alloc] initWithUTF8String:nameChars];
        }

    }
    else {
        NSLog(@"SQL ERROR");
    }
    return [name autorelease];
}

- (NSMutableArray *)fetchAll
{
    //sqlite> create table stations(uniqueId text, name text, host text, category text, image text);

    NSMutableArray *resultSet = [NSMutableArray array];
//    NSString *query = @"SELECT * FROM stations where age > 30 ORDER BY age DESC";
    NSString *query = @"SELECT * FROM stations";
    sqlite3_stmt *statement;
    
    int status = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
    if (status == SQLITE_OK){
        NSLog(@"SQL SUCCESS");
        while (sqlite3_step(statement) == SQLITE_ROW) {
//            int uniqueId = sqlite3_column_int(statement, 0);
            char *idNum = (char *)sqlite3_column_text(statement, 0);
            char *nameChars = (char *)sqlite3_column_text(statement, 1);
            char *hostChars = (char *)sqlite3_column_text(statement, 2);
            char *categoryChars = (char *)sqlite3_column_text(statement, 3);
            char *imageChars = (char *)sqlite3_column_text(statement, 4);
            printf("uniqueId == %s; name==%s; host==%s\n", idNum, nameChars, hostChars);
            
            
            Station *station = [[Station alloc] init];
            station.saved = TRUE;
//            NSString *uniqueId = [[NSString alloc] initWithUTF8String:idNum];
            station.unique_id = [NSString stringWithUTF8String:idNum];
            station.category = [NSString stringWithUTF8String:categoryChars];
            station.image = [NSString stringWithUTF8String:imageChars];

            NSString *name = [[NSString alloc] initWithUTF8String:nameChars];
            station.name = [self decodedString:name];
            [name release];

            NSString *host = [[NSString alloc] initWithUTF8String:hostChars];
            station.host = host;
            [host release];

            [resultSet addObject:station];
            [station release];
            
        }
        sqlite3_finalize(statement);
    }
    else { NSLog(@"SQL ERROR"); }
    return resultSet;
}


- (void)insertToDB:(NSDictionary *)params
{
//    NSString *query = @"INSERT INTO PEOPLE VALUES('jane', 'female', 25)";
    NSLog(@"INSERT TO DB: %@", [params description]);
    
    NSString *idNum = [params objectForKey:@"idNum"];        
        
    NSString *name = [self fetchByID:idNum];
    if (name==nil){ //not found - this is what should happen
        NSLog(@"NOT FOUND");
        NSString *name = [params objectForKey:@"name"];
        name = [self esacpedString:name];
        
        NSString *host = [params objectForKey:@"host"];
        NSString *category = [params objectForKey:@"category"];
        NSString *image = [params objectForKey:@"image"];
        NSString *values = [NSString stringWithFormat:@"'%@', '%@', '%@', '%@', '%@'", idNum, name, host, category, image];
        NSString *query = [NSString stringWithFormat:@"INSERT INTO STATIONS VALUES(%@)", values];
        
        sqlite3_stmt *statement;
        
        int status = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
        if (status != SQLITE_OK){
            NSLog(@"SQL ERROR: %d", status);
            return;
        }
        
        status = sqlite3_step(statement);
        if (status!=SQLITE_DONE){
            NSLog(@"INSERT FAILED");
            return;
        }
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kResetDatabase object:nil]];
        sqlite3_finalize(statement);
    }
    else{ //found
        NSLog(@"FOUND: %@", name);
    }
}

- (void)deleteFromDB:(NSString *)uniqueId
{
//    NSString *query = @"DELETE FROM people where age = 30"; //sample query
    NSString *query = [NSString stringWithFormat:@"DELETE FROM stations where uniqueId = %@", uniqueId]; 
    sqlite3_stmt *statement;
    
    int status = sqlite3_prepare_v2(_database, [query UTF8String], -1, &statement, nil);
    if (status==SQLITE_OK){
        status = sqlite3_step(statement);
        if (status==SQLITE_DONE){ 
            NSLog(@"DELETE COMPLETE");
        }
        else {
            NSLog(@"DELETE FAILED");
        }
        sqlite3_finalize(statement);
    }
    else { 
        NSLog(@"SQL ERROR");
    }
    
}

- (NSString *)esacpedString:(NSString *)unencodedString
{
    
    for (NSString *unescaped in [escapeCodes allKeys]) {
        unencodedString = [unencodedString stringByReplacingOccurrencesOfString:unescaped withString:[escapeCodes objectForKey:unescaped]];
    }
    
    return unencodedString;
    
    
    
}

- (NSString *)decodedString:(NSString *)escapedNSString
{
    for (NSString *escaped in [decodedMap allKeys]) {
        
        escapedNSString = [escapedNSString stringByReplacingOccurrencesOfString:escaped withString:[decodedMap objectForKey:escaped]];
    }
    
    return escapedNSString;
}

- (void)dealloc
{
    sqlite3_close(_database);
    [escapeCodes release];
    [super dealloc];
}

@end
