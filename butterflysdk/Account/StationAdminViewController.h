//
//  StationAdminViewController.h
//  butterflyradio
//
//  Created by Denny Kwon on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButterflyViewController.h"
#import "StationDetailsViewController.h"
#import "ArticleViewController.h"
#import "StationDetailCell.h"
#import "InviteAdminViewController.h"
#import "ReviewsViewController.h"


@interface StationAdminViewController : ButterflyViewController <StationDelegate, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, BRNetworkOpDelegate, DetailCellDelegate> {
    
    Station *station;
    LoadingIndicator *loading;
    UITableView *theTableview;
    
    int mode; //0==tracks, 1==articles, 2==admins
    int deleteIndex;
    
    NSArray *icons;
    BRNetworkOp *req;
    BOOL reload;
    UIImage *tableBg;
    
}

@property (nonatomic) int mode;
@property (retain, nonatomic) Station *station;
@property (retain, nonatomic) Host *host;
@end
