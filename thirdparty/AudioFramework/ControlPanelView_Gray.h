//
//  ControlPanelView_Gray.h
//  TeamLove
//
//  Created by Denny Kwon on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"
#import <QuartzCore/QuartzCore.h>

@interface ControlPanelView_Gray : UIView {
    UISlider *slider;
    Player *player;
    
    UIImageView *image;
    UILabel *authorLabel;
    UILabel *titleLabel;

}

@property (retain, nonatomic) UISlider *slider;
@property (retain, nonatomic) Player *player;
- (void)sliderValue;
- (void)showSlider;
- (void)hideSlider;
- (void)audioBtnPressed:(id)sender;
- (void)showFileInfo:(NSDictionary *)info;
- (void)fillImage:(UIImage *)img;
- (void)clear;
@end
