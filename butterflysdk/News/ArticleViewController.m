//
//  ArticleViewController.m
//  butterflyradio
//
//  Created by Denny Kwon on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ArticleViewController.h"

@interface ArticleViewController ()

@end

@implementation ArticleViewController
@synthesize article;
@synthesize station;

- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)dealloc
{
    [theWebview release];
    [article release];
    [station release];
    [loading release];
    if (req){
        req.delegate = nil;
        [req release];
    }
    [super dealloc];
}

- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    frame.origin.y = 0.0f;
    frame.origin.x = 0.0f;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    view.backgroundColor = [UIColor greenColor];
    
    theWebview = [[UIWebView alloc] initWithFrame:frame];
    theWebview.delegate = self;
    theWebview.autoresizingMask = view.autoresizingMask;
    [view addSubview:theWebview];
    
    UIButton *btnHide = [UIButton buttonWithType:UIButtonTypeCustom];
    btnHide.showsTouchWhenHighlighted = YES;
    btnHide.backgroundColor = [UIColor blackColor];
    [btnHide setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnHide setTitle:@"+" forState:UIControlStateNormal];
    btnHide.layer.cornerRadius = 5.0f;
    btnHide.alpha = 0.6f;
    CGFloat width = 30.0f;
    btnHide.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin);
    btnHide.frame = CGRectMake(view.frame.size.width-width, view.frame.size.height-width, width, width);
    [btnHide addTarget:self action:@selector(toggleNavBar) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnHide];

    loading = [[LoadingIndicator alloc] initWithFrame:view.frame];
    loading.hidden = YES;
    [view addSubview:loading];
    
    if (article.link==TRUE){
        theWebview.scalesPageToFit = YES;
        [theWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:article.content]]];
        [loading show];
    }
    else{ //send url request, parse contents from results and load html string
        theWebview.scalesPageToFit = NO;
        if (article.content==nil){
            NSString *url = [NSString stringWithFormat:@"http://www.butterflyradio.com/api/article/%@", article.unique_id];
            req = [[BRNetworkOp alloc] initWithAddress:url parameters:nil];
            [req setHttpMethod:@"GET"];
            req.delegate = self;
            [req sendRequest];
            [loading show];
        }
        else{ [self setupHtml]; }
    }
    
    self.view = view;
    [view release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kSupportLandscape object:nil]];
    
}

- (void)toggleNavBar
{
    BOOL hide = !self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:hide animated:YES];
}

- (void)exit
{
    if (req){
        req.delegate = nil;
        [req cancel];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupHtml
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"txt"];
    NSError *error = nil;
    NSString *template = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error){
        NSLog(@"TEMPLATE NOT FOUND");
    }
    else {
        template = [template stringByReplacingOccurrencesOfString:@"{{content}}" withString:article.content];
        template = [template stringByReplacingOccurrencesOfString:@"{{author}}" withString:article.author];
        
        NSString *image = nil;
        if ([article.imageUrl isEqualToString:@"none"]==TRUE){
            template = [template stringByReplacingOccurrencesOfString:@"{{image}}" withString:@""];
        }
        else{
            image = [[article.imageUrl componentsSeparatedByString:@"=="] objectAtIndex:0];
            image = [NSString stringWithFormat:@"<img style='width:300px' src='%@' />", image];
            template = [template stringByReplacingOccurrencesOfString:@"{{image}}" withString:image];
        }
        template = [template stringByReplacingOccurrencesOfString:@"{{date}}" withString:article.date];
        template = [template stringByReplacingOccurrencesOfString:@"{{title}}" withString:article.title];
        [theWebview loadHTMLString:template baseURL:nil];
    }
}

- (void)requestData:(NSArray *)pkg //returns [address, data]
{
    if (pkg!=nil){
        NSString *json = [[NSString alloc] initWithData:[pkg objectAtIndex:1] encoding:NSUTF8StringEncoding];
        NSDictionary *d = [json JSONValue];
        [json release];
        if (d==nil){
            [req sendRequest];
        }
        else{
            d = [d objectForKey:@"results"];
            NSLog(@"%@", [d description]);
            NSString *confirmation = [d objectForKey:@"confirmation"];
            if ([confirmation isEqualToString:@"found"]==TRUE){
                NSDictionary *a = [d objectForKey:@"article"];
                NSString *content = [a objectForKey:@"content"];
                article.content = content;
                
                NSString *img = [a objectForKey:@"image"];
                article.imageUrl = img;
                [self setupHtml];
            }
            else {
                [loading hide];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Article Not Found" message:@"This article was removed from the stataion" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *btnComment = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_comment.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(viewComments:)];

    UIBarButtonItem *btnTweet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_twitter.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(tweet:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:btnComment, btnTweet, nil];
    [btnTweet release];
    [btnComment release];
}

- (void)tweet:(UIBarButtonItem *)btn
{
    NSLog(@"TWEET: %@", article.title);
    Class tweeterClass = NSClassFromString(@"TWTweetComposeViewController");
    if(tweeterClass == nil) {   // check for Twitter integration
        // no Twitter integration; default to third-party Twitter framework
    } 
    else { // check Twitter accessibility and at least one account is setup
        if([TWTweetComposeViewController canSendTweet]==TRUE) {
            TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
            
            [tweetViewController setInitialText:[NSString stringWithFormat:@"Found this on Butterfly Radio:\n%@", article.title]];
            if (article.link==TRUE){
                [tweetViewController addURL:[NSURL URLWithString:article.content]];
            }
            else{
                [tweetViewController addURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.butterflyradio.com/site/article/%@", article.unique_id]]];
            }
            [tweetViewController addURL:[NSURL URLWithString:@"http://www.butterflyradio.com"]];
            
            tweetViewController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
                if(result == TWTweetComposeViewControllerResultDone) { // the user finished composing a tweet
                    
                } 
                else if(result == TWTweetComposeViewControllerResultCancelled) { // the user cancelled composing a tweet
                    
                }
                [self dismissViewControllerAnimated:YES completion:nil];
            };
            [self presentViewController:tweetViewController animated:YES completion:nil];
            [tweetViewController release]; 
        } 
        else {
            NSLog(@"NO TWITTER ACCOUNT SET UP!");
            // Twitter is not accessible or the user has not setup an account
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Twitter Account" message:@"Please link your Twitter account in the Settings section of your iPhone." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
}

- (void)viewComments:(UIBarButtonItem *)btn
{
    ReviewsViewController *reviews = [[ReviewsViewController alloc] initWithMode:ReviewModeArticle];
    reviews.station = station;
    reviews.uniqueID = article.unique_id;
    [self.navigationController pushViewController:reviews animated:YES];
    [reviews release];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    [loading show];
//    if (loading.hidden==TRUE){
//        [loading show];
//    }
    return TRUE;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [loading hide];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}


#pragma mark - UIResponder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan:");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesMoved:");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesEnded");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesCancelled");
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

@end
