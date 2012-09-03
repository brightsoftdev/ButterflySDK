//
//  StationsViewController.m
//  butterflyradio
//
//  Created by Denny Kwon on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.


#import "StationsViewController.h"
#import "SearchViewController.h"

@interface StationsViewController ()

@end

@implementation StationsViewController
@synthesize searchString;

- (id)init
{
    self = [super init];
    if (self) {
        reload = FALSE;
        isLoading = FALSE;
        self.tabBarItem.image = [UIImage imageNamed:@"tab_home.png"];

//        UIImage *img_banner = [UIImage imageNamed:@"banner_home.png"];
//        CGFloat w = img_banner.size.width;
//        CGFloat h = img_banner.size.height;
//        UIImageView *banner = [[UIImageView alloc] initWithFrame:CGRectMake(0.5*(320-w), 10, w, h)];
//        banner.image = img_banner;
//        self.navigationItem.titleView = banner;
//        [banner release];

        imageCount = 0;
        self.title = @"Home";
        searchedStations = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (id)initWithManager:(ButterflyManager *)mgr
{
    self = [super initWithManager:mgr];
    if (self) {
        reload = FALSE;
        isLoading = FALSE;
        self.tabBarItem.image = [UIImage imageNamed:@"tab_home.png"];
        
        imageCount = 0;
        self.title = @"Home";
        searchedStations = [[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [loading release];
    [searchString release];
    [searchedStations release];
    [featuredView release];
    [super dealloc];
}

- (void)searchStations
{
    NSLog(@"SEARCH STATIONS: %@", self.searchString);
    
    if (![self.signal checkSignal]){
        [loading hide];
        [self showAlert:@"No Connection" message:@"Please find an internet connection"];
        return;
    }

    imageCount = 0;
    if (req!=nil){
        req.delegate = nil;
        [req release];
    }
    
    req = [[BRNetworkOp alloc] initWithAddress:self.searchString parameters:nil];
    req.delegate = self;
    [req setHttpMethod:@"GET"];
    [req sendRequest];
    
    if (isLoading==FALSE){
        [loading show];
    }

}

- (void)loadView
{
    UIViewAutoresizing resize = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);

    CGRect frame = [UIScreen mainScreen].applicationFrame;
    frame.size.height -= self.navigationController.navigationBar.frame.size.height;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_history.png"]];
    view.autoresizingMask = resize;
    
    
    featuredView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, frame.size.height)];
    featuredView.autoresizingMask = resize;
    featuredView.backgroundColor = [UIColor clearColor];
    featuredView.showsVerticalScrollIndicator = YES;
    featuredView.delegate = self;
    [view addSubview:featuredView];
    [self addPullToRefreshHeader:featuredView];
    
    loading = [[LoadingIndicator alloc] initWithFrame:frame];
    [view addSubview:loading];
    
    self.view = view;
    [view release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *url = [NSString stringWithFormat:@"http://www.butterflyradio.com/api/station?admins=%@", self.butterflyMgr.appHost];
    self.searchString = url;
    NSLog(@"STATIONS VIEW CONTROLLER - viewDidLoad: %@", self.searchString);

    UIButton *nowPlaying = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"nowPlaying.png"];
    [nowPlaying setBackgroundImage:img forState:UIControlStateNormal];
    [nowPlaying addTarget:self action:@selector(showRadio) forControlEvents:UIControlEventTouchUpInside];
    nowPlaying.showsTouchWhenHighlighted = YES;
    nowPlaying.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    UIBarButtonItem *showRadio = [[UIBarButtonItem alloc] initWithCustomView:nowPlaying];

    self.navigationItem.rightBarButtonItem = showRadio;
    [showRadio release];
    
    [self searchStations];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPortraitOnly object:nil]];
}


