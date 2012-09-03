//
//  ButterflyViewController.h
//  frenchkiss
//
//  Created by Denny Kwon on 8/20/12.
//  Copyright (c) 2012 Frenchkiss Records. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButterflyManager.h"
#import "Globals.h"
#import "JSON.h"
#import "BRNetworkOp.h"
#import "Station.h"
#import "Host.h"
#import "LoadingIndicator.h"
#import "SignalCheck.h"
#import <QuartzCore/QuartzCore.h>

@interface ButterflyViewController : UIViewController <UIScrollViewDelegate> {
    
    
    
    //Only for tableviews - not all subclasses will use these:
    UIView *refreshHeaderView;
    UILabel *refreshLabel;
    UIImageView *refreshArrow;
    UIActivityIndicatorView *refreshSpinner;
    BOOL isDragging;
    BOOL isLoading;
    
    BOOL reloadable;
    
}

@property (retain, nonatomic) ButterflyManager *butterflyMgr;
@property (retain, nonatomic) SignalCheck *signal;
- (id)initWithManager:(ButterflyManager *)mgr;
- (void)showRadio;
- (void)showRadioWithLoader;
- (NSString *)createFilePath:(NSString *)fileName;
- (void)addPullToRefreshHeader:(UIScrollView *)container;
- (void)stopLoading:(UIScrollView *)scrollView;
- (void)showAlert:(NSString *)title message:(NSString *)msg;

@end
