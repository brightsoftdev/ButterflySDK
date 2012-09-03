//
//  Article.h
//  butterflyradio
//
//  Created by Denny Kwon on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetImage.h"
#import "Globals.h"
#import <UIKit/UIKit.h>
//#import "ImageHelpers.h"

@interface Article : NSObject {
    
    NSString *title;
    NSString *date;
    NSString *author;
    NSString *content;
    NSString *unique_id;
    NSString *imageUrl;
    
    UIImage *image;
    UIImage *thumb;
    BOOL link;
    
    NSOperationQueue *queue;
    GetImage *getThumb;
}

@property (copy, nonatomic) NSString *imageUrl;
@property (copy, nonatomic) NSString *unique_id;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *date;
@property (copy, nonatomic) NSString *author;
@property (copy, nonatomic) NSString *content;
@property (retain, nonatomic) UIImage *image;
@property (retain, nonatomic) UIImage *thumb;
@property (nonatomic) BOOL link;
- (void)parse:(NSString *)a;
- (void)fetchThumbnail:(int)dimen;
- (void)thumbnailReady:(NSArray *)pkg;
@end
