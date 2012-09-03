//
//  ReviewsViewController.h
//  butterflyradio
//
//  Created by Denny Kwon on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButterflyViewController.h"
#import "ReviewCell.h"
#import "CommentViewController.h"
#import "SummaryView.h"


@interface Comment : NSObject {
    NSString *text;
    NSString *username;
    NSString *date;
    int rating;
}

@property (nonatomic) int rating;
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *date;
- (void)populate:(NSString *)c;
@end

typedef enum {
    ReviewModeStation = 0,
    ReviewModeArticle,
    ReviewModeTrack,
} ReviewMode;


@interface ReviewsViewController : ButterflyViewController <BRNetworkOpDelegate, UITableViewDelegate, UITableViewDataSource, CommentVCDelegate> {
    
    UITableView *theTableview;
    LoadingIndicator *loading;
    BRNetworkOp *req;
    Station *station;
    NSMutableArray *commentsArray;
    int offset;
    
    ReviewMode mode; //0 is default
    NSString *uniqueID;
    BOOL showStars;
    UIImageView *image;
    SummaryView *tableHeader;
}

- (id)initWithMode:(ReviewMode)m;
@property (nonatomic) BOOL showStars;
@property (retain, nonatomic) Station *station;
@property (copy, nonatomic) NSString *uniqueID;
@end
