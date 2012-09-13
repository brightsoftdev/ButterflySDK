//
//  ButterflyManager.m
//  frenchkiss
//
//  Created by Denny Kwon on 8/19/12.
//  Copyright (c) 2012 Frenchkiss Records. All rights reserved.
//

#import "ButterflyManager.h"


static ButterflyManager *manager;

@implementation ButterflyManager
@synthesize currentStation;
@synthesize stations;
@synthesize host;
@synthesize player;
@synthesize delegate;
@synthesize appBundle;
@synthesize appName;
@synthesize appVersion;
@synthesize appHost;
@synthesize db;
@synthesize favorites;


- (id)initWithAppHost:(NSString *)hostStation
{
    self = [super init];
    if (self){
        self.appHost = [hostStation lowercaseString];
        self.stations = nil;
        
        queue = [[NSOperationQueue alloc] init];
        NSLog(@"BUTTERFLY MANAGER - INIT WITH APP HOST: %@", self.appHost);
        [self configure];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newFile:) name:@"new file" object:nil];
        
        Host *h = [[Host alloc] init];
        self.host = h;
        self.host.appHost = self.appHost;
        [h release];
        
        Player *p = [[Player alloc] init];
        self.player = p;
        [p release];
        
        [self checkDatabase];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkFavorites) name:kResetDatabase object:nil];
    }
    return self;
}



+ (ButterflyManager *)managerWithAppHost:(NSString *)appHost
{
    if (manager==nil){
        manager = [[ButterflyManager alloc] initWithAppHost:appHost];
    }

    return manager;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"new file" object:nil];
    self.currentStation = nil;
    self.host = nil;
    self.player = nil;
    self.appBundle = nil;
    self.appName = nil;
    self.appVersion = nil;
    self.appHost = nil;
    self.db = nil;
    self.favorites = nil;
    
    if (req!=nil){
        req.delegate = nil;
        [req cancel];
        [req release];
    }
    
    if (manager){
        [manager release];
    }
    [queue release];
    [super dealloc];
}

- (void)configure
{
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    NSLog(@"%@", [appInfo description]);
    if (appInfo){
        NSString *bundleId = [appInfo objectForKey:@"CFBundleIdentifier"];
        if (bundleId)
            self.appBundle = bundleId;
        
        NSString *aName = [appInfo objectForKey:@"CFBundleDisplayName"];
        if (aName)
            self.appName = aName;
        
        NSString *version = [appInfo objectForKey:@"CFBundleVersion"];
        if (version)
            self.appVersion = version;
        
    }
}



- (NSString *)createFilePath:(NSString *)fileName
{
	fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"+"];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
	return filePath;
}

- (void)checkDatabase
{
    // First, test for existence.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *writableDBPath = [self createFilePath:kDatabase];
    BOOL success = [fileManager fileExistsAtPath:writableDBPath];
    if (success==TRUE){
        NSLog(@"DATABASE FOUND!");
        self.db = [Database database];
        [self checkFavorites];

        return;
    }
    
    // The writable database does not exist, so copy the default to the appropriate location.    NSLog(@"CREATING NEW DATABASE");
    NSError *error = nil;
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDatabase];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
    
    self.db = [Database database];
    [self checkFavorites];
}

- (void)checkFavorites
{
    NSLog(@"BUTTERFLY MANAGER - checkFavorites");
    self.favorites = [db fetchAll];
}

- (void)loadTrack:(NSIndexPath *)indexPath fromStation:(Station *)station
{
    Thread *thread = (Thread *)[station.threadArray objectAtIndex:indexPath.section];
    AudioFile *track = (AudioFile *)[thread.thread objectAtIndex:indexPath.row];
    
    self.player.files = station.tracks;
    self.player.adFrequency = station.adFreq;
    self.currentStation = station;
    
    if (self.player.streamer.isRunning==TRUE){
        [self.player playFile:[station.tracks indexOfObject:track]];
    }
    else {
        [self.player start:[station.tracks indexOfObject:track]];
    }
}

- (void)fetchStations
{
//    [self checkCache:kAdminStationsReq];
    if (req!=nil){
        req.delegate = nil;
        [req cancel];
        [req release];
    }
    
    NSString *url = [NSString stringWithFormat:@"http://%@/api/station?admins=%@", kUrl, self.appHost];
    NSLog(@"BUTTERFLY MANAGER - FETCH STATIONS: %@", url);
    req = [[BRNetworkOp alloc] initWithAddress:url parameters:nil];
    req.delegate = self;
    [req setHttpMethod:@"GET"];
    [req sendRequest];
}


