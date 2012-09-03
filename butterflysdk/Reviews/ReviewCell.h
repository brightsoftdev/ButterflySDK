//
//  ReviewCell.h
//  butterflyradio
//
//  Created by Denny Kwon on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import <QuartzCore/QuartzCore.h>


@interface ReviewCell : UITableViewCell {
    
    UILabel *commentLabel;
    UILabel *detailsLabel;
    
    UIView *base;
    
    UIImageView *star0;
    UIImageView *star1;
    UIImageView *star2;
    UIImageView *star3;
    UIImageView *star4;
    NSMutableArray *stars;
}

@property (retain, nonatomic) UIImageView *star0;
@property (retain, nonatomic) UIImageView *star1;
@property (retain, nonatomic) UIImageView *star2;
@property (retain, nonatomic) UIImageView *star3;
@property (retain, nonatomic) UIImageView *star4;
@property (retain, nonatomic) UILabel *commentLabel;
@property (retain, nonatomic) UILabel *detailsLabel;
- (void)resize;
- (void)fillStars:(int)rating;
@end
