//
//  StationViewController.m
//  butterflyradio
//
//  Created by Denny Kwon on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StationViewController.h"

#define REFRESH_HEADER_HEIGHT 62.0f

@implementation DetailView
@synthesize titleLabel;
@synthesize textLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:kRGBMax/kRGBMax green:kRGBMax/kRGBMax blue:210.0f/kRGBMax alpha:1.0f];
        self.layer.borderColor = [[UIColor grayColor] CGColor];
        self.layer.borderWidth = 0.5f;
        self.layer.cornerRadius = 4.0f;

        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, frame.size.width-10, 20)];
        titleLabel.text = @"Category";
        titleLabel.textColor = [UIColor colorWithRed:70.0f/kRGBMax green:70.0f/kRGBMax blue:170.0f/kRGBMax alpha:1.0f];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        [self addSubview:titleLabel];
        
        frame.origin.y += 20.0f;
        frame.size.height -= 25.0f;
        
        theScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, frame.size.height)];
        theScrollview.backgroundColor = [UIColor clearColor];
        [self addSubview:theScrollview];
        
        textLabel = [[UILabel alloc] initWithFrame:frame];
        textLabel.lineBreakMode = UILineBreakModeWordWrap;
        textLabel.numberOfLines = 0;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor darkGrayColor];
        textLabel.font = [UIFont fontWithName:@"Heiti SC" size:12.0f];
//        textLabel.frame = CGRectMake(5, 20.0f, frame.size.width-10, 20.0f);
        textLabel.frame = CGRectMake(5, 0.0f, frame.size.width-10, 20.0f);
        textLabel.text = @"sports";
        [theScrollview addSubview:textLabel];
        
    }
    return self;
}

- (void)resize
{
    CGRect frame = textLabel.frame;
    CGSize size = [textLabel.text sizeWithFont:textLabel.font constrainedToSize:CGSizeMake(frame.size.width, 300) lineBreakMode:textLabel.lineBreakMode];
    frame.size.height = size.height;
    
    textLabel.frame = frame;
    theScrollview.contentSize = CGSizeMake(theScrollview.frame.size.width, size.height);
}

- (void)dealloc
{
    [titleLabel release];
    [textLabel release];
    [theScrollview release];
    [super dealloc];
}

@end



@interface StationViewController ()

@end

static NSString *audio = @"radio";
static NSString *about = @"about";
static NSString *articles = @"articles";
static NSString *contact = @"contact";
static NSString *reviews = @"reviews";
static NSString *share = @"share";
//static NSString *submit = @"submit";

@implementation StationViewController
@synthesize station;
@synthesize btn_save;
@synthesize btn_reviews;
@synthesize btn_share;
@synthesize btn_contact;


- (CGRect)adjustFrame:(UIImage *)img;
{
    CGRect frame = image.frame;
    CGFloat width = img.size.width;
    CGFloat height = img.size.height;
    CGFloat max = kMaxDimen;
    
    double scale;
    if (width>max){
        scale = max/width;
        width = max;
        height *= scale;
    }
    if (height>max){
        scale = max/height;
        height = max;
        width *= scale;
    }
    
    frame.size.width = width;
    frame.size.height = height;
    return frame;
}

- (id)init
{
    self = [super init];
    if (self) {
        reload = FALSE;
        self.hidesBottomBarWhenPushed = TRUE;
        vMode = ViewModeRadio;
        backgrounds = [[NSArray alloc] initWithObjects:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_cell.png"]],  [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_cell_tint.png"]], nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"image ready" object:nil];
        sections = [[NSArray alloc] initWithObjects:audio, articles, reviews, share, contact, nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:UIApplicationDidBecomeActiveNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thumbnailReady) name:kThumbnailReadyNotification object:nil];
        
//        UISegmentedControl *sectionsSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Radio", @"News", nil]];
//        sectionsSegment.frame = CGRectMake(0, 0, 160, 30);
//        [sectionsSegment addTarget:self action:@selector(switchMode:) forControlEvents:UIControlEventValueChanged];
//        sectionsSegment.selectedSegmentIndex = 0;
//        sectionsSegment.segmentedControlStyle = UISegmentedControlStyleBar;
//        sectionsSegment.tintColor = self.navigationController.navigationBar.tintColor;
//        self.navigationItem.titleView = sectionsSegment;
//        [sectionsSegment release];

    }
    return self;
}

