//
//  CommentViewController.m
//  butterflyradio
//
//  Created by Denny Kwon on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommentViewController.h"

@interface CommentViewController ()

@end

@implementation CommentViewController
@synthesize station;
@synthesize delegate;
@synthesize uniqueID;
@synthesize mode;
@synthesize showStars;


/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        mode = 0;
        showStars = TRUE;
    }
    return self;
}
 */


- (id)init
{
    self = [super init];
    if (self) {
        mode = 0;
        showStars = TRUE;
    }
    return self;
}


- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor blueColor];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
    toolbar.barStyle = UIBarStyleBlack;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, toolbar.frame.size.width, toolbar.frame.size.height-10)];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"Write Comment";
    titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:18.0f];
    [toolbar addSubview:titleLabel];
    [titleLabel release];
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    btnCancel.tintColor = [UIColor redColor];
    
    UIBarButtonItem *btnSend = [[UIBarButtonItem alloc] initWithTitle:@"send" style:UIBarButtonItemStyleBordered target:self action:@selector(postComment)];
    btnSend.tintColor = [UIColor blueColor];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    toolbar.items = [NSArray arrayWithObjects:btnCancel, flex, btnSend, nil];
    [btnCancel release];
    [flex release];
    [btnSend release];
    
    
    [view addSubview:toolbar];
    [toolbar release];
    
    
    top = [[UIView alloc] initWithFrame:CGRectMake(0, 44, frame.size.width, 35)];
    top.backgroundColor = [UIColor yellowColor];
    
    usernameField = [[UITextField alloc] initWithFrame:CGRectMake(10, 2, 290, 31)];
    usernameField.font = [UIFont fontWithName:@"Heiti SC" size:17.0f];
    usernameField.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
    usernameField.placeholder = @"Username";
    usernameField.delegate = self;
    usernameField.borderStyle = UITextBorderStyleNone;
    [top addSubview:usernameField];
    [view addSubview:top];
    
    commentField = [[UITextView alloc] initWithFrame:CGRectMake(5, 90, 310, 102)];
    commentField.text = @"comment";
    commentField.textColor = [UIColor grayColor];
    commentField.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    commentField.delegate = self;
    [view addSubview:commentField];
    
    
    UIImage *imgEmptyStar = [UIImage imageNamed:@"emptyStar.png"];
    for (int i=0; i<5; i++) {
        int tag = 1000+i;
        UIButton *star = [UIButton buttonWithType:UIButtonTypeCustom];
        star.frame = CGRectMake(55+(i*45), 200, 30, 30);
        [star setBackgroundImage:imgEmptyStar forState:UIControlStateNormal];
        [star addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
        star.tag = tag;
        [view addSubview:star];
    }

    
    self.view = view;
    [view release];
}


- (void)dealloc
{
    [usernameField release];
    [commentField release];
    [station release];
    [loading release];
    [uniqueID release];
    [top release];
    [super dealloc];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    commentField.delegate = self;

    top.backgroundColor = [UIColor colorWithRed:kRGBMax/kRGBMax green:kRGBMax/kRGBMax blue:210.0f/kRGBMax alpha:1.0f];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kMainBackground]];
    
    usernameField.delegate = self;
    loading = [[LoadingIndicator alloc] initWithFrame:self.view.frame];
    loading.hidden = YES;
//    [loading hide];
    [self.view addSubview:loading];
    
    if (showStars==FALSE){
        for (int i=0; i<5; i++) {
            int tag = 1000+i;
            UIButton *star = (UIButton *)[self.view viewWithTag:tag];
            star.userInteractionEnabled = NO;
            star.hidden = YES;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}

- (void)cancel
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)btnTapped:(UIButton *)btn
{
    rating = 0;
    int tag = btn.tag;
    for (int i=1000; i<1005; i++){
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        if (i<=tag){
            rating++;
            [button setBackgroundImage:[UIImage imageNamed:@"fullStar.png"] forState:UIControlStateNormal];
        }
        else{
            [button setBackgroundImage:[UIImage imageNamed:@"emptyStar.png"] forState:UIControlStateNormal];
        }
    }
    [usernameField resignFirstResponder];
    [commentField resignFirstResponder];
}

- (void)postComment
{
    if (req!=nil){
        req.delegate = nil;
        [req release];
    }
    
    [usernameField resignFirstResponder];
    [commentField resignFirstResponder];
    
    if ([usernameField.text length]==0 || [commentField.text length]==0){
        [self showAlert:@"Missing Value" message:@"Please fill in all fields."];
    }
    else{
        
        NSMutableDictionary *params = nil;
        NSString *url = nil;
        if (mode==0){ // Station review
            params = [NSMutableDictionary dictionaryWithObjectsAndKeys:usernameField.text, @"username", commentField.text, @"comment", [NSString stringWithFormat:@"%d", rating], @"rating", nil];
            url = [NSString stringWithFormat:@"http://www.butterflyradio.com/api/reviews/%@", uniqueID];
        }
        if (mode==1){ // Article review
            params = [NSMutableDictionary dictionaryWithObjectsAndKeys:usernameField.text, @"username", commentField.text, @"comment", nil];
            url = [NSString stringWithFormat:@"http://www.butterflyradio.com/api/comments/%@?type=article", uniqueID];
        }
        if (mode==2){ // Tracl review
            params = [NSMutableDictionary dictionaryWithObjectsAndKeys:usernameField.text, @"username", commentField.text, @"comment", nil];
            url = [NSString stringWithFormat:@"http://www.butterflyradio.com/api/comments/%@?type=track", uniqueID];
        }
        
        NSLog(@"%@", [params description]);
        req = [[BRNetworkOp alloc] initWithAddress:url parameters:params];
        req.delegate = self;
        [req sendRequest];
        [loading show];
    }
}

- (void)requestData:(NSArray *)pkg //returns [address, data]
{
    if (pkg!=nil){
        NSString *json = [[NSString alloc] initWithData:[pkg objectAtIndex:1] encoding:NSUTF8StringEncoding];
        NSDictionary *d = [json JSONValue];
        if (d==nil){
            [req sendRequest];
        }
        else{
            [loading hide];
            d = [d objectForKey:@"results"];
            NSString *confirmation = [d objectForKey:@"confirmation"];
            if ([confirmation isEqualToString:@"found"]==TRUE || [confirmation isEqualToString:@"new"]==TRUE){
                NSDictionary *reviews = [d objectForKey:@"reviews"];
//                NSArray *comments = [reviews objectForKey:@"comments"]; //send this back to ReviewsViewController and refresh tableview
//                [delegate resetComments:comments];
                [delegate resetComments:reviews];
                [self dismissModalViewControllerAnimated:YES];
            }
            NSLog(@"%@", [d description]);
        }
        
    }
}


#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSString *comment = commentField.text;
    if ([comment isEqualToString:@"comment"]){
        commentField.textColor = [UIColor blackColor];
        commentField.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSString *comment = commentField.text;
    if ([comment length]==0){
        commentField.textColor = [UIColor grayColor];
        commentField.text = @"comment";
        [commentField resignFirstResponder];
    }
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    BOOL confirmation = TRUE;
    if ([text isEqualToString:@"\n"]){
        confirmation = FALSE;
        [textView resignFirstResponder];
    }
    return confirmation;
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
