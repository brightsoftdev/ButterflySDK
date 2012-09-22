//
//  StationAdminViewController.m
//  butterflyradio
//
//  Created by Denny Kwon on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StationAdminViewController.h"

@interface StationAdminViewController ()

@end

@implementation StationAdminViewController
@synthesize station;
@synthesize mode;
@synthesize host;

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kRefreshNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:UIApplicationDidBecomeActiveNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kThumbnailReadyNotification object:nil];

        
        mode = 0;
        deleteIndex = -1;
        reload = FALSE;
        self.hidesBottomBarWhenPushed = TRUE;
        icons = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"table_tracks.png"], [UIImage imageNamed:@"table_icon.png"], nil];
        tableBg = [[UIImage imageNamed:@"bg_cell_admin.png"] retain];
    }
    return self;
}

- (id)initWithManager:(ButterflyManager *)mgr
{
    self = [super initWithManager:mgr];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kRefreshNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kThumbnailReadyNotification object:nil];
        
        
        mode = 0;
        deleteIndex = -1;
        reload = FALSE;
        self.hidesBottomBarWhenPushed = TRUE;
        icons = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"table_tracks.png"], [UIImage imageNamed:@"table_icon.png"], nil];
        tableBg = [[UIImage imageNamed:@"bg_cell_admin.png"] retain];
    }
    return self;
}

- (void)dealloc
{
    station.delegate = nil;
    [station release];
    [loading release];
    [theTableview release];
    [icons release];
    [super dealloc];
}

- (void)loadView
{
    reloadable = NO;
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    view.backgroundColor = [UIColor blackColor];
    
    frame.origin.y = 0;
    frame.origin.x = 0;
    
    theTableview = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    if (mode!=2){
        theTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    theTableview.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_table_admin.png"]];
    theTableview.autoresizingMask = view.autoresizingMask;
    theTableview.dataSource = self;
    theTableview.delegate = self;
    [view addSubview:theTableview];
    
    loading = [[LoadingIndicator alloc] initWithFrame:frame];
    [view addSubview:loading];
    
    self.view = view;
    [view release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (mode==2){
        self.title = @"Admins";
        UIBarButtonItem *btnInviteAdmin = [[UIBarButtonItem alloc] initWithTitle:@"invite" style:UIBarButtonItemStyleBordered target:self action:@selector(inviteAdmin)];
        btnInviteAdmin.tintColor = [UIColor greenColor];
        self.navigationItem.rightBarButtonItem = btnInviteAdmin;
        [btnInviteAdmin release];
    }
    else {
        UIButton *nowPlaying = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img = [UIImage imageNamed:@"nowPlaying.png"];
        [nowPlaying setBackgroundImage:img forState:UIControlStateNormal];
        [nowPlaying addTarget:self action:@selector(showRadio) forControlEvents:UIControlEventTouchUpInside];
        nowPlaying.showsTouchWhenHighlighted = YES;
        nowPlaying.frame = CGRectMake(0, 0, img.size.width, img.size.height);
        UIBarButtonItem *showRadio = [[UIBarButtonItem alloc] initWithCustomView:nowPlaying];
        
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:showRadio, nil];
        [showRadio release];
    }

    if (station.ready==FALSE){
        station.delegate = self;
        [station getStationInfo];
        [loading show];
    }
    else{
        loading.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
//    typeSegment.selectedSegmentIndex = mode;
    [theTableview deselectRowAtIndexPath:[theTableview indexPathForSelectedRow] animated:YES];
}

- (void)refresh
{
    self.title = station.name;
    [theTableview reloadData];
}

- (void)enterBackground
{
    NSLog(@"STATION ADMIN VIEW CONTROLLER - enterBackground");
    reload = TRUE;
}

- (void)reloadData
{
    if (reload==TRUE){
        NSLog(@"STATION ADMIN VIEW CONTROLLER - reloadData");
        station.delegate = self;
        [station getStationInfo];
        [loading show];
        reload = FALSE;
    }
}

- (void)switchMode:(UISegmentedControl *)segment
{
    NSLog(@"switchMode: %d", segment.selectedSegmentIndex);
    if (segment.selectedSegmentIndex<3){
        mode = segment.selectedSegmentIndex;
        [theTableview reloadData];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.6f];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:theTableview cache:YES];
        theTableview.frame = theTableview.frame;
        [UIView commitAnimations];
    }
    else{
        StationDetailsViewController *details = [[StationDetailsViewController alloc] initWithNibName:@"StationDetailsViewController" bundle:nil];
        details.station = station;
        details.view.frame = [UIScreen mainScreen].applicationFrame;
        [self.navigationController pushViewController:details animated:YES];
        [details release];
    }
}
   

