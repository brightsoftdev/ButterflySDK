//
//  HostViewController.m
//  butterflyradio
//
//  Created by Denny Kwon on 6/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HostViewController.h"

@interface HostViewController ()

@end

static UIImage *cellBg;

@implementation HostViewController
@synthesize host;

- (id)init
{
    self = [super init];
    if (self) {
        isLoading = FALSE;
        cellBg = [[UIImage imageNamed:@"bg_cell_station.png"] retain];

        deleteIndex = -1;
        newStation = FALSE;
        self.title = @"Stations";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kRefreshNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kThumbnailReadyNotification object:nil];
    }
    return self;
}

- (id)initWithManager:(ButterflyManager *)mgr
{
    self = [super initWithManager:mgr];
    if (self) {
        self.host = self.butterflyMgr.host;
        isLoading = FALSE;
        cellBg = [[UIImage imageNamed:@"bg_cell_station.png"] retain];
        
        deleteIndex = -1;
        newStation = FALSE;
        self.title = @"Stations";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kRefreshNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kThumbnailReadyNotification object:nil];
    }
    return self;
}



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRefreshNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kThumbnailReadyNotification object:nil];
    
    if (req!=nil){
        [req cancel];
        req.delegate = nil;
        [req release];
    }
    [host release];
    [theTableview release];
    [loading release];
    [descriptionLabel release];
    [super dealloc];
}

- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_admin.png"]];

    
    frame.origin.y = 0;
    theTableview = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    theTableview.autoresizingMask = view.autoresizingMask;
    theTableview.backgroundColor = [UIColor clearColor];
    theTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    theTableview.dataSource = self;
    theTableview.delegate = self;
    [view addSubview:theTableview];
    [self addPullToRefreshHeader:theTableview];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"intro" ofType:@"txt"];
    
    NSError *error = nil;
    NSString *intro = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!error){
        NSString *text = [intro stringByReplacingOccurrencesOfString:@"{{APP NAME}}" withString:self.butterflyMgr.appName];
        [intro release];
        
        UIFont *font = [UIFont fontWithName:kFont size:16.0f];
        CGSize size = [intro sizeWithFont:font constrainedToSize:CGSizeMake(300, 450) lineBreakMode:UILineBreakModeWordWrap];
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, size.height)];
        descriptionLabel.textColor = [UIColor blackColor];
        descriptionLabel.shadowColor = [UIColor whiteColor];
        descriptionLabel.shadowOffset = CGSizeMake(-0.5f, 0.5f);
        descriptionLabel.backgroundColor = [UIColor clearColor];
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.lineBreakMode = UILineBreakModeWordWrap;
        descriptionLabel.font = font;
        descriptionLabel.text = text;
        [view addSubview:descriptionLabel];
    }
    
    self.view = view;
    [view release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [theTableview deselectRowAtIndexPath:[theTableview indexPathForSelectedRow] animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *rightButtons = [NSMutableArray array];
    UIBarButtonItem *btnCreateStation = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStyleBordered target:self action:@selector(createStation)];
    btnCreateStation.tintColor = [UIColor colorWithRed:0.4f green:1.0f blue:0.6f alpha:1.0f];
    //    self.navigationItem.rightBarButtonItem = btnCreateStation;
    [rightButtons addObject:btnCreateStation];
    [btnCreateStation release];
    
    UIBarButtonItem *btnLogout = [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStyleBordered target:self action:@selector(logout)];
    btnLogout.tintColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:1.0f];
    [rightButtons addObject:btnLogout];
    [btnLogout release];
    
    self.navigationItem.rightBarButtonItems = rightButtons;

    
    loading = [[LoadingIndicator alloc] initWithFrame:self.view.frame];
    loading.hidden = YES;
    [self.view addSubview:loading];
    
    if ([host.stations containsObject:@"none"]==TRUE || [host.stations count]==0){
        goToBtfly = FALSE;
        descriptionLabel.hidden = NO;
    }
    else{
        descriptionLabel.hidden = YES;
    }
}

