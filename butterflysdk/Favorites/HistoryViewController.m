//
//  HistoryViewController.m
//  butterflyradio
//
//  Created by Denny Kwon on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController
@synthesize saved;

- (id)init
{
    self = [super init];
    if (self) {
        cellBg = [[UIImage imageNamed:@"bg_cell_station.png"] retain];
        self.tabBarItem.image = [UIImage imageNamed:@"tab_favorites.png"];
        self.title = @"Favorites";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kThumbnailReadyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetData) name:kResetDatabase object:nil];
        
        db = [Database database];
        self.saved = [db fetchAll];
        
    }
    return self;
}

- (id)initWithManager:(ButterflyManager *)mgr
{
    self = [super initWithManager:mgr];
    if (self) {
        cellBg = [[UIImage imageNamed:@"bg_cell_station.png"] retain];
        self.tabBarItem.image = [UIImage imageNamed:@"tab_favorites.png"];
        self.title = @"Favorites";
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kThumbnailReadyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetData) name:kResetDatabase object:nil];
        
        db = [Database database];
        self.saved = [db fetchAll];
    }
    return self;
}


- (void)dealloc
{
    [theTableview release];
    [saved release];
    [db release];
    [cellBg release];
    [explanation release];
    [super dealloc];
}

- (void)loadView
{
    reloadable = FALSE;
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    frame.origin.y = 0.0f;
    frame.origin.x = 0.0f;
    UIViewAutoresizing resize = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = resize;
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_history.png"]];
    
    theTableview = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    theTableview.separatorStyle = UITableViewCellSelectionStyleNone;
    theTableview.showsVerticalScrollIndicator = NO;
    theTableview.backgroundColor = [UIColor clearColor];
    theTableview.dataSource = self;
    theTableview.delegate = self;
    theTableview.autoresizingMask = resize;
    [view addSubview:theTableview];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"favorites" ofType:@"txt"];
    NSError *e = nil;
    NSString *exp = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&e];
    if (!e){
        UIFont *font = [UIFont fontWithName:kFont size:16.0f];
        CGSize size = [exp sizeWithFont:font constrainedToSize:CGSizeMake(300, 300) lineBreakMode:UILineBreakModeWordWrap];
        explanation = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 300, size.height)];
        explanation.text = exp;
        [exp release];
        explanation.backgroundColor = [UIColor clearColor];
        explanation.numberOfLines = 0;
        explanation.textColor = [UIColor darkGrayColor];
        explanation.font = font;
        explanation.lineBreakMode = UILineBreakModeWordWrap;
        [view addSubview:explanation];
        
    }
    
    if ([saved count]>0){
        explanation.hidden = YES;
    }
    
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
    
    self.navigationItem.rightBarButtonItem = showRadio;
    [showRadio release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [theTableview deselectRowAtIndexPath:[theTableview indexPathForSelectedRow] animated:YES];
}

- (void)refresh //called when station thumbnail is ready
{
    [theTableview reloadData];
    if ([saved count]>0){
        explanation.hidden = YES;
    }
    else{
        explanation.hidden = NO;
    }
}

- (void)resetData
{
    self.saved = [db fetchAll];
    [self refresh];
}

#pragma mark - Tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [saved count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ID";
    HistoryCell *cell = [theTableview dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil){
        cell = [[[HistoryCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
        [cell setup];
        cell.delegate = self;
    }
    Station *station = (Station *)[saved objectAtIndex:indexPath.row];
    cell.nameLabel.text = station.name;
    cell.categoryLabel.text = station.category;
    cell.tag = 1000+indexPath.row;
    
    if (station.ready==FALSE){
        station.delegate = self;
        [station getStationInfo];
        return cell;
    }
    
    station.delegate = nil;
    if ([station.tracks containsObject:@"none"]){
        [cell.btnTracks setTitle:@"0 tracks" forState:UIControlStateNormal];
    }
    else {
        [cell.btnTracks setTitle:[NSString stringWithFormat:@"%d tracks", [station.tracks count]] forState:UIControlStateNormal];
    }
    
    if ([station.articles containsObject:@"none"]){
        [cell.btnNews setTitle:@"0 articles" forState:UIControlStateNormal];
    }
    else {
        [cell.btnNews setTitle:[NSString stringWithFormat:@"%d articles", [station.articles count]] forState:UIControlStateNormal];
    }
    
    [cell.btnAdmins setTitle:[NSString stringWithFormat:@"%d admins", [station.admins count]] forState:UIControlStateNormal];
    
    if(station.thumbnail==nil){
        [station fetchThumbnail:240];
        return cell;
    }
    
    
    [cell fillImage:station.thumbnail];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Station *station = (Station *)[saved objectAtIndex:indexPath.row];
    if (station){
        StationViewController *stationView = [[StationViewController alloc] init];
        stationView.butterflyMgr = self.butterflyMgr;
        stationView.station = station;
        [self.navigationController pushViewController:stationView animated:YES];
        [stationView release];
    }

}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellBg.size.height;
}


- (void)deleteStation:(int)index
{
    Station *station = [saved objectAtIndex:index];
    if (station){
        NSLog(@"DELETE STATION: %@", station.unique_id);
        [station deleteFromDb];
        [saved removeObject:station];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [theTableview deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self refresh];
    }
}


#pragma mark - HistoryCellDelegate
- (void)buttonAction:(int)tag title:(NSString *)title
{
    NSLog(@"buttonAction: %@, %d", title, tag);
    if (tag>999){
        tag -= 1000;
        if ([title isEqualToString:@"delete"]){ [self deleteStation:tag]; }
    }
}


#pragma mark - StationDelegate
- (void)imageReady:(NSString *)addr
{
    
}

- (void)stationInfoReady
{
    [theTableview reloadData];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
