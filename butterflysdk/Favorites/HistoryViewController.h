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
    NSMutableArray *saved; //station name==email==category==image
    Database *db;
    
    UIImage *cellBg;
    UILabel *explanation;
}

@property (retain, nonatomic) NSMutableArray *saved;
@end
