//
//  Streamer.h
//  FileStream
//
//  Created by Denny Kwon on 8/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
#import "AudioFile.h"

@protocol StreamerDelegate
- (void)fileFinished;
- (void)changePlayState;
- (void)playbackStarted;
@end

#define kUpdateFreq 0.50f

@interface Streamer : NSObject {
	id delegate;
	AudioFileStreamID fileStream;
	AudioQueueRef queue;
	
	BOOL isRunning; 
    BOOL readyToAcceptPackets;
    BOOL flushing;
    BOOL falseFinish;
	int bufferCount, callbackCount;
    int checkDataCount;
	SInt32 totalBytes, byteOffset;
    
    AudioFile *source;
    NSTimer *timer;
}

@property (readwrite) SInt32 byteOffset;
@property (assign) id delegate;
@property (nonatomic) int bufferCount;
@property (nonatomic) int callbackCount;
@property (nonatomic) BOOL isRunning;
@property (nonatomic) BOOL flushing;
@property (nonatomic) BOOL readyToAcceptPackets;
@property (readwrite) AudioFileStreamID fileStream;
@property (readwrite) AudioQueueRef queue;
@property (retain, nonatomic) AudioFile *source;
- (void)parseBytes:(NSData *)data;
- (void)play;
- (void)pause;
- (void)resume;
- (void)seekto:(int)offset;
- (void)reset:(BOOL)reset;
- (void)checkDataSize;
- (void)finished;
- (void)clear;
@end
