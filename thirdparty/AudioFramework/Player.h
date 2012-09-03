//  Player.h
//  Audio
//  Created by Denny Kwon on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Streamer.h"
#import "AudioFile.h"
#import "Sponsors.h"
//#import "ControlPanelView.h"

@protocol PlayerDelegate <NSObject>
- (void)trackInfo:(NSMutableDictionary *)d;
- (void)fileError;
- (void)setSliderMax:(NSUInteger)max;
- (void)updateSliderPosition:(int)s;
- (void)fileComplete;
- (void)displayLoading:(BOOL)s; //s==TRUE means show, s==FALSE means hide
@end

#define kAdFrequency 1000 //2=ad every other file, 3=ad every third file and so on. defaults to never

@interface Player : NSObject <StreamerDelegate, AudioFileDelegate> {
    
    Streamer *streamer;
    NSMutableArray *files; //mutable because you might have to remove files if they are corrupted
    
    int selected, fileindex;
    id delegate;
    BOOL nextIndexSet, adSelected, sequential; //set sequential to TRUE if you want playback in order
    
    Sponsors *sponsors;
    
    int adFrequency;
}

@property (assign) id delegate;
@property (nonatomic) int adFrequency;
@property (nonatomic) BOOL sequential;
@property (retain, nonatomic) NSMutableArray *files;
@property (retain, nonatomic) Streamer *streamer;
- (id)initWithAudioFiles:(NSArray *)f;
- (void)setNextIndex;
- (void)startPlayback;
- (void)start:(int)i;
- (void)playFile:(int)i;
- (void)pause;
- (void)play;
- (void)skip;
- (void)clear;
- (void)seek:(int)offset;
@end
