//
//  RadioViewController.m
//  butterflyradio
//
//  Created by Denny Kwon on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RadioViewController.h"

@interface RadioViewController ()

@end

@implementation RadioViewController
@synthesize playPause;
@synthesize image;
@synthesize loading;

static const CGFloat kDefaultReflectionFraction = 0.65;
static const CGFloat kDefaultReflectionOpacity = 0.60;



- (id)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.title = @"Radio";
        
        show = FALSE;
        img_pause = [[UIImage imageNamed:@"radio_pause.png"] retain];
        img_play = [[UIImage imageNamed:@"radio_play.png"] retain];
    }
    return self;
}

- (id)initWithManager:(ButterflyManager *)mgr
{
    self = [super initWithManager:mgr];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.title = @"Radio";
        
        show = FALSE;
        img_pause = [[UIImage imageNamed:@"radio_pause.png"] retain];
        img_play = [[UIImage imageNamed:@"radio_play.png"] retain];
    }
    return self;
}

- (void)dealloc
{
    self.butterflyMgr.player.delegate = nil;
    
    [image release];
    [playPause release];
    [reflectionView release];
    [detailsView release];
    [img_play release];
    [img_pause release];
    [loading release];
    [trackTitleLabel release];
    [super dealloc];
}

- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    frame.origin.y = 0.0f;
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default.png"]];
    
    image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.width)];
    image.backgroundColor = [UIColor clearColor];
    [view addSubview:image];
    
    
    reflectionView = [[UIImageView alloc] initWithFrame:CGRectMake(0, image.frame.size.height, image.frame.size.width, image.frame.size.height)];
    [view addSubview:reflectionView];
    
    CGFloat height = 75.0f;
    
    frame = view.frame;
    frame.size.height -= (height-1);
    
    detailsView = [[TrackDetailView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    detailsView.delegate = self;
//    if (player.streamer.source.full==TRUE){ 
//        detailsView.slider.hidden = NO;
//    }
    if (self.butterflyMgr.player.streamer.source.full==TRUE){
        detailsView.slider.hidden = NO;
    }
    else{
        detailsView.slider.hidden = YES;
    }
    detailsView.hidden = YES;
    detailsView.slider.value = 0;
    [self fillInDetails];
    [view addSubview:detailsView];

    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, view.frame.size.height-height+1, 320, height)];
    toolbar.barStyle = UIBarStyleBlack;
    toolbar.translucent = YES;
    toolbar.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    
    trackTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, toolbar.frame.size.width, 20)];
    trackTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    trackTitleLabel.textAlignment = UITextAlignmentCenter;
    trackTitleLabel.textColor = [UIColor whiteColor];
    trackTitleLabel.font = [UIFont systemFontOfSize:12.0f];
    trackTitleLabel.backgroundColor = [UIColor clearColor];
    [toolbar addSubview:trackTitleLabel];
    
    self.playPause = [UIButton buttonWithType:UIButtonTypeCustom];
    playPause.showsTouchWhenHighlighted = YES;
    [playPause addTarget:self action:@selector(btnPlayPausePressed:) forControlEvents:UIControlEventTouchUpInside];
    [playPause setBackgroundImage:[UIImage imageNamed:@"radio_pause.png"] forState:UIControlStateNormal];
    playPause.frame = CGRectMake(0, 0, 42, 42);
    UIBarButtonItem *btnPlayPause = [[UIBarButtonItem alloc] initWithCustomView:playPause];
    
    UIButton *skip = [UIButton buttonWithType:UIButtonTypeCustom];
    [skip setBackgroundImage:[UIImage imageNamed:@"radio_skip.png"] forState:UIControlStateNormal];
    [skip addTarget:self action:@selector(btnSkipPressed:) forControlEvents:UIControlEventTouchUpInside];
    skip.showsTouchWhenHighlighted = YES;
    skip.frame = playPause.frame;
    UIBarButtonItem *btnSkip = [[UIBarButtonItem alloc] initWithCustomView:skip];
    
    UIBarButtonItem *btnReply = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(reply:)];

    UIBarButtonItem *btnEmail = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showEmail)];

    UIBarItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarItem *flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarItem *flex3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarItem *flex4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarItem *flex5 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];


    toolbar.items = [NSArray arrayWithObjects:flex, btnPlayPause, flex2, btnSkip, flex3, btnReply, flex4, btnEmail, flex5, nil];
    [flex release];
    [flex2 release];
    [flex4 release];
    [flex3 release];
    [flex5 release];
    [btnEmail release];
    [btnPlayPause release];
    [btnSkip release];
    [btnReply release];
    
    [view addSubview:toolbar];
    [toolbar release];
    
    LoadingIndicator *spinner = [[LoadingIndicator alloc] initWithFrame:view.frame];
    self.loading = spinner;
    [spinner release];
    
    loading.hidden = YES;
    [view addSubview:loading];
    
    self.view = view;
    [view release];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.butterflyMgr.player.delegate = self;
    
    UIBarButtonItem *btnComment = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_comment.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(viewComments:)];
    
    UIBarButtonItem *btnTweet = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_twitter.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(btnTweetPressed:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:btnComment, btnTweet, nil];
    [btnTweet release];
    [btnComment release];
    