- (void)logout
{
    NSArray *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
    for(NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)createStation
{
    CreateStationViewController *create = [[CreateStationViewController alloc] initWithManager:self.butterflyMgr];
    create.host = host;
    create.delegate = self;
    [self.navigationController pushViewController:create animated:YES];
    [create release];
}

- (void)stationCreated
{
    newStation = TRUE;
}

- (void)refresh
{
    [theTableview reloadData];
    if ([host.stations containsObject:@"none"]==TRUE || [host.stations count]==0){
        descriptionLabel.hidden = NO;
    }
    else{
        descriptionLabel.hidden = YES;
    }
    
    if (newStation==TRUE){
        NSLog(@"REFRESH!!");
        newStation = FALSE;
        NSString *msg = [NSString stringWithFormat:@"Your station has been submitted to the %@ App. If approved, it will appear on the app home page shortly. If you would like to begin managing the station now, you may do so through the Butterfly Radio iPhone App.", self.butterflyMgr.appName];
        
        goToBtfly = TRUE;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Station Submitted" message:msg delegate:self cancelButtonTitle:@"ok" otherButtonTitles:@"Butterfly Radio", nil];
        [alert show];
        [alert release];
    }
    
    if (isLoading)
        [self stopLoading:theTableview];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"alertView clickedButtonAtIndex: %d", buttonIndex);
    if (buttonIndex==0){
        if (deleteIndex >= 0){
            if (req!=nil){
                [req cancel];
                req.delegate = nil;
                [req release];
            }
            
            Station *s = (Station *)[host.stations objectAtIndex:deleteIndex];
            
            if ([s.host isEqualToString:self.host.email]==TRUE){ //standard delete
                NSString *url = [NSString stringWithFormat:@"http://%@/api/station/%@", kUrl, s.unique_id];
                NSLog(@"URL = %@", url);
                req = [[BRNetworkOp alloc] initWithAddress:url parameters:nil];
                [req setHttpMethod:@"DELETE"];
            }
            else { // remove self.host from admin list, do not fully delete station. This would happen if the school is removing a substation from its list.  the station itself is not erased but it no longer shows up on the school list.
                
                /* REQUIRED PARAMS:
                 String name = req.getParameter("name");
                 String email = req.getParameter("email");
                 String tags = req.getParameter("tags");
                 String category = req.getParameter("category");
                 String action = req.getParameter("action");
                 */
                
                NSString *url = [NSString stringWithFormat:@"http://%@/api/station", kUrl];
                NSLog(@"URL = %@", url);
                NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"removeAdmin", @"action", self.host.email, @"admin", s.unique_id, @"station", s.name, @"name", [s tagsString], @"tags", s.category, @"category", s.host, @"email", nil];
                
                req = [[BRNetworkOp alloc] initWithAddress:url parameters:params];
            }
            
            
            req.delegate = self;
            [req sendRequest];
            [loading show];
        }
    }
    else {
        if (goToBtfly==TRUE){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/butterfly-radio/id532051737?mt=8"]];
        }
    }
}

- (void)requestData:(NSArray *)pkg //returns [address, data]
{
    if (pkg!=nil){
        NSString *address = [pkg objectAtIndex:0];
//        if ([address isEqualToString:[NSString stringWithFormat:@"http://%@/api/station", kUrl]]==TRUE){
        if ([address hasPrefix:[NSString stringWithFormat:@"http://%@/api/station", kUrl]]==TRUE){
            req.delegate = nil;
            [req release];

            NSString *url = [NSString stringWithFormat:@"http://%@/api/host?email=%@", kUrl, host.email];
            req = [[BRNetworkOp alloc] initWithAddress:url parameters:nil];
            [req setHttpMethod:@"GET"];
            req.delegate = self;
            [req sendRequest];
            if (loading.hidden==TRUE){
                [loading show];
            }
        }
        else {
            NSString *json = [[NSString alloc] initWithData:[pkg objectAtIndex:1] encoding:NSUTF8StringEncoding];
            NSDictionary *d = [json JSONValue];
            if (d==nil){
                [req sendRequest];
            }
            else{
                [loading hide];
                d = [d objectForKey:@"results"];
                NSLog(@"%@", [d description]);
                NSString *confirmation = [d objectForKey:@"confirmation"];
                if ([confirmation isEqualToString:@"found"]){
                    NSDictionary *hostInfo = [d objectForKey:@"host"];
                    [self.host populate:hostInfo];
                    [theTableview reloadData];
                }
            }
            [json release];
        }
    }
}


