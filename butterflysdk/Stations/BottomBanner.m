//
//  BottomBanner.m
//  butterflyradio
//
//  Created by Denny Kwon on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BottomBanner.h"

@implementation BottomBanner

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        frame.origin.x = 0.0f;
        frame.origin.y = 0.0f;
        UIView *background = [[UIView alloc] initWithFrame:frame];
        background.backgroundColor = [UIColor blackColor];
        background.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        background.alpha = 0.6f;
        [self addSubview:background];
        [background release];
        
        frame.origin.x = 0.0f;
        frame.origin.y = 0.0f;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"bottomBar.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = frame;
        [self addSubview:btn];
        
    }
    return self;
}

- (void)btnTapped:(UIButton *)btn
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/butterfly-radio/id532051737?mt=8"]];
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