//    if (!self.butterflyMgr.player.streamer.isRunning)
//        [loading show];


}

- (void)reply:(UIBarItem *)btn
{
    NSLog(@"reply:");
    if (self.butterflyMgr.player.streamer.isRunning==TRUE){
        [playPause setBackgroundImage:img_play forState:UIControlStateNormal];
        [self.butterflyMgr.player pause];
    }

    RecordViewController *submitTrack = [[RecordViewController alloc] initWithManager:self.butterflyMgr];
    submitTrack.butterflyMgr = self.butterflyMgr;
    NSString *thread = self.butterflyMgr.player.streamer.source.thread;
    if (thread != nil){
        NSLog(@"REPLY TO: %@", thread);
        submitTrack.thread = thread;
    }
    
    submitTrack.station = self.butterflyMgr.currentStation;
    [self presentModalViewController:submitTrack animated:YES];
    [submitTrack release];
}

- (void)fillInDetails
{
    trackTitleLabel.text = self.butterflyMgr.player.streamer.source.name;
    detailsView.nameLabel.text = [NSString stringWithFormat:@"%@: %@", self.butterflyMgr.currentStation.name, self.butterflyMgr.player.streamer.source.name];
    detailsView.authorLabel.text = [NSString stringWithFormat:@"submitted by %@", self.butterflyMgr.player.streamer.source.author];
    detailsView.dateLabel.text = self.butterflyMgr.player.streamer.source.date;
}

- (void)populateImage:(UIImage *)img
{
    self.view.backgroundColor = nil;
    CGFloat w = img.size.width;
    CGFloat h = img.size.height;
    CGFloat max = self.view.frame.size.width;
    double scale;
    if (w>max){
        scale = max/w;
        w = max;
        h *= scale;
    }
    
    image.image = img;
    CGRect frame = image.frame;
    frame.size.width = w;
    frame.size.height = h;
    image.frame = frame;
    
    frame.origin.y = frame.size.height;
    reflectionView.frame = frame;
    
    NSUInteger reflectionHeight = image.bounds.size.height * kDefaultReflectionFraction;
    reflectionView.image = [self reflectedImage:image withHeight:reflectionHeight];
	reflectionView.alpha = kDefaultReflectionOpacity;

}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.butterflyMgr.currentStation){
        Station *station = self.butterflyMgr.currentStation;
        if (station.imgData==nil){
            station.delegate = self;
            [station fetchImage];
        }
        else {
            UIImage *img = [UIImage imageWithData:station.imgData];
            [self populateImage:img];
        }
    }

}

- (void)imageReady:(NSString *)addr
{
    UIImage *img = [UIImage imageWithData:self.butterflyMgr.currentStation.imgData];
    [self populateImage:img];
}

- (void)btnPlayPausePressed:(UIButton *)btn
{
    NSLog(@"btnPlayPausePressed:");
    
    if (self.butterflyMgr.player.streamer.isRunning==TRUE){
        [playPause setBackgroundImage:img_play forState:UIControlStateNormal];
        [self.butterflyMgr.player pause];
    }
    else{
        [playPause setBackgroundImage:img_pause forState:UIControlStateNormal];
        [self.butterflyMgr.player play];
    }

}

- (void)btnSkipPressed:(UIButton *)btn
{
    [self.butterflyMgr.player skip];
    [playPause setBackgroundImage:img_pause forState:UIControlStateNormal];
    
//    if (self.butterflyMgr.currentStation){
//        [self.butterflyMgr.player skip];
//        [playPause setBackgroundImage:img_pause forState:UIControlStateNormal];
//    }
}

