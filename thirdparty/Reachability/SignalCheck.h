//
//  SignalCheck.h
//  FileStream
//
//  Created by Denny Kwon on 10/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@protocol SignalCheckDelegate
- (void)signalStatus:(BOOL)status;
@end


@interface SignalCheck : NSObject {
	Reachability *hostReach, *internetReach, *wifiReach;
	id delegate;
}

@property (assign) id delegate;
+ (SignalCheck *)signalWithDelegate:(id)del;
- (id)initWithDelegate:(id)del;
- (BOOL)checkSignal;
- (void)lostConnection;
- (void)reachabilityChanged:(NSNotification *)note;
- (void)statusChanged:(Reachability *)reach;
@end
