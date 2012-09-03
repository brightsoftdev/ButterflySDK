//
//  RegisterViewController.m
//  butterflyradio
//
//  Created by Denny Kwon on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RegisterViewController.h"

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

@interface RegisterViewController ()

@end

@implementation RegisterViewController
@synthesize nameField;
@synthesize emailField;
@synthesize emailHost;
@synthesize delegate;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        clearCookies = TRUE;
        UIImage *img_banner = [UIImage imageNamed:@"banner_signup.png"];
        CGFloat w = 180.0f;
        double scale = w/img_banner.size.width;
        CGFloat h = scale*img_banner.size.height;
        UIImageView *banner = [[UIImageView alloc] initWithFrame:CGRectMake(0.5*(320-w), 10, w, h)];
        banner.image = img_banner;
        self.navigationItem.titleView = banner;
        [banner release];
    }
    return self;
}
 */

- (id)initWithManager:(ButterflyManager *)mgr
{
    self = [super initWithManager:mgr];
    if (self) {
        clearCookies = TRUE;
        UIImage *img_banner = [UIImage imageNamed:@"banner_signup.png"];
        CGFloat w = 180.0f;
        double scale = w/img_banner.size.width;
        CGFloat h = scale*img_banner.size.height;
        UIImageView *banner = [[UIImageView alloc] initWithFrame:CGRectMake(0.5*(320-w), 10, w, h)];
        banner.image = img_banner;
        self.navigationItem.titleView = banner;
        [banner release];
    }
    return self;
}



- (void)dealloc
{
    if (clearCookies==TRUE){
        NSArray *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
        for(NSHTTPCookie *cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
    
    self.delegate = nil;
    [nameField release];
    [emailField release];
    [emailHost release];
    [loading release];
    [descriptionLabel release];
    [super dealloc];
}


- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_register.png"]];
    
    descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 85, frame.size.width-40, 85)];
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.lineBreakMode = UILineBreakModeWordWrap;
    descriptionLabel.textColor = [UIColor blackColor];
    descriptionLabel.font = [UIFont fontWithName:kFont size:14.0f];
    descriptionLabel.shadowOffset = CGSizeMake(-0.5f, 0.5f);
    [view addSubview:descriptionLabel];
    
    UIButton *btnRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    btnRegister.frame = CGRectMake(10, 323, 145, 35);
    [btnRegister addTarget:self action:@selector(registerBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnRegister setBackgroundImage:[UIImage imageNamed:@"btn_base_gray@2x.png"] forState:UIControlStateNormal];
    [btnRegister setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRegister setTitle:@"Register" forState:UIControlStateNormal];
    btnRegister.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    btnRegister.showsTouchWhenHighlighted = YES;
    [view addSubview:btnRegister];

    UIButton *btnAppstore = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAppstore.frame = CGRectMake(165, 323, 145, 35);
    [btnAppstore addTarget:self action:@selector(appstoreBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnAppstore setBackgroundImage:[UIImage imageNamed:@"btn_base_gray@2x.png"] forState:UIControlStateNormal];
    [btnAppstore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnAppstore setTitle:@"Butterfly Radio" forState:UIControlStateNormal];
    btnAppstore.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    btnAppstore.showsTouchWhenHighlighted = YES;
    [view addSubview:btnAppstore];

    
    self.view = view;
    [view release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"register" ofType:@"txt"];
    
    NSError *e = nil;
    NSString *text = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&e];
    if (!e){
        NSString *finalText = [text stringByReplacingOccurrencesOfString:@"{{APP NAME}}" withString:self.butterflyMgr.appName];
        descriptionLabel.text = finalText;
        CGSize size = [descriptionLabel.text sizeWithFont:descriptionLabel.font constrainedToSize:CGSizeMake(descriptionLabel.frame.size.width, 500) lineBreakMode:descriptionLabel.lineBreakMode];
        CGRect frame = descriptionLabel.frame;
        frame.size.height = size.height;
        descriptionLabel.frame = frame;
        [text release];
    }
    
    
    DetailBackground *nameBg = [DetailBackground backgroundWithFrame:CGRectMake(0, 0, 320, 35)];
    [nameBg.btnLabel setTitle:@"Name" forState:UIControlStateNormal];
    self.nameField = [UITextField textFieldwithFrame:CGRectMake(80, 5, 225, 25) placeholder:@"name"];
    nameField.borderStyle = UITextBorderStyleNone;
    nameField.delegate = self;
    [nameBg addSubview:nameField];
    [self.view addSubview:nameBg];
    
    DetailBackground *emailBg = [DetailBackground backgroundWithFrame:CGRectMake(0, 35, 320, 35)];
    [emailBg.btnLabel setTitle:@"Email" forState:UIControlStateNormal];
    self.emailField = [UITextField textFieldwithFrame:CGRectMake(80, 5, 225, 25) placeholder:@"email"];
    emailField.borderStyle = UITextBorderStyleNone;
    emailField.userInteractionEnabled = NO;
    emailField.textColor = [UIColor grayColor];
    [emailBg addSubview:emailField];
    [self.view addSubview:emailBg];
    
    UIImage *shadow = [UIImage imageNamed:@"dropShadow.png"];
    UIImageView *dropShadow = [[UIImageView alloc] initWithImage:shadow];
    dropShadow.frame = CGRectMake(0, emailBg.frame.origin.y+emailBg.frame.size.height, shadow.size.width, shadow.size.height);
    [self.view addSubview:dropShadow];
    [dropShadow release];

    
    loading = [[LoadingIndicator alloc] initWithFrame:self.view.frame];
    loading.hidden = YES;
    [self.view addSubview:loading];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}

- (IBAction)registerBtnPressed:(UIButton *)btn
{
    NSLog(@"registerBtnPressed:");
    if ([nameField.text length]==0){
        [self showAlert:@"Missing Value" message:@"Please enter your name in the name field."];
        return;
    }
    
    
    if (req!=nil){
        [req cancel];
        req.delegate = nil;
        [req release];
    }
    
    NSString *url = [NSString stringWithFormat:@"http://%@/api/host", kUrl];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:emailHost, @"emailhost", [emailField.text lowercaseString], @"email", nameField.text, @"name", @"create", @"action", nil];
    
    req = [[BRNetworkOp alloc] initWithAddress:url parameters:params];
    req.delegate = self;
    [req sendRequest];
    [loading show];
}

- (IBAction)appstoreBtnPressed:(UIButton *)btn
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kItunesURL]];
}

- (void)requestData:(NSArray *)pkg //returns [address, data]
{
    if (pkg!=nil){
        NSString *json = [[NSString alloc] initWithData:[pkg objectAtIndex:1] encoding:NSUTF8StringEncoding];
        NSDictionary *d = [json JSONValue];
        if (d==nil){
            NSLog(@"%@", json);
            [json release];
            return;
        }
        
        [loading hide];
        d = [d objectForKey:@"results"];
        NSLog(@"%@", [d description]);
        NSString *confirmation = [d objectForKey:@"confirmation"];
        if ([confirmation isEqualToString:@"fail"]==FALSE){
            clearCookies = FALSE;
            [delegate registrationComplete];
            [self.navigationController popViewControllerAnimated:NO];
        }
        [json release];
    }
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
