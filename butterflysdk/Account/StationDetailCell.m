//
//  StationDetailCell.m
//  butterflyradio
//
//  Created by Denny Kwon on 8/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.


#import "StationDetailCell.h"

@implementation StationDetailCell
@synthesize delegate;
@synthesize btnGarbage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    self.btnGarbage = nil;
    [super dealloc];
}

- (void)setup:(int)mode //0==tracks, 1==news
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.textLabel.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    self.textLabel.textColor = [UIColor darkGrayColor];
    self.textLabel.shadowColor = [UIColor whiteColor];
    self.textLabel.shadowOffset = CGSizeMake(-0.5f, 0.5f);
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.numberOfLines = 2;
    self.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
    self.detailTextLabel.backgroundColor = [UIColor clearColor];

    self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_cell.png"]];
    
    
    UIImage *imgReply = [UIImage imageNamed:@"btn_reply.png"];
    self.btnGarbage = [UIButton buttonWithType:UIButtonTypeCustom];
    btnGarbage.showsTouchWhenHighlighted = YES;
    [btnGarbage setBackgroundImage:imgReply forState:UIControlStateNormal];
    btnGarbage.tag = 2000;
    btnGarbage.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    btnGarbage.titleLabel.text = @"garbage";
    btnGarbage.titleLabel.font = [UIFont fontWithName:kFont size:13.0f];
    [btnGarbage setTitle:@"delete" forState:UIControlStateNormal];
    [btnGarbage setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnGarbage.frame = CGRectMake(260, 30, imgReply.size.width+5, imgReply.size.height);
    [btnGarbage addTarget:self action:@selector(expand:) forControlEvents:UIControlEventTouchDown];
    [btnGarbage addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btnGarbage addTarget:self action:@selector(cancelBtnAction:) forControlEvents:UIControlEventTouchDragExit];
    [self.contentView addSubview:btnGarbage];
    
}

- (void)expand:(UIButton *)btn
{
    NSLog(@"expand");
    [UIView animateWithDuration:0.07f 
                          delay:0.0f 
                        options:UIViewAnimationOptionCurveLinear 
                     animations:^{
                         CGAffineTransform trans = CGAffineTransformMakeScale(1.2f, 1.2f);
                         btn.transform = trans;
                     }
                     completion:NULL];
    
}

- (void)btnTapped:(UIButton *)btn
{
    [UIView animateWithDuration:0.07f 
                          delay:0.0f 
                        options:UIViewAnimationOptionCurveLinear 
                     animations:^{
                         btn.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished){
                         NSArray *contents = [NSArray arrayWithObjects:btn.titleLabel.text, [NSString stringWithFormat:@"%d", self.tag], nil];
                         [delegate cellTapped:contents];
                     }];
}

- (void)cancelBtnAction:(UIButton *)btn
{
    NSLog(@"cancelBtnAction:");
    [UIView animateWithDuration:0.07f 
                          delay:0.0f 
                        options:UIViewAnimationOptionCurveLinear 
                     animations:^{
                         btn.transform = CGAffineTransformIdentity;
                     }
                     completion:NULL];
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
