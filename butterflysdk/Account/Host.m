//
//  Host.m
//  butterflyradio
//
//  Created by Denny Kwon on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Host.h"

static NSString *emailKey = @"hostEmail";

@implementation Host
@synthesize email;
@synthesize emailHost;
@synthesize name;
@synthesize stations;
@synthesize loggedIn;
@synthesize guest;
@synthesize appHost;

- (id)init
{
    self = [super init];
    if (self){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *savedEmail = [defaults objectForKey:emailKey];
        if (savedEmail==nil){
            savedEmail = @"none";
        }
        
        self.email = savedEmail;
        loggedIn = FALSE;
        NSLog(@"HOST EMAIL == %@", email);
    }
    return self;
}


- (void)populate:(NSDictionary *)info
{
    for (NSString *key in [info allKeys]){
        if ([key isEqualToString:@"name"]){
            self.name = [info objectForKey:key];
        }
        if ([key isEqualToString:@"email"]){
            self.email = [info objectForKey:key];
            self.loggedIn = TRUE;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:self.email forKey:emailKey];
            [defaults synchronize];
        }
        if ([key isEqualToString:@"emailhost"]){
            self.emailHost = [info objectForKey:key];
        }
        
        if ([key isEqualToString:@"shared stations"]){ //all stations where the host is an admin.
            NSArray *s = [info objectForKey:key];
            if ([s count]==0){ self.stations = [NSArray arrayWithObject:@"none"]; }
            else{
                NSMutableArray *a = [NSMutableArray array];
                for (NSDictionary *info in s){ 
                    Station *st = [[Station alloc] init];
                    [st populate:info];
                    if (self.guest==TRUE){
//                        if ([st.admins containsObject:kAppHost]){ //only add stations that the host shares with current app host
//                            [a addObject:st];
//                        }
                        
                        if ([st.admins containsObject:self.appHost]){ //only add stations that the host shares with current app host
                            [a addObject:st];
                        }
                    }
                    else {
                        [a addObject:st];
                    }
                    [st release];
                }
                self.stations = a;
            }
        }
    }
}

- (void)refresh
{
    if (req!=nil){
        req.delegate = nil;
        [req cancel];
        [req release];
    }
    
    NSString *url = [NSString stringWithFormat:@"http://www.butterflyradio.com/api/host?email=%@", self.email];
    req = [[URLRequest alloc] initWithAddress:url parameters:nil];
    [req setHttpMethod:@"GET"];
    req.delegate = self;
    [req sendRequest];
}

- (void)requestData:(NSArray *)pkg //returns [address, data]
{
    if (pkg!=nil){
        NSString *json = [[NSString alloc] initWithData:[pkg objectAtIndex:1] encoding:NSUTF8StringEncoding];
        NSDictionary *d = [json JSONValue];
        if (d==nil) {
            NSLog(@"JSON ERROR: %@", json);
            [json release];
            [req sendRequest];
            return;
        }
        
        d = [d objectForKey:@"results"];
        NSLog(@"%@", [d description]);
        NSString *confirmation = [d objectForKey:@"confirmation"];
        
        if ([confirmation isEqualToString:@"found"]){
            NSDictionary *info = [d objectForKey:@"host"];
            [self populate:info];
        }
        
        [json release];
        
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kRefreshNotification object:nil]];
    }
}


- (void)dealloc
{
    self.appHost = nil;
    [email release];
    [emailHost release];
    [name release];
    [stations release];
    [super dealloc];
}

@end
