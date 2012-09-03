//
//  Thread.h
//  butterflyradio
//
//  Created by Denny Kwon on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioFile.h"


@interface Thread : NSMutableArray {
    NSDate *date;
    NSString *threadId;
    NSMutableArray *thread;
    
    NSDateFormatter *dateFormatter;
}

@property (copy, nonatomic) NSString *threadId;
@property (copy, nonatomic) NSMutableArray *thread;
@property (retain, nonatomic) NSDate *date;
- (void)processDateString:(NSString *)s;
@end
