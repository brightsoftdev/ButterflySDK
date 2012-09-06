//  GetImage.h
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import <Foundation/Foundation.h>
#import "Globals.h"


@interface GetImage : NSOperation {
    id target;
    SEL action;
    BRStationSearchFilter filter;
    NSString *address;
}

- (id)initWithTarget:(id)t address:(NSString *)a action:(SEL)cbk filter:(BRStationSearchFilter)f;
- (id)initWithTarget:(id)t address:(NSString *)a action:(SEL)cbk;
@property (retain, nonatomic) NSString *address;
@end
