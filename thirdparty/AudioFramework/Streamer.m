//  Streamer.m
//  FileStream
//
//  Created by Denny Kwon on 8/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.

#import "Streamer.h"
void interruptionListener(void *inClientData, UInt32 inInterruptionState)
{
	NSLog(@"STREAMER - interruptionListener");
	Streamer *self = (Streamer *)inClientData;
//    NSLog(@"TEST: %@", self.source.name);
    [self pause];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"InterruptionNotification" object:nil]];
}

void AQOutputCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer)
{
    unsigned long p = inBuffer->mAudioDataByteSize;
//	NSLog(@"STREAMER - AQOutputCallback: %lu bytes played", inBuffer->mAudioDataByteSize);
	NSLog(@"STREAMER - AQOutputCallback: %lu bytes played", p);
	Streamer *self = (Streamer *)inUserData;
	/* This callback is mainly to used to track used buffers and recycle them after use.
	 This is where most of the threading locks are removed etc.
	 For now, don't worry about this because we are not recycling buffers.
	 Instead, we just create new buffers in memory whenever data gets called in from server */
	
	AudioQueueFreeBuffer(self.queue, inBuffer); //since we're not recycling buffers, you need to free them after use every time.
	self.callbackCount++;
	NSLog(@"STREAMER - AQOutputCallback: bufferCount=%d, callbackCount=%d", self.bufferCount, self.callbackCount);
	if ((self.bufferCount-self.callbackCount) <= 1){
        if (self.flushing==FALSE){
            NSLog(@"STREAMER - AQOutputCallback: SEND MORE DATA!");
            [self parseBytes:[self.source getData]];
        }
	}
	if ((self.bufferCount>1)&&(self.bufferCount == self.callbackCount)){ 
        if (self.flushing==FALSE){
            [self finished];
        }
	}
}


void propertyChangeCallback(void *data, AudioQueueRef inAQ, AudioQueuePropertyID inID)
{
	if (inID == kAudioQueueProperty_IsRunning){
		NSLog(@"STREAMER - propertyChangeCallback: kAudioQueueProperty_IsRunning"); //1634824814
	}
    else{ NSLog(@"STREAMER - propertyChangeCallback: not running"); }
}


//String reference: http://developer.apple.com/mac/library/documentation/Cocoa/Conceptual/Strings/Articles/formatSpecifiers.html
void propertyListenerCallback(void *inClientData, AudioFileStreamID inAudioFileStream, AudioFileStreamPropertyID inPropertyID, UInt32 *ioFlags)
{
	NSUInteger propID = (NSUInteger)inPropertyID;
	NSLog(@"STREAMER - propertyListenerCallback: %i", propID);
	Streamer *self = (Streamer *)inClientData;
	
	if (inPropertyID == kAudioFileStreamProperty_ReadyToProducePackets){
		NSLog(@"ALL SET TO GO! %lu", inPropertyID); //all metadata of the file is acquired
        self.source.used = TRUE;
		[self.delegate changePlayState];
		
		/* here we are getting the audio format and putting it into the 'asbd' struct */
		UInt32 dataSize = sizeof(AudioStreamBasicDescription);
		AudioStreamBasicDescription asbd; //this is a struct that holds info about the file
		AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataFormat, &dataSize, &asbd);
        if (asbd.mFormatID==kAudioFormatMPEG4AAC){ //AAC
            self.source.format = FileFormatM4A;
        }
        else{
            NSLog(@"FORMAT ID: %lu, MP3!!", asbd.mFormatID); //MP3
            self.source.format = FileFormatMP3;
        }

		/* open up a new queue and set it to self's queue property */
		AudioQueueRef playQueue;
		AudioQueueNewOutput(&asbd, AQOutputCallback, self, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &playQueue);
		self.queue = playQueue;
//		[self.delegate changePlayState];
		
		AudioQueueAddPropertyListener(self.queue, kAudioQueueProperty_IsRunning, propertyChangeCallback, self); //add property listener
	}
	else { NSLog(@"not ready yet: %lu", inPropertyID); }
}

