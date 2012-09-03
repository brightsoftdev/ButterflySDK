//
//  FeaturedView.m
//  butterflyradio
//
//  Created by Denny Kwon on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeaturedView.h"

double getRandomFloat()
{
    int x = 0+arc4random()%255;
    double color = x/kRGBMax;
    return color;
}

@implementation FeaturedView
@synthesize image;
@synthesize nameLabel;
@synthesize categoryLabel;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reset) name:kResetFeaturedViews object:nil];

        UIViewAutoresizing resize = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth);
        
        self.autoresizingMask = resize;

        self.backgroundColor = [UIColor clearColor];
        self.showsTouchWhenHighlighted = YES;
        
        image = [[UIImageView alloc] initWithFrame:CGRectMake(11, 7.5, frame.size.width-22, frame.size.height-27)];
        originalFrame = image.frame;
        maxWidth = image.frame.size.width;
        maxHeight = image.frame.size.height;
        
        image.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
        image.alpha = 0.0f;
        [self addSubview:image];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-17, frame.size.width, 20)];
        nameLabel.autoresizingMask = resize;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor lightGrayColor];
        nameLabel.shadowColor = [UIColor blackColor];
        nameLabel.lineBreakMode = UILineBreakModeWordWrap;
        nameLabel.numberOfLines = 0;
        nameLabel.shadowOffset = CGSizeMake(-0.5, 0.5);
        nameLabel.textAlignment = UITextAlignmentCenter;
        nameLabel.font = [UIFont fontWithName:@"Heiti SC" size:13.0f];
        [self addSubview:nameLabel];
        
        frame = image.frame;
        categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x+1, frame.origin.y, frame.size.width-2, 15)];
        categoryLabel.autoresizingMask = resize;
        categoryLabel.alpha = 0.6f;
        categoryLabel.backgroundColor = [UIColor blackColor];
        categoryLabel.font = [UIFont fontWithName:@"arial" size:12.0f];
        categoryLabel.textAlignment = UITextAlignmentCenter;
        categoryLabel.textColor = [UIColor whiteColor];
        categoryLabel.text = @"featured station";
        categoryLabel.alpha = 0.0f;
        [self addSubview:categoryLabel];
        
        [self setBackgroundImage:[UIImage imageNamed:@"featuredBackground@2x.png"] forState:UIControlStateNormal];
        
    }
    return self;
}

- (void)enterBackground
{
    image.alpha = 0.0f;
}

- (void)reset
{
    //    NSLog(@"REMOVING FROM SUPERVIEW!");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kResetFeaturedViews object:nil];
    image.alpha = 0.0f;
    [self removeFromSuperview];
}


- (void)fillImage:(NSData *)imgData
{
    image.alpha = 0.0f;

    UIImage *img = [UIImage imageWithData:imgData];
    CGFloat width = img.size.width;
    CGFloat height = img.size.height;
    
    double scale;
    if (width>maxWidth){
        scale = maxWidth/width;
        width = maxWidth;
        height = scale*height;
    }
    if (height>maxHeight){
        scale = maxHeight/height;
        height = maxHeight;
        width *= scale;
    }

    
//    image.frame = CGRectMake(0.5*(m-width)+frame.origin.x, 0.5*(h-height)+frame.origin.y, width, height);
    
    image.frame = CGRectMake(0.5*(maxWidth-width)+originalFrame.origin.x, 0.5*(maxHeight-height)+originalFrame.origin.y, width, height);
    image.image = img;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5f];
    image.alpha = 1.0f;
    [UIView commitAnimations];
}

- (void)dealloc
{
    [image release];
    [nameLabel release];
    [categoryLabel release];
    [super dealloc];
}


/*
#pragma mark - UITouchResponders
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan:");
    self.alpha = 0.6;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesMoved:");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesEnded:");
    self.alpha = 1.0;
    [delegate featuredSelected:self.uniqueId];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
{
    NSLog(@"touchesCancelled:");
    self.alpha = 1.0;
}
 
 */




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
