//  LoginViewController.m
//  butterflyradio
//  Created by Denny Kwon on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.


#import "LoginViewController.h"

@interface LoginViewController ()

@end


@implementation LoginViewController
@synthesize theWebview;
@synthesize btnYahoo;
@synthesize btnGoogle;
@synthesize url;

/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Account";
        self.tabBarItem.image = [UIImage imageNamed:@"tab_account.png"];
    }
    return self;
}
 */


- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Account";
        self.tabBarItem.image = [UIImage imageNamed:@"tab_account.png"];
    }
    return self;
}

- (id)initWithManager:(ButterflyManager *)mgr
{
    self = [super initWithManager:mgr];
    if (self) {
        loginOnAppear = FALSE;
        self.title = @"Account";
        self.tabBarItem.image = [UIImage imageNamed:@"tab_account.png"];
    }
    return self;
}


- (void)dealloc
{
    self.btnGoogle = nil;
    self.btnYahoo = nil;
    self.url = nil;
    
    [loading release];
    [req release];
    [descriptionLabel release];
    [titleLabel release];
    [super dealloc];
}

- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_station.png"]];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 26)];
    titleLabel.text = @"Login or Register";
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:kFont size:16.0f];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(-0.5, 0.5f);
    [view addSubview:titleLabel];

    
    self.btnGoogle = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnGoogle.frame = CGRectMake(20, 51, 120, 50);
    [btnGoogle setBackgroundImage:[UIImage imageNamed:@"gmail.png"] forState:UIControlStateNormal];
    btnGoogle.showsTouchWhenHighlighted = YES;
    [btnGoogle addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnGoogle setTitle:@"google" forState:UIControlStateNormal];
    [btnGoogle setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    btnGoogle.layer.cornerRadius = 5.0f;
    btnGoogle.layer.masksToBounds = YES;
    [view addSubview:btnGoogle];

    self.btnYahoo = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnYahoo.frame = CGRectMake(180, 51, 120, 50);
    [btnYahoo setBackgroundImage:[UIImage imageNamed:@"yahoo.png"] forState:UIControlStateNormal];
    btnYahoo.showsTouchWhenHighlighted = YES;
    [btnYahoo addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnYahoo setTitle:@"yahoo" forState:UIControlStateNormal];
    [btnYahoo setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    self.btnYahoo.layer.cornerRadius = 5.0f;
    self.btnYahoo.layer.masksToBounds = YES;
    [view addSubview:btnYahoo];
    
    
    descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 126, frame.size.width-40, 35)];
    descriptionLabel.backgroundColor = [UIColor clearColor];
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    descriptionLabel.textColor = [UIColor darkGrayColor];
    descriptionLabel.lineBreakMode = UILineBreakModeWordWrap;
    [view addSubview:descriptionLabel];
    
    
    self.view = view;
    [view release];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"login" ofType:@"txt"];
    
    NSError *error = nil;
    NSString *loginText = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!error){
        descriptionLabel.text = [loginText stringByReplacingOccurrencesOfString:@"{{app name}}" withString:self.butterflyMgr.appName];
        CGSize size = [descriptionLabel.text sizeWithFont:descriptionLabel.font constrainedToSize:CGSizeMake(descriptionLabel.frame.size.width, 500) lineBreakMode:descriptionLabel.lineBreakMode];
        CGRect frame = descriptionLabel.frame;
        frame.size.height = size.height;
        descriptionLabel.frame = frame;
    }
    [loginText release];
                           
    
    
    UIButton *nowPlaying = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"nowPlaying.png"];
    [nowPlaying setBackgroundImage:img forState:UIControlStateNormal];
    [nowPlaying addTarget:self action:@selector(showRadio) forControlEvents:UIControlEventTouchUpInside];
    nowPlaying.showsTouchWhenHighlighted = YES;
    nowPlaying.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    UIBarButtonItem *showRadio = [[UIBarButtonItem alloc] initWithCustomView:nowPlaying];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:showRadio, nil];
    [showRadio release];
     

    theWebview = [[UIWebView alloc] initWithFrame:self.view.frame];
    theWebview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    theWebview.delegate = self;
    theWebview.hidden = YES;
    [self.view addSubview:theWebview];

    loading = [[LoadingIndicator alloc] initWithFrame:self.view.frame];
    loading.hidden = YES;
    [self.view addSubview:loading];
}


