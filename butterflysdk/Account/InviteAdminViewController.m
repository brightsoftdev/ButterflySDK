//
//  InviteAdminViewController.m
//  butterflyradio
//
//  Created by Denny Kwon on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InviteAdminViewController.h"

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


@interface InviteAdminViewController ()

@end

@implementation InviteAdminViewController
@synthesize station;
@synthesize emailField;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    [station release];
    [emailField release];
    [loading release];
    if (req!=nil) {
        [req cancel];
        req.delegate = nil;
        [req release];
    }
    [super dealloc];
}

- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kMainBackground]];
    view.tag = 1111;
	
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.barStyle = UIBarStyleBlack;
    
//    UIImage *img_banner = [UIImage imageNamed:@"banner.png"];
//    CGFloat w = 180.0f;
//    double scale = w/img_banner.size.width;
//    CGFloat h = scale*img_banner.size.height;
//    UIImageView *banner = [[UIImageView alloc] initWithFrame:CGRectMake(0.5*(320-w), 10, w, h)];
//    banner.image = img_banner;
//    [toolbar addSubview:banner];
//    [banner release];
    
    CGFloat w = 220.f;
    CGFloat h = 30.0f;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.5*(320-w), 10, w, h)];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"Invite Admin";
    titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [toolbar addSubview:titleLabel];
    [titleLabel release];
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:@"cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(exit)];
    btnCancel.tintColor = [UIColor redColor];
    toolbar.items = [NSArray arrayWithObjects:btnCancel, nil];
    [btnCancel release];
    [view addSubview:toolbar];
    [toolbar release];
    
    DetailBackground *nameBg = [DetailBackground backgroundWithFrame:CGRectMake(0, 44, 320, 35)];
    [nameBg.btnLabel setTitle:@"Email" forState:UIControlStateNormal];
    self.emailField = [UITextField textFieldwithFrame:CGRectMake(80, 5, 225, 25) placeholder:@"admin email"];
    self.emailField.delegate = self;
    [nameBg addSubview:emailField];
    [view addSubview:nameBg];
    
    UIImage *shadow = [UIImage imageNamed:@"dropShadow.png"];
    UIImageView *dropShadow = [[UIImageView alloc] initWithImage:shadow];
    dropShadow.frame = CGRectMake(0, nameBg.frame.origin.y+nameBg.frame.size.height, shadow.size.width, shadow.size.height);
    [view addSubview:dropShadow];
    [dropShadow release];
    
    UILabel *explanation = [[UILabel alloc] initWithFrame:CGRectMake(10, dropShadow.frame.origin.y+dropShadow.frame.size.height+10, 300, 10)];
    explanation.numberOfLines = 0;
    explanation.lineBreakMode = UILineBreakModeWordWrap;
    explanation.font = [UIFont fontWithName:kFont size:16.0f];
    explanation.backgroundColor = [UIColor clearColor];
    explanation.text = @"Invite an admin to help run your station. Each admin will receive submissions to your station for approval. They will be able to approve or reject subsmissions.";
    CGSize size = [explanation.text sizeWithFont:explanation.font constrainedToSize:CGSizeMake(300, 500) lineBreakMode:UILineBreakModeWordWrap];
	explanation.tag = 1111;
    
    frame = explanation.frame;
    frame.size.height = size.height;
    explanation.frame = frame;
    [view addSubview:explanation];
    [explanation release];
    
    UIButton *btnInvite = [UIButton buttonWithType:UIButtonTypeCustom];
    btnInvite.showsTouchWhenHighlighted = YES;
    btnInvite.titleLabel.font = [UIFont fontWithName:kFont size:14.0f];
    [btnInvite setBackgroundImage:[UIImage imageNamed:@"btn_gray@2x.png"] forState:UIControlStateNormal];
    [btnInvite setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnInvite addTarget:self action:@selector(inviteAdmin) forControlEvents:UIControlEventTouchUpInside];

    btnInvite.frame = CGRectMake(10, 414, 300, 35);
    [btnInvite setTitle:@"invite admin" forState:UIControlStateNormal];
    [view addSubview:btnInvite];
    
    loading = [[LoadingIndicator alloc] initWithFrame:view.frame];
    loading.hidden = YES;
    [view addSubview:loading];
    
    self.view = view;
    [view release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}

- (void)exit
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)inviteAdmin
{
    if ([self.emailField.text length]==0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Value" message:@"Please enter an email address." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else{
        if (req!=nil){
            [req cancel];
            req.delegate = nil;
            [req release];
        }
        
        NSString *url = [NSString stringWithFormat:@"http://%@/api/station", kUrl];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:station.unique_id, @"station", emailField.text, @"email", @"admin", @"action", station.name, @"name", [station tagsString], @"tags", station.category, @"category", nil];
        req = [[URLRequest alloc] initWithAddress:url parameters:params];
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
            
        }
        else{
            [loading hide];
            d = [d objectForKey:@"results"];
            NSLog(@"%@", [d description]);
            
            NSString *success = [d objectForKey:@"success"];
            if ([success isEqualToString:@"yes"]){
                NSString *msg = [NSString stringWithFormat:@"%@ has been invited to your station as an admin.", emailField.text]; 
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invitation Sent" message:msg delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
                [alert release];
                [self dismissModalViewControllerAnimated:YES];
            }
        }
        [json release];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIResponder Touch Methods
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *tchd = [touches anyObject];
	if (tchd.view.tag==1111){
		[emailField resignFirstResponder];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}
@end
