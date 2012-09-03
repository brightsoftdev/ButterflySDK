//
//  TracksViewController.h
//  butterflyradio
//
//  Created by Denny Kwon on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButterflyViewController.h"
#import "AudioFile.h"
#import "RecordViewController.h"
#import "RadioViewController.h"


@interface TracksViewController : ButterflyViewController <UITableViewDelegate, UITableViewDataSource> {
    
    Station *station;
    UITableView *theTablview;

}

@property (retain, nonatomic) Station *station;
@end
