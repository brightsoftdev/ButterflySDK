//
//  ButterflyManager.h
//  frenchkiss
//
//  Created by Denny Kwon on 8/19/12.
//  Copyright (c) 2012 Frenchkiss Records. All rights reserved.


#import <Foundation/Foundation.h>
#import "Globals.h"
#import "BRNetworkOp.h"
#import "Station.h"
#import "JSON.h"
#import "Host.h"
#import "Player.h"
#import "Database.h"


@protocol ButterflyDelegate <NSObject>

@end


@interface ButterflyManager : NSObject <BRNetworkOpDelegate> {
    BRNetworkOp *req;
    NSOperationQueue *queue;
}

@property (assign) id delegate;
@property (retain, nonatomic) Database *db;
@property (retain, nonatomic) Player *player;
@property (retain, nonatomic) Host *host;
@property (retain, nonatomic) Station *currentStation;
@property (retain, nonatomic) NSMutableDictionary *stations;
@property (retain, nonatomic) NSString *appBundle;
@property (retain, nonatomic) NSString *appName;
@property (retain, nonatomic) NSString *appVersion;
@property (copy, nonatomic) NSString *appHost;
+ (ButterflyManager *)managerWithAppHost:(NSString *)appHost;
- (void)fetchStations;
- (void)getStationsByAdmin:(NSString *)admin;
- (void)showRadio;
- (void)start:(int)index;
- (void)receivedRemoteControlEvent:(UIEvent *)event;
- (void)searchStations:(BRStationSearchFilter)filter;
@end
