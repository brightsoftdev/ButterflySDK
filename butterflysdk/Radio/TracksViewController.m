//
//  TracksViewController.m
//  butterflyradio
//
//  Created by Denny Kwon on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TracksViewController.h"

@interface TracksViewController ()

@end

@implementation TracksViewController
@synthesize station;

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kUpdate object:nil];
    }
    return self;
}

- (id)initWithManager:(ButterflyManager *)mgr
{
    self = [super initWithManager:mgr];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kUpdate object:nil];
    }
    return self;
}

- (void)dealloc
{
    [theTablview release];
    [station release];
    [super dealloc];
}

- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    frame.origin.y = 0;
    frame.origin.x = 0.0f;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor redColor];
    view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    theTablview = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    theTablview.autoresizingMask = view.autoresizingMask;
    theTablview.delegate = self;
    theTablview.dataSource = self;
    [view addSubview:theTablview];
    
    self.view = view;
    [view release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"post" style:UIBarButtonItemStyleBordered target:self action:@selector(postTrack:)];
    
    UIButton *nowPlaying = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"nowPlaying.png"];
    [nowPlaying setBackgroundImage:img forState:UIControlStateNormal];
    [nowPlaying addTarget:self action:@selector(showRadio:) forControlEvents:UIControlEventTouchUpInside];
    nowPlaying.showsTouchWhenHighlighted = YES;
    nowPlaying.frame = CGRectMake(0, 0, img.size.width, img.size.height);
    UIBarButtonItem *showRadio = [[UIBarButtonItem alloc] initWithCustomView:nowPlaying];

    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:showRadio, barButton, nil];
    [barButton release];
    [showRadio release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kSupportLandscape object:nil]];
    [theTablview deselectRowAtIndexPath:[theTablview indexPathForSelectedRow] animated:YES];
}

- (void)showRadio:(UIButton *)btn
{
    [self.butterflyMgr showRadio];
    
}

- (void)postTrack:(UIBarButtonItem *)btn
{
    RecordViewController *submitTrack = [[RecordViewController alloc] init];
    submitTrack.station = station;
    [self presentModalViewController:submitTrack animated:YES];
    [submitTrack release];
}

- (void)refresh
{
    NSLog(@"TRACKS VIEW CONTROLLER - refresh");
    [theTablview reloadData];
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [station.tracks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ID";
    UITableViewCell *cell = [theTablview dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
        cell.textLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:16.0f];
//        cell.imageView.image = [UIImage imageNamed:@"btn_play.png"];
        cell.imageView.image = [UIImage imageNamed:@"table_tracks.png"];
    }
    
    if ([station.tracks containsObject:@"none"]==TRUE){ cell.textLabel.text = @"none"; }
    else {
        AudioFile *track = [station.tracks objectAtIndex:indexPath.row];
        cell.textLabel.text = track.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\nsubmitted by %@", track.date, track.author];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.station.tracks containsObject:@"none"]){
        [theTablview deselectRowAtIndexPath:[theTablview indexPathForSelectedRow] animated:YES];
    }
    else {
//        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        appDelegate.player.files = station.tracks;
//        appDelegate.currentStation = station;
//        
//        if (appDelegate.player.streamer.isRunning==TRUE){
//            [appDelegate.player playFile:indexPath.row];
//        }
//        else {
//            [appDelegate.player start:indexPath.row];
//        }
        
        self.butterflyMgr.player.files = station.tracks;
        self.butterflyMgr.currentStation = station;
        
        if (self.butterflyMgr.player.streamer.isRunning==TRUE){
            [self.butterflyMgr.player playFile:indexPath.row];
        }
        else {
            [self.butterflyMgr.player start:indexPath.row];
        }

        
        RadioViewController *radio = [[RadioViewController alloc] initWithManager:self.butterflyMgr];
        radio.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:radio animated:YES];
        [radio.loading show];
        [radio release];
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
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