- (void)setupFeaturedViews:(int)numFeatured
{
    NSLog(@"setup Featured Views");
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kResetFeaturedViews object:nil]];

    int yOffset;
    for (int i=0; i<numFeatured; i++){
        int xOffset = i%2; //0, 1, 0, 1,...
        double y = i/2;
        yOffset = (int)y;
        FeaturedView *f = [[FeaturedView alloc] initWithFrame:CGRectMake(5+(xOffset*155), 5+(yOffset*120), 155, 120)];
        f.alpha = 0.0f;
        f.tag = (1000+i);
        [f addTarget:self action:@selector(featuredSelected:) forControlEvents:UIControlEventTouchUpInside];
        [featuredView addSubview:f];
        [f release];
    }
    
    double r = 0.5*numFeatured;
    int rows = (int)r;
    if ((numFeatured %2) != 0){ rows++; }
    featuredView.contentSize = CGSizeMake(320.0, (rows*120)+10);
    [self.view bringSubviewToFront:loading];
}



- (void)showSearch
{
    SearchViewController *search = [[SearchViewController alloc] init];
    [self.navigationController pushViewController:search animated:YES];
    [search release];
}

- (void)enterBackground
{
    NSLog(@"STATIONS VIEW CONTROLLER - enterBackground");
    reload = TRUE;

}

- (void)refresh
{
    if (reload==TRUE){
        NSLog(@"STATIONS VIEW CONTROLLER - refresh ");
        [self searchStations];
        reload = FALSE;
    }
}

- (void)search
{
    
}

- (void)featuredSelected:(FeaturedView *)btn
{
    NSLog(@"STATIONS VIEW CONTROLLER - featuredSelected: %@", btn.titleLabel.text);
    Station *station = [searchedStations objectForKey:btn.titleLabel.text];
    if (station){
        StationViewController *stationView = [[StationViewController alloc] init];
        stationView.butterflyMgr = self.butterflyMgr;
        stationView.hidesBottomBarWhenPushed = YES;

        stationView.station = station;
        stationView.title = station.name;
        [self.navigationController pushViewController:stationView animated:YES];
        [stationView release];
    }
}

- (void)imageReady:(NSString *)addr
{
    Station *s = (Station *)[searchedStations objectForKey:addr];
    if (s){
        [loading hide];
        s.delegate = nil;
        
        FeaturedView *f = (FeaturedView *)[featuredView viewWithTag:(imageCount+1000)];
        if (f){
            f.categoryLabel.text = s.category;
            f.titleLabel.text = s.unique_id;
            [f fillImage:s.imgData];
            f.nameLabel.text = [NSString stringWithFormat:@"%@  ", s.name];
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5f];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:f cache:YES];
            f.alpha = 1.0f;
            [UIView commitAnimations];
            

        }
        imageCount++;
    }
}


- (void)requestData:(NSArray *)pkg //returns [address, data]
{
    if (pkg!=nil){
        NSString *json = [[NSString alloc] initWithData:[pkg objectAtIndex:1] encoding:NSUTF8StringEncoding];
        NSDictionary *d = [json JSONValue];
        if (d==nil){ [req sendRequest]; }
        else{
            d = [d objectForKey:@"results"];
            NSLog(@"%@", [d description]);
            NSString *confirmation = [d objectForKey:@"confirmation"];
            if ([confirmation isEqualToString:@"found"]){
                [searchedStations removeAllObjects];
                NSArray *s = (NSArray *)[d objectForKey:@"stations"];
                if ([s count]>0){
                    [self setupFeaturedViews:[s count]];
                    
                    for (NSDictionary *info in s){ 
                        Station *station = [[Station alloc] init];
                        [station populate:info];
                        [searchedStations setObject:station forKey:station.unique_id];
                        
                        if (station.imgData==nil){
                            station.delegate = self;
                            [station fetchImage];
                        }
                        else{ [self imageReady:station.image]; }
                        [station release];
                    }
                }
                else{
                    // no stations alert
                }
            }
            else{
                //host not found (?) - should never happen.
            }
            if (isLoading==TRUE){ [self stopLoading:featuredView]; }

        }
    }
}



- (void)updateInfo
{
    NSLog(@"updateInfo");
    [self searchStations];
    //
    //    station.delegate = self;
    //    [station getStationInfo];
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
