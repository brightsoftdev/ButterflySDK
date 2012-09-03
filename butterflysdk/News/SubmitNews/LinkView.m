//
//  LinkView.m
//  butterflyradio
//
//  Created by Denny Kwon on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LinkView.h"
@implementation UITextField (UITextFieldCategory)
+ (UITextField *)textFieldwithFrame:(CGRect)frame placeholder:(NSString *)p
{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.borderStyle = UITextBorderStyleNone;
    textField.placeholder = p;
    textField.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    return [textField autorelease];
}
@end


@implementation LinkView
@synthesize titleField;
@synthesize authorField;
@synthesize contentField;
@synthesize titleLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kMainBackground]];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 25)];
        titleLabel.backgroundColor = [UIColor grayColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont fontWithName:kFont size:16.0f];
        [self addSubview:titleLabel];

        frame = CGRectMake(0, titleLabel.frame.size.height, 320, 35);
        UIView *background = [[UIView alloc] initWithFrame:frame];
        background.backgroundColor = [UIColor colorWithRed:kRGBMax/kRGBMax green:kRGBMax/kRGBMax blue:210.0f/kRGBMax alpha:1.0f];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, background.frame.size.height-1, background.frame.size.width, 1)];
        line.backgroundColor = [UIColor darkGrayColor];
        [background addSubview:line];
        [line release];

        frame = CGRectMake(10, 5, 300, 25);
        self.titleField = [UITextField textFieldwithFrame:frame placeholder:@"title"];
        titleField.delegate = self;
        titleField.borderStyle = UITextBorderStyleNone;
        [background addSubview:titleField];
        [self addSubview:background];
        [background release];
        
        frame = CGRectMake(0, background.frame.origin.y+background.frame.size.height, 320, 35);
        background = [[UIView alloc] initWithFrame:frame];
        background.backgroundColor = [UIColor colorWithRed:kRGBMax/kRGBMax green:kRGBMax/kRGBMax blue:210.0f/kRGBMax alpha:1.0f];
        line = [[UIView alloc] initWithFrame:CGRectMake(0, background.frame.size.height-1, background.frame.size.width, 1)];
        line.backgroundColor = [UIColor darkGrayColor];
        [background addSubview:line];
        [line release];
        
        self.authorField = [UITextField textFieldwithFrame:titleField.frame placeholder:@"submitted by"];
        authorField.delegate = self;
        authorField.borderStyle = UITextBorderStyleNone;
        [background addSubview:authorField];
        [self addSubview:background];
        [background release];
        
        frame = CGRectMake(0, background.frame.origin.y+background.frame.size.height, 320, 35);
        background = [[UIView alloc] initWithFrame:frame];
        background.backgroundColor = [UIColor colorWithRed:kRGBMax/kRGBMax green:kRGBMax/kRGBMax blue:210.0f/kRGBMax alpha:1.0f];
        line = [[UIView alloc] initWithFrame:CGRectMake(0, background.frame.size.height-1, background.frame.size.width, 1)];
        line.backgroundColor = [UIColor darkGrayColor];
        [background addSubview:line];
        [line release];

        self.contentField = [UITextField textFieldwithFrame:authorField.frame placeholder:@"link url"];
        contentField.borderStyle = UITextBorderStyleNone;
        contentField.keyboardType = UIKeyboardTypeURL;
        contentField.tag = 1001;
        contentField.font = titleField.font;
        contentField.delegate = self;
        [background addSubview:contentField];
        [self addSubview:background];
        [background release];
        
        UIImage *shadow = [UIImage imageNamed:@"dropShadow.png"];
        UIImageView *dropShadow = [[UIImageView alloc] initWithImage:shadow];
        dropShadow.frame = CGRectMake(0, background.frame.origin.y+background.frame.size.height, shadow.size.width, shadow.size.height);
        [self addSubview:dropShadow];
        [dropShadow release];

    }
    return self;
}

- (void)dealloc
{
    [titleField release];
    [contentField release];
    [authorField release];
    [titleLabel release];
    [super dealloc];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"textFieldDidBeginEditing:");
    if (textField.tag==1001){
        if ([contentField.text length]==0){
            contentField.text = @"http://";
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag==1001){
        if ([contentField.text isEqualToString:@"http://"]==TRUE){
            contentField.text = nil;
        }
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
