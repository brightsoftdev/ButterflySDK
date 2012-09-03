//
//  Database.h
//  sql
//
//  Created by Denny Kwon on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Globals.h"
#import "Station.h"

@interface Database : NSObject {
    sqlite3 *_database;
    NSDictionary *escapeCodes;
    NSDictionary *decodedMap;
}

+ (Database *)database;
- (BOOL)checkSaved:(NSString *)uniqueId;
- (void)insertToDB:(NSDictionary *)params;
- (NSMutableArray *)fetchAll;
- (void)deleteFromDB:(NSString *)uniqueId;
@end
