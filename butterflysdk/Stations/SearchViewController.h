//
//  SearchViewController.h
//  butterflyradio
//  Created by Denny Kwon on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.


#import <UIKit/UIKit.h>
#import "ButterflyViewController.h"


@interface SearchViewController : ButterflyViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, BRNetworkOpDelegate> {
    
    UITableView *theTableview;
    UISearchBar *theSearchBar;
    
    UIView *screen;
    BRNetworkOp *req;
    NSMutableArray *searchResults;
    LoadingIndicator *loading;
    
}

@property (retain, nonatomic) NSMutableArray *searchResults;
@end
