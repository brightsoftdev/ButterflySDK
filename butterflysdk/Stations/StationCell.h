//
//  StationCell.h
//  butterflyradio
//
//  Created by Denny Kwon on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"

@protocol StationTableCellDelegate <NSObject>
- (void)btnReplyTapped:(NSIndexPath *)ip;
@end

@interface StationCell : UITableViewCell {
    
    UIButton *btnReply;
    NSIndexPath *ip;
    id delegate;
    
}

@property (assign) id delegate;
@property (retain, nonatomic) NSIndexPath *ip;
@property (retain, nonatomic) UIButton *btnReply;
- (void)setup;
@end
