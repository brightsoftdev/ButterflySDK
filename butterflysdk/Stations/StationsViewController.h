//
//  StationsViewController.h
//  butterflyradio
//
//  Created by Denny Kwon on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButterflyViewController.h"
#import "StationViewController.h"
#import "FeaturedView.h"
#import "TracksViewController.h"


@interface StationsViewController : ButterflyViewController <BRNetworkOpDelegate>{
    NSMutableDictionary *searchedStations;
    UIScrollView *featuredView;
    
    LoadingIndicator *loading;
    NSString *searchString;
    BRNetworkOp *req;
    
    int imageCount;
    BOOL reload;
    
//    SignalCheck *signal;
    
    
}

@property (copy, nonatomic) NSString *searchString;
@end
