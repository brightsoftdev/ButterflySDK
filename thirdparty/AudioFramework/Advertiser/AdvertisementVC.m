//
//  AdvertisementVC.m
//  TeamLove
//
//  Created by Denny Kwon on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AdvertisementVC.h"

@implementation AdvertisementVC
@synthesize fileInfo;

- (void)gotoSite
{
    if (fileInfo!=nil){
        NSString *url = [fileInfo objectForKey:@"link"];
        NSLog(@"ADVERTISEMENT VC - gotoSite: %@", url);
        
        if ([url rangeOfString:@".com"].location != NSNotFound){ //check for valid URL
            NSString *http = @"http://";
            if ([url hasPrefix:http]==FALSE){
               url = [http stringByAppendingString:url];
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_advertisement.png"]];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    toolbar.barStyle = UIBarStyleBlack;
    [self.view addSubview:toolbar];
    [toolbar release];
    
    
    UIToolbar *bottom_toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 380, 320, 80)];
    bottom_toolbar.barStyle = UIBarStyleBlack;
    
    UIButton *btn_go = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_go setBackgroundImage:[UIImage imageNamed:@"btn_goto.png"] forState:UIControlStateNormal];
    [btn_go setTitle:@"Visit Sponsor" forState:UIControlStateNormal];
    btn_go.frame = CGRectMake(0, 25, 320, 50);
    [btn_go addTarget:self action:@selector(gotoSite) forControlEvents:UIControlEventTouchUpInside];
    [bottom_toolbar addSubview:btn_go];

    [self.view addSubview:bottom_toolbar];
    [bottom_toolbar release];
    
}

- (void)dealloc
{
    [fileInfo release];
    if (req!=nil){ [req release]; }
    if (image!=nil){ [image release]; }
    [super dealloc];
}

- (void)flush
{
    NSLog(@"ADVERTISEMENT VC - flush"); //release image view here to conserve memory
    if (image!=nil){
        [image removeFromSuperview];
        [image release]; //this might over release
        image = nil;
    }
    if (nameLabel!=nil){
        [nameLabel removeFromSuperview];
        [nameLabel release];
        nameLabel = nil;
    }
}

- (void)setupAd
{
    NSLog(@"ADVERTISEMENT VC - setupAd");
    if (fileInfo!=nil){
        NSLog(@"%@", [fileInfo description]);
        /*
         fileInfo =     {
            author = DKGmail;
            image = "http://lh5.ggpht.com/yuaefFxPn0XQGtcu1jcvijklrUsF3SY13trpNU8RiSNnEbd_3Jv1BC95N0QnNHmAaW4obY_VT5PR7_X2Iuf4ijFtJ0bfZg";
            index = none;
         	link = "www.dkyahoo.com";
            name = "ad1 - Cameron.mp3";
            url = "http://www.thegridmedia.com/serve?key=AMIfv967M59UvTXChT6CiBjLAhv8g0dWp0naum7q3zLiy_IOq24Yo_EGXMfHkuoIdywGp6niyduaDwUiacfrboYOsx7J-mFv3aWUAi-9NpffAQsy2fLlGHTeZoOV3wPyLjrpWO4829T9HP8sI6bW7nVdIqRhbGPGZjgkIpS_WRIjMvpClilwzP8&sponsor=dk23412179@yahoo.com";
         }; 
         */
        
        NSString *img_url = [fileInfo objectForKey:@"image"];
        if (img_url!=nil){
            if (req!=nil){ [req release]; req = nil; }
            img_url = [img_url stringByAppendingString:@"=s450"];
            req = [[URLRequest alloc] initWithAddress:img_url parameters:nil];
            [req setHttpMethod:@"GET"];
            req.delegate = self;
            [req sendRequest];
        }
        
        NSString *sponsor = [fileInfo objectForKey:@"author"];
        if (sponsor!=nil){
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 30)];
            nameLabel.textColor = [UIColor whiteColor];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.textAlignment = UITextAlignmentCenter;
            nameLabel.text = sponsor;
            [self.view addSubview:nameLabel];
        }
    }
}

- (void)requestData:(NSArray *)pkg
{
    if (pkg!=nil){
        NSData *img_data = [pkg objectAtIndex:1];
        UIImage *img = [UIImage imageWithData:img_data];
        if (image!=nil){ [image release]; image = nil; }
        
        image = [[UIImageView alloc] initWithImage:img];
        
        CGFloat width = img.size.width;
        CGFloat height = img.size.height;
        double scale;
        if (width>kMax){
            scale = kMax/width;
            width = kMax;
            height *= scale;
        }
        if (height>kMax){
            scale = kMax/height;
            height = kMax;
            width *= scale;
        }
        
        image.frame = CGRectMake(0.5*(320-width), 0.5*(340-height)+40, width, height);
        image.alpha = 0.0f;
        [self.view addSubview:image];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        image.alpha = 1.0f;
        [UIView commitAnimations];
    }
}





- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
