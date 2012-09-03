//
//  ArticlesViewController.m
//  butterflyradio
//
//  Created by Denny Kwon on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ArticlesViewController.h"

@interface ArticlesViewController ()

@end

@implementation ArticlesViewController
@synthesize station;

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:kThumbnailReadyNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [station release];
    [theTablview release];
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
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"post" style:UIBarButtonItemStyleBordered target:self action:@selector(postComment:)];
    
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
    
    if (station.thumbnail==nil){
        int dimen = kCellHeight+20;
        [station fetchThumbnail:dimen];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kSupportLandscape object:nil]];
    [theTablview deselectRowAtIndexPath:[theTablview indexPathForSelectedRow] animated:YES];
}

- (void)showRadio:(UIButton *)btn
{
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate showRadio];
    
    [self.butterflyMgr showRadio];
    
}

- (void)refresh
{
    NSLog(@"ARTICLES VIEW CONTROLLER - refresh");
    [theTablview reloadData];
}

#pragma mark - UITableViewStuff
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [station.articles count];
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
//        cell.imageView.layer.cornerRadius = 5.0f;
//        cell.imageView.layer.masksToBounds = YES;
    }
    if ([self.station.articles containsObject:@"none"]){
        cell.textLabel.text = @"none";
        if (station.thumbnail==nil){
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
            int dimen = kCellHeight+20;
            [article fetchThumbnail:dimen];
            if (station.thumbnail==nil){
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
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.station.articles containsObject:@"none"]){
        [theTablview deselectRowAtIndexPath:[theTablview indexPathForSelectedRow] animated:YES];
    }
    else {
        Article *article = (Article *)[station.articles objectAtIndex:indexPath.row];
        ArticleViewController *articleView = [[ArticleViewController alloc] initWithNibName:@"ArticleViewController" bundle:nil];
        articleView.butterflyMgr = self.butterflyMgr;
        articleView.hidesBottomBarWhenPushed = YES;
        
        articleView.article = article;
        articleView.station = station;
        articleView.view.frame = [UIScreen mainScreen].applicationFrame;
        [self.navigationController pushViewController:articleView animated:YES];
        [articleView release];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (void)postComment:(UIBarButtonItem *)btn
{
    SubmitArticleViewController *submitArticle = [[SubmitArticleViewController alloc] init];
    submitArticle.station = station;
    [self presentModalViewController:submitArticle animated:YES];
    [submitArticle release];
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