- (void)dealloc
{
    self.btn_reviews = nil;
    self.btn_save = nil;
    self.btn_share = nil;
    self.btn_contact = nil;
    station.delegate = nil;
    [backgrounds release];
    [station cancelUpdate];
    [station release];
    [theTableview release];
    [image release];
    [sections release];
    [imageShadow release];
    [loading release];
    [titleLabel release];
    [bottom release];
    
    [refreshArrow release];
    [refreshHeaderView release];
    [refreshLabel release];
    [refreshSpinner release];

    [super dealloc];
}

- (void)loadView
{
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Heiti SC" size:20.0f] forKey:UITextAttributeFont];
    
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    UIViewAutoresizing resize = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);

    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = resize;
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_station.png"]];
    
    UISegmentedControl *sectionsSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Radio", @"News", nil]];
    sectionsSegment.frame = CGRectMake(0, 0, 160, 30);
    [sectionsSegment addTarget:self action:@selector(switchMode:) forControlEvents:UIControlEventValueChanged];
    sectionsSegment.selectedSegmentIndex = 0;
    sectionsSegment.segmentedControlStyle = UISegmentedControlStyleBar;
    sectionsSegment.tintColor = self.navigationController.navigationBar.tintColor;
    self.navigationItem.titleView = sectionsSegment;
    [sectionsSegment release];

    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 26)];
    titleLabel.font = [UIFont fontWithName:kFont size:16.0f];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(-0.5, 0.5f);
    titleLabel.text = station.name;
    titleLabel.backgroundColor = [UIColor clearColor];
    [view addSubview:titleLabel];

    image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 32, kMaxDimen, kMaxDimen)];
    image.layer.cornerRadius = 4.0f;
    image.layer.masksToBounds = YES;
    [view addSubview:image];
    if (station.imgData==nil){
        station.delegate = self;
        image.image = [UIImage imageNamed:@"placeholder.png"];
        [station fetchImage];
    }
    else{ 
        image.image = [UIImage imageWithData:station.imgData];;
        CGRect frame = [self adjustFrame:image.image];
        image.frame = frame;
        
        CGRect shadowFrame = imageShadow.frame;
        shadowFrame.size.width = frame.size.width;
        shadowFrame.size.height = frame.size.height;
        imageShadow.frame = shadowFrame; 
    }
    
    imageShadow = [[UIImageView alloc] initWithFrame:image.frame];
    imageShadow.image = [UIImage imageNamed:@"bezel.png"];
    imageShadow.layer.cornerRadius = image.layer.cornerRadius;
    imageShadow.layer.masksToBounds = YES;
    imageShadow.backgroundColor = [UIColor clearColor];
    [view addSubview:imageShadow];
    
    UIImage *imgButtons = [UIImage imageNamed:@"buttonTray.png"];
    UIImageView *buttonTray = [[UIImageView alloc] initWithImage:imgButtons];
    double scale = 0.85f;
    CGFloat w = scale*imgButtons.size.width;
    CGFloat h = scale*imgButtons.size.height;
    buttonTray.frame = CGRectMake(150, image.frame.origin.y, w, h);
    [view addSubview:buttonTray];
    [buttonTray release];
    
    UIColor *darkGray = [UIColor darkGrayColor];
    CGFloat x = 150.0f;
    CGFloat wid = 80.0f;
    CGFloat height = 38.0f;
    self.btn_save = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_save.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom; 
    btn_save.backgroundColor = [UIColor clearColor];
    btn_save.frame = CGRectMake(x, image.frame.origin.y+3, wid, height);
    btn_save.showsTouchWhenHighlighted = YES;
    btn_save.titleLabel.font = [UIFont fontWithName:kFont size:10.0f];
    [btn_save addTarget:self action:@selector(saveStation) forControlEvents:UIControlEventTouchUpInside];
    if (station.saved==TRUE){
        [btn_save setTitle:@"Saved" forState:UIControlStateNormal];
        [btn_save setBackgroundImage:[UIImage imageNamed:@"heart-red.png"] forState:UIControlStateNormal];
        btn_save.userInteractionEnabled = NO;
        btn_save.titleLabel.textColor = [UIColor lightGrayColor];
    }
    else {
        [btn_save setTitle:@"Save" forState:UIControlStateNormal];
        [btn_save setBackgroundImage:[UIImage imageNamed:@"heart.png"] forState:UIControlStateNormal];
        [btn_save setTitleColor:darkGray forState:UIControlStateNormal];
    }
    [view addSubview:btn_save];
    
    self.btn_reviews = [UIButton buttonWithType:btn_save.buttonType];
    [btn_reviews setBackgroundImage:[UIImage imageNamed:@"reviews.png"] forState:UIControlStateNormal];
    btn_reviews.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom; 
    btn_reviews.backgroundColor = [UIColor clearColor];
    [btn_reviews setTitleColor:darkGray forState:UIControlStateNormal];
    btn_reviews.frame = CGRectMake(x+wid, btn_save.frame.origin.y, wid, height);
    btn_reviews.showsTouchWhenHighlighted = YES;
    btn_reviews.titleLabel.font = [UIFont fontWithName:kFont size:10.0f];
    [btn_reviews addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btn_reviews setTitle:@"Reviews" forState:UIControlStateNormal];
    [view addSubview:btn_reviews];

    self.btn_contact = [UIButton buttonWithType:btn_save.buttonType];
    [btn_contact setBackgroundImage:[UIImage imageNamed:@"contact.png"] forState:UIControlStateNormal];
    btn_contact.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom; 
    btn_contact.backgroundColor = [UIColor clearColor];
    [btn_contact setTitleColor:darkGray forState:UIControlStateNormal];
    btn_contact.frame = CGRectMake(x, btn_reviews.frame.origin.y+btn_reviews.frame.size.height+4, wid, height);
    btn_contact.showsTouchWhenHighlighted = YES;
    btn_contact.titleLabel.font = [UIFont fontWithName:kFont size:10.0f];
    [btn_contact addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btn_contact setTitle:@"Contact" forState:UIControlStateNormal];
    [view addSubview:btn_contact];
    
    UIButton *btnPost = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPost setBackgroundImage:[UIImage imageNamed:@"mic.png"] forState:UIControlStateNormal];
    btnPost.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    btnPost.backgroundColor = [UIColor clearColor];
    [btnPost setTitleColor:darkGray forState:UIControlStateNormal];
    btnPost.frame = CGRectMake(x+wid, btn_contact.frame.origin.y, wid, height);
    btnPost.showsTouchWhenHighlighted = YES;
    btnPost.titleLabel.font = [UIFont fontWithName:kFont size:10.0f];
