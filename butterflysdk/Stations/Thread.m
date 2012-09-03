//
//  Thread.m
//  butterflyradio
//
//  Created by Denny Kwon on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.


#import "Thread.h"

@implementation Thread
@synthesize date;
@synthesize threadId;
@synthesize thread;

- (id)init
{
    self = [super init];
    if (self){
        thread = [[NSMutableArray alloc] init];
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss a"]; //Wed Jul 04 05:02:24 UTC 2012
    }
    return self;
}

- (void)processDateString:(NSString *)s
{
    self.date = [dateFormatter dateFromString:s];
}

- (void)dealloc
{
    [thread release];
    [dateFormatter release];
    self.threadId = nil;
    self.date = nil;
    [super dealloc];
}


@end
