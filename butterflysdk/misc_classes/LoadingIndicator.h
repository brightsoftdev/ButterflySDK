//
//  LoadingIndicator.h
//  butterflyradio
//
//  Created by Denny Kwon on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface LoadingIndicator : UIView {
    UIActivityIndicatorView *spinner;
    UILabel *titleLabel;
    UIView *darkScreen;
}

@property (retain, nonatomic) UIView *darkScreen;
@property (retain, nonatomic) UILabel *titleLabel;
- (void)show;
- (void)hide;
@end
