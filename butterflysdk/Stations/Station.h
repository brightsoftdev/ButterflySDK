//
//  Station.h
//  butterflyradio
//
//  Created by Denny Kwon on 4/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Globals.h"
#import "GetImage.h"
#import "Globals.h"
#import "Article.h"
#import "AudioFile.h"
#import "JSON.h"
#import "Database.h"
#import "URLRequest.h"
#import "Thread.h"


@protocol StationDelegate <NSObject>
@optional
- (void)imageReady:(NSString *)stationId;
- (void)thumbnailDownloaded:(NSString *)stationId;
- (void)stationInfoReady;
@end

@interface Station : NSObject <URLRequestDelegate> {
    
    NSString *name;
    NSString *unique_id;
    NSString *description;
    NSString *category;
    NSString *image;
    NSString *host;
    int adFreq;
    
    long long plays;
    NSArray *tags;
    NSMutableArray *tracks;
    NSMutableDictionary *threadMap;
    NSMutableArray *threadArray;
    NSArray *admins;
    NSMutableArray *articles;
    
    NSOperationQueue *queue;
    NSData *imgData;
    UIImage *thumbnail;
    GetImage *getImage;
    GetImage *getThumb;
    
    id delegate;
    BOOL ready;
    BOOL saved;
    URLRequest *req;
}

@property (assign) id delegate;
@property (nonatomic) int adFreq;
@property (nonatomic) BOOL ready;
@property (nonatomic) BOOL saved;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *host;
@property (copy, nonatomic) NSString *unique_id;
@property (copy, nonatomic) NSString *description;
@property (copy, nonatomic) NSString *category;
@property (copy, nonatomic) NSString *image;
@property (retain, nonatomic) NSArray *tags;
@property (retain, nonatomic) NSArray *admins;
@property (retain, nonatomic) NSMutableArray *tracks;
@property (retain, nonatomic) NSMutableArray *articles;
@property (retain, nonatomic) NSMutableArray *threadArray;
@property (retain, nonatomic) NSMutableDictionary *threadMap;
@property (nonatomic) long long plays;
@property (retain, nonatomic) NSData *imgData;
@property (retain, nonatomic) UIImage *thumbnail;
- (void)getStationInfo;
- (void)populate:(NSDictionary *)info;
- (void)fetchImage;
- (void)fetchThumbnail:(int)dimen;
- (NSString *)adminsString;
- (void)save;
- (void)deleteFromDb;
- (NSString *)tagsString;
- (void)cancelUpdate;
@end