//
//  ArticlesViewController.h
//  butterflyradio
//
//  Created by Denny Kwon on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButterflyViewController.h"
#import "ArticleViewController.h"
#import "SubmitArticleViewController.h"


@interface ArticlesViewController : ButterflyViewController <UITableViewDelegate, UITableViewDataSource>{
    
    Station *station;
    UITableView *theTablview;
    
}

@property (retain, nonatomic) Station *station;
@end
