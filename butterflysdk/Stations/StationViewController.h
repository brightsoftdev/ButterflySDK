//
//  StationViewController.h
//  butterflyradio
//
//  Created by Denny Kwon on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.


#import <UIKit/UIKit.h>
#import "ButterflyViewController.h"
#import "RecordViewController.h"
#import "ArticlesViewController.h"
#import "SubmitArticleViewController.h"
#import "ReviewsViewController.h"
#import "TracksViewController.h"
#import <MessageUI/MessageUI.h>
#import "StationCell.h"
#import "BottomBanner.h"


@interface DetailView : UIView {
    
    UILabel *titleLabel;
    UILabel *textLabel;
    UIScrollView *theScrollview;
}
@property (retain, nonatomic) UILabel *titleLabel;
@property (retain, nonatomic) UILabel *textLabel;
- (void)resize;
@end

typedef enum {
    ViewModeRadio = 0,
    ViewModeNews,
} ViewMode;


@interface StationViewController : ButterflyViewController <UITableViewDelegate, UITableViewDataSource, ToolBarDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, StationTableCellDelegate> {
    
    Station *station;
    UILabel *titleLabel;
    UITableView *theTableview;
    NSArray *sections;
    
    UIImageView *image;
    UIImageView *imageShadow;
    LoadingIndicator *loading;
    BOOL reload;
    
    UIButton *btn_save;
    UIButton *btn_reviews;
    UIButton *btn_share;
    UIButton *btn_contact;
    
    ViewMode vMode;
    NSArray *backgrounds;
    
//    UIView *refreshHeaderView;
//    UILabel *refreshLabel;
//    UIImageView *refreshArrow;
//    UIActivityIndicatorView *refreshSpinner;
//    BOOL isDragging;
//    BOOL isLoading;
    BottomBanner *bottom;
}

@property (retain, nonatomic) UIButton *btn_save;
@property (retain, nonatomic) UIButton *btn_reviews;
@property (retain, nonatomic) UIButton *btn_share;
@property (retain, nonatomic) UIButton *btn_contact;
@property (retain, nonatomic) Station *station;

@end
