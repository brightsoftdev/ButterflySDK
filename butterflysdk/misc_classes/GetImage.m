//  GetImage.m
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import "GetImage.h"

@implementation GetImage
@synthesize address;

- (id)initWithTarget:(id)t address:(NSString *)a action:(SEL)cbk
{
    self = [super init];
    if (self){
        target = t;
        action = cbk;
        address = [a retain];
    }
    return  self;
}

- (void)dealloc
{
    [address release];
    [super dealloc];
}

- (void)cancel
{
    NSLog(@"GET IMAGE CANCELLED!");
    [super cancel];
}

- (void)main
{
    NSLog(@"GET IMAGE: %@", address);
    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:address]];
    if (imgData==nil){
        NSLog(@"GET IMAGE - Cancelling");
        [self cancel];
    }
    else{
        if (![self isCancelled]){
            NSArray *pkg = [NSArray arrayWithObjects:address, imgData, nil];
            [target performSelectorOnMainThread:action withObject:pkg waitUntilDone:NO];
        }
    }
}

@end
