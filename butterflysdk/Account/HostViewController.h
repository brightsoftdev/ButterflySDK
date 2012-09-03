//
//  HostViewController.h
//  butterflyradio
//
//  Created by Denny Kwon on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButterflyViewController.h"
#import "StationAdminViewController.h"
#import "CreateStationViewController.h"
#import "AdminCell.h"


@interface HostViewController : ButterflyViewController <UITableViewDelegate, UITableViewDataSource, BRNetworkOpDelegate, StationDelegate, AdminCellDelegate, CreateStationDelegate> {
    
    Host *host;
    UITableView *theTableview;
    UILabel *descriptionLabel;
    
    BRNetworkOp *req;
    LoadingIndicator *loading;
    int deleteIndex;
    BOOL newStation, goToBtfly;
    
    
}

@property (retain, nonatomic) Host *host;
@end
