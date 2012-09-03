//
//  StationDetailCell.h
//  butterflyradio
//
//  Created by Denny Kwon on 8/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import <QuartzCore/QuartzCore.h>

@protocol DetailCellDelegate <NSObject>
- (void)cellTapped:(NSArray *)contents;
@end

@interface StationDetailCell : UITableViewCell {
    
    id delegate;
}

@property (assign) id delegate;
@property (retain, nonatomic) UIButton *btnGarbage;
- (void)setup:(int)mode;
@end
