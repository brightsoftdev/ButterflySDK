//
//  ButterflyViewController.m
//  frenchkiss
//
//  Created by Denny Kwon on 8/20/12.
//  Copyright (c) 2012 Frenchkiss Records. All rights reserved.


#import "ButterflyViewController.h"
#import "RadioViewController.h"

@interface ButterflyViewController ()

@end

@implementation ButterflyViewController
@synthesize butterflyMgr;
@synthesize signal;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        reloadable = TRUE;
        self.signal = [SignalCheck signalWithDelegate:self];
    }
    return self;
}

- (id)initWithManager:(ButterflyManager *)mgr
{
    self = [super init];
    if (self) {
        self.butterflyMgr = mgr;
        reloadable = TRUE;
        self.signal = [SignalCheck signalWithDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    self.signal = nil;
    self.butterflyMgr = nil;
    [super dealloc];
}

- (void)showAlert:(NSString *)title message:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}


- (void)showRadio
{
    if (!self.butterflyMgr.currentStation){
        [self showAlert:@"No Station" message:@"There is no station currently selected."];
        return;
    }
    
    RadioViewController *radio = [[RadioViewController alloc] init];
    radio.butterflyMgr = self.butterflyMgr;
    [self.navigationController pushViewController:radio animated:YES];
    [radio release];
}

- (void)showRadioWithLoader
{
    if (!self.butterflyMgr.currentStation){
        [self showAlert:@"No Station" message:@"There is no station currently selected."];
        return;
    }
    
    RadioViewController *radio = [[RadioViewController alloc] init];
    radio.butterflyMgr = self.butterflyMgr;
    [self.navigationController pushViewController:radio animated:YES];
    [radio.loading show];
    [radio release];
}


- (NSString *)createFilePath:(NSString *)fileName
{
	fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"+"];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *docPath = [paths objectAtIndex:0];
	NSString *filePath = [docPath stringByAppendingPathComponent:fileName];
	NSLog(@"filepath = %@", filePath);
	return filePath;
}



#pragma mark - RefreshHeader
- (void)addPullToRefreshHeader:(UIScrollView *)container
{
    refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    refreshHeaderView.backgroundColor = [UIColor clearColor];
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, REFRESH_HEADER_HEIGHT)];
    refreshLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    refreshLabel.shadowColor = [UIColor whiteColor];
    refreshLabel.shadowOffset = CGSizeMake(-0.5f, 0.5f);
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.textColor = [UIColor grayColor];
    refreshLabel.numberOfLines = 2;
    refreshLabel.textAlignment = UITextAlignmentCenter;
    
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    refreshArrow.frame = CGRectMake(floorf((REFRESH_HEADER_HEIGHT - 27) / 2),
                                    (floorf(REFRESH_HEADER_HEIGHT - 44) / 2),
                                    27, 44);
    
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [refreshHeaderView addSubview:refreshSpinner];
    [container addSubview:refreshHeaderView];
}


#pragma mark - ScrollviewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewWillBeginDragging:");
    if (!reloadable)
        return;
    
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidScroll:");
    if (!reloadable)
        return;
    
    if (isLoading) { // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            scrollView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView animateWithDuration:0.25 animations:^{
            if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                refreshLabel.text = @"Release to refresh...";
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else {
                // User is scrolling somewhere within the header
                refreshLabel.text = @"Pull down to refresh...";
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
        }];
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"scrollViewDidEndDragging: willDecelerate:");
    if (!reloadable)
        return;
    
    if (isLoading) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading:scrollView];
    }
}


- (void)startLoading:(UIScrollView *)scrollView
{
    NSLog(@"startLoading");

    if (!reloadable)
        return;

    isLoading = YES;
    
    // Show the header
    [UIView animateWithDuration:0.3 animations:^{
        scrollView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        refreshLabel.text = @"Loading...";
        refreshArrow.hidden = YES;
        [refreshSpinner startAnimating];
    }];
    
    
    if (![signal checkSignal]){
        [self showAlert:@"No Connection" message:@"Please find an internet connection."];
        [self stopLoading:scrollView];
        return;
    }

    // Refresh action!
    [self updateInfo];
}


- (void)updateInfo //subclass should always override this!
{
    
}


- (void)stopLoading:(UIScrollView *)scrollView
{
    NSLog(@"stopLoading");
    if (!reloadable)
        return;

    isLoading = NO;
    
    // Hide the header
    [UIView animateWithDuration:0.3 animations:^{
        scrollView.contentInset = UIEdgeInsetsZero;
        [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(stopLoadingComplete)];
                     }];
}

- (void)stopLoadingComplete
{
    NSLog(@"stopLoadingComplete");
    if (!reloadable)
        return;

    // Reset the header
    refreshLabel.text = @"Pull down to refresh...";
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
}




#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
