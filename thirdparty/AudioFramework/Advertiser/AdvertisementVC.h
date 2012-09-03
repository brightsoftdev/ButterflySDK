//
//  AdvertisementVC.h
//  TeamLove
//
//  Created by Denny Kwon on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URLRequest.h"

#define kMax 300.0f

@interface AdvertisementVC : UIViewController <URLRequestDelegate> {
    NSDictionary *fileInfo;
    URLRequest *req;
    
    UIImageView *image;
    UILabel *nameLabel;
    
}

@property (retain, nonatomic) NSDictionary *fileInfo;
- (void)flush;
- (void)setupAd;
@end
