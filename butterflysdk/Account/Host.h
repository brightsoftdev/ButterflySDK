//
//  Host.h
//  butterflyradio
//
//  Created by Denny Kwon on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Globals.h"
#import "Station.h"

@interface Host : NSObject <URLRequestDelegate> {
    
    NSString *email;
    NSString *emailHost;
    NSString *name;
    NSArray *stations; //array of dictionaries
    
    BOOL loggedIn;
    BOOL guest;
    
    URLRequest *req;
    
}

@property (nonatomic) BOOL guest;
@property (nonatomic) BOOL loggedIn;
@property (copy, nonatomic) NSString *appHost;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *emailHost;
@property (copy, nonatomic) NSString *name;
@property (retain, nonatomic) NSArray *stations;
- (void)populate:(NSDictionary *)info;
- (void)refresh;
@end
