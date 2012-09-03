//
//  AdminCell.h
//  butterflyradio
//
//  Created by Denny Kwon on 8/14/12.
//
//

#import <UIKit/UIKit.h>
#import "Globals.h"
#import <QuartzCore/QuartzCore.h>

@protocol AdminCellDelegate <NSObject>
- (void)buttonAction:(int)tag title:(NSString *)title;
@end

@interface AdminCell : UITableViewCell {
    UIView *whiteBg;
    NSArray *backgrounds;
    NSDictionary *btnTitles;
    
    id delegate;
}

@property (assign) id delegate;
@property (retain, nonatomic) UIImageView *stationImage;
@property (retain, nonatomic) UILabel *nameLabel;
@property (retain, nonatomic) UILabel *categoryLabel;

@property (retain, nonatomic) UIButton *btnTracks;
@property (retain, nonatomic) UIButton *btnNews;
@property (retain, nonatomic) UIButton *btnAdmins;
@property (retain, nonatomic) UIButton *btnDetails;
@property (retain, nonatomic) UIButton *btnGarbage;

- (void)setup;
- (void)fillImage:(UIImage *)img;
@end
