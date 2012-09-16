//
//  AdminCell.m
//  butterflyradio
//
//  Created by Denny Kwon on 8/14/12.
//
//

#import "AdminCell.h"

@implementation AdminCell
@synthesize stationImage;
@synthesize nameLabel;
@synthesize categoryLabel;
@synthesize btnNews;
@synthesize btnTracks;
@synthesize btnAdmins;
@synthesize btnGarbage;
@synthesize btnDetails;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        backgrounds = [[NSArray alloc] initWithObjects:@"bg_button_station.png", @"bg_button_station_news.png", @"bg_button_station_admins.png", @"bg_button_station_info.png", @"bg_button_station_garbage.png", nil];
        
        btnTitles = [[NSDictionary alloc] initWithObjectsAndKeys:@"tracks", @"bg_button_station.png", @"news", @"bg_button_station_news.png", @"admins", @"bg_button_station_admins.png", @"delete", @"bg_button_station_garbage.png", @"info", @"bg_button_station_garbage.png", nil];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_cell_station.png"]];

    }
    return self;
}

- (void)dealloc
{
    [whiteBg release];
    [backgrounds release];
    [btnTitles release];
    self.stationImage = nil;
    self.nameLabel = nil;
    self.btnAdmins = nil;
    self.btnTracks = nil;
    self.btnNews = nil;
    self.btnGarbage = nil;
    self.btnDetails = nil;
    [super dealloc];
}



- (void)setup
{
    CGRect frame = CGRectMake(19, 13, 80, 80);
    whiteBg = [[UIView alloc] initWithFrame:frame];
    whiteBg.backgroundColor = [UIColor darkGrayColor];
    whiteBg.layer.masksToBounds = YES;
    [self.contentView addSubview:whiteBg];
    
    frame.origin.x += 1.0f;
    frame.origin.y -= 1.0f;
    
    stationImage = [[UIImageView alloc] initWithFrame:frame];
    stationImage.layer.masksToBounds = YES;
    stationImage.backgroundColor = [UIColor lightGrayColor];
    stationImage.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    stationImage.layer.borderWidth = 0.5f;
    stationImage.image = [UIImage imageNamed:@"Icon@2x.png"];
    [self.contentView addSubview:stationImage];
    
    frame = stationImage.frame;
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x+frame.size.width+10, frame.origin.y, 200, 20)];
    nameLabel.textColor = [UIColor darkGrayColor];
    nameLabel.font = [UIFont fontWithName:kFont size:16.0f];
    nameLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:nameLabel];
    
    frame = nameLabel.frame;
    frame.origin.y += frame.size.height;
    frame.size.height = 15.0f;
    categoryLabel = [[UILabel alloc] initWithFrame:frame];
    categoryLabel.textColor = [UIColor grayColor];
    categoryLabel.font = [UIFont fontWithName:kFont size:13.0f];
    categoryLabel.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:categoryLabel];
    
    UIImage *img_btn_station = [UIImage imageNamed:[backgrounds objectAtIndex:0]];
