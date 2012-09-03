//
//  StationCell.m
//  butterflyradio
//
//  Created by Denny Kwon on 7/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StationCell.h"

@implementation StationCell
@synthesize btnReply;
@synthesize ip;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    self.btnReply = nil;
    self.ip = nil;
    [super dealloc];
}

- (void)setup
{
    self.textLabel.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    self.textLabel.textColor = [UIColor darkGrayColor];
    self.textLabel.shadowColor = [UIColor whiteColor];
    self.textLabel.shadowOffset = CGSizeMake(-0.5f, 0.5f);
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.numberOfLines = 2;
    self.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
    self.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    UIImage *imgReply = [UIImage imageNamed:@"btn_reply.png"];
    self.btnReply = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnReply addTarget:self action:@selector(btnTapped) forControlEvents:UIControlEventTouchUpInside];
    btnReply.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [btnReply setTitle:@"reply" forState:UIControlStateNormal];
    btnReply.showsTouchWhenHighlighted = YES;
    btnReply.titleLabel.font = [UIFont fontWithName:kFont size:13.0f];
    [btnReply setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btnReply setBackgroundImage:imgReply forState:UIControlStateNormal];
    btnReply.frame = CGRectMake(265, 30, imgReply.size.width, imgReply.size.height);
    [self.contentView addSubview:btnReply];
}

- (void)btnTapped
{
    [delegate btnReplyTapped:ip];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
