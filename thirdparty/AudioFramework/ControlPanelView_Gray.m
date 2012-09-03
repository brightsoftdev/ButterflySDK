//
//  ControlPanelView_Gray.m
//  TeamLove
//
//  Created by Denny Kwon on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ControlPanelView_Gray.h"

@implementation ControlPanelView_Gray
@synthesize slider;
@synthesize player;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:138.0f/255.0f green:138.0f/255.0f blue:136.0f/255.0f alpha:1.0];
        
        CGFloat dimensions = frame.size.height-20;
        image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, dimensions, dimensions)];
        image.image = [UIImage imageNamed:@"placeholder.png"];
        image.layer.borderColor = [[UIColor whiteColor] CGColor];
        image.layer.borderWidth = 0.7f;
        image.layer.shadowRadius = 8.0f;
        image.layer.shadowOffset = CGSizeMake(-8, 8);
        image.layer.shadowOpacity = 0.8;
        image.layer.shadowColor = [[UIColor blackColor] CGColor];
        
        [self addSubview:image];
        
        UILabel *nowPlaying = [[UILabel alloc] initWithFrame:CGRectMake(dimensions+20, 10, 100, 20)];
        nowPlaying.text = @"Now Playing";
        nowPlaying.font = [UIFont boldSystemFontOfSize:16];
        nowPlaying.textColor = [UIColor whiteColor];
        nowPlaying.backgroundColor = [UIColor clearColor];
        [self addSubview:nowPlaying];
        [nowPlaying release];
        
        authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(dimensions+20, 33, 210, 20)];
        authorLabel.font = [UIFont systemFontOfSize:14];
        authorLabel.alpha = 0.0f;
        authorLabel.backgroundColor = [UIColor clearColor];
        authorLabel.textColor = [UIColor whiteColor];
        authorLabel.text = @"author";
        [self addSubview:authorLabel];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(dimensions+20, 53, 210, 20)];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.alpha = 0.0f;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = @"title";
        [self addSubview:titleLabel];
        
        CGFloat dimens = 25.0f;
        CGFloat vertical_offset = 7.0f;
        UIButton *btn_play = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_play.tag = 1001;
        [btn_play addTarget:self action:@selector(audioBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [btn_play setBackgroundImage:[UIImage imageNamed:@"btn_play@2x.png"] forState:UIControlStateNormal];
        btn_play.frame = CGRectMake(dimensions+135, vertical_offset, dimens, dimens);
        [self addSubview:btn_play];
        
        UIButton *btn_pause = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_pause.tag = 1002;
        [btn_pause addTarget:self action:@selector(audioBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [btn_pause setBackgroundImage:[UIImage imageNamed:@"btn_pause@2x.png"] forState:UIControlStateNormal];
        btn_pause.frame = CGRectMake(dimensions+170, vertical_offset, dimens, dimens);
        [self addSubview:btn_pause];

        UIButton *btn_skip = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_skip.tag = 1003;
        [btn_skip addTarget:self action:@selector(audioBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [btn_skip setBackgroundImage:[UIImage imageNamed:@"btn_skip@2x.png"] forState:UIControlStateNormal];
        btn_skip.frame = CGRectMake(dimensions+205, vertical_offset, dimens, dimens);
        [self addSubview:btn_skip];

        slider = [[UISlider alloc] initWithFrame:CGRectMake(110, self.frame.size.height, 200, 20)];
        slider.minimumValue = 0.0f;
        slider.maximumValue = 0.0f;
        [slider addTarget:self action:@selector(sliding) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(sliderValue) forControlEvents:UIControlEventTouchUpInside];
        
        [slider setThumbImage:[UIImage imageNamed:@"track.png"] forState:UIControlStateNormal];
        [self addSubview:slider];
    }
    return self;
}

- (void)dealloc
{
    [player release];
    [slider release];
    [image release];
    [authorLabel release];
    [super dealloc];
}

- (void)showFileInfo:(NSDictionary *)info
{
    authorLabel.text = [info objectForKey:@"author"];
    titleLabel.text = [info objectForKey:@"name"];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    titleLabel.alpha = 1.0;
    authorLabel.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)clear
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    titleLabel.alpha = 0.0;
    authorLabel.alpha = 0.0;
    [UIView commitAnimations];
    
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
}

- (void)fillImage:(UIImage *)img
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:image cache:YES];
    image.image = img;
    [UIView commitAnimations];
}

- (void)showSlider
{
    NSLog(@"CONTROL PANEL - showSlider");
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    CGFloat height = slider.frame.size.height;
    slider.frame = CGRectMake(slider.frame.origin.x, self.frame.size.height-height, slider.frame.size.width, height);
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



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
