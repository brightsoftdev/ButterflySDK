//
//  Sponsors.m
//  TeamLove
//
//  Created by Denny Kwon on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Sponsors.h"

@implementation Sponsors
@synthesize sponsors;
@synthesize location;
@synthesize ready;

- (id)init
{
    self = [super init];
    if (self){
        self.ready = FALSE;
        sponsors = [[NSMutableArray alloc] init];
        selected = 0;
    }
    return self;
}

- (void)dealloc
{
    [sponsors release];
    if (req!=nil){
        req.delegate = nil;
        [req release];
    }
    [location release];
    [super dealloc];
}

- (void)findlocation
{
    //send an initial request for national advertisers. then start polling for location.
    NSString *url = [NSString stringWithFormat:@"http://www.thegridmedia.com/file?state=all&app=%@&zip=00000", kApplicationName];
    req = [[URLRequest alloc] initWithAddress:url parameters:nil];
    [req setHttpMethod:@"GET"];
    req.delegate = self;
    [req sendRequest];

    
    location = [[Location alloc] init];
    location.delegate = self;
    [location findCurrentLocation];
}

- (int)getRandomNum:(int)max
{
    int rand = arc4random();
    rand = abs(rand);
    rand = rand%max;
    return rand;
}

- (void)prepareNext
{
    if (next!=nil){ [next release]; next = nil; }
    
    selected = [self getRandomNum:[sponsors count]];
    NSDictionary *sponsor = (NSDictionary *)[sponsors objectAtIndex:selected];
    NSArray *files = [sponsor objectForKey:@"files"];
    int rand = [self getRandomNum:[files count]]; //get a random file from the sponsor's list
    
    NSString *fileInfo = [files objectAtIndex:rand];
    NSLog(@"SPONSORS - getRandomFile: %@", fileInfo);
    NSArray *parts = [fileInfo componentsSeparatedByString:@"=="];
    if ([parts count]>3){
        next = [[AudioFile alloc] init];
        next.author = [sponsor objectForKey:@"name"];
        next.ad = TRUE;
        next.url = [NSString stringWithFormat:@"http://www.thegridmedia.com/serve?key=%@&sponsor=%@", [parts objectAtIndex:0], [sponsor objectForKey:@"email"]];
        next.name = [parts objectAtIndex:1];
        next.link = [parts objectAtIndex:2];
        next.image = [parts objectAtIndex:3];
        if ([next checkSavedFiles]==FALSE){ [next downloadData]; }
    }
}

- (AudioFile *)getSelectedFile
{
    next.ad = TRUE;
    return next;
}

- (AudioFile *)getRandomFile
{
    AudioFile *file = nil;
    int rand = [self getRandomNum:[sponsors count]];
    NSDictionary *sponsor = (NSDictionary *)[sponsors objectAtIndex:rand]; //get a random sponsor
    NSArray *files = [sponsor objectForKey:@"files"];
    rand = [self getRandomNum:[files count]]; //get a random file from the sponsor's list
    
    NSString *fileInfo = [files objectAtIndex:rand];
    NSLog(@"SPONSORS - getRandomFile: %@", fileInfo);
    NSArray *parts = [fileInfo componentsSeparatedByString:@"=="];
    if ([parts count]>3){
        file = [[AudioFile alloc] init];
        file.author = [sponsor objectForKey:@"name"];
        file.ad = TRUE;
        file.url = [NSString stringWithFormat:@"http://www.thegridmedia.com/serve?key=%@&sponsor=%@", [parts objectAtIndex:0], [sponsor objectForKey:@"email"]];
        file.name = [parts objectAtIndex:1];
        file.link = [parts objectAtIndex:2];
        file.image = [parts objectAtIndex:3];
        [file autorelease];
    }
    return file;
}

- (void)sendRequest
{
    if (req!=nil){ 
        [req cancel];
        [req release];
        req.delegate = nil;
        req = nil;
    }
    NSString *url = [NSString stringWithFormat:@"http://www.thegridmedia.com/file?state=%@&app=%@&zip=%@", location.state, kApplicationName, location.zip];
    NSLog(@"SPONSORS - sendRequest: %@", url);
    req = [[URLRequest alloc] initWithAddress:url parameters:nil];
    [req setHttpMethod:@"GET"];
    req.delegate = self;
    [req sendRequest];
}

- (void)requestData:(NSArray *)pkg
{
    if (pkg!=nil){
        NSString *json = [[NSString alloc] initWithData:[pkg objectAtIndex:1] encoding:NSUTF8StringEncoding];
        NSDictionary *d = [json JSONValue]; [json release];
        if (d==nil){ //JSON error. Probably app engine failure. try again.
            [self sendRequest];
        }
        else{
            NSArray *a = [[d objectForKey:@"results"] objectForKey:@"advertisers"];
            if (a!=nil){ 
                [sponsors removeAllObjects];
                for (int i=0; i<[a count]; i++){
                    NSDictionary *sponsor = [a objectAtIndex:i];
                    NSArray *files = [sponsor objectForKey:@"files"];
                    if ([files containsObject:@"none"]==FALSE){
                        [sponsors addObject:sponsor];
                    }
                }
            }
            NSLog(@"SPONSORS: advertisers ready: %@", [sponsors description]);
            self.ready = TRUE;
        }
    }
}

- (void)locationReady
{
    NSLog(@"SPONSORS: locationReady");
    [self sendRequest];
}



/*
 (
 {
 email = "dennykwon2@gmail.com";
 files =         (
 "AMIfv96dGaFSCOwI5L8oarZ3IBIAJi4dQG2uTvmIQDHDNc2pFEsLrFHMZuNmak-TwkPORnJbBOKTMFULKNWQ8_QBSSApmhRkDoyfXWmU_d0vQfRrCo3YFiHncPoe3mg4EhVYX2MWXwclq0Gtn5LhWyB8YUBzgU5mv4rr4CKaURSmShNxGwdtYwk==ad1 - Frank.mp3==www.dkgmail.com==http://lh4.ggpht.com/QNjx1YT1__lmYp1FU5st9jwxSsiVBDtoYP7DMlIqubv8khQcEYpCHatqgSCYsr27aNYzvC_3yV0dciPGVDZowXLqEmmomg"
 );
 name = DKGmail;
 states =         (
 anywhere,
 CT
 );
 website = "www.dkgmail.com";
 },
 {
 email = "dk23412179@yahoo.com";
 files =         (
 "AMIfv967M59UvTXChT6CiBjLAhv8g0dWp0naum7q3zLiy_IOq24Yo_EGXMfHkuoIdywGp6niyduaDwUiacfrboYOsx7J-mFv3aWUAi-9NpffAQsy2fLlGHTeZoOV3wPyLjrpWO4829T9HP8sI6bW7nVdIqRhbGPGZjgkIpS_WRIjMvpClilwzP8==ad1 - Cameron.mp3==www.dkyahoo.com==http://lh5.ggpht.com/yuaefFxPn0XQGtcu1jcvijklrUsF3SY13trpNU8RiSNnEbd_3Jv1BC95N0QnNHmAaW4obY_VT5PR7_X2Iuf4ijFtJ0bfZg"
 );
 name = DKYahoo;
 states =         (
 CT,
 MA,
 anywhere
 );
 website = "www.dkyahoo.com";
 }
 ) */


@end
