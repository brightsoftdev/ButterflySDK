//
//  ReviewsViewController.m
//  butterflyradio
//
//  Created by Denny Kwon on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReviewsViewController.h"

@implementation Comment
@synthesize username;
@synthesize date;
@synthesize text;
@synthesize rating;

- (id)init
{
    self = [super init];
    if (self){
        self.text = @"none";
        self.date = @"none";
        self.username = @"none";
        self.rating = 0;
    }
    return self;
}

- (void)populate:(NSString *)c
{
    if ([c isEqualToString:@"none"]){
        self.text = @"none";
        self.date = @"none";
        self.username = @"none";
    }
    else{ // comment::laborum. Nam liber te conscient to factor tum==username::dk234==date::April 21, ...
        NSLog(@"%@", c);

        NSArray *parts = [c componentsSeparatedByString:@"=="];
        for (NSString *s in parts){
            NSArray *t = [s componentsSeparatedByString:@"::"]; //key::value
            NSString *key = [t objectAtIndex:0];
            NSString *value = [t objectAtIndex:1];
            if ([key isEqualToString:@"comment"]){
                self.text = value;
            }
            if ([key isEqualToString:@"username"]){
                self.username = value;
            }
            if ([key isEqualToString:@"rating"]){
                self.rating = [value intValue];
            }
            if ([key isEqualToString:@"date"]){
                NSArray *d = [value componentsSeparatedByString:@" "];
                self.date = [NSString stringWithFormat:@"%@ %@, %@", [d objectAtIndex:1], [d objectAtIndex:2], [d lastObject]];
            }
        }
    }
    
}

- (void)dealloc
{
    [username release];
    [date release];
    [text release];
    [super dealloc];
}

@end


@interface ReviewsViewController ()

@end

@implementation ReviewsViewController
@synthesize station;
@synthesize uniqueID;
@synthesize showStars;

- (id)init
{
    self = [super init];
    if (self) {
        showStars = FALSE;
        commentsArray = [[NSMutableArray alloc] init];
        offset = 0;
        mode = ReviewModeStation;
        self.title = @"Comments";
    }
    return self;
}

- (id)initWithMode:(ReviewMode)m
{
    self = [super init];
    if (self){
        commentsArray = [[NSMutableArray alloc] init];
        offset = 0;
        mode = m;
    }
    return self;
}

- (id)initWithManager:(ButterflyManager *)mgr
{
    self = [super initWithManager:mgr];
    if (self) {
        showStars = FALSE;
        commentsArray = [[NSMutableArray alloc] init];
        offset = 0;
        mode = ReviewModeStation;
        self.title = @"Comments";
    }
    return self;
}


- (void)dealloc
{
    if (req){
        req.delegate = nil;
        [req cancel];
        [req release];
    }
    [loading release];
    [station release];
    [commentsArray release];
    [uniqueID release];
    [image release];
    [tableHeader release];
    [super dealloc];
}

- (void)loadView
{
    reloadable = FALSE;
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    frame.origin.y = 0.0f;
    frame.origin.x = 0.0f;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    view.backgroundColor = [UIColor colorWithRed:kRGBMax/kRGBMax green:kRGBMax/kRGBMax blue:210.0f/kRGBMax alpha:1.0f];

    tableHeader = [[SummaryView alloc] initWithFrame:CGRectMake(0, 0, 320, 110) image:[UIImage imageWithData:station.imgData]];
    tableHeader.titleLabel.text = station.name;
    
    theTableview = [[UITableView alloc] initWithFrame:frame];
    theTableview.tableHeaderView = tableHeader;
    theTableview.backgroundColor = view.backgroundColor;

    theTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    theTableview.autoresizingMask = view.autoresizingMask;
    theTableview.dataSource = self;
    theTableview.delegate = self;
    [view addSubview:theTableview];
    
    loading = [[LoadingIndicator alloc] initWithFrame:frame];
//    [loading hide];
    [view addSubview:loading];
    
    self.view = view;
    [view release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *nowPlaying = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"nowPlaying.png"];
    [nowPlaying setBackgroundImage:img forState:UIControlStateNormal];
    [nowPlaying addTarget:self action:@selector(showRadio) forControlEvents:UIControlEventTouchUpInside];
    nowPlaying.showsTouchWhenHighlighted = YES;
    nowPlaying.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    UIBarButtonItem *showRadio = [[UIBarButtonItem alloc] initWithCustomView:nowPlaying];
    
    
//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:showRadio, barButton, nil];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"post" style:UIBarButtonItemStyleBordered target:self action:@selector(commentBtnTapped)];

    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:showRadio, barButton, nil];
    [showRadio release];
    [barButton release];

    
    
    NSString *url = nil;
    if (mode==ReviewModeStation){
        url = [NSString stringWithFormat:@"http://www.butterflyradio.com/api/reviews/%@?offset=%d", uniqueID, offset];
    }
    if (mode==ReviewModeArticle){ //http://www.butterflyradio.com/api/comments/37102372485885315?type=article&offset=0
        url = [NSString stringWithFormat:@"http://www.butterflyradio.com/api/comments/%@?type=article&offset=%d", uniqueID, offset];
    }
    if (mode==ReviewModeTrack){ 
        url = [NSString stringWithFormat:@"http://www.butterflyradio.com/api/comments/%@?type=track&offset=%d", uniqueID, offset];
    }
    
    req = [[BRNetworkOp alloc] initWithAddress:url parameters:nil];
    req.delegate = self;
    [req setHttpMethod:@"GET"];
    [req sendRequest];
    [loading show];
    
}

