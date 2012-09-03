//
//  RecordViewController.h
//  butterflyradio
//
//  Created by Denny Kwon on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButterflyViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ASIFormDataRequest.h"
#import "RecordView.h"


typedef enum {
    ENC_AAC = 1,
    ENC_ALAC = 2,
    ENC_IMA4 = 3,
    ENC_ILBC = 4,
    ENC_ULAW = 5,
    ENC_PCM = 6,
} EncodingType;

typedef enum {
    StateInactive = 0,
    StateRecording,
    StatePlaying,
} State;

@interface RecordViewController : ButterflyViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate, ASIHTTPRequestDelegate, URLRequestDelegate, UIAlertViewDelegate> {
    
    AVAudioRecorder *recorder;
    AVAudioPlayer *audioPlayer;
    
    NSMutableDictionary *recordSettings;
    NSString *upload;
    RecordView *recordingView;
    int timeLeft;
    NSTimer *timer;
    LoadingIndicator *loading;
    UIProgressView *progress;
    Station *station;
    
    BRNetworkOp *req;
    State state;
    NSString *thread;
    
}

@property (retain, nonatomic) Station *station;
@property (copy, nonatomic) NSString *upload;
@property (copy, nonatomic) NSString *thread;
@end