- (void)deleteContent:(int)index
{
    deleteIndex = index - 1000;
    goToBtfly = FALSE;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are You Sure?" message:@"This will permanently remove the station from your profile." delegate:self cancelButtonTitle:@"yes" otherButtonTitles:@"no", nil];
    [alert show];
    [alert release];
}



#pragma mark - StationDelegate
- (void)imageReady:(NSString *)addr
{
    [theTableview reloadData];
}

- (void)stationInfoReady
{
    
}



#pragma mark - UITableViewStuff
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([host.stations count]==0){
        return 0;
    }
    if ([host.stations containsObject:@"none"]==TRUE){
        return 0;
    }
    
    return [host.stations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ID";
    AdminCell *cell = [theTableview dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil){
        cell = [[[AdminCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
        [cell setup];
        cell.delegate = self;
    }
    
    if ([host.stations containsObject:@"none"]==TRUE){
        cell.nameLabel.text = @"no stations";
        return cell;;
    }

    Station *station = (Station *)[host.stations objectAtIndex:indexPath.row];
    
    int tag = (indexPath.row+1000);
    cell.tag = tag;
    
    cell.nameLabel.text = station.name;
    cell.categoryLabel.text = station.category;
    
    if (station.thumbnail==nil){
        [station fetchThumbnail:240];
        return cell;
    }
    
    
    [cell fillImage:station.thumbnail];
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellBg.size.height;
}


- (void)updateInfo
{
    NSLog(@"updateInfo");
    
    [self.host refresh];
    //    [self searchStations];
}



#pragma mark - AdminCellDelegate
- (void)buttonAction:(int)tag title:(NSString *)title
{
    NSLog(@"buttonAction:%d title:%@", tag, title);
    if ([title isEqualToString:@"delete"]){
        [self deleteContent:tag];
        return;
    }


    tag -= 1000;
    
    if ([host.stations containsObject:@"none"]==TRUE){
        [theTableview deselectRowAtIndexPath:[theTableview indexPathForSelectedRow] animated:YES];
        return;
    }
    
    
    Station *station = (Station *)[host.stations objectAtIndex:tag];
    if ([title isEqualToString:@"details"]){
        StationDetailsViewController *details = [[StationDetailsViewController alloc] initWithManager:self.butterflyMgr];
        details.station = station;
        [self.navigationController pushViewController:details animated:YES];
        [details release];
        return;
    }
    
    int mode;
    if ([title isEqualToString:@"tracks"]){
        mode = 0;
        if ([station.tracks containsObject:@"none"]==TRUE || [station.tracks count]==0){
            [self showAlert:@"No Tracks" message:@"This station has no tracks."];
            return;
        }
    }
    
    if ([title isEqualToString:@"news"]){
        mode = 1;
        if ([station.articles containsObject:@"none"]==TRUE || [station.articles count]==0){
            [self showAlert:@"No Articles" message:@"This station has no articles."];
            return;
        }
    }
    
    if ([title isEqualToString:@"admins"])
        mode = 2;

    
//    StationAdminViewController *admin = [[StationAdminViewController alloc] init];
    StationAdminViewController *admin = [[StationAdminViewController alloc] initWithManager:self.butterflyMgr];
    admin.host = self.host;
    admin.mode = mode;
    admin.title = station.name;
    admin.station = station;
    
    [self.navigationController pushViewController:admin animated:YES];
    [admin release];
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