void packetCallback(void *inClientData, UInt32 inNumberBytes, UInt32 inNumberPackets, const void *inInputData, AudioStreamPacketDescription *inPacketDescriptions)
{
	NSLog(@"STREAMER - packetCallback: %lu packets, %lu bytes", inNumberPackets, inNumberBytes);
	Streamer *self = (Streamer *)inClientData;
	
	AudioQueueBufferRef bufferRef;
    
//	AudioQueueAllocateBuffer(self.queue, inNumberBytes, &bufferRef); //this version didn't work.  not sure why.  have to use the one below.
	AudioQueueAllocateBufferWithPacketDescriptions(self.queue, inNumberBytes, inNumberPackets, &bufferRef); //allocate a buffer the size of the received bytes
	
	memcpy(bufferRef->mAudioData, inInputData, inNumberBytes);
	bufferRef->mAudioDataByteSize = inNumberBytes; /* * * before you added this line, the buffer wouldn't enqueue * * */
	
	memcpy(bufferRef->mPacketDescriptions, inPacketDescriptions, sizeof(AudioStreamPacketDescription)*inNumberPackets);
	bufferRef->mPacketDescriptionCount = inNumberPackets;
	

	if (self.readyToAcceptPackets==TRUE){
		OSStatus status = AudioQueueEnqueueBuffer(self.queue, bufferRef, 0, NULL);
		if (status == noErr){ 
			self.bufferCount++;
            self.flushing = FALSE;
			NSLog(@"STREAMER - BUFFER ENQUEUED: %d", self.bufferCount);
        }
		else { 
            NSLog(@"STREAMER - COULD NOT ENQUEUE BUFFER!"); 
//            [self.source rollback];
        }
	}
	
	if (self.isRunning==FALSE){
		OSStatus status = AudioQueueStart(self.queue, NULL);
		if (status == noErr){
			self.isRunning = TRUE;
			NSLog(@"STREAMER - QUEUE STARTED");
		}
		else { NSLog(@"STREAMER - COULDN'T START THE QUEUE!"); }
	}
}

@implementation Streamer
@synthesize fileStream;
@synthesize queue;
@synthesize isRunning;
@synthesize bufferCount;
@synthesize callbackCount;
@synthesize delegate;
@synthesize byteOffset;
@synthesize readyToAcceptPackets;
@synthesize flushing;
@synthesize source;

+ (void)initialize
{
	NSLog(@"Streamer: initialize");
//	AudioSessionInitialize(NULL, NULL, interruptionListener, self);
//	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
//	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
}

- (id)init
{
	NSLog(@"Streamer - init");
	self = [super init];
	if (self){
        falseFinish = FALSE;
        flushing = FALSE;
        AudioSessionInitialize(NULL, NULL, interruptionListener, self);
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);

		isRunning = FALSE;
		readyToAcceptPackets = FALSE;
	}
	return self;
}

- (void)dealloc
{
	NSLog(@"Streamer - DEALLOC");
    AudioQueueStop(self.queue, false); //calling 'false' here flushes the AudioQueue so you don't have to call 'Flush' later.  it's also a smoother transition
	AudioQueueDispose(self.queue, true);
	AudioFileStreamClose(self.fileStream);

	fileStream = nil;
	queue = nil;
	delegate = nil;
	AudioSessionSetActive(false);
	if (source){ 
        source.delegate = nil;
        [source release];
        source = nil;
    }
    [super dealloc];
}

//this is only called when starting a new stream NOT when resuming from a pause.
//resuming from a pause is done with: - (void)resume
- (void)play
{
	NSLog(@"Streamer: play");
	AudioSessionSetActive(true);
//	AudioFileStreamOpen(self, propertyListenerCallback, packetCallback, 0, &fileStream); //open the file stream
	AudioFileStreamOpen(self, propertyListenerCallback, packetCallback, kAudioFileMPEG4Type, &fileStream); //open the file stream
    
    
//    kAudioFileAAC_ADTSType
	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
	AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
	bufferCount = 0; callbackCount = 0;
	readyToAcceptPackets = TRUE;
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkDataSize) userInfo:nil repeats:NO]; 
}