//    [btnPost addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [btnPost addTarget:self action:@selector(post) forControlEvents:UIControlEventTouchUpInside];
    [btnPost setTitle:@"Post" forState:UIControlStateNormal];
    [view addSubview:btnPost];


    frame.origin.y = kMaxDimen+40;
    frame.origin.x = 0.0f;
    frame.size.width = view.frame.size.width;
    frame.size.height -= (frame.origin.y);
    
    theTableview = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    theTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    theTableview.backgroundColor = [backgrounds objectAtIndex:0];
    theTableview.autoresizingMask = resize;
    theTableview.delegate = self;
    theTableview.dataSource = self;
    [view addSubview:theTableview];
    
    UIImage *dropShadow = [UIImage imageNamed:@"dropShadow.png"];
    UIImageView *shadow = [[UIImageView alloc] initWithImage:dropShadow];
    shadow.frame = CGRectMake(theTableview.frame.origin.x, theTableview.frame.origin.y-1, dropShadow.size.width, dropShadow.size.height);
    shadow.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [view addSubview:shadow];
    [shadow release];
    
    frame = view.frame;
    frame.origin.x = 0.0f;
    h = 22.0f;
    frame.origin.y = frame.size.height-66+h; //off screen at first
    frame.size.height = h;
    bottom = [[BottomBanner alloc] initWithFrame:frame];
    bottom.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [view addSubview:bottom];
    
    loading = [[LoadingIndicator alloc] initWithFrame:view.frame];
    loading.hidden = YES;
    [view addSubview:loading];
    
    self.view = view;
    [view release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.station.name;
//    [self addPullToRefreshHeader];
    [self addPullToRefreshHeader:theTableview];

    UIButton *nowPlaying = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"nowPlaying.png"];
    [nowPlaying setBackgroundImage:img forState:UIControlStateNormal];
//    [nowPlaying addTarget:self action:@selector(showRadio:) forControlEvents:UIControlEventTouchUpInside];
    [nowPlaying addTarget:self action:@selector(showRadio) forControlEvents:UIControlEventTouchUpInside];
    nowPlaying.showsTouchWhenHighlighted = YES;
    nowPlaying.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    UIBarButtonItem *showRadio = [[UIBarButtonItem alloc] initWithCustomView:nowPlaying];
    
    self.navigationItem.rightBarButtonItem = showRadio;
    [showRadio release];
    
    if (station.ready==FALSE){
        station.delegate = self;
        [station getStationInfo];
        [loading show];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showBottomBar) userInfo:nil repeats:NO];
}

