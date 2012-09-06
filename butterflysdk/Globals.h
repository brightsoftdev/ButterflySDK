//
//  Globals.h
//  butterflyradio
//
//  Created by Denny Kwon on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef butterflyradio_Globals_h
#define butterflyradio_Globals_h

typedef enum {
    StationSearchFilterTop = 0, //top 10 stations overall
    StationSearchFilterAdmin, // all stations where ButterflyManager email is also an admin
    StationSearchFilterEmail //stations whose host is the ButterflyManager email
} BRStationSearchFilter;


#define kUrl @"thegrid-butterflyradio.appspot.com"

// NOTIFICATIONS:
#define kImageReadyNotification @"image ready"
#define kThumbnailReadyNotification @"thumbnail ready"
#define kSupportLandscape @"support_landscape"
#define kPortraitOnly @"portraitOnly"
#define kResetDatabase @"resetDatabase"
#define kUpdate @"update"
#define kInterruptionNotification @"pause"
#define kRefreshNotification @"refresh"
#define kResetFeaturedViews @"ResetFeaturedViews"


#define REFRESH_HEADER_HEIGHT 62.0f
#define kCellLabelWidth 290.0f
//#define kCellHeight 55.0f //standard cell height for TracksVC and ArticlesVC
#define kCellHeight 65.0f //standard cell height for TracksVC and ArticlesVC
#define kAdminCellHeight 150.0f
#define kDetailCellHeight 100.0f //standard cell height for tracks, articles, admins in login section
#define kRGBMax 255.0f
#define kMainBackground @"bg_generic.png"
#define kFont @"Heiti SC"
#define kMaxDimen 130.0f //max image dimensions


#define kDatabase @"database.sqlite3"
#define kTimeLimit 300
#define kCategories [[NSArray alloc] initWithObjects:@"advice", @"comedy", @"misc", @"politics", @"sports", nil]
#define kItunesURL @"http://itunes.apple.com/us/app/butterfly-radio/id532051737?mt=8"

#define kAdminStationsReq @"AdminStations"

#endif
