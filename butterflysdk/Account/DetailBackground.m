//
//  DetailBackground.m
//  butterflyradio
//
//  Created by Denny Kwon on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailBackground.h"

@implementation DetailBackground
@synthesize btnLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:kRGBMax/kRGBMax green:kRGBMax/kRGBMax blue:210.0f/kRGBMax alpha:1.0f];
        
//        UIImage *shadow = [UIImage imageNamed:@"dropShadow.png"];
//        UIImageView *dropShadow = [[UIImageView alloc] initWithImage:shadow];
//        dropShadow.frame = CGRectMake(0, 0, shadow.size.width, shadow.size.height);
//        [self addSubview:dropShadow];
//        [dropShadow release];

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
        line.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:line];
        [line release];
        
        self.btnLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        btnLabel.userInteractionEnabled = NO;
        btnLabel.frame = CGRectMake(-2, 0, 77, 35);
        [btnLabel setBackgroundImage:[UIImage imageNamed:@"btn_base_gray@2x.png"] forState:UIControlStateNormal];
        btnLabel.titleLabel.font = [UIFont fontWithName:kFont size:14.0f];
        [btnLabel setTitle:@"Category" forState:UIControlStateNormal];
        [self addSubview:btnLabel];
    }
    return self;
}

+ (DetailBackground *)backgroundWithFrame:(CGRect)frame
{
    DetailBackground *bg = [[DetailBackground alloc] initWithFrame:frame];
    return [bg autorelease];
}

- (void)dealloc
{
    [btnLabel release];
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
