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


- (id)initWithAppHost:(NSString *)hostStation
{
    self = [super init];
    if (self){
        self.appHost = hostStation;
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
        
        [self checkDatabase]; // 

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

}


- (void)checkCache:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *json = [defaults objectForKey:kAdminStationsReq];
    if (json){
        [self parse:json];
    }
}

- (void)getStationsByAdmin:(NSString *)admin //returns all stations with specific admin
{
    [self checkCache:kAdminStationsReq];
    if (req!=nil){
        req.delegate = nil;
        [req cancel];
        [req release];
    }
    
    NSString *url = [NSString stringWithFormat:@"http://%@/api/station?admins=%@", kUrl, admin];
    req = [[BRNetworkOp alloc] initWithAddress:url parameters:nil];
    req.delegate = self;
    [req setHttpMethod:@"GET"];
    [req sendRequest];
}

- (void)parse:(NSString *)json
{
    NSDictionary *d = [json JSONValue];
    if (d==nil){
        NSLog(@"JSON ERROR: %@", json);
        [req sendRequest];
    }
    else{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:json forKey:kAdminStationsReq];
        [defaults synchronize];

        d = [d objectForKey:@"results"];
        NSLog(@"%@", [d description]);
        
        NSString *confirmation = [d objectForKey:@"confirmation"];
        if ([confirmation isEqualToString:@"found"]){
            self.stations = [NSMutableDictionary dictionary];
            NSArray *s = [d objectForKey:@"stations"];
            for (int i=0; i<[s count]; i++){
                NSDictionary *info = [s objectAtIndex:i];
                Station *station = [[Station alloc] init];
                [station populate:info];
                
                [stations setObject:station forKey:station.name];
                [station release];
            }
        }
    }
}

- (void)requestData:(NSArray *)pkg
{
    if (pkg!=nil){
        NSString *json = [[NSString alloc] initWithData:[pkg objectAtIndex:1] encoding:NSUTF8StringEncoding];
        [self parse:json];
        [json release];
    }
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
