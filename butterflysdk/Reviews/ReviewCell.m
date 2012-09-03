//
//  ReviewCell.m
//  butterflyradio
//
//  Created by Denny Kwon on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReviewCell.h"

@implementation ReviewCell
@synthesize detailsLabel;
@synthesize commentLabel;
@synthesize star0;
@synthesize star1;
@synthesize star2;
@synthesize star3;
@synthesize star4;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        
        CGRect frame = self.contentView.frame;
        base = [[UIView alloc] initWithFrame:CGRectMake(10, 0, frame.size.width-20, frame.size.height)];
        base.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        CGFloat gray = 245.0f;
        base.backgroundColor = [UIColor colorWithRed:gray/kRGBMax green:gray/kRGBMax blue:gray/kRGBMax alpha:1.0f];
//        base.backgroundColor = [UIColor lightGrayColor];
        base.layer.borderColor = [[UIColor grayColor] CGColor];
        base.layer.borderWidth = 0.5f;
        base.layer.cornerRadius = 4.0f;
        
        commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, kCellLabelWidth, frame.size.height)];
        commentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        commentLabel.backgroundColor = [UIColor clearColor];
        commentLabel.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
        commentLabel.numberOfLines = 0;
        commentLabel.lineBreakMode = UILineBreakModeWordWrap;
        [base addSubview:commentLabel];
        
        frame = commentLabel.frame;
        frame.origin.y += frame.origin.y+frame.size.height+10;
        frame.size.height = 35;
        detailsLabel = [[UILabel alloc] initWithFrame:frame];
        detailsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        detailsLabel.textColor = [UIColor darkGrayColor];
        detailsLabel.lineBreakMode = UILineBreakModeWordWrap;
        detailsLabel.font = [UIFont fontWithName:@"Arial" size:12.0f];
        detailsLabel.textAlignment = UITextAlignmentRight;
        detailsLabel.backgroundColor = [UIColor clearColor];
        detailsLabel.numberOfLines = 0;
        
        [base addSubview:detailsLabel];
        
        stars = [[NSMutableArray alloc] init];
        
        CGFloat x = 212;
        int offset = 17;
        star0 = [[UIImageView alloc] initWithImage:nil];
        star0.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        star0.frame = CGRectMake(x, 5, 12, 12);
        [base addSubview:star0];
        [stars addObject:star0];
        x += offset;

        star1 = [[UIImageView alloc] initWithImage:nil];
        star1.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        star1.frame = CGRectMake(x, 5, 12, 12);
        [base addSubview:star1];
        [stars addObject:star1];
        x += offset;

        star2 = [[UIImageView alloc] initWithImage:nil];
        star2.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        star2.frame = CGRectMake(x, 5, 12, 12);
        [base addSubview:star2];
        [stars addObject:star2];
        x += offset;

        star3 = [[UIImageView alloc] initWithImage:nil];
        star3.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        star3.frame = CGRectMake(x, 5, 12, 12);
        [base addSubview:star3];
        [stars addObject:star3];
        x += offset;

        star4 = [[UIImageView alloc] initWithImage:nil];
        star4.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        star4.frame = CGRectMake(x, 5, 12, 12);
        [base addSubview:star4];
        [stars addObject:star4];
        x += offset;

        [self.contentView addSubview:base];
    }
    return self;
}

- (void)dealloc
{
    [star0 release];
    [star1 release];
    [star2 release];
    [star3 release];
    [star4 release];
    [stars release];
    [detailsLabel release];
    [commentLabel release];
    [base release];
    [super dealloc];
}

- (void)fillStars:(int)rating
{
    for (int i=0; i<5; i++){
        UIImageView *star = [stars objectAtIndex:i];
        if ((i+1)<=rating){
            star.image = [UIImage imageNamed:@"fullStar.png"];
        }
        else {
            star.image = [UIImage imageNamed:@"emptyStar.png"];
        }
    }
    
    
}

- (void)resize
{
    CGRect frame = commentLabel.frame;
    CGSize size = [commentLabel.text sizeWithFont:commentLabel.font constrainedToSize:CGSizeMake(kCellLabelWidth, 400) lineBreakMode:commentLabel.lineBreakMode];
    frame.size.height = size.height;
    commentLabel.frame = frame;
    
    frame = star0.frame;
    CGFloat y = commentLabel.frame.origin.y+commentLabel.frame.size.height+8;
    star0.frame = CGRectMake(frame.origin.x, y, frame.size.width, frame.size.height);

    frame = star1.frame;
    star1.frame = CGRectMake(frame.origin.x, y, frame.size.width, frame.size.height);

    frame = star2.frame;
    star2.frame = CGRectMake(frame.origin.x, y, frame.size.width, frame.size.height);

    frame = star3.frame;
    star3.frame = CGRectMake(frame.origin.x, y, frame.size.width, frame.size.height);

    frame = star4.frame;
    star4.frame = CGRectMake(frame.origin.x, y, frame.size.width, frame.size.height);

    frame = detailsLabel.frame;
    frame.origin.y = commentLabel.frame.origin.y+commentLabel.frame.size.height+5;
    detailsLabel.frame = frame;
    
    frame = base.frame;
    frame.size.height = commentLabel.frame.origin.y+commentLabel.frame.size.height+detailsLabel.frame.size.height+10;
    base.frame = frame;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