- (void)pause
{
	NSLog(@"Streamer: pause");
    if (timer!=nil){
        [timer invalidate];
        timer = nil;
    }
    isRunning = FALSE;
	AudioQueuePause(queue);
}

- (void)resume
{
	NSLog(@"Streamer: resume");
    isRunning = TRUE;
	AudioQueueStart(queue, NULL);
    if (timer==nil){
//        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(playBackTimer) userInfo:nil repeats:YES];
        timer = [NSTimer scheduledTimerWithTimeInterval:kUpdateFreq target:self selector:@selector(playBackTimer) userInfo:nil repeats:YES];
    }
    if (falseFinish==TRUE){
        [self parseBytes:[self.source getData]];
        falseFinish = FALSE;
    }
}
/*- (void)stop
{
	NSLog(@"Streamer: stop");
	if (isRunning==TRUE){
		NSLog(@"checkpoint1");
		AudioQueuePause(self.queue);
		AudioQueueFlush(self.queue);
		AudioQueueStop(self.queue, true); //true here because we want the audio to stop immediately
		NSLog(@"checkpoint2");
				
		AudioQueueDispose(self.queue, true); self.queue = nil;
		
		AudioFileStreamClose(fileStream); self.fileStream = NULL;
		callbackCount = 0; bufferCount = 0;
		isRunning = FALSE;
		AudioSessionSetActive(false);
	}
} */

- (void)clear
{
    isRunning = FALSE;
    [self pause];
    [self reset:TRUE];
    [source flush];
    [self.source reset];
}

- (void)end
{
    [self clear];
    [delegate fileFinished];
}

- (void)finished
{
    if (source.urlConnection==nil){
        NSLog(@"STERAMER: Conventional Finish");
        [self.source reset];
//        [self clear];
//        [delegate fileFinished];
        
        //Have to add some buffer time here because the last few bytes need to play out before clearing out the player and starting the next file.
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(end) userInfo:nil repeats:NO];
    }
    else{
        NSLog(@"STERAMER: FALSE FINISH - Ran out of data");
        falseFinish = TRUE;

        //FALSE FINISH - Ran out of data
        [self pause];
        [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(resume) userInfo:nil repeats:NO];
    }
}

- (void)parseBytes:(NSData *)data
{
    NSLog(@"STREAMER - parse bytes");
	AudioFileStreamParseBytes(fileStream, data.length, data.bytes, 0);
}

- (void)reset:(BOOL)reset
{
	//this basically just resets everything.  kills the queue, closes the file stream, and restarts everything by calling [self play]
	NSLog(@"STREAMER - reset");
	AudioQueueStop(self.queue, false); //calling 'false' here flushes the AudioQueue so you don't have to call 'Flush' later.  it's also a smoother transition
	AudioQueueDispose(self.queue, true);
	AudioFileStreamClose(self.fileStream);
	isRunning = FALSE;
	readyToAcceptPackets = FALSE;
    if (reset==TRUE){
        [self play];
    }
}

- (void)seekto:(int)offset
{
    
    NSLog(@"STREAMER - seekTo:%d", offset);
    [self pause]; //this kills the timer too.
    flushing = TRUE;
    
    self.source.leftoff = offset;
    double i = (offset/self.source.delta);
    i = round(i);
    int index = (int)i;
    self.source.index = index;
    
    AudioQueueReset(self.queue);
    AudioQueueStart(self.queue, NULL);
    
//    UInt32 dataSize = sizeof(AudioStreamBasicDescription);
//    AudioStreamBasicDescription asbd; //this is a struct that holds info about the file
//    AudioFileStreamGetProperty(self.fileStream, kAudioFileStreamProperty_DataFormat, &dataSize, &asbd);
//    if (asbd.mFormatID==kAudioFormatMPEG4AAC){ //AAC
//        self.source.format = FileFormatM4A;
//    }
//    else{
//        NSLog(@"FORMAT ID: %lu, MP3!!", asbd.mFormatID); //MP3
//        self.source.format = FileFormatMP3;
//    }
//    
//    /* open up a new queue and set it to self's queue property */
//    AudioQueueRef playQueue;
//    AudioQueueNewOutput(&asbd, AQOutputCallback, self, CFRunLoopGetCurrent(), kCFRunLoopCommonModes, 0, &playQueue);
//    self.queue = playQueue;
//    AudioQueueAddPropertyListener(self.queue, kAudioQueueProperty_IsRunning, propertyChangeCallback, self); //add property listener

    
    
    NSLog(@"STREAMER: seekto - check 1");
    [self parseBytes:[self.source getData]];
    NSLog(@"STREAMER: seekto - check 2");
    
    if (timer==nil){ //restart the timer
//        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(playBackTimer) userInfo:nil repeats:YES];
        timer = [NSTimer scheduledTimerWithTimeInterval:kUpdateFreq target:self selector:@selector(playBackTimer) userInfo:nil repeats:YES];
    }
}

