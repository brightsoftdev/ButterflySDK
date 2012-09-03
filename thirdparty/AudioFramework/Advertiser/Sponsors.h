//
//  Sponsors.h
//  TeamLove
//
//  Created by Denny Kwon on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLRequest.h"
#import "JSON.h"
#import "Constants.h"
#import "AudioFile.h"
#import "Location.h"

@interface Sponsors : NSObject <URLRequestDelegate, LocationDelegate> {
    URLRequest *req;
    NSMutableArray *sponsors;
    Location *location;
    
    AudioFile *next;
    
    int selected;
    BOOL ready; //set to true once a sponsors list is received
}

@property (retain ,nonatomic) Location *location;
@property (retain, nonatomic) NSMutableArray *sponsors;
@property (nonatomic) BOOL ready;
- (void)findlocation;
- (AudioFile *)getRandomFile;
- (void)prepareNext;
- (AudioFile *)getSelectedFile;
@end
