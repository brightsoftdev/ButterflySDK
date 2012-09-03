//
//  Station.m
//  butterflyradio
//
//  Created by Denny Kwon on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Station.h"

#define kTitleKey       @"Title"
#define kRatingKey      @"Rating"

@implementation Station
@synthesize name;
@synthesize unique_id;
@synthesize description;
@synthesize category;
@synthesize image;
@synthesize tags;
@synthesize tracks;
@synthesize admins;
@synthesize plays;
@synthesize imgData;
@synthesize thumbnail;
@synthesize articles;
@synthesize delegate;
@synthesize host;
@synthesize ready;
@synthesize saved;
@synthesize threadMap;
@synthesize threadArray;
@synthesize adFreq;

- (id)init
{
    self = [super init];
    if (self){
        threadMap = [[NSMutableDictionary alloc] init];
        threadArray = [[NSMutableArray alloc] init];
        
        getImage = nil;
        getThumb = nil;
        ready = FALSE;
        saved = FALSE;
    }
    return self;
}

- (void)dealloc
{
    [threadArray release];
    [threadMap release];
    [queue cancelAllOperations];
    [name release];
    [unique_id release];
    [description release];
    [category release];
    [image release];
    [tags release];
    [tracks release];
    [admins release];
    [articles release];
    [host release];
    if (queue){
        [queue release];
    }
    if (getImage){
        [getImage release];
    }
    if (getThumb){
        [getThumb release];
    }
    [super dealloc];
}

- (void)getStationInfo
{
    if (req!=nil){
        req.delegate = nil;
        [req release];
    }
    
    NSString *url = [NSString stringWithFormat:@"http://%@/api/station/%@", kUrl, self.unique_id];
    req = [[URLRequest alloc] initWithAddress:url parameters:nil];
    req.delegate = self;
    [req setHttpMethod:@"GET"];
    [req sendRequest];
}

- (void)cancelUpdate
{
    if (req!=nil){
        req.delegate = nil;
        [req cancel];
        [req release];
    }
    self.delegate = nil;
}

- (void)requestData:(NSArray *)pkg //returns [address, data]
{
    if (pkg!=nil) {
        NSString *json = [[NSString alloc] initWithData:[pkg objectAtIndex:1] encoding:NSUTF8StringEncoding];
        NSDictionary *d = [json JSONValue];
        if (d==nil){
            [req sendRequest];
        }
        else {
            d = [d objectForKey:@"results"];
            NSLog(@"%@", [d description]);
            NSDictionary *info = [d objectForKey:@"station"];
            [self populate:info];
            [delegate stationInfoReady];
            
            req.delegate = nil;
            [req release];
            req = nil;
        }
        [json release];
    }
}

- (void)save
{
    NSLog(@"STATION - save");
    
    Database *db = [Database database];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:self.unique_id, @"idNum", self.name, @"name", self.host, @"host", self.category, @"category", self.image, @"image", nil];
    [db insertToDB:params];
    self.saved = TRUE;
}

- (void)deleteFromDb
{
    Database *db = [Database database];
    [db deleteFromDB:self.unique_id];
}

- (void)fetchImage
{
    if (getImage==nil){
        if (queue==nil){ queue = [[NSOperationQueue alloc] init]; }
        NSString *url = self.image;
        if ([url rangeOfString:@"default.jpg"].location == NSNotFound){
            url = [url stringByAppendingString:@"=s450"];
        }
        getImage = [[GetImage alloc] initWithTarget:self address:url action:@selector(imageReady:)];
        [queue addOperation:getImage];
    }
}

- (void)imageReady:(NSArray *)pkg
{
    NSLog(@"STATION: imageReady:");
    if (pkg!=nil){
        self.imgData = [pkg objectAtIndex:1];
        [getImage release];
        getImage = nil;
        [delegate imageReady:self.unique_id];
    }
}

- (void)fetchThumbnail:(int)dimen
{
    NSLog(@"STATION: fetchThumbnail");
    if (getThumb==nil){
        if (queue==nil){ queue = [[NSOperationQueue alloc] init]; }
        NSString *url = self.image;
        if ([url rangeOfString:@"default.jpg"].location == NSNotFound){
//            url = [url stringByAppendingString:@"=s60-c"];
//            int dimen = kCellHeight-10;
            url = [url stringByAppendingString:[NSString stringWithFormat:@"=s%d-c", dimen]];
        }
        getThumb = [[GetImage alloc] initWithTarget:self address:url action:@selector(thumbnailReady:)];
        [queue addOperation:getThumb];
    }
}

- (void)thumbnailReady:(NSArray *)pkg
{
    NSLog(@"STATION: thumbnailReady");
    if (pkg!=nil){
        self.thumbnail = [UIImage imageWithData:[pkg objectAtIndex:1]];
        [getThumb release];
        getThumb = nil;
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kThumbnailReadyNotification object:nil]];
    }
}

- (NSString *)adminsString
{
    NSString *adminList = @"";
    if ([self.admins containsObject:@"none"]==TRUE){
        adminList = @"none";
    }
    else{
        for (NSString *a in self.admins){
            adminList = [adminList stringByAppendingString:a];
            adminList = [adminList stringByAppendingString:@","];
        }
    }
    adminList = [adminList substringToIndex:[adminList length]-1];
    return adminList;
}

