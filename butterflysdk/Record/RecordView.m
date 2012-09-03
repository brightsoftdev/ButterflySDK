//
//  RecordView.m
//  butterflyradio
//
//  Created by Denny Kwon on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecordView.h"

static NSString *play = @"play";
static NSString *stop = @"stop";
static NSString *record = @"record";
static NSString *submit = @"submit";
static NSString *fileName = @"track.m4a";
static NSString *clear = @"clear";
static NSString *kDescription = @"description (optional)";

static CGFloat kHeight = 35.0f;


@implementation RecordView
@synthesize delegate;
@synthesize titleField;
@synthesize tagsField;
@synthesize commentField;
@synthesize timeLabel;
@synthesize mainButton;
@synthesize authorField;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, kHeight)];
        background.backgroundColor = [UIColor colorWithRed:kRGBMax/kRGBMax green:kRGBMax/kRGBMax blue:210.0f/kRGBMax alpha:1.0f];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, background.frame.size.height-1, background.frame.size.width, 1)];
        line.backgroundColor = [UIColor darkGrayColor];
        [background addSubview:line];
        [line release];

        titleField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, 300, kHeight-10)];
        titleField.tag = 1000;
        titleField.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
        titleField.borderStyle = UITextBorderStyleNone;
        titleField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        titleField.delegate = self;
        titleField.placeholder = @"title";
        [background addSubview:titleField];
        [self addSubview:background];
        [background release];

        background = [[UIView alloc] initWithFrame:CGRectMake(0, 35, 320, kHeight)];
        background.backgroundColor = [UIColor colorWithRed:kRGBMax/kRGBMax green:kRGBMax/kRGBMax blue:210.0f/kRGBMax alpha:1.0f];
        line = [[UIView alloc] initWithFrame:CGRectMake(0, background.frame.size.height-1, background.frame.size.width, 1)];
        line.backgroundColor = [UIColor darkGrayColor];
        [background addSubview:line];
        [line release];
        
        authorField = [[UITextField alloc] initWithFrame:titleField.frame];
        authorField.tag = 1000;
        authorField.borderStyle = titleField.borderStyle;
        authorField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        authorField.font = titleField.font;
        authorField.delegate = self;
        authorField.placeholder = @"from";
        [background addSubview:authorField];
        [self addSubview:background];

        background = [[UIView alloc] initWithFrame:CGRectMake(0, 70, 320, kHeight)];
        background.backgroundColor = [UIColor colorWithRed:kRGBMax/kRGBMax green:kRGBMax/kRGBMax blue:210.0f/kRGBMax alpha:1.0f];
        line = [[UIView alloc] initWithFrame:CGRectMake(0, background.frame.size.height-1, background.frame.size.width, 1)];
        line.backgroundColor = [UIColor darkGrayColor];
        [background addSubview:line];
        [line release];
        
        tagsField = [[UITextField alloc] initWithFrame:titleField.frame];
        tagsField.tag = 1000;
        tagsField.borderStyle = titleField.borderStyle;
        tagsField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        tagsField.font = titleField.font;
        tagsField.delegate = self;
        tagsField.placeholder = @"tags (separated by commas)";
        [background addSubview:tagsField];
        
        [self addSubview:background];
        [background release];

        commentField = [[UITextView alloc] initWithFrame:CGRectMake(5, 105, 310, 165)];
        commentField.delegate = self;
        commentField.returnKeyType = UIReturnKeyDone;
        commentField.tag = 1000;
        commentField.backgroundColor = [UIColor clearColor];
        commentField.textColor = [UIColor lightGrayColor];
        commentField.text = kDescription;
        commentField.font = titleField.font;
        commentField.delegate = self;
        [self addSubview:commentField];
        
        UIImage *shadow = [UIImage imageNamed:@"dropShadow.png"];
        UIImageView *dropShadow = [[UIImageView alloc] initWithImage:shadow];
        dropShadow.frame = CGRectMake(0, commentField.frame.origin.y, shadow.size.width, shadow.size.height);
        [self addSubview:dropShadow];
        [dropShadow release];

        frame = commentField.frame;
        CGFloat y = frame.origin.y+frame.size.height;
        UIView *screen = [[UIView alloc] initWithFrame:CGRectMake(0, y, 320, self.frame.size.height-y)];
        screen.alpha = 0.6f;
        screen.backgroundColor = [UIColor blackColor];
        [self addSubview:screen];
        [screen release];
        
        frame = commentField.frame;
        frame.origin.y = frame.origin.y+frame.size.height;
        frame.size.height = 30.0f;
        timeLabel = [[UILabel alloc] initWithFrame:frame];
        timeLabel.font = [UIFont fontWithName:@"Heiti SC" size:18.0f];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textAlignment = UITextAlignmentCenter;
        timeLabel.textColor = [UIColor whiteColor];
        
        timeLabel.text = [NSString stringWithFormat:@"%@", kMaxTime];
        [self addSubview:timeLabel];
        
        self.mainButton = [UIButton buttonWithType:UIButtonTypeCustom];
        mainButton.showsTouchWhenHighlighted = YES;
        [mainButton setBackgroundImage:[UIImage imageNamed:@"btRecord@2x.png"] forState:UIControlStateNormal];
        CGFloat width = 70.0f;
        mainButton.frame = CGRectMake(0.5*(320-width), timeLabel.frame.origin.y+timeLabel.frame.size.height, width, width);
        [mainButton addTarget:self action:@selector(mainButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:mainButton];
    }
    return self;
}


- (void)dealloc
{
    [titleField release];
    [tagsField release];
    [commentField release];
    [timeLabel release];
    [mainButton release];
    [authorField release];
    [super dealloc];
}

- (void)exit
{
    [delegate exit];
}

- (void)showRadio
{
    [delegate showRadio];
}

- (void)setBtnImage:(UIImage *)img
{
    [mainButton setBackgroundImage:img forState:UIControlStateNormal];
}

- (void)clear
{
    timeLabel.text = [NSString stringWithFormat:@"%@", kMaxTime];
    commentField.textColor = [UIColor lightGrayColor];
    commentField.text = kDescription;
    tagsField.text = nil;
    titleField.text = nil;
}

- (void)activateUploadButton
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}

//- (void)btnPressed:(UIButton *)btn
//{
//    [delegate btnPressed:btn.titleLabel.text];
//}

- (void)mainButtonPressed:(UIButton *)btn
{
    [delegate mainbtnPressed];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"textViewDidBeginEditing:");
    commentField.textColor = [UIColor blackColor];
    if ([commentField.text isEqualToString:kDescription]){
        commentField.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"textViewDidEndEditing:");
    if ([commentField.text length]==0){
        commentField.textColor = [UIColor lightGrayColor];
        commentField.text = kDescription;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    BOOL confirmation = TRUE;
    if ([text isEqualToString:@"\n"]){
        confirmation = FALSE;
        [commentField resignFirstResponder];
    }
    return confirmation;
}

#pragma mark - TouchEvents
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *t = [touches anyObject];
    UIView *view = [t view];
    if (view.tag!=1000){
        [commentField resignFirstResponder];
        [titleField resignFirstResponder];
        [tagsField resignFirstResponder];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
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
