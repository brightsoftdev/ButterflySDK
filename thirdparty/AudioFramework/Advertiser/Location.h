//
//  Location.h
//  TeamLove
//
//  Created by Denny Kwon on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "URLRequest.h"
#import "JSON.h"
#import "SignalCheck.h"

//http://maps.googleapis.com/maps/api/geocode/json?latlng=41.02558410,-74.05188041&sensor=true

@protocol LocationDelegate <NSObject>
- (void)locationReady;
@end

@interface Location : NSObject <CLLocationManagerDelegate, URLRequestDelegate, SignalCheckDelegate>{
    
    CLLocationManager *locationManager;
    CLLocation *location;
    
    URLRequest *req;
    NSString *zip;
    NSString *state;
    
    SignalCheck *signal;
    id delegate;
    
}

@property (retain, nonatomic) CLLocation *location;
@property (copy, nonatomic) NSString *zip;
@property (copy, nonatomic) NSString *state;
@property (assign) id delegate;
- (void)findCurrentLocation;
+ (Location *)location;
@end