- (void)viewComments:(UIButton *)btn
{
    if (self.butterflyMgr.player.streamer.source==nil){
        
    }
    else{
        NSString *url = self.butterflyMgr.player.streamer.source.url;
        if ([url rangeOfString:@"stream"].location != NSNotFound){
            
            NSArray *parts = [url componentsSeparatedByString:@"/"];
            url = [parts lastObject];  
            NSLog(@"viewComments: %@", url);
            
            ReviewsViewController *reviews = [[ReviewsViewController alloc] initWithMode:ReviewModeTrack];
            reviews.uniqueID = url;
            reviews.station = self.butterflyMgr.currentStation;
            [self.navigationController pushViewController:reviews animated:YES];
            [reviews release];

            
        }
    }
}

- (void)btnTweetPressed:(UIButton *)btn
{
    if (self.butterflyMgr.currentStation){
        Class tweeterClass = NSClassFromString(@"TWTweetComposeViewController");
        if(tweeterClass == nil) {   // check for Twitter integration
            // no Twitter integration; default to third-party Twitter framework
        } 
        else { // check Twitter accessibility and at least one account is setup
            if([TWTweetComposeViewController canSendTweet]==TRUE) {
                TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
                
                [tweetViewController setInitialText:self.butterflyMgr.player.streamer.source.name];
                NSString *url = self.butterflyMgr.player.streamer.source.url;
                url = [url stringByReplacingOccurrencesOfString:@"thegrid-butterflyradio.appspot.com" withString:@"www.butterflyradio.com"];
                [tweetViewController addURL:[NSURL URLWithString:url]];
                
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
}



#pragma mark - Image Reflection
CGImageRef CreateGradientImage(int pixelsWide, int pixelsHigh)
{
	CGImageRef theCGImage = NULL;
    
	// gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	
	// create the bitmap context
	CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh, 8, 0, colorSpace, kCGImageAlphaNone);
	
	// define the start and end grayscale values (with the alpha, even though
	// our bitmap context doesn't support alpha the gradient requires it)
	CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
	
	// create the CGGradient and then release the gray color space
	CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
	CGColorSpaceRelease(colorSpace);
	
	// create the start and end points for the gradient vector (straight down)
	CGPoint gradientStartPoint = CGPointZero;
	CGPoint gradientEndPoint = CGPointMake(0, pixelsHigh);
	
	// draw the gradient into the gray bitmap context
	CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
								gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(grayScaleGradient);
	
	// convert the context into a CGImageRef and release the context
	theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
	CGContextRelease(gradientBitmapContext);
	
	// return the imageref containing the gradient
    return theCGImage;
}

CGContextRef MyCreateBitmapContext(int pixelsWide, int pixelsHigh)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	// create the bitmap context
	CGContextRef bitmapContext = CGBitmapContextCreate (NULL, pixelsWide, pixelsHigh, 8,
														0, colorSpace,
														// this will give us an optimal BGRA format for the device:
														(kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
	CGColorSpaceRelease(colorSpace);
    return bitmapContext;
}

- (UIImage *)reflectedImage:(UIImageView *)fromImage withHeight:(NSUInteger)height
{
    if(height == 0)
		return nil;
    
	CGContextRef mainViewContentContext = MyCreateBitmapContext(fromImage.bounds.size.width, height); // create a bitmap graphics context the size of the image
	
	// create a 2 bit CGImage containing a gradient that will be used for masking the 
	// main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
	// function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
	CGImageRef gradientMaskImage = CreateGradientImage(1, height);
	
	// create an image by masking the bitmap of the mainView content with the gradient view
	// then release the  pre-masked content bitmap and the gradient bitmap
	CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, fromImage.bounds.size.width, height), gradientMaskImage);
	CGImageRelease(gradientMaskImage);
	
	// In order to grab the part of the image that we want to render, we move the context origin to the
	// height of the image that we want to capture, then we flip the context so that the image draws upside down.
	CGContextTranslateCTM(mainViewContentContext, 0.0, height);
	CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);
	
	// draw the image into the bitmap context
	CGContextDrawImage(mainViewContentContext, fromImage.bounds, fromImage.image.CGImage);
	
	// create CGImageRef of the main view bitmap content, and then release that bitmap context
	CGImageRef reflectionImage = CGBitmapContextCreateImage(mainViewContentContext);
	CGContextRelease(mainViewContentContext);
	
	// convert the finished reflection image to a UIImage 
	UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
	
	// image is retained by the property setting above, so we can release the original
	CGImageRelease(reflectionImage);
	
	return theImage;
}

