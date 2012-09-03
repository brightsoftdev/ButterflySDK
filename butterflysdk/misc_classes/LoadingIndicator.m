//
//  LoadingIndicator.m
//  butterflyradio
//
//  Created by Denny Kwon on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoadingIndicator.h"

@implementation LoadingIndicator
@synthesize titleLabel;
@synthesize darkScreen;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        CGFloat width = 160.0f;
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0.5*(frame.size.width-width), 100, width, 100)];
        
        self.darkScreen = background;
        [background release];
        
        darkScreen.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);;
        darkScreen.layer.cornerRadius = 10.0f;
        darkScreen.backgroundColor = [UIColor blackColor];
        darkScreen.alpha = 0.7f;
        [self addSubview:darkScreen];
        [darkScreen release];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.5*(frame.size.width-width), 110, width, 35)];
        titleLabel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        titleLabel.text = @"Loading...";
        titleLabel.font = [UIFont fontWithName:@"Helvetica" size:18.0f];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        [self addSubview:titleLabel];
        
        width = 20.0f;
        spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.5*(frame.size.width-width), 150, width, width)];
        spinner.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        [self addSubview:spinner];
    }
    return self;
}

- (void)dealloc
{
    [titleLabel release];
    [spinner release];
    [super dealloc];
}

- (void)show
{
    [spinner startAnimating];
    if (self.hidden==TRUE){
        self.alpha = 0.0f;
        self.hidden = NO;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        self.alpha = 1.0f;
        [UIView commitAnimations];
    }
}

- (void)hide
{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDone)];
    self.alpha = 0.0f;
    [UIView commitAnimations];
    

//    self.hidden = TRUE;
//    [spinner stopAnimating];
}

- (void)animationDone
{
    self.hidden = TRUE;
    [spinner stopAnimating];
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
