//
//  ControlPanelView.h
//  soundbyte
//
//  Created by Denny Kwon on 11/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"



@interface ControlPanelView : UIView {
    
    UISlider *slider;
    Player *player;
}

@property (retain, nonatomic) UISlider *slider;
@property (retain, nonatomic) Player *player;
- (void)sliderValue;
- (void)showSlider;
- (void)hideSlider;
- (void)audioBtnPressed:(id)sender;
@end
