//
//  SignalCheck.m
//  FileStream
//
//  Created by Denny Kwon on 10/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SignalCheck.h"
#import <UIKit/UIKit.h>

static SignalCheck *sig;

@implementation SignalCheck
@synthesize delegate;

- (id)initWithDelegate:(id)del
{
	self = [super init];
	if (self){
		self.delegate = del;
	}
	return self;
}

+ (SignalCheck *)signalWithDelegate:(id)del
{
    if (sig==nil){
        sig = [[SignalCheck alloc] initWithDelegate:del];
    }
    
    return sig;
}


- (void)dealloc
{
    if (sig!=nil){
        [sig release];
    }
	[hostReach release];
	[internetReach release];
	[wifiReach release];
	[super dealloc];
}

- (void)lostConnection
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Network Connection" message:@"please find an internet connection" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
	[alert show]; [alert release];
}

- (void)reachabilityChanged:(NSNotification *)note
{
	Reachability *current = [note object];
	NSParameterAssert([current isKindOfClass:[Reachability class]]);
	[self statusChanged:current];
}


- (void)statusChanged:(Reachability *)reach
{
	NSLog(@"status changed called");
	NetworkStatus status = [reach currentReachabilityStatus];
	switch (status) {
		case NotReachable: {
			NSLog(@"no connection");
			[self lostConnection];
			break;
		}
		case ReachableViaWWAN: {
			NSLog(@"WWAN connected");
			break;
		}
		case ReachableViaWiFi: {
			NSLog(@"wifi connected");
			break;
		}
	}
}

- (BOOL)checkSignal
{
    BOOL signal = YES;
	hostReach = [[Reachability reachabilityWithHostName:@"http://www.google.com"] retain];
	internetReach = [[Reachability reachabilityForInternetConnection] retain];
	wifiReach = [[Reachability reachabilityForLocalWiFi] retain];
	if ([hostReach currentReachabilityStatus]==NotReachable&&[wifiReach currentReachabilityStatus]==NotReachable&&[internetReach currentReachabilityStatus]==NotReachable){
        signal = FALSE;
	}
    return signal;
}


@end
