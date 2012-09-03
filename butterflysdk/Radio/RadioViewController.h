//
//  RadioViewController.h
//  butterflyradio
//  Created by Denny Kwon on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.


#import <UIKit/UIKit.h>
#import "ButterflyViewController.h"
#import "Twitter/Twitter.h"
#import "TrackDetailView.h"
#import "ReviewsViewController.h"
#import "RecordViewController.h"
#import <MessageUI/MessageUI.h>


@interface RadioViewController : ButterflyViewController <TrackDetailDelegate, MFMailComposeViewControllerDelegate> {
    
    UIButton *playPause;
    
    UIImageView *image;
    UIImageView *reflectionView;
    BOOL show;
    
    TrackDetailView *detailsView;
    UILabel *trackTitleLabel;
    
    UIImage *img_pause;
    UIImage *img_play;
    
    LoadingIndicator *loading;
}

@property (retain, nonatomic) UIImageView *image;
@property (retain, nonatomic) UIButton *playPause;
@property (retain, nonatomic) LoadingIndicator *loading;
@end
