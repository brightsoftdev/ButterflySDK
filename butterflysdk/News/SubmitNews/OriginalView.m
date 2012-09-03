//
//  OriginalView.m
//  butterflyradio
//
//  Created by Denny Kwon on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OriginalView.h"
@implementation UITextField (UITextFieldCategory)
+ (UITextField *)textFieldwithFrame:(CGRect)frame placeholder:(NSString *)p
{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = p;
    textField.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    return textField;
}
@end

static CGFloat slide = 40.0f;

@implementation OriginalView
@synthesize titleField;
@synthesize contentField;
@synthesize authorField;
@synthesize btn_selectImg;
@synthesize image;
@synthesize delegate;
@synthesize titleLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor redColor];
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kMainBackground]];

        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 25)];
        titleLabel.backgroundColor = [UIColor grayColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont fontWithName:kFont size:16.0f];
        [self addSubview:titleLabel];

        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 25, frame.size.width, 35)];
        background.backgroundColor = [UIColor colorWithRed:kRGBMax/kRGBMax green:kRGBMax/kRGBMax blue:210.0f/kRGBMax alpha:1.0f];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, background.frame.size.height-1, background.frame.size.width, 1)];
        line.backgroundColor = [UIColor darkGrayColor];
        [background addSubview:line];
        [line release];
        [self addSubview:background];
        [background release];
        
        frame = CGRectMake(10, 5, 300, 25);
        self.titleField = [UITextField textFieldwithFrame:frame placeholder:@"title"];
        self.titleField.backgroundColor = [UIColor clearColor];
        self.titleField.borderStyle = UITextBorderStyleNone;
        titleField.delegate = self;
        [background addSubview:titleField];
        
        background = [[UIView alloc] initWithFrame:CGRectMake(0, 60, background.frame.size.width, 35)];
        background.backgroundColor = [UIColor colorWithRed:kRGBMax/kRGBMax green:kRGBMax/kRGBMax blue:210.0f/kRGBMax alpha:1.0f];
        line = [[UIView alloc] initWithFrame:CGRectMake(0, background.frame.size.height-1, background.frame.size.width, 1)];
        line.backgroundColor = [UIColor darkGrayColor];
        [background addSubview:line];
        [line release];
        [self addSubview:background];
        [background release];

        
        int offset = 7;

        frame.origin.y += frame.size.height;
        self.authorField = [UITextField textFieldwithFrame:titleField.frame placeholder:@"submitted by"];
        self.authorField.borderStyle = UITextBorderStyleNone;
        self.authorField.backgroundColor = [UIColor clearColor];
        authorField.delegate = self;
        [background addSubview:authorField];
//        [self addSubview:authorField];
        
        UIImage *shadow = [UIImage imageNamed:@"dropShadow.png"];
        UIImageView *dropShadow = [[UIImageView alloc] initWithImage:shadow];
        dropShadow.frame = CGRectMake(0, background.frame.origin.y+background.frame.size.height, shadow.size.width, shadow.size.height);
        [self addSubview:dropShadow];
        [dropShadow release];
        
        
        frame.origin.y += (2*background.frame.size.height)+2;
        frame.size.height = 120;
        frame.origin.x = 5;
        frame.size.width += (2*frame.origin.x);
        
        contentField = [[UITextView alloc] initWithFrame:frame];
        contentField.textColor = [UIColor grayColor];
        contentField.delegate = self;
        contentField.text = @"content";
        contentField.font = titleField.font;
        contentField.backgroundColor = [UIColor clearColor];
        contentField.delegate = self;
        [self addSubview:contentField];
        
        frame.origin.y += frame.size.height+offset;
        image = [[UIImageView alloc] initWithFrame:CGRectMake(10, frame.origin.y, 130, 130)];
        image.image = [UIImage imageNamed:@"photo.png"];
        image.backgroundColor = [UIColor clearColor];
        [self addSubview:image];
        
        self.btn_selectImg = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_selectImg.titleLabel.font = [UIFont fontWithName:kFont size:14.0f];
        btn_selectImg.showsTouchWhenHighlighted = YES;
        [btn_selectImg setBackgroundImage:[UIImage imageNamed:@"btn_base_gray@2x.png"] forState:UIControlStateNormal];
        [btn_selectImg setTitle:@"add image" forState:UIControlStateNormal];
        [btn_selectImg addTarget:self action:@selector(selectImage) forControlEvents:UIControlEventTouchUpInside];
        btn_selectImg.frame = CGRectMake(10, image.frame.origin.y+image.frame.size.height+12, 300, 35);
        [self addSubview:btn_selectImg];

        doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.frame.size.height, 320, 40)];
        doneToolbar.barStyle = UIBarStyleBlack;
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(btnDonePressed:)];
        doneToolbar.items = [NSArray arrayWithObjects:flex, done, nil];
        [flex release];
        [done release];
        [self addSubview:doneToolbar];
    }
    return self;
}

- (void)dealloc
{
    [titleField release];
    [authorField release];
    [contentField release];
    [image release];
    [btn_selectImg release];
    [titleLabel release];
    [super dealloc];
}

- (void)btnDonePressed:(UIBarButtonItem *)btn
{
    [titleField resignFirstResponder];
    [authorField resignFirstResponder];
    [contentField resignFirstResponder];
    [self slideView:(slide+3)];
}

- (void)selectImage
{
    NSLog(@"selectImage");
    [delegate launchCamera];
}

- (void)slideView:(CGFloat)pos
{
    CGRect frame = self.frame;
    frame.origin.y = pos;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25f];
    self.frame = frame;
    if (pos<0){
//        if (pos==-slide){ doneToolbar.frame = CGRectMake(0, 244, 320, 40); }
        if (pos==-slide){ doneToolbar.frame = CGRectMake(0, 264, 320, 40); }
        else { doneToolbar.frame = CGRectMake(0, 324, 320, 40); }
    }
    else{
        doneToolbar.frame = CGRectMake(0, self.frame.size.height, 320, 40);
    }
    [UIView commitAnimations];
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
}


#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"textViewDidBeginEditing:");
    [self slideView:-slide];
    
    NSString *comment = contentField.text;
    if ([comment isEqualToString:@"content"]){
        contentField.textColor = [UIColor blackColor];
        contentField.text = @"";
    }

}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"textViewDidEndEditing:");
    NSString *comment = contentField.text;
    if ([comment length]==0){
        contentField.textColor = [UIColor grayColor];
        contentField.text = @"content";
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
