//
//  SearchViewController.m
//  butterflyradio
//
//  Created by Denny Kwon on 5/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "StationViewController.h"


@interface SearchViewController ()

@end

@implementation SearchViewController
@synthesize searchResults;

- (id)init
{
    self = [super init];
    if (self) {
//        UIImage *img_banner = [UIImage imageNamed:@"banner_search.png"];
//        CGFloat w = 180.0f;
//        double scale = w/img_banner.size.width;
//        CGFloat h = scale*img_banner.size.height;
//        UIImageView *banner = [[UIImageView alloc] initWithFrame:CGRectMake(0.5*(320-w), 10, w, h)];
//        banner.image = img_banner;
//        self.navigationItem.titleView = banner;
//        [banner release];

        
        self.title = @"Search";
        self.tabBarItem.image = [UIImage imageNamed:@"tab_search.png"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kThumbnailReadyNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [theSearchBar release];
    [theTableview release];
    [loading release];
    if (searchResults!=nil){
        [searchResults release];
    }
    [super dealloc];
}

- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    frame.origin.y = 0.0f;
    frame.origin.x = 0.0f;
    UIViewAutoresizing resize = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = resize;
    view.backgroundColor = [UIColor yellowColor];
    
    theSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
    theSearchBar.barStyle = UIBarStyleBlack;
    theSearchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    theSearchBar.delegate = self;
    [view addSubview:theSearchBar];
    
    frame.origin.y = theSearchBar.frame.size.height;
    frame.size.height -= frame.origin.y;
    theTableview = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    theTableview.dataSource = self;
    theTableview.delegate = self;
    theTableview.autoresizingMask = resize;
    [view addSubview:theTableview];
    
    screen = [[UIView alloc] initWithFrame:frame];
    screen.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    screen.tag = 2000;
    screen.backgroundColor = [UIColor blackColor];
    screen.hidden = YES;
    screen.alpha = 0.6f;
    [view addSubview:screen];

    loading = [[LoadingIndicator alloc] initWithFrame:view.frame];
    [view addSubview:loading];
    [loading hide];

    self.view = view;
    [view release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *nowPlaying = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"nowPlaying.png"];
    [nowPlaying setBackgroundImage:img forState:UIControlStateNormal];
    [nowPlaying addTarget:self action:@selector(showRadio:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)showRadio:(UIButton *)btn
{
    [theSearchBar resignFirstResponder];
    [self hideScreen];
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self.butterflyMgr showRadio];
}

- (void)search
{
    [loading show];
    NSString *term = theSearchBar.text;
    if ([term length]==0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Value" message:@"Please fill in the search field." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show]; [alert release];
    }
    else{
        [loading show];
        term = [term stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        term = [term lowercaseString];
        
        if (req!=nil){
            req.delegate = nil;
            [req release];
        }
        
        NSString *url = [NSString stringWithFormat:@"http://www.butterflyradio.com/api/station?tag=%@", term];
        req = [[BRNetworkOp alloc] initWithAddress:url parameters:nil];
        [req setHttpMethod:@"GET"];
        req.delegate = self;
        [req sendRequest];
    }

}

- (void)requestData:(NSArray *)pkg; //returns [address, data]
{
    if (pkg!=nil){
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
                NSArray *stations = [d objectForKey:@"stations"];
                NSMutableArray *s = [NSMutableArray array];
                for (int i=0; i<[stations count]; i++){
                    NSDictionary *info = [stations objectAtIndex:i];
                    Station *station = [[Station alloc] init];
                    [station populate:info];
                    [s addObject:station];
                    [station release];
                }
                self.searchResults = s;
                [theTableview reloadData];
            }
            else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Found" message:@"There were no search results returned." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show]; [alert release];
            }
        }
        
    }
}

- (void)refresh //called when station thumbnail is ready
{
    [theTableview reloadData];
}


#pragma mark - UITableViewStuff
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ID";
    UITableViewCell *cell = [theTableview dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
        cell.detailTextLabel.numberOfLines = 3;
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
        cell.textLabel.font = [UIFont fontWithName:kFont size:16.0f];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    Station *station = [searchResults objectAtIndex:indexPath.row];
    
    cell.textLabel.text = station.name;
    cell.textLabel.text = station.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"\n%@", station.category];
    if(station.thumbnail==nil){
        cell.imageView.image = [UIImage imageNamed:@"placeholder.png"];
        [station fetchThumbnail:100];
    }
    else {
        cell.imageView.image = station.thumbnail;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Station *station = [searchResults objectAtIndex:indexPath.row];
    if (station){
        StationViewController *stationView = [[StationViewController alloc] init];
        stationView.hidesBottomBarWhenPushed = TRUE;
        stationView.station = station;
        stationView.title = station.name;
        [self.navigationController pushViewController:stationView animated:YES];
        [stationView release];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


- (void)hideScreen
{
    [theSearchBar setShowsCancelButton:FALSE animated:YES];
    [self.navigationController setNavigationBarHidden:FALSE animated:YES];
    [theSearchBar resignFirstResponder];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4f];
    screen.alpha = 0.0f;
    [UIView commitAnimations];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [theSearchBar setShowsCancelButton:TRUE animated:YES];
    [self.navigationController setNavigationBarHidden:TRUE animated:YES];
    
    screen.alpha = 0.0f;
    screen.hidden = NO;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4f];
    screen.alpha = 0.6f;
    [UIView commitAnimations];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self hideScreen];
    [self search];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [self hideScreen];
}

#pragma mark - UIResponder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan:");
    UITouch *touch = [touches anyObject];
    if (touch.view.tag==2000){
        [self hideScreen];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesMoved:");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesEnded:");
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesCancelled:");
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
