//
//  TrackDetailView.h
//  butterflyradio
//
//  Created by Denny Kwon on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol TrackDetailDelegate <NSObject>
- (void)sliding;
- (void)seekTo:(int)x;
@end


@interface TrackDetailView : UIView {
    
    UISlider *slider;
    id delegate;
    
    UILabel *nameLabel;
    UILabel *authorLabel;
    UILabel *dateLabel;
}

@property (assign) id delegate;
@property (retain, nonatomic) UISlider *slider;
@property (retain, nonatomic) UILabel *nameLabel;
@property (retain, nonatomic) UILabel *authorLabel;
@property (retain, nonatomic) UILabel *dateLabel;
@end