- (void)requestData:(NSArray *)pkg
{
    if (pkg==nil)
        return;
    
    NSLog(@"PACKAGE: %d", [pkg count]);
    
    NSData *returnData = [pkg objectAtIndex:1];
    NSString *jsonString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%d bytes, JSON STRING: %@", returnData.length, jsonString);
    [jsonString release];
    
    NSError *error = nil;
    NSDictionary *d = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers error:&error];
    if (error){
        [req sendRequest];
        return;
    }
    
    d = [d objectForKey:@"results"];
    NSLog(@"BUTTERFLY MANAGER - REQUEST DATA: %@", [d description]);
    
    NSString *confirmation = [d objectForKey:@"confirmation"];
    if ([confirmation isEqualToString:@"found"]){
        NSArray *s = [d objectForKey:@"stations"];
        if ([s containsObject:@"none"])
            return;
        

        if (self.stations==nil)
            self.stations = [NSMutableDictionary dictionary];
        
        [self.stations removeAllObjects];
        NSMutableArray *allStations = [NSMutableArray array];
        NSMutableArray *hostStations = [NSMutableArray array];
        NSMutableArray *admin = [NSMutableArray array];
        
        for (int i=0; i<[s count]; i++){
            NSDictionary *info = [s objectAtIndex:i];
            Station *station = [[Station alloc] init];
            [station populate:info];
            
            [allStations addObject:station];
            if ([station.host isEqualToString:self.appHost]){
                [hostStations addObject:station];
            }
            else{
                [admin addObject:station];
            }
            [station release];
        }
        
        [self.stations setObject:allStations forKey:@"all"];
        [self.stations setObject:hostStations forKey:@"host"];
        [self.stations setObject:admin forKey:@"admin"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kStationsReadyNotification object:nil]];
}


- (void)showRadio
{
    NSLog(@"BUTTERFLY MANAGER - show radio");
}

- (void)start:(int)index
{
    NSLog(@"BUTTERFLY MANAGER - start: %d", index);
}



- (void)newFile:(NSNotification *)note //this notification comes from the Payer whenever a new file is loaded
{
    NSDictionary *info = [note userInfo];
    NSLog(@"BUTTERFLY MANAGER: %@", [info description]);
    
    /*
    [advertisement flush];
    NSString *ad = [info objectForKey:@"ad"];
    NSDictionary *fileInfo = [info objectForKey:@"fileInfo"];
    if ([ad isEqualToString:@"yes"]){
        if (fileInfo!=nil){
            advertisement.fileInfo = fileInfo;
            [advertisement setupAd];
        }
        //show the ad
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.7];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:advertisement.view cache:YES];
        advertisement.view.hidden = NO;
        [UIView commitAnimations];
    }
    else{ //Hide the ad
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.7];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:advertisement.view cache:YES];
        advertisement.view.hidden = YES;
        [UIView commitAnimations];
    }
     */
}

#pragma mark - StationSearches:
- (void)searchStations:(BRStationSearchFilter)filter
{
    NSString *url = nil;
    
    
    if (filter==StationSearchFilterTop)
        url = [NSString stringWithFormat:@"http://%@/api/station", kUrl];


    if (filter==StationSearchFilterEmail)
        url = [NSString stringWithFormat:@"http://%@/api/station?host=%@", kUrl, self.appHost];


    if (filter==StationSearchFilterAdmin)
        url = [NSString stringWithFormat:@"http://%@/api/station?admins=%@", kUrl, self.appHost];

    
    if (!url)
        return;

    GetImage *adminStations = [[GetImage alloc] initWithTarget:self address:url action:@selector(searchResultsReturned:) filter:filter];
    [queue addOperation:adminStations];
    [adminStations release];

}

- (void)searchResultsReturned:(NSArray *)pkg
{
    NSLog(@"searchResultsReturned:");
    if (pkg!=nil){
        NSData *returnData = [pkg lastObject];
        
        NSError *error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:returnData options:NSJSONReadingMutableContainers error:&error];
        if (error)
            return;
        
        NSLog(@"%@", [jsonObject description]);
        
        
        
    }
    
}

#pragma mark - RemoteControlNotifications;
//    [self.butterflyMgr receivedRemoteControlEvent:event];
- (void)receivedRemoteControlEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype==UIEventSubtypeRemoteControlPlay){
            NSLog(@"PLAY");
            if (self.player){
                [self.player play];
            }
        }
        if (event.subtype==UIEventSubtypeRemoteControlPause){
            NSLog(@"PAUSE");
            if (self.player){
                [self.player pause];
            }
        }
        if (event.subtype==UIEventSubtypeRemoteControlStop){
            if (self.player){
                [self.player pause];
            }
            NSLog(@"STOP");
        }
        if (event.subtype==UIEventSubtypeRemoteControlTogglePlayPause){
            NSLog(@"TOGGLE PLAY PAUSE");
            if (self.player){
                if (self.player.streamer.isRunning){
                    [self.player pause];
                }
                else{
                    [self.player play];
                }
            }
        }
        if (event.subtype==UIEventSubtypeRemoteControlNextTrack){
            NSLog(@"SKIP");
            if (self.player){
                [self.player skip];
            }
        }
        if (event.subtype==UIEventSubtypeRemoteControlPreviousTrack){
            NSLog(@"GO BACK");
        }
    }
}




@end
