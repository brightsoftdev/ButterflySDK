//  Player.m
//  Audio
//
//  Created by Denny Kwon on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.

#import "Player.h"


@implementation Player
@synthesize delegate;
@synthesize files;
@synthesize streamer;
@synthesize adFrequency;
@synthesize sequential;

- (void)setup
{
    self.adFrequency = kAdFrequency;
    nextIndexSet = FALSE;
    sequential = TRUE;
    adSelected = FALSE;
    selected = -1;
    
    streamer = [[Streamer alloc] init];
    streamer.delegate = self;
    
    sponsors = [[Sponsors alloc] init];
    [sponsors findlocation];
}

- (id)init
{
    self = [super init];
    if (self){
        [self setup];
    }
    return self;
}

- (id)initWithAudioFiles:(NSArray *)f
{
    self = [super init];
    if (self){
        [self setup];
        files = [[NSMutableArray alloc] initWithArray:f];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"PLAYER - dealloc");
    [streamer release];
    [files release];
    if (sponsors!=nil){
        [sponsors release];
    }
    [super dealloc];
}

- (void)clear
{
    selected = -1;
    nextIndexSet = FALSE;
    adSelected = TRUE;
}

- (void)start:(int)i
{
    if (i<0){ [self setNextIndex]; }
    else{ selected = (i%[files count]); }
    [self startPlayback];
}

- (void)playFile:(int)i
{
    [delegate fileComplete];
    [streamer clear];
    selected = i;
    [self startPlayback];
}

- (void)startPlayback
{
    NSLog(@"PLAYER - startPlayback");
    AudioFile *file = nil;
    if (adSelected==TRUE){ //advertising file
        file = [sponsors getSelectedFile];
        if (file==nil){ file = [sponsors getRandomFile]; } //no file queued up in the sponsors
    }
    else{
        file = (AudioFile *)[files objectAtIndex:selected];
    }
    streamer.source = file;
    file.playing = TRUE;
    file.delegate = self;
    if ([file checkSavedFiles]==FALSE){
        if (file.bytes==nil){ //start downloading file
            [file downloadData];
        } 
        if (streamer.source.ad==FALSE){
            [delegate displayLoading:TRUE];
//            if ([delegate respondsToSelector:@selector(displayLoading:)]){
//                [delegate displayLoading:TRUE];
//            }
        }
    }
    [streamer play];
    nextIndexSet = FALSE;
    
    NSString *ad = nil;
    if (streamer.source.ad==TRUE){ ad = @"yes"; }
    else{ ad = @"no"; }
    NSDictionary *note = [NSDictionary dictionaryWithObjectsAndKeys:ad, @"ad", [streamer.source getFileInfo], @"fileInfo", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"new file" object:nil userInfo:note];
}

#pragma mark - AudioFileDelegate
- (void)fileFailed:(int)index
{
    NSLog(@"PLAYER - fileFailed:");
    [files removeObjectAtIndex:index];
    if ([files count]>0){
        [self skip];
    }
    [delegate fileError];

    //show alert
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error in the selected file. An alternate file is playing." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)fileSize:(NSUInteger)s
{
    NSLog(@"PLAYER - fileSize: %d", s);
    [delegate setSliderMax:s];
}

- (void)progressUpdate:(int)s
{
    NSLog(@"PLAYER - progressUpdate: %d", s);
    [delegate updateSliderPosition:s];
}

- (void)almostDone
{
    NSLog(@"PLAYER - almostDone"); //this gets called to prep the next file
    [self setNextIndex];
    
//    if (selected<[files count]){ //not an advertising file
//        AudioFile *file = (AudioFile *)[files objectAtIndex:selected];
//        if ([file checkSavedFiles]==FALSE){ [file downloadData]; } //start downloading file
//    }
    
    if (adSelected==TRUE){
        [sponsors prepareNext];
    }
    else{
        AudioFile *file = (AudioFile *)[files objectAtIndex:selected];
        if ([file checkSavedFiles]==FALSE){ [file downloadData]; } //start downloading file
    }
}

#pragma mark -
- (void)setNextIndex
{
    int check = 0;
    for (AudioFile *f in files){
        if (f.used==TRUE){ check++; }
    }
    if (check==[files count]){
        for (AudioFile *f in files){ f.used = FALSE; }
    }
    
    if (nextIndexSet==FALSE){
        fileindex++;
//        if (fileindex%kAdFrequency==0){ adSelected = TRUE; }
        if (fileindex%self.adFrequency==0){ adSelected = TRUE; }
        else{ 
            adSelected = FALSE; 
            if (sequential==TRUE){ //go in order
                selected++;
                selected = selected%[files count];
            }
            else{ //choose random file
                BOOL used = TRUE; 
                int i;
                while (used==TRUE) {
                    i = 0+arc4random();
                    i = i%[files count];
                    AudioFile *file = (AudioFile *)[files objectAtIndex:i];
                    used = file.used;
                }
                selected = i;
            }
        }
        nextIndexSet = TRUE;
        
        NSLog(@"PLAYER: setNextIndex = %d", selected);
    }
}

- (void)pause
{
    [streamer pause];
}

- (void)play
{
    [streamer resume];
}

- (void)skip
{
    NSLog(@"PLAYER - SKIP");
    if (streamer.source.ad == FALSE){
        [delegate fileComplete];
        [streamer clear];
        [self setNextIndex];
        [self startPlayback];
    }
}

- (void)seek:(int)offset
{
    [streamer seekto:offset];
}

#pragma mark - StreamerDelegate
- (void)fileFinished
{
    NSLog(@"PLAYER - fileFinished");
    [delegate fileComplete];
    [self setNextIndex];
    [self startPlayback];
}

- (void)changePlayState
{
    NSLog(@"PLAYER - changePlayState");
    [delegate trackInfo:[streamer.source getFileInfo]];
}

- (void)playbackStarted
{
    [delegate displayLoading:FALSE];
}

@end
