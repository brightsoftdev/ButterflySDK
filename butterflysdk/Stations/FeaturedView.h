//
//  FeaturedView.h
//  butterflyradio
//
//  Created by Denny Kwon on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Globals.h"


@interface FeaturedView : UIButton {
    
    UIImageView *image;
    UILabel *nameLabel;
    UILabel *categoryLabel;
    
    CGFloat maxWidth;
    CGFloat maxHeight;
    CGRect originalFrame;
}

@property (retain, nonatomic) UIImageView *image;
@property (retain, nonatomic) UILabel *nameLabel;
@property (retain, nonatomic) UILabel *categoryLabel;
- (void)fillImage:(NSData *)imgData;
@end