- (void)deleteContent:(int)index
{
    deleteIndex = index - 1000;
    NSLog(@"deleteContent: %d" ,deleteIndex);
    
    NSString *msg = nil;
    if (mode==2){
        msg = [NSString stringWithFormat:@"This will permanently remove the admin from your station."];
    }
    else{
        msg = [NSString stringWithFormat:@"This will permanently remove the file from your station."];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are You Sure?" message:msg delegate:self cancelButtonTitle:@"yes" otherButtonTitles:@"no", nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"alertView clickedButtonAtIndex: %d, mode==%d, deleteIndex==%d", buttonIndex, mode, deleteIndex);
    if (buttonIndex==0){
        NSLog(@"test 1");
        BOOL complete = FALSE;
        if (deleteIndex >= 0){
            NSLog(@"test 2");
            NSString *key = nil;
            NSString *type = nil;
            if (mode==0){ //tracks
                AudioFile *track = (AudioFile *)[station.tracks objectAtIndex:deleteIndex];
                NSArray *parts = [track.url componentsSeparatedByString:@"/"];
                key = [parts lastObject];
                type = @"track";
                complete = TRUE;
            }
            if (mode==1){ // news 
                Article *article = (Article *)[station.articles objectAtIndex:deleteIndex];
                key = article.unique_id;
                type = @"article";
                complete = TRUE;
            }
            if (mode==2){ // admins
                complete = TRUE;
                NSString *admin = [station.admins objectAtIndex:deleteIndex];
                NSLog(@"REMOVE ADMIN: %@", admin);
                key = [NSString stringWithFormat:@"%@::%@", admin, station.unique_id];
                type = @"admin";
                if ([admin isEqualToString:station.host]==TRUE){
                    complete = FALSE;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You cannot remove yourself as an admin." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                }
           }
            
            if (complete==TRUE){
                if (req!=nil){
                    req.delegate = nil;
                    [req release];
                }
                
                NSString *url = [NSString stringWithFormat:@"http://%@/api/authorize?key=%@&type=%@&action=remove", kUrl, key, type];
                NSLog(@"URL = %@", url);
                
                req = [[BRNetworkOp alloc] initWithAddress:url parameters:nil];
                req.delegate = self;
                [req setHttpMethod:@"PUT"];
                [req sendRequest];
                [loading show];
            }
        }
    }
}

- (void)requestData:(NSArray *)pkg //returns [address, data]
{
    if (pkg!=nil) {
        NSString *json = [[NSString alloc] initWithData:[pkg objectAtIndex:1] encoding:NSUTF8StringEncoding];
        NSDictionary *d = [json JSONValue];
        if (d==nil){
            
        }
        else{
            [loading hide];
            d = [d objectForKey:@"results"];
            NSLog(@"%@", [d description]);
            NSDictionary *info = [d objectForKey:@"station"];
            if (info){
                [self.station populate:info];
                [theTableview reloadData];
            }
        }
        [json release];
    }
}

- (void)cellTapped:(NSArray *)contents
{
    NSLog(@"cellTapped: %@", [contents description]);
    NSString *action = [contents objectAtIndex:0];
    int tag = [[contents lastObject] intValue];
    tag -= 1000;
    
    if ([action isEqualToString:@"play"]){ //this might be an article too so cover both possibilities
        if (mode==0){ //tracks
//            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//            appDelegate.player.files = station.tracks;
//            appDelegate.currentStation = station;
            
            self.butterflyMgr.player.files = station.tracks;
            self.butterflyMgr.currentStation = station;

            
            if (self.butterflyMgr.player.streamer.isRunning==TRUE){ [self.butterflyMgr.player playFile:tag]; }
            else { [self.butterflyMgr.player start:tag]; }
            [self.butterflyMgr showRadio];
        }
        if (mode==1){
            if ([self.station.articles containsObject:@"none"]){
                [theTableview deselectRowAtIndexPath:[theTableview indexPathForSelectedRow] animated:YES];
            }
            else {
                Article *article = (Article *)[station.articles objectAtIndex:tag];
                ArticleViewController *articleView = [[ArticleViewController alloc] initWithNibName:@"ArticleViewController" bundle:nil];
                articleView.hidesBottomBarWhenPushed = YES;
                
                articleView.article = article;
                articleView.station = station;
                articleView.view.frame = [UIScreen mainScreen].applicationFrame;
                [self.navigationController pushViewController:articleView animated:YES];
                [articleView release];
            }
        }
    }
    if ([action isEqualToString:@"comments"]){
        AudioFile *track = (AudioFile *)[station.tracks objectAtIndex:tag];
        
        NSString *url = track.url;
        if ([url rangeOfString:@"stream"].location != NSNotFound){
            
            NSArray *parts = [url componentsSeparatedByString:@"/"];
            url = [parts lastObject];  
            NSLog(@"viewComments: %@", url);
            
            ReviewsViewController *reviews = [[ReviewsViewController alloc] initWithMode:ReviewModeTrack];
            reviews.uniqueID = url;
            reviews.station = station;
            [self.navigationController pushViewController:reviews animated:YES];
            [reviews release];
        }
    }
    if ([action isEqualToString:@"delete"]){
        tag += 1000;
        [self deleteContent:tag];
        
    }
    
}

#pragma mark - StationDelegate
- (void)imageReady:(NSString *)addr
{
    NSLog(@"imageReady:");
    [theTableview reloadData];
    
}

- (void)stationInfoReady
{
    NSLog(@"stationInfoReady");
    station.delegate = nil;
    [loading hide];
    [theTableview reloadData];
}



#pragma mark - UITableViewStuff
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows;
    if (mode==0){
        numRows = [station.tracks count];
    }
    if (mode==1){
        numRows = [station.articles count];
    }
    if (mode==2){
        numRows = [station.admins count];
    }
    return numRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (mode==0){ //tracks
        if ([station.tracks containsObject:@"none"]==TRUE){
            static NSString *cellID = @"RegularCell";
            UITableViewCell *cell = [theTableview dequeueReusableCellWithIdentifier:cellID];
            if (cell==nil){
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
            }
            cell.textLabel.text = @"No Tracks";
            cell.detailTextLabel.text = @"There are currently no tracks on this station.";
            return cell;
        }
        
        static NSString *cellID = @"StationDetailCell";
        StationDetailCell *cell = [theTableview dequeueReusableCellWithIdentifier:cellID];
        if (cell==nil){
            cell = [[[StationDetailCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
            cell.delegate = self;
            [cell setup:mode];
        }
        
        cell.tag = (indexPath.row+1000);
        cell.imageView.image = [UIImage imageNamed:@"table_tracks.png"];
        AudioFile *track = (AudioFile *)[station.tracks objectAtIndex:indexPath.row];
        cell.textLabel.text = track.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"submitted by %@\n%@", track.author, track.date];
        return cell;
    }
    
    
    
    if (mode==1){ // news
        if ([station.articles containsObject:@"none"]==TRUE){
            static NSString *cellID = @"RegularCell";
            UITableViewCell *cell = [theTableview dequeueReusableCellWithIdentifier:cellID];
            if (cell==nil){
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
            }
            cell.textLabel.text = @"No Articles";
            cell.detailTextLabel.text = @"There are currently no articles on this station.";
            return cell;
        }
        static NSString *cellID = @"StationDetailCell";
        StationDetailCell *cell = [theTableview dequeueReusableCellWithIdentifier:cellID];
        if (cell==nil){
            cell = [[[StationDetailCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
            cell.delegate = self;
            [cell setup:mode];
        }
        
        cell.tag = (indexPath.row+1000);
        cell.imageView.image = [icons objectAtIndex:mode];
        Article *article = (Article *)[station.articles objectAtIndex:indexPath.row];
        cell.textLabel.text = article.title;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"submitted by %@\n%@", article.author, article.date];
        
        int dimen = kCellHeight+30;
        if (article.thumb==nil){
            [article fetchThumbnail:dimen];
            if (station.thumbnail==nil){
                [station fetchThumbnail:dimen];
                station.delegate = self;
                cell.imageView.image = [UIImage imageNamed:@"table_icon.png"];
            }
            else{
                cell.imageView.image = station.thumbnail;
            }
        }
        else {
            cell.imageView.image = article.thumb;
        }


        return cell;
    }
    
    
    //admins:
    static NSString *cellID = @"RegularCell";
    StationDetailCell *cell = [theTableview dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil){
        cell = [[[StationDetailCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
        [cell setup:mode];
        cell.delegate = self;
    }
    
    NSString *admin = (NSString *)[station.admins objectAtIndex:indexPath.row];
    cell.tag = (indexPath.row+1000);
    cell.textLabel.text = admin;
    
    if ([admin isEqualToString:station.host]){
        cell.btnGarbage.hidden = YES; //cannot remove main host (the station creator) as an admin
        cell.detailTextLabel.text = @"creator\n\n";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    }
    else{
        cell.detailTextLabel.text = @"guest moderator\n\n";
        cell.textLabel.font = [UIFont fontWithName:kFont size:16.0f];
    }
    
    if ([host.email isEqualToString:station.host]==FALSE){ //logged in as a guest moderator - can only remove yourself from admin list
        if ([admin isEqualToString:host.email]) {
            cell.btnGarbage.hidden = NO;
        }
        else{
            cell.btnGarbage.hidden = YES;
        }
    }
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (mode==0){
        if ([self.station.tracks containsObject:@"none"]){
            [theTableview deselectRowAtIndexPath:[theTableview indexPathForSelectedRow] animated:YES];
        }
        else {
//            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//            appDelegate.player.files = station.tracks;
//            appDelegate.currentStation = station;

            self.butterflyMgr.player.files = station.tracks;
            self.butterflyMgr.currentStation = station;

            if (self.butterflyMgr.player.streamer.isRunning==TRUE){ [self.butterflyMgr.player playFile:indexPath.row]; }
            else { [self.butterflyMgr.player start:indexPath.row]; }
            [self showRadioWithLoader];
        }
    }
    if (mode==1){
        if ([self.station.articles containsObject:@"none"]){
            [theTableview deselectRowAtIndexPath:[theTableview indexPathForSelectedRow] animated:YES];
        }
        else {
            Article *article = (Article *)[station.articles objectAtIndex:indexPath.row];
            ArticleViewController *articleView = [[ArticleViewController alloc] initWithNibName:@"ArticleViewController" bundle:nil];
            articleView.hidesBottomBarWhenPushed = YES;
            
            articleView.article = article;
            articleView.station = station;
            articleView.view.frame = [UIScreen mainScreen].applicationFrame;
            [self.navigationController pushViewController:articleView animated:YES];
            [articleView release];
        }
    }
    if (mode==2){
        [theTableview deselectRowAtIndexPath:[theTableview indexPathForSelectedRow] animated:YES];
        if (indexPath.row==[station.admins count]){
            NSLog(@"INVITE ADMIN");
            [self inviteAdmin];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (mode!=2){
//        return kCellHeight;
//    }
//    
//    return 40;
    
    return kCellHeight;
}


- (void)inviteAdmin
{
    InviteAdminViewController *invite = [[InviteAdminViewController alloc] init];
    invite.station = station;
    [self presentModalViewController:invite animated:YES];
    [invite release];
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
