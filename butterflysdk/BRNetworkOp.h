//
//  BRNetworkOp.h
//  frenchkiss
//
//  Created by Denny Kwon on 8/21/12.
//  Copyright (c) 2012 Frenchkiss Records. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Globals.h"


@protocol BRNetworkOpDelegate <NSObject>
@required
- (void)requestData:(NSArray *)pkg; //returns [address, data]
@end

@interface BRNetworkOp : NSObject {
    NSString *address;
    
    NSMutableURLRequest *urlRequest;
    NSMutableData *responseData;
    NSURLConnection *urlConnection;
    
    id delegate;
}

- (id)initWithAddress:(NSString *)a parameters:(NSDictionary *)p;
- (void)sendRequest;
- (void)setHttpMethod:(NSString *)m;
- (void)clear;
- (void)cancel;
@property (retain, nonatomic) NSString *address;
@property (assign)id delegate;
@end
