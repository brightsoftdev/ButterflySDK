//
//  SummaryView.h
//  butterflyradio
//
//  Created by Denny Kwon on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import <QuartzCore/QuartzCore.h>


@interface SummaryView : UIView {
    
    UIImageView *image;
    UILabel *detailsLabel;
    UILabel *titleLabel;
    
}

- (id)initWithFrame:(CGRect)frame image:(UIImage *)img;
@property (retain, nonatomic) UIImageView *image;
@property (retain, nonatomic) UILabel *detailsLabel;
@property (retain, nonatomic) UILabel *titleLabel;
@end