- (void)showBottomBar
{
    CGRect frame = bottom.frame;
    frame.origin.y -= bottom.frame.size.height;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6f];
    bottom.frame = frame;
    [UIView commitAnimations];
}

//this override is necessary for the reload functions to work properly:
- (void)updateInfo
{
    NSLog(@"updateInfo");
    station.delegate = self;
    [station getStationInfo];
}



- (void)switchMode:(UISegmentedControl *)sender
{
    NSLog(@"Switch Mode: %d", sender.selectedSegmentIndex);
    vMode = sender.selectedSegmentIndex;
    
    [theTableview reloadData];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:theTableview cache:YES];
    [UIView setAnimationDuration:0.7];
    theTableview.alpha = 1.0f;
    [UIView commitAnimations];
    
}

- (void)btnTapped:(UIButton *)btn
{
    NSString *title = btn.titleLabel.text;
    title = [title lowercaseString];
    NSLog(@"btnTapped: %@", title);

    if ([title isEqualToString:contact]){ 
		if (![MFMailComposeViewController canSendMail]) {
			NSLog(@"CAN'T SEND EMAIL");
            [self showAlert:@"ERROR" message:@"No email accounts are configured on this device.\n\nPlease add an email account."];
            return;
		}
        [self showEmail:@"" recipients:station.admins];
	}
	
    if ([title isEqualToString:share]){
        NSString *content = [NSString stringWithFormat:@"Check out this station on Butterfly Radio: <a href='http://www.butterflyradio.com/site/station/%@'>click here</a>", station.unique_id];
        [self showEmail:content recipients:nil];
    }
    if ([title isEqualToString:reviews]){
//        ReviewsViewController *reviews = [[ReviewsViewController alloc] init];
        ReviewsViewController *reviews = [[ReviewsViewController alloc] initWithManager:self.butterflyMgr];
        reviews.showStars = TRUE;
//        reviews.butterflyMgr = self.butterflyMgr;
        reviews.station = station;
        reviews.uniqueID = station.unique_id;
        [self.navigationController pushViewController:reviews animated:YES];
        [reviews release];
    }
}

- (void)enterBackground
{
    NSLog(@"STATION VIEW CONTROLLER - enterBackground");
    reload = TRUE;
}

- (void)reloadData
{
    if (reload==TRUE){
        NSLog(@"STATION VIEW CONTROLLER - reloadData");
        station.delegate = self;
        [station getStationInfo];
        [loading show];
        reload = FALSE;
    }
}

- (void)thumbnailReady
{
    NSLog(@"STATION VIEW CONTROLLER - thumbnailReady");
    [theTableview reloadData];
}

- (void)post
{
    NSLog(@"STATION VIEW CONTROLLER - post");
    if (vMode==ViewModeRadio){
        RecordViewController *submitTrack = [[RecordViewController alloc] initWithManager:self.butterflyMgr];
//        submitTrack.butterflyMgr = self.butterflyMgr;
        submitTrack.station = station;
        submitTrack.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:submitTrack animated:YES];
        [submitTrack release];
    }
    else {
        SubmitArticleViewController *submitArticle = [[SubmitArticleViewController alloc] initWithManager:self.butterflyMgr];
//        submitArticle.butterflyMgr = self.butterflyMgr;
        submitArticle.station = station;
        submitArticle.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:submitArticle animated:YES];
        [submitArticle release];
    }
}


#pragma mark - StationDelegate
- (void)stationInfoReady
{
    //remove loading indicator
    if (isLoading==TRUE){
        [self stopLoading:theTableview];
    }
    
    [theTableview reloadData];
    [loading hide];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kUpdate object:nil]];
}

- (void)imageReady:(NSString *)addr
{
    image.image = [UIImage imageWithData:station.imgData];;
    CGRect frame = [self adjustFrame:image.image];
    image.frame = frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6f];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:image cache:YES];
    image.frame = frame;
    [UIView commitAnimations];


    CGRect shadowFrame = imageShadow.frame;
    shadowFrame.size.width = frame.size.width;
    shadowFrame.size.height = frame.size.height;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6f];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:imageShadow cache:YES];
    imageShadow.frame = shadowFrame; 
    [UIView commitAnimations];

}