//    frame = CGRectMake(13, 99.5, 0.995*img_btn_station.size.width, img_btn_station.size.height);
    frame = CGRectMake(13, 99.5, 0.796*img_btn_station.size.width, img_btn_station.size.height);
    
    int i = 0;
    
    // Tracks Button
    NSString *background = [backgrounds objectAtIndex:i];
    self.btnTracks = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTracks.adjustsImageWhenHighlighted = YES;
    btnTracks.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    [btnTracks setTitle:[btnTitles objectForKey:background] forState:UIControlStateNormal];
    [btnTracks setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnTracks.titleLabel.font = [UIFont fontWithName:kFont size:9.0f];
    [btnTracks addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    btnTracks.frame = frame;
    [btnTracks setBackgroundImage:[UIImage imageNamed:background] forState:UIControlStateNormal];
    [self.contentView addSubview:btnTracks];
    frame.origin.x += frame.size.width;
    i++;
    
    
    // News Button
    background = [backgrounds objectAtIndex:i];
    self.btnNews = [UIButton buttonWithType:UIButtonTypeCustom];
    btnNews.adjustsImageWhenHighlighted = YES;
    btnNews.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    [btnNews setTitle:[btnTitles objectForKey:background] forState:UIControlStateNormal];
    [btnNews setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnNews.titleLabel.font = [UIFont fontWithName:kFont size:9.0f];
    [btnNews addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    btnNews.frame = frame;
    [btnNews setBackgroundImage:[UIImage imageNamed:background] forState:UIControlStateNormal];
    [self.contentView addSubview:btnNews];
    frame.origin.x += frame.size.width;
    i++;
    
    
    
    // Admins Button
    background = [backgrounds objectAtIndex:i];
    self.btnAdmins = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAdmins.adjustsImageWhenHighlighted = YES;
    btnAdmins.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    [btnAdmins setTitle:[btnTitles objectForKey:background] forState:UIControlStateNormal];
    [btnAdmins setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnAdmins.titleLabel.font = [UIFont fontWithName:kFont size:9.0f];
    [btnAdmins addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    btnAdmins.frame = frame;
    [btnAdmins setBackgroundImage:[UIImage imageNamed:background] forState:UIControlStateNormal];
    [self.contentView addSubview:btnAdmins];
    frame.origin.x += frame.size.width;
    i++;
    
    
    //Details Button
    background = [backgrounds objectAtIndex:i];
    self.btnDetails = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDetails.adjustsImageWhenHighlighted = YES;
    btnDetails.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
//    [btnDetails setTitle:[btnTitles objectForKey:background] forState:UIControlStateNormal];
    [btnDetails setTitle:@"details" forState:UIControlStateNormal];
    [btnDetails setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnDetails.titleLabel.font = [UIFont fontWithName:kFont size:9.0f];
    [btnDetails addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    btnDetails.frame = frame;
    [btnDetails setBackgroundImage:[UIImage imageNamed:background] forState:UIControlStateNormal];
    [self.contentView addSubview:btnDetails];
    frame.origin.x += frame.size.width;
    i++;
    
    
    //Delete Button
    background = [backgrounds objectAtIndex:i];
    self.btnGarbage = [UIButton buttonWithType:UIButtonTypeCustom];
    btnGarbage.adjustsImageWhenHighlighted = YES;
    btnGarbage.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    [btnGarbage setTitle:[btnTitles objectForKey:background] forState:UIControlStateNormal];
    [btnGarbage setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnGarbage.titleLabel.font = [UIFont fontWithName:kFont size:9.0f];
    [btnGarbage addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    btnGarbage.frame = frame;
    [btnGarbage setBackgroundImage:[UIImage imageNamed:background] forState:UIControlStateNormal];
    [self.contentView addSubview:btnGarbage];

    
    
}

- (void)fillImage:(UIImage *)img
{
    
    if (![stationImage.image isEqual:img]){
        //        stationImage.transform = CGAffineTransformMakeScale(0.0, 0.0);
        self.stationImage.image = img;
        
        [UIView animateWithDuration:0.08f
                              delay:0.0f
                            options:UIViewAnimationCurveLinear
                         animations:^{
                             stationImage.transform = CGAffineTransformMakeScale(1.1, 1.1);
                         }
                         completion:^(BOOL finished){
                             
                             [UIView animateWithDuration:0.08f
                                                   delay:0.0f
                                                 options:UIViewAnimationCurveLinear
                                              animations:^{
                                                  stationImage.transform = CGAffineTransformMakeScale(0.95, 0.95);
                                              }
                                              completion:^(BOOL finished){
                                                  [UIView animateWithDuration:0.08
                                                                        delay:0.0f
                                                                      options:UIViewAnimationCurveLinear
                                                                   animations:^{
                                                                       stationImage.transform = CGAffineTransformIdentity;
                                                                   }
                                                                   completion:NULL];
                                                  
                                              }];
                             
                             
                         }];
    }
}

- (void)buttonTapped:(UIButton *)btn
{
    if (btn.adjustsImageWhenHighlighted){
        [delegate buttonAction:self.tag title:btn.titleLabel.text];
    }
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