- (NSString *)tagsString
{
    NSString *tagsList = @"";
    if ([self.tags containsObject:@"none"]==TRUE){
        tagsList = @"none";
    }
    else{
        for (NSString *a in self.tags){
            tagsList = [tagsList stringByAppendingString:a];
            tagsList = [tagsList stringByAppendingString:@","];
        }
        tagsList = [tagsList substringToIndex:[tagsList length]-1];
    }
    return tagsList;
}

- (NSMutableDictionary *)createMap:(NSString *)a
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    NSArray *parts = [a componentsSeparatedByString:@"=="];
    for (NSString *part in parts) {
        NSArray *keyValue = [part componentsSeparatedByString:@"::"];
        if ([keyValue count]==2){
            NSString *key = [keyValue objectAtIndex:0];
            NSString *value = [keyValue objectAtIndex:1];
            [info setObject:value forKey:key];
        }
    }
    return info;
}

- (void)parseTracks:(NSArray *)t
{
    self.tracks = [NSMutableArray array];
    self.threadArray = [NSMutableArray array];
    self.threadMap = [NSMutableDictionary dictionary];
    
    for (int i=0; i<[t count]; i++) {
        NSString *track = [t objectAtIndex:i];
        NSLog(@"TRACK == %@",track);
        NSMutableDictionary *trackInfo = [self createMap:track];
        
        AudioFile *file = [[AudioFile alloc] init];
        NSString *thr = [trackInfo objectForKey:@"in_reply_to"];
        if (thr==nil){ file.thread = [trackInfo objectForKey:@"id"]; }
        else{
            if ([thr isEqualToString:@"0"]){ file.thread = [trackInfo objectForKey:@"id"]; }
            else{ file.thread = thr; }
        }
        file.name = [trackInfo objectForKey:@"title"];
        file.url = [NSString stringWithFormat:@"http://%@/stream/%@", kUrl, [trackInfo objectForKey:@"id"]];
        
        NSString *d = [trackInfo objectForKey:@"date"];
        NSArray *p = [d componentsSeparatedByString:@" "];
        if ([p count]>3){
            file.date = [NSString stringWithFormat:@"%@ %@, %@", [p objectAtIndex:1], [p objectAtIndex:2], [p lastObject]];
        }
        else{ file.date = d; }
        
        file.author = [trackInfo objectForKey:@"author"];
        
//        [tracks addObject:file];
        
        
        //////
        Thread *th = (Thread *)[threadMap objectForKey:file.thread];
        if (th==nil){
            th = [[Thread alloc] init];
            th.threadId = file.thread;
            
            [th.thread insertObject:file atIndex:0];
            [threadMap setObject:th forKey:th.threadId];
            [threadArray addObject:th];
            [th release];
        }
        else{
            [th.thread insertObject:file atIndex:0];
        }
        ///////

        
        [file release];
    }
    
    for (int i=0; i<[threadArray count]; i++) {
        Thread *thread = (Thread *)[threadArray objectAtIndex:i];
        [tracks addObjectsFromArray:thread.thread];
    }
}

- (void)populate:(NSDictionary *)info
{
    for (NSString *key in [info allKeys]){
        if ([key isEqualToString:@"adFrequency"]){ self.adFreq = [[info objectForKey:key] intValue]; }
        if ([key isEqualToString:@"name"]){ self.name = [info objectForKey:key]; }
        if ([key isEqualToString:@"id"]){ 
            self.unique_id = [info objectForKey:key]; 
            Database *db = [Database database];
            self.saved = [db checkSaved:self.unique_id];
            if (self.saved==TRUE){
                NSLog(@"STATION SAVED!");
            }
        }
        if ([key isEqualToString:@"description"]){ self.description = [info objectForKey:key]; }
        if ([key isEqualToString:@"category"]){ self.category = [info objectForKey:key]; }
        if ([key isEqualToString:@"host"]){ self.host = [info objectForKey:key]; }
        if ([key isEqualToString:@"image"]){ 
            NSString *img = [info objectForKey:key];
            NSArray *parts = [img componentsSeparatedByString:@"=="];
            self.image = [parts objectAtIndex:0];
        }
        
        if ([key isEqualToString:@"tags"]){ self.tags = [info objectForKey:key]; }
        if ([key isEqualToString:@"tracks"]){
            NSArray *t = [info objectForKey:key];
            if ([t containsObject:@"none"]){
                self.tracks = [NSMutableArray arrayWithArray:t];
            }
            else{
                [self parseTracks:t];
            }
        }
        if ([key isEqualToString:@"admins"]){ self.admins = [info objectForKey:key]; }
        if ([key isEqualToString:@"articles"]){ 
            NSArray *a = [info objectForKey:key];
            if ([a containsObject:@"none"]){
                self.articles = [NSMutableArray arrayWithArray:a];
            }
            else{
                NSMutableArray *array = [NSMutableArray array];
                for (NSString *s in a) {
                    Article *article = [[Article alloc] init];
                    [article parse:s];
                    [array addObject:article];
                    [article release];
                }
                self.articles = array;
                
            }
        }
        if ([key isEqualToString:@"plays"]){ self.plays = [[info objectForKey:key] longLongValue]; }
    }
    ready = TRUE;
}


@end
