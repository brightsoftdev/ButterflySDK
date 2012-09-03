//
//  SummaryView.m
//  butterflyradio
//
//  Created by Denny Kwon on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SummaryView.h"

@implementation SummaryView
@synthesize image;
@synthesize titleLabel;
@synthesize detailsLabel;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)img
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 110)];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        UIView *summary = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, self.frame.size.height-20)];
        summary.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        CGFloat rgbMax = 255.0f;
        summary.backgroundColor = [UIColor colorWithRed:150/rgbMax green:rgbMax/rgbMax blue:150/rgbMax alpha:1.0f];
        summary.layer.borderColor = [[UIColor grayColor] CGColor];
        summary.layer.borderWidth = 0.5f;
        summary.layer.cornerRadius = 4.0f;
        
        image = [[UIImageView alloc] initWithImage:img];
        image.backgroundColor = [UIColor redColor];
        CGFloat dimension = summary.frame.size.height-10;
        
        CGFloat width = img.size.width;
        CGFloat height = img.size.height;
        
        double scale;
        if (width>dimension){
            scale = dimension/width;
            width = dimension;
            height *= scale;
        }
        if (height>dimension){
            scale = height/dimension;
            height = dimension;
            width *= scale;
        }
        
        image.frame = CGRectMake(5, 5, width, height);
        image.layer.shadowOffset = CGSizeMake(-1, 1);
        image.layer.shadowOpacity = 0.5f;
        image.layer.shadowRadius = 4.0f;
        [summary addSubview:image];
        
        CGFloat x = image.frame.origin.x+image.frame.size.width;
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, image.frame.origin.y, summary.frame.size.width-x-5, 20)];
        titleLabel.textAlignment = UITextAlignmentRight;
        titleLabel.font = [UIFont fontWithName:kFont size:16.0f];
//        titleLabel.text = station.name;
//        titleLabel.text = @"Title";
        titleLabel.backgroundColor = [UIColor clearColor];
        [summary addSubview:titleLabel];
        
        detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, image.frame.origin.y+titleLabel.frame.size.height, summary.frame.size.width-x-5, 35)];
        detailsLabel.backgroundColor = [UIColor clearColor];
        detailsLabel.textColor = [UIColor darkGrayColor];
        detailsLabel.numberOfLines = 2;
        detailsLabel.textAlignment = UITextAlignmentRight;
        detailsLabel.font = [UIFont fontWithName:kFont size:12.0f];
        [summary addSubview:detailsLabel];
        
        [self addSubview:summary];
        [summary release];

    }
    return self;
}

- (void)dealloc
{
    [detailsLabel release];
    [titleLabel release];
    [image release];
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
