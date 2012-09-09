//
//  HistoryViewController.h
//  butterflyradio
//
//  Created by Denny Kwon on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.


#import <UIKit/UIKit.h>
#import "ButterflyViewController.h"
#import "Database.h"
#import "HistoryCell.h"
#import "StationViewController.h"

@interface HistoryViewController : ButterflyViewController <UITableViewDelegate, UITableViewDataSource, StationDelegate, HistoryCellDelegate> {
    
    UITableView *theTableview;
    
    UIImage *cellBg;
    UILabel *explanation;
}

@end