/*
- (void)checkDataSize
{
	int minDataSize = 200000; //200k for standard situations
	if (checkDataCount>=10) { minDataSize = 300000; } //stretch it out for slow connections
	if (checkDataCount>=20) { minDataSize = 400000; }
	if (checkDataCount==20){
		UIAlertView *slowConnectionAlert = [[UIAlertView alloc] initWithTitle:@"Slow Connection" message:@"the connection is slow right now.  please be patient while the data downloads." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
		[slowConnectionAlert show]; [slowConnectionAlert release];
	}
    if (source.bytes.length > minDataSize){
        NSLog(@"STREAMER - checkDataSize: %@ -- enough bytes: %d", source.name, source.bytes.length);
        [self parseBytes:[source getData]];
        checkDataCount = 0;
        [delegate playbackStarted];
        if (timer==nil){
            timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(playBackTimer) userInfo:nil repeats:YES];
        }
    }
    else{
        NSLog(@"STREAMER - checkDataSize: %@ -- not enough bytes: %d", source.name, source.bytes.length);
        checkDataCount++;
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkDataSize) userInfo:nil repeats:NO]; 
    }
}
 */

- (void)startPlayback
{
    [self parseBytes:[self.source getData]];
    checkDataCount = 0;
    [delegate playbackStarted];
    if (timer==nil){
//        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(playBackTimer) userInfo:nil repeats:YES];
        timer = [NSTimer scheduledTimerWithTimeInterval:kUpdateFreq target:self selector:@selector(playBackTimer) userInfo:nil repeats:YES];
    }
}

- (void)checkDataSize
{
	int minDataSize = 200000; //200k for standard situations
	if (checkDataCount>=10) { minDataSize = 300000; } //stretch it out for slow connections
	if (checkDataCount>=20) { minDataSize = 400000; }
	if (checkDataCount==20){
		UIAlertView *slowConnectionAlert = [[UIAlertView alloc] initWithTitle:@"Slow Connection" message:@"the connection is slow right now.  please be patient while the data downloads." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
		[slowConnectionAlert show]; [slowConnectionAlert release];
	}
    if (source.full==TRUE){
        NSLog(@"STREAMER - checkDataSize: %@ -- enough bytes: %d", source.name, source.bytes.length);
        [self startPlayback];
    }
    else{
        if (source.bytes.length > minDataSize){
            NSLog(@"STREAMER - checkDataSize: %@ -- enough bytes: %d", source.name, source.bytes.length);
            [self startPlayback];
        }
        else{
            NSLog(@"STREAMER - checkDataSize: %@ -- not enough bytes: %d", source.name, source.bytes.length);
            checkDataCount++;
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkDataSize) userInfo:nil repeats:NO]; 
        }
    }
}


- (void)playBackTimer
{
    NSString *running = @"YES";
    if (isRunning==FALSE){ //some files need more data to be pushed in before they start playing. This covers for that.
        running = @"NO";
        [self parseBytes:[source getData]];
    }
    NSLog(@"STREAMER - playBackTimer: RUNNING = %@", running);
    [self.source incrementIndex];
}


@end