- (void)viewWillAppear:(BOOL)animated
{
    if (loginOnAppear==TRUE){
        if (self.url){
            loginOnAppear = FALSE;
            [self login:self.url];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    theWebview.hidden = YES;
}

- (void)login:(NSString *)addr
{
    if (req!=nil){
        req.delegate = nil;
        [req release];
    }

    req = [[BRNetworkOp alloc] initWithAddress:addr parameters:nil];
    [req setHttpMethod:@"GET"];
    req.delegate = self;
    [req sendRequest];
    [loading show];
}

- (void)btnPressed:(UIButton *)btn
{
    NSString *domain = btn.titleLabel.text;
    NSLog(@"btnPressed: %@", domain);
//    NSString *url = [NSString stringWithFormat:@"http://www.butterflyradio.com/api/login?host=%@", domain];
    self.url = [NSString stringWithFormat:@"http://www.butterflyradio.com/api/login?host=%@", domain];

    [self login:self.url];
}

- (void)requestData:(NSArray *)pkg //returns [address, data]
{
    if (pkg!=nil){
        NSString *json = [[NSString alloc] initWithData:[pkg objectAtIndex:1] encoding:NSUTF8StringEncoding];
        NSDictionary *d = [json JSONValue];
        if (d==nil){
            NSLog(@"%@", json);
        }
        else{
            d = [d objectForKey:@"results"];
            NSLog(@"%@", [d description]);
            
            NSString *loggedIn = [d objectForKey:@"logged in"];
            if ([loggedIn isEqualToString:@"yes"]==TRUE){
                NSLog(@"LOGGED IN");
                theWebview.hidden = YES;
                [loading hide];
                NSString *found = [d objectForKey:@"found"];
                if ([found isEqualToString:@"yes"]){ //user had a profile - route to admin page
                    NSDictionary *info = [d objectForKey:@"host"];
                    NSString *email = [d objectForKey:@"email"];

                    self.butterflyMgr.host.guest = ![email isEqualToString:self.butterflyMgr.appHost];
                    [self.butterflyMgr.host populate:info];
                    
                    HostViewController *hostVC = [[HostViewController alloc] initWithManager:self.butterflyMgr];
                    [self.navigationController pushViewController:hostVC animated:YES];
                    [hostVC release];

                    /*
                    if (appDelegate.host.guest==TRUE){
                        NSLog(@"MAIN HOST!");
                        HostViewController *hostVC = [[HostViewController alloc] init];
                        hostVC.host = appDelegate.host;
                        [self.navigationController pushViewController:hostVC animated:YES];
                        [hostVC release];
                    }
                    else {
                        NSLog(@"WRONG HOST - SHOW GUEST VC!");
                        GuestViewController *guest = [[GuestViewController alloc] initWithNibName:@"GuestViewController" bundle:nil];
                        guest.host = appDelegate.host;
                        [self.navigationController pushViewController:guest animated:YES];
                        [guest release];
                    } 
                     */
                    
                }
                else{ // user logged in but does not have profile - route to sign up page
                    NSLog(@"NEW USER!");
                    RegisterViewController *signup = [[RegisterViewController alloc] initWithManager:self.butterflyMgr];
                    signup.delegate = self;
                    signup.emailHost = [d objectForKey:@"emailhost"];
                    [self.navigationController pushViewController:signup animated:YES];
                    signup.emailField.text = [[d objectForKey:@"email"] lowercaseString];
                    [signup release];
                }
            }
            else{
                NSLog(@"NOT LOGGED IN");
                NSString *redirect = [d objectForKey:@"login redirect"];
                [theWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:redirect]]];
            }
        }
        [json release];
    }
}

- (void)registrationComplete
{
    loginOnAppear = TRUE;
}


#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL shouldContinue = TRUE;
    NSString *address = request.URL.absoluteString;
    NSLog(@"webView shouldStartLoadWithRequest: %@", address);
    if ([address isEqualToString:self.url]){
        shouldContinue = FALSE;
        [self login:self.url];
    }
    else {
        [loading show];
    }
    return shouldContinue;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad:");
    if (loading.hidden==TRUE) {
        [loading show];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad:");
    theWebview.alpha = 0.0f;
    theWebview.hidden = NO;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4f];
    theWebview.alpha = 1.0f;
    [UIView commitAnimations];
    [loading hide];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"webView didFailLoadWithError:");
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