- (void)saveStation
{
    NSLog(@"STATION VIEW CONTROLLER - saveStation");
    if (station.saved==FALSE){
        [station save];
        
        [btn_save setTitle:@"Saved" forState:UIControlStateNormal];
        [btn_save setBackgroundImage:[UIImage imageNamed:@"heart-red.png"] forState:UIControlStateNormal];
        [btn_save setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        btn_save.userInteractionEnabled = NO;
        
        [self showAlert:@"Station Saved" message:[NSString stringWithFormat:@"%@ was saved to your favorites.", station.name]];
    }
}

- (void)refresh
{
    if (station.imgData){
        image.image = [UIImage imageWithData:station.imgData];
        CGRect frame = [self adjustFrame:image.image];
        
        CGRect shadowFrame = imageShadow.frame;
        shadowFrame.size.width = frame.size.width;
        shadowFrame.size.height = frame.size.height;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.6f];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:image cache:YES];
        image.frame = frame;
        imageShadow.frame = shadowFrame; 
        [UIView commitAnimations];
    }
    else{
        [station fetchImage];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kPortraitOnly object:nil]];
    self.title = station.name;
    [theTableview deselectRowAtIndexPath:[theTableview indexPathForSelectedRow] animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.title = nil;
}

- (void)exit
{
    station.delegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSLog(@"controller didFinishWithResult:");
    self.title = station.name;
    [theTableview deselectRowAtIndexPath:[theTableview indexPathForSelectedRow] animated:YES];
    [controller dismissModalViewControllerAnimated:YES];
}



