//
//  Article.m
//  butterflyradio
//
//  Created by Denny Kwon on 5/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Article.h"

@implementation UIImage (scale)
+ (UIImage*)imageWithImage:(UIImage*)img scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end


@implementation Article
@synthesize title;
@synthesize date;
@synthesize author;
@synthesize content;
@synthesize link;
@synthesize unique_id;
@synthesize imageUrl;
@synthesize image;
@synthesize thumb;


- (void)parse:(NSString *)a
{
    NSArray *parts = [a componentsSeparatedByString:@"=="];
    for (NSString *part in parts) {
        NSArray *keyValue = [part componentsSeparatedByString:@"::"];
        if ([keyValue count]==2){
            NSString *key = [keyValue objectAtIndex:0];
            NSString *value = [keyValue objectAtIndex:1];
            
            if ([key isEqualToString:@"title"]){ self.title = value; }
            if ([key isEqualToString:@"image"]){ self.imageUrl = value; }
            if ([key isEqualToString:@"author"]){ self.author = value; }
            if ([key isEqualToString:@"date"]){
                NSArray *dateParts = [value componentsSeparatedByString:@" "];
                if ([dateParts count]>3){
                    self.date = [NSString stringWithFormat:@"%@ %@, %@", [dateParts objectAtIndex:1], [dateParts objectAtIndex:2], [dateParts lastObject]];
                }
                else{
                    self.date = value;
                }
            }
            if ([key isEqualToString:@"content"]){ self.content = value; }
            if ([key isEqualToString:@"id"]){ self.unique_id = value; }
            if ([key isEqualToString:@"link"]){
                if ([value isEqualToString:@"yes"]){
                    self.link = TRUE;
                }
                else{
                    self.link = FALSE;
                }
            }
        }
    }
}

- (void)dealloc
{
    if (queue!=nil){
        [queue cancelAllOperations];
        [queue release];
    }
    if (getThumb!=nil){
        [getThumb release];
    }
    
    self.imageUrl = nil;
    self.image = nil;
    self.thumb = nil;
    [title release];
    [date release];
    [author release];
    [content release];
    [unique_id release];
    [super dealloc];
}

- (void)fetchThumbnail:(int)dimen
{
    NSLog(@"ARTICLE: fetchThumbnail");
    if ([self.imageUrl isEqualToString:@"none"]==TRUE){

        if (self.content!=nil){
            if ([self.content rangeOfString:@"imgur.com"].location != NSNotFound){  // imgur image
                if (getThumb==nil){
                    if (queue==nil){ queue = [[NSOperationQueue alloc] init]; }
                    NSArray *parts = [self.content componentsSeparatedByString:@"/"];
                    NSString *photoId = [parts lastObject];
                    if ([photoId rangeOfString:@".jpg"].location == NSNotFound){
                        photoId = [photoId stringByAppendingString:@".jpg"];
                    }
                    photoId = [photoId stringByReplacingOccurrencesOfString:@".jpg" withString:@"s.jpg"];
                    NSString *imgur = @"http://imgur.com/";
                    NSString *url = [imgur stringByAppendingString:photoId];
                    
                    getThumb = [[GetImage alloc] initWithTarget:self address:url action:@selector(thumbnailReady:)];
                    [queue addOperation:getThumb];
                }
            }
            if ([self.content rangeOfString:@"youtube.com"].location != NSNotFound){  // youtube image
                if ([self.content rangeOfString:@"?v="].location != NSNotFound){
                    if (getThumb==nil){
                        if (queue==nil){ queue = [[NSOperationQueue alloc] init]; }
                        NSArray *parts = [self.content componentsSeparatedByString:@"?v="];
                        NSString *suffix = [parts objectAtIndex:1];
                        NSString *youtubeId = [suffix substringToIndex:11];
                        
                        NSString *url = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/1.jpg", youtubeId];
                        getThumb = [[GetImage alloc] initWithTarget:self address:url action:@selector(thumbnailReady:)];
                        [queue addOperation:getThumb];
                    }
                }
            }
        }

    }
    else{ //blob store image
        if (getThumb==nil){
            if (queue==nil){ queue = [[NSOperationQueue alloc] init]; }
            NSString *url = self.imageUrl;
            url = [[url componentsSeparatedByString:@"=="] objectAtIndex:0];
            url = [url stringByAppendingString:[NSString stringWithFormat:@"=s%d-c", dimen]];
            
            getThumb = [[GetImage alloc] initWithTarget:self address:url action:@selector(thumbnailReady:)];
            [queue addOperation:getThumb];
        }
    }
}

- (void)thumbnailReady:(NSArray *)pkg
{
    NSLog(@"ARTICLE: thumbnailReady");
    if (pkg!=nil){
//        self.thumb = [UIImage imageWithData:[pkg objectAtIndex:1]];
        UIImage *img = [UIImage imageWithData:[pkg objectAtIndex:1]];
        self.thumb = [UIImage imageWithImage:img scaledToSize:CGSizeMake(kCellHeight+20, kCellHeight+20)];
        
        [getThumb release];
        getThumb = nil;
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kThumbnailReadyNotification object:nil]];
    }
}


@end
