//
//  ArticleViewController.h
//  butterflyradio
//
//  Created by Denny Kwon on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButterflyViewController.h"
#import "Article.h"
#import "ReviewsViewController.h"
#import "Twitter/Twitter.h"


@interface ArticleViewController : ButterflyViewController <UIWebViewDelegate, BRNetworkOpDelegate> {
    
    UIWebView *theWebview;
    Article *article;
    LoadingIndicator *loading;
    
    BRNetworkOp *req;
    Station *station;
}

@property (retain, nonatomic) Article *article;
@property (retain, nonatomic) Station *station;
@end