#pragma mark - UITableViewStuff:
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = 1;
    if (vMode==ViewModeRadio){
        if ([station.tracks containsObject:@"none"]){
            count = 1;
        }
        else{
            count = [station.threadArray count];
        }
    }
    return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (vMode==ViewModeRadio){
        if (section==0){
            title = @"Tracks";
        }
    }
    else {
        title = @"News";
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (vMode==ViewModeRadio){
        if ([station.tracks containsObject:@"none"]){
            count = 1;
        }
        else {
            Thread *thread = (Thread *)[station.threadArray objectAtIndex:section];
            count = [thread.thread count];
        }
    }
    else {
        count = [station.articles count];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ID";
    StationCell *cell = [theTableview dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil){
        cell = [[[StationCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
        cell.delegate = self;
        [cell setup];
    }
    cell.contentView.backgroundColor = [backgrounds objectAtIndex:(indexPath.section%2)];
    cell.ip = indexPath;
    if (vMode==ViewModeRadio){
        cell.imageView.image = [UIImage imageNamed:@"table_tracks.png"];
        if ([station.tracks containsObject:@"none"]==TRUE){ 
            cell.btnReply.hidden = YES;
            cell.textLabel.text = @"none"; 
            cell.detailTextLabel.text = @"";
        }
        else {
            cell.btnReply.hidden = NO;
            Thread *thread = (Thread *)[station.threadArray objectAtIndex:indexPath.section];
            AudioFile *track = (AudioFile *)[thread.thread objectAtIndex:indexPath.row];
            cell.textLabel.text = track.name;
            if (indexPath.row==0){
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\nsubmitted by %@", track.date, track.author];
            }
            else {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\nreplied by %@", track.date, track.author];
            }
        }
    }
    else{
        cell.btnReply.hidden = YES;
        int dimen = kCellHeight+30;
        if ([self.station.articles containsObject:@"none"]==TRUE){
            cell.textLabel.text = @"none";
            cell.detailTextLabel.text = @"";
            if (station.thumbnail==nil){
                [station fetchThumbnail:dimen];
                cell.imageView.image = [UIImage imageNamed:@"table_icon.png"];
            }
            else{
                cell.imageView.image = station.thumbnail;
            }
        }
        else {
            Article *article = (Article *)[station.articles objectAtIndex:indexPath.row];
            cell.textLabel.text = article.title;
            if (article.link==TRUE) {
                NSArray *parts = [article.content componentsSeparatedByString:@"//"];
                NSString *url = nil;
                if ([parts count]>1){
                    url = [parts objectAtIndex:1];
                    url = [[url componentsSeparatedByString:@"/"] objectAtIndex:0];
                }
                else { url = [parts objectAtIndex:0]; }
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\nsubmitted by %@ on %@", url, article.author, article.date];
            }
            else{
                cell.detailTextLabel.text = [NSString stringWithFormat:@"original\nsubmitted by %@ on %@", article.author, article.date];
            }
            
            if (article.thumb==nil){
                [article fetchThumbnail:dimen];
                if (station.thumbnail==nil){
                    [station fetchThumbnail:dimen];
                    cell.imageView.image = [UIImage imageNamed:@"table_icon.png"];
                }
                else{
                    cell.imageView.image = station.thumbnail;
                }
            }
            else {
                cell.imageView.image = article.thumb;
            }
        }
    }
    return cell;
}

- (void)showEmail:(NSString *)content recipients:(NSArray *)a
{
    MFMailComposeViewController *mailVC = [[[MFMailComposeViewController alloc] init] autorelease];
	
    mailVC.mailComposeDelegate = self;
    mailVC.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    
    NSString *body = [NSString stringWithFormat:@"<html><body><div>%@</div><img style='margin-top:10px;width:150px' src='http://www.butterflyradio.com/site/images/default.jpg' /><br /><a href='http://itunes.apple.com/us/app/butterfly-radio/id532051737?mt=8'>download here</a></body></html>", content];

    if (a!=nil){ [mailVC setToRecipients:a]; }
    [mailVC setMessageBody:body isHTML:YES];
//    [mailVC setSubject:@"Butterfly Radio"];
    
    NSString *subject = [NSString stringWithFormat:@"%@ App: %@", self.butterflyMgr.appName, self.station.name];
    [mailVC setSubject:subject];
    [self presentModalViewController:mailVC animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (vMode==ViewModeRadio) {
        if ([self.station.tracks containsObject:@"none"]){
            [theTableview deselectRowAtIndexPath:[theTableview indexPathForSelectedRow] animated:YES];
        }
        else {
            Thread *thread = (Thread *)[station.threadArray objectAtIndex:indexPath.section];
            AudioFile *track = (AudioFile *)[thread.thread objectAtIndex:indexPath.row];

            self.butterflyMgr.player.files = station.tracks;
            self.butterflyMgr.player.adFrequency = station.adFreq;
            self.butterflyMgr.currentStation = station;
            
            if (self.butterflyMgr.player.streamer.isRunning==TRUE){
                [self.butterflyMgr.player playFile:[station.tracks indexOfObject:track]];
            }
            else {
                [self.butterflyMgr.player start:[station.tracks indexOfObject:track]];
            }

//            [self showRadio];
            [self showRadioWithLoader];
        }
    }
    else{
        if ([self.station.articles containsObject:@"none"]){
            [theTableview deselectRowAtIndexPath:[theTableview indexPathForSelectedRow] animated:YES];
        }
        else {
            Article *article = (Article *)[station.articles objectAtIndex:indexPath.row];
            ArticleViewController *articleView = [[ArticleViewController alloc] initWithNibName:@"ArticleViewController" bundle:nil];
            
            articleView.article = article;
            articleView.station = station;
            articleView.view.frame = [UIScreen mainScreen].applicationFrame;
            [self.navigationController pushViewController:articleView animated:YES];
            [articleView release];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (void)btnReplyTapped:(NSIndexPath *)ip
{
    
    if (vMode==ViewModeRadio) {
        if ([self.station.tracks containsObject:@"none"]){
            [theTableview deselectRowAtIndexPath:[theTableview indexPathForSelectedRow] animated:YES];
        }
        else {
            Thread *thread = (Thread *)[station.threadArray objectAtIndex:ip.section];
            AudioFile *track = (AudioFile *)[thread.thread objectAtIndex:ip.row];
            if (track){
                NSLog(@"btnReplyTapped: %@", track.name);
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kInterruptionNotification object:nil]];
                
                RecordViewController *submitTrack = [[RecordViewController alloc] initWithManager:self.butterflyMgr];
                NSString *thread = track.thread;
                if (thread != nil){
                    NSLog(@"REPLY TO: %@", thread);
                    submitTrack.thread = thread;
                }
                
                submitTrack.station = self.station;
                submitTrack.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [self presentModalViewController:submitTrack animated:YES];
                [submitTrack release];
            }
        }
    }
}

#pragma mark -  UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet clickedButtonAtIndex: %d", buttonIndex);
    if (buttonIndex==0){ //submit audio
        RecordViewController *recordView = [[RecordViewController alloc] initWithManager:self.butterflyMgr];
        recordView.station = station;
        [self.navigationController pushViewController:recordView animated:YES];
        [recordView release];
    }
    if (buttonIndex==1){ //submit article
        SubmitArticleViewController *submitArticle = [[SubmitArticleViewController alloc] initWithManager:self.butterflyMgr];
        submitArticle.station = station;
        [self.navigationController pushViewController:submitArticle animated:YES];
        [submitArticle release];
    }
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