#pragma mark - TrackDetailsViewDelegate
- (void)sliding
{
    NSLog(@"SLIDING");
    [self.butterflyMgr.player pause];
}

- (void)seekTo:(int)x
{
    [self.butterflyMgr.player seek:x];
}


#pragma mark - PlayerDelegate
- (void)displayLoading:(BOOL)s; //s==TRUE means show, s==FALSE means hide
{
    if (s==TRUE){ [loading show]; }
    else{ [loading hide]; }
}

- (void)trackInfo:(NSMutableDictionary *)d
{
    NSLog(@"RADIO VIEW CONTROLLER - trackInfo: %@", [d description]);
    detailsView.slider.value = 0;
    [self fillInDetails];
//    [loading show];

//    detailsView.nameLabel.text = [d objectForKey:@"name"];
//    detailsView.authorLabel.text = [NSString stringWithFormat:@"submitted by %@", [d objectForKey:@"author"]];
//    detailsView.dateLabel.text = [d objectForKey:@"date"];
    
}

- (void)fileError
{
    
}

- (void)setSliderMax:(NSUInteger)max
{
    NSLog(@"RADIO VIEW CONTROLLER - setSliderMax:");
    detailsView.slider.maximumValue = max;
}

- (void)updateSliderPosition:(int)s
{
    NSLog(@"RADIO VIEW CONTROLLER - updateSliderPosition:");
    if (loading.hidden == FALSE){
        [loading hide];
    }

    if (detailsView.slider.hidden==TRUE && self.butterflyMgr.player.streamer.source.full==TRUE){ detailsView.slider.hidden = NO; }
    [playPause setBackgroundImage:img_pause forState:UIControlStateNormal];
    detailsView.slider.maximumValue = self.butterflyMgr.player.streamer.source.bytes.length;
    detailsView.slider.value = s;
    
    [self fillInDetails];

    
    if (self.butterflyMgr.player.streamer.source.format==FileFormatM4A){
        detailsView.slider.userInteractionEnabled = FALSE;
    }
    else{
        detailsView.slider.userInteractionEnabled = TRUE;
    }

}

- (void)fileComplete
{
    NSLog(@"RADIO VIEW CONTROLLER - fileComplete");
    detailsView.slider.value = detailsView.slider.maximumValue;
}


#pragma mark - Mail
- (void)showEmail
{
    MFMailComposeViewController *mailVC = [[[MFMailComposeViewController alloc] init] autorelease];
    mailVC.mailComposeDelegate = self;
    mailVC.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    
    NSString *body = [NSString stringWithFormat:@"<html><body><img style='margin-top:10px;width:150px' src='http://www.butterflyradio.com/site/images/default.jpg' /><br /><a href='http://itunes.apple.com/us/app/butterfly-radio/id532051737?mt=8'>download here</a></body></html>"];
    [mailVC setMessageBody:body isHTML:YES];
    
    [mailVC setSubject:@"Butterfly Radio"];
    
    AudioFile *track = self.butterflyMgr.player.streamer.source;
    if (track.full==TRUE) {
        NSString *file = nil;
        NSString *mime = nil;
        if (track.format==FileFormatMP3){
            file = [NSString stringWithFormat:@"%@.mp3", track.name];
            mime = @"audio/mpeg";
        }
        else {
            file = [NSString stringWithFormat:@"%@.m4a", track.name];
            mime = @"audio/x-m4a";
        }
        [mailVC addAttachmentData:self.butterflyMgr.player.streamer.source.bytes mimeType:mime fileName:file];
        NSLog(@"test 9");
    }
    [self presentModalViewController:mailVC animated:YES];
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSLog(@"controller didFinishWithResult:");
//    self.title = station.name;
//    [theTableview deselectRowAtIndexPath:[theTableview indexPathForSelectedRow] animated:YES];
    [controller dismissModalViewControllerAnimated:YES];
}



#pragma mark - UIResponder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan:");
    show = TRUE;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesMoved:");
    show = FALSE;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesEnded");
    if (show==TRUE){
        detailsView.hidden = !detailsView.hidden;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesCancelled");
    show = FALSE;
}




- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