- (void)exit
{
    if (req){
        [req cancel];
        req.delegate = nil;
    }
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)commentBtnTapped
{
    NSLog(@"commentBtnTapped");
//    CommentViewController *comment = [[CommentViewController alloc] initWithNibName:@"CommentViewController" bundle:nil];
    
    
    CommentViewController *comment = [[CommentViewController alloc] init];
    comment.butterflyMgr = self.butterflyMgr;
    comment.showStars = showStars;
    comment.mode = mode;
    comment.uniqueID = uniqueID;
    comment.delegate = self;
    comment.station = station;
//    comment.view.frame = [UIScreen mainScreen].applicationFrame;
    [self presentModalViewController:comment animated:YES];
    [comment release];
}

- (void)setupComments:(NSDictionary *)reviews
{
    NSArray *comments = [reviews objectForKey:@"comments"];
    if (offset==0){
        [commentsArray removeAllObjects];
    }
    for (int i=0; i<[comments count]; i++){
        NSString *c = [comments objectAtIndex:i];
        Comment *comment = [[Comment alloc] init];
        [comment populate:c];
        [commentsArray addObject:comment];
        [comment release];
    }
    [theTableview reloadData];
    
    if (showStars){
        double rating = [[reviews objectForKey:@"rating"] doubleValue];
        NSString *total = [reviews objectForKey:@"total"];
        tableHeader.detailsLabel.text = [NSString stringWithFormat:@"%@ reviews\navg: %.1f stars", total, rating];
    }

}

- (void)resetComments:(NSDictionary *)reviews //called by CommentVC when user enters a new comment. 
{
    [commentsArray removeAllObjects];
    [self setupComments:reviews];
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
//            [loading hide];
            d = [d objectForKey:@"results"];
            NSLog(@"%@", [d description]);
            NSDictionary *reviews = [d objectForKey:@"reviews"];
            [self setupComments:reviews];
            [loading hide];
            
        }
    }
}



#pragma mark - UITableViewStuff
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [commentsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ID";
    ReviewCell *cell = (ReviewCell *)[theTableview dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil){
        cell = [[[ReviewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
    }
    Comment *c = (Comment *)[commentsArray objectAtIndex:indexPath.row];
    
    cell.commentLabel.text = [NSString stringWithFormat:@"%d. %@", (indexPath.row+1), c.text];
    [cell resize];
    
    if (showStars==TRUE){
        cell.detailsLabel.text = [NSString stringWithFormat:@"\nby %@ on %@", c.username, c.date];
        [cell fillStars:c.rating];
    }
    else{
        cell.detailsLabel.text = [NSString stringWithFormat:@"\nby %@ on %@", c.username, c.date];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Comment *c = (Comment *)[commentsArray objectAtIndex:indexPath.row];

    CGSize size = [c.text sizeWithFont:[UIFont fontWithName:@"Heiti SC" size:14.0f] constrainedToSize:CGSizeMake(kCellLabelWidth, 300) lineBreakMode:UILineBreakModeWordWrap];
    return size.height+60;
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
