//
//  ToolBar.m
//  frenchkiss
//
//  Created by Denny Kwon on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ToolBar.h"

@implementation ToolBar
@synthesize titleLabel;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.barStyle = UIBarStyleBlack;
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 280, 30)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:18.0f];
        [self addSubview:titleLabel];
        
        UIBarButtonItem *btn_home = [[UIBarButtonItem alloc] initWithTitle:@"cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(btnPressed:)];
        btn_home.tintColor = [UIColor redColor];
        btn_home.tag = 1111;

        UIBarButtonItem *btn_radio = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_radio.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(btnPressed:)];
        btn_radio.tag = 2222;
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];        
        self.items = [NSArray arrayWithObjects:btn_home, flex, btn_radio, nil];
        [btn_home release];
        [btn_radio release];
        [flex release];
        
    }
    return self;
}

- (void)dealloc
{
    [titleLabel release];
    [super dealloc];
}

- (void)btnPressed:(UIBarButtonItem *)sender
{
    if (sender.tag==1111){
        [delegate exit];
    }
    if (sender.tag==2222){
        [delegate showRadio];
    }
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
