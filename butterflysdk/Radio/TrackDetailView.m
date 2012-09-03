//
//  TrackDetailView.m
//  butterflyradio
//
//  Created by Denny Kwon on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrackDetailView.h"

@implementation TrackDetailView
@synthesize delegate;
@synthesize slider;
@synthesize nameLabel;
@synthesize authorLabel;
@synthesize dateLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIViewAutoresizing resize = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        self.autoresizingMask = resize;
        self.backgroundColor = [UIColor clearColor];

        
        UIView *base = [[UIView alloc] initWithFrame:frame];
        base.backgroundColor = [UIColor blackColor];
        base.autoresizingMask = resize;
        base.alpha = 0.6f;
        [self addSubview:base];
        [base release];
        
        UIView *top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 90)];
        top.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        top.backgroundColor = [UIColor clearColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, top.frame.size.height-1, top.frame.size.width, 1)];
        line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        line.backgroundColor = [UIColor whiteColor];
        [top addSubview:line];
        [line release];
        
        UIImageView *shadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, top.frame.size.height-2, top.frame.size.width, 8)];
        shadow.image = [UIImage imageNamed:@"dropShadow.png"];
        [top addSubview:shadow];
        [shadow release];
        
        CGFloat y = 5.0f;
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, frame.size.width, 20)];
        nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
        nameLabel.textAlignment = UITextAlignmentCenter;
        [top addSubview:nameLabel];
        y += nameLabel.frame.size.height;
        
        CGFloat inset = 30;
        slider = [[UISlider alloc] initWithFrame:CGRectMake(inset, y, frame.size.width-(2*inset), 20)];
        slider.minimumValue = 0.0f;
        slider.maximumValue = 1.0f;
        slider.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [slider addTarget:self action:@selector(sliding) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(seek) forControlEvents:(UIControlEventTouchUpInside|UIControlEventTouchUpOutside)];
        [top addSubview:slider];
        y += slider.frame.size.height;
        
        authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, frame.size.width, 20)];
        authorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        authorLabel.backgroundColor = [UIColor clearColor];
        authorLabel.textColor = [UIColor whiteColor];
        authorLabel.font = [UIFont fontWithName:@"Heiti SC" size:13.0f];
        authorLabel.textAlignment = UITextAlignmentCenter;
        [top addSubview:authorLabel];
        y += authorLabel.frame.size.height;
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, frame.size.width, 20)];
        dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.textColor = [UIColor whiteColor];
        dateLabel.font = [UIFont fontWithName:@"Heiti SC" size:13.0f];
        dateLabel.textAlignment = UITextAlignmentCenter;
        [top addSubview:dateLabel];
        
        
        [self addSubview:top];
        [top release];
        
        
        
    }
    return self;
}

- (void)dealloc
{
    [authorLabel release];
    [dateLabel release];
    [nameLabel release];
    [slider release];
    [super dealloc];
}

- (void)sliding
{
    NSLog(@"TRACK DETAIL VIEW - sliding:");
    [delegate sliding]; //pauses the player
}

- (void)seek
{
    [delegate seekTo:slider.value];
}


- (void)sliderValue
{
    NSLog(@"TRACK DETAIL VIEW - sliderValue: %.3f", slider.value);
//    if (slider.value<slider.maximumValue){ [player seek:slider.value]; }
//    else{ [player skip]; } //slider scrolled all the way to the end - skip to next song.
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
