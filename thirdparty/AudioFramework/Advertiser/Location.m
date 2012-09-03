//
//  Location.m
//  TeamLove
//
//  Created by Denny Kwon on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Location.h"

@implementation Location
@synthesize location;
@synthesize zip;
@synthesize state;
@synthesize delegate;

-(id)init
{
    self = [super init];
    if (self){
        double coords[2] = {0.0f, 0.0f};
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        coords[0] = [defaults doubleForKey:@"latitude"];
        coords[1] = [defaults doubleForKey:@"longitude"];
        location = [[CLLocation alloc] initWithLatitude:coords[0] longitude:coords[1]];
        NSLog(@"LOCATION - CACHED: %f, %f", location.coordinate.latitude, location.coordinate.longitude);
        
        NSString *z = [defaults stringForKey:@"zip"];
        if (z!=nil){ self.zip = z; }
        else{ self.zip = [NSString stringWithFormat:@"00000"]; }
        NSLog(@"LOCATION - CACHED: zip=%@", self.zip);
        
        NSString *s = [defaults stringForKey:@"state"];
        if (s==nil){ self.state = [NSString stringWithFormat:@"anywhere"]; }
        else{ self.state = s; }
        NSLog(@"LOCATION - CACHED: state=%@", self.state);
    }
    return self;
}

+ (Location *)location
{
    Location *l = [[Location alloc] init];
    return [l autorelease];
}

- (void)dealloc
{
    NSLog(@"LOCATION - dealloc");
    [zip release];
    [locationManager release];
    [state release];
    [location release];
    if (req != nil){
        [req release];
    }
    [super dealloc];
}

- (void)findCurrentLocation
{
    if (locationManager==nil){
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 200.0;
        [locationManager startUpdatingLocation];
    }
}

- (void)requestData:(NSArray *)pkg //returns [address, data]
{
    if (pkg !=nil ){
        NSString *json = [[NSString alloc] initWithData:[pkg objectAtIndex:1] encoding:NSUTF8StringEncoding];
        NSDictionary *d = [json JSONValue]; [json release];
        if (d==nil){
            
        }
        else{
            NSString *status = [d objectForKey:@"status"];
            if (status){
                if ([status isEqualToString:@"OK"]){
                    NSArray *parts = [d objectForKey:@"results"];
                    NSArray *components = [[parts objectAtIndex:0] objectForKey:@"address_components"]; //Array of dictionaries
                    NSLog(@"%@", [components description]);
                    for (NSDictionary *component in components){
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        NSArray *types = [component objectForKey:@"types"];
                        if ([types containsObject:@"postal_code"]){
                            self.zip = [component objectForKey:@"short_name"];
                            [defaults setObject:self.zip forKey:@"zip"];
                            [defaults synchronize];
                        }
                        if ([types containsObject:@"administrative_area_level_1"]){
                            self.state = [component objectForKey:@"short_name"];
                            [defaults setObject:self.state forKey:@"state"];
                            [defaults synchronize];
                        }
                    }
                    NSLog(@"LOCATION: state=%@, zip=%@", self.state, self.zip);
                    [delegate locationReady];
                }
            }
        }
    }
}

- (void)reverseGeocode
{
    signal = [[SignalCheck alloc] initWithDelegate:self];
    [signal checkSignal];
}

- (void)signalStatus:(BOOL)status
{
    if (status==TRUE){
        if (req!=nil){ [req release]; req = nil; }
        NSString *url = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true", location.coordinate.latitude, location.coordinate.longitude];
        req = [[URLRequest alloc] initWithAddress:url parameters:nil];
        [req setHttpMethod:@"GET"];
        req.delegate = self;
        [req sendRequest];
    }
    [signal release];
    signal.delegate = nil;
    signal = nil;
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"manager didUpdateToLocation: (%.2f, %.2f); accuracy = %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude, newLocation.horizontalAccuracy);
    if (newLocation.horizontalAccuracy < 500 && abs([newLocation.timestamp timeIntervalSinceNow])<=5){
        [locationManager stopUpdatingLocation];
        
        self.location = newLocation;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setDouble:self.location.coordinate.latitude forKey:@"latitude"];
        [defaults setDouble:self.location.coordinate.longitude forKey:@"longitude"];
        [defaults synchronize];
        
        [self reverseGeocode];
    }
    else{
        NSLog(@"LOCATION: Keep Trying");
    }

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"manager didFailWithError: %@", [error localizedDescription]);
    [locationManager stopUpdatingLocation];
    [delegate locationReady];
}

@end
