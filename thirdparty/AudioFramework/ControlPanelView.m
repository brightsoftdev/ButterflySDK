//
//  ControlPanelView.m
//  soundbyte
//
//  Created by Denny Kwon on 11/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ControlPanelView.h"

@implementation ControlPanelView
//@synthesize delegate;
@synthesize slider;
@synthesize player;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-20)];
        
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        
        UIBarButtonItem *cushionLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *play = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(audioBtnPressed:)];
        play.tag = 1001;
        
        UIBarButtonItem *flex1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *pause = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(audioBtnPressed:)];
        pause.tag = 1002;
        
        UIBarButtonItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *skip = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(audioBtnPressed:)];
        skip.tag = 1003;
        UIBarButtonItem *cushionRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        toolbar.items = [NSArray arrayWithObjects:cushionLeft, play, flex1, pause, flex2, skip, cushionRight, nil];
        [play release];
        [flex1 release];
        [pause release];
        [flex2 release];
        [skip release];
        [cushionLeft release];
        [cushionRight release];
        
        [self addSubview:toolbar];
        [toolbar release];
        
        slider = [[UISlider alloc] initWithFrame:CGRectMake(10, self.frame.size.height, 300, 20)];
        slider.minimumValue = 0.0f;
        slider.maximumValue = 0.0f;
        [slider addTarget:self action:@selector(sliding) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(sliderValue) forControlEvents:UIControlEventTouchUpInside];
        
        [slider setThumbImage:[UIImage imageNamed:@"track.png"] forState:UIControlStateNormal];
        [self addSubview:slider];
    }
    return self;
}

- (void)sliding
{
    NSLog(@"CONTROL PANEL VIEW - sliding:");
    [player pause];
}

- (void)sliderValue
{
    NSLog(@"CONTROL PANEL VIEW - sliderValue: %.3f", slider.value);
    if (slider.value<slider.maximumValue){ [player seek:slider.value]; }
    else{ [player skip]; } //slider scrolled all the way to the end - skip to next song.
}

- (void)audioBtnPressed:(id)sender
{
    UIBarButtonItem *btn = (UIBarButtonItem *)sender;
    NSLog(@"CONTROL PANEL VIEW VC - audioBtnPressed: %d", btn.tag);
    if (btn.tag==1001){ //play
        [player play];
    }
    if (btn.tag==1002){ //pause
        [player pause];
    }
    if (btn.tag==1003){ //skip
        [self hideSlider];
        [player skip];
    }
    if (btn.tag==1004){ //seek
        [player seek:100000];
    }
    
}

- (void)showSlider
{
    NSLog(@"CONTROL PANEL - showSlider");
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    slider.frame = CGRectMake(slider.frame.origin.x, 50, slider.frame.size.width, slider.frame.size.height);
    [UIView commitAnimations];
}

- (void)hideSlider
{
    NSLog(@"CONTROL PANEL - hideSlider");
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    slider.frame = CGRectMake(slider.frame.origin.x, self.frame.size.height, slider.frame.size.width, slider.frame.size.height);
    [UIView commitAnimations];
}

- (void)dealloc
{
    [player release];
    [slider release];
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
