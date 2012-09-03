//
//  RecordViewController.m
//  butterflyradio
//
//  Created by Denny Kwon on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecordViewController.h"

@interface RecordViewController ()

@end

static NSString *play = @"play";
static NSString *stop = @"stop";
static NSString *record = @"record";
static NSString *submit = @"submit";
static NSString *fileName = @"track.m4a";
static NSString *clear = @"clear";

@implementation RecordViewController
@synthesize upload;
@synthesize station;
@synthesize thread;

- (id)initWithManager:(ButterflyManager *)mgr
{
    self = [super initWithManager:mgr];
    if (self) {
        state = StateInactive;
        self.title = @"Record";   
        self.tabBarItem.image = [UIImage imageNamed:@"tab_record.png"];
        timeLeft = kTimeLimit;
        
        //remove any old files that were left in the cache:
        NSString *filepath = [self createFilePath:fileName];
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filepath error:&error]; //this removes files
        if (error){
            
        }
        
        recordSettings = [[NSMutableDictionary alloc] init];
        [recordSettings setObject:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey: AVFormatIDKey];
//        [recordSettings setObject:[NSNumber numberWithInt:kAudioFormatMPEGLayer3] forKey: AVFormatIDKey]; //this is unsupported for some reason meaning iPhone CANNOT record to MP3
        
//        [recordSettings setObject:[NSNumber numberWithFloat:441000.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithFloat:16000.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
        
//        [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:6400] forKey:AVEncoderBitRateKey];
        
//        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithInt:32] forKey:AVLinearPCMBitDepthKey];
        
        [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
    }
    return self;
}

- (void)dealloc
{
    self.thread = nil;
    [recordSettings release];
//    [recorder release];
    [loading release];
    [progress release];
    [station release];
    if (timer){ [timer invalidate]; }
    if (record){
        [recorder release];
    }
    if (audioPlayer){
        [audioPlayer release];
    }
    if (upload){
        [upload release];
    }
    [super dealloc];
}

- (void)loadView
{
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    UIView *view = [[UIView alloc] initWithFrame:appFrame];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kMainBackground]];
    
    ToolBar *toolbar = [[ToolBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.delegate = self;
    
    UIBarButtonItem *submit = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(submit)];
    UIBarButtonItem *clear = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearBtnPressed)];
    toolbar.items = [NSArray arrayWithObjects:[toolbar.items objectAtIndex:0], [toolbar.items objectAtIndex:1], clear, submit, nil];
    [submit release];
    [clear release];
    [view addSubview:toolbar];
    [toolbar release];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, toolbar.frame.size.height, appFrame.size.width, 25)];
    titleLabel.backgroundColor = [UIColor grayColor];
    titleLabel.text = [NSString stringWithFormat:@"   record: %@", station.name];
    titleLabel.textAlignment = UITextAlignmentLeft;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:kFont size:16.0f];
    [view addSubview:titleLabel];
    [titleLabel release];
    
    appFrame.origin.y = toolbar.frame.size.height+titleLabel.frame.size.height;
    appFrame.size.height -= appFrame.origin.y;
    recordingView = [[RecordView alloc] initWithFrame:appFrame];
    recordingView.delegate = self;
    recordingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kMainBackground]];
    [view addSubview:recordingView];
    
    appFrame.origin.y = 0.0f;
    loading = [[LoadingIndicator alloc] initWithFrame:appFrame];
    loading.titleLabel.text = @"Uploading File...";
    [loading hide];
    
    progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    CGFloat w = loading.darkScreen.frame.size.width-30;
    progress.frame = CGRectMake(0.5*(loading.frame.size.width-w), 180, w, 10);
    [loading addSubview:progress];
    [view addSubview:loading];
    
    self.view = view;
    [view release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)exit
{
    if (state==StateInactive){
        [self dismissModalViewControllerAnimated:YES];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Currently Recording" message:@"Please stop the recording first." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (BOOL)checkFile
{
    BOOL file = FALSE;
    NSString *filePath = [self createFilePath:fileName];
    NSData *d = [NSData dataWithContentsOfFile:filePath];
    if (d){
        file = TRUE;
    }
    
    return file;

}

- (void)stopTimer
{
    if (timer!=nil){
        [timer invalidate];
        timer = nil;
    }
    recordingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kMainBackground]];
}

- (void)reset //this stops timers and changes colors back to normal. it does NOT erase a track or clear out text fields.
{
    [self stopTimer];
    recordingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kMainBackground]];
    if (recorder!=nil){
        if (recorder.recording==TRUE){
            NSLog(@"RESET: STOP RECORDING");
            [recorder stop];
            
            recorder.delegate = nil; [recorder release]; recorder = nil;
            [recordingView activateUploadButton];
        }
    }
    if (audioPlayer != nil){
        NSLog(@"RESET: STOP PLAYING");
        [audioPlayer stop];
        audioPlayer.delegate = nil; [audioPlayer release]; audioPlayer = nil;
    }
    state = StateInactive;
}

- (void)startOver //this is a total reset - it removes any recorded track
{
    [self reset];
    [recordingView clear]; //clear out the text from the view;
    timeLeft = kTimeLimit;
    NSString *filepath = [self createFilePath:fileName];
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:filepath error:&error]; //this removes files
    if (error){
        
    }
}



- (NSString *)createFilePath:(NSString *)fileName
{
	fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"+"];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *docPath = [paths objectAtIndex:0];
	NSString *filePath = [docPath stringByAppendingPathComponent:fileName];
	NSLog(@"filepath = %@", filePath);
	return filePath;
}

- (void)timerMethod
{
    timeLeft--;
    if (timeLeft<=30){
        recordingView.backgroundColor = [UIColor redColor];
        if (timeLeft==0){ [self reset]; }
    }
    
    float m = timeLeft/60;
    int mins = (int)m;
    
    int s = timeLeft%60;
    NSString *seconds = nil;
    if (s<10){
        seconds = [NSString stringWithFormat:@"0%d", s];
    }
    else{
        seconds = [NSString stringWithFormat:@"%d", s];
    }
    recordingView.timeLabel.text = [NSString stringWithFormat:@"time - %d:%@", mins, seconds];
}

- (void)uploadTrack
{
    NSLog(@"RECORD VIEW CONTROLLER - UPLOAD STRING: %@", self.upload);
    ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:self.upload]] autorelease];
    request.delegate = self;
    
//    [request setFile:[self createFilePath:fileName] forKey:@"file"];
    
    //artificially setting the MIME type here. this TRICKS the Android into thinking it's streaming an MP3 when it's really streaming an AAC - it works.
    [request setFile:[self createFilePath:fileName] withFileName:@"track.mp4" andContentType:@"audio/mpeg" forKey:@"file"];
    
    [request setUploadProgressDelegate:progress];
    [request setPostValue:station.name forKey:@"stationName"];
    [request setPostValue:recordingView.authorField.text forKey:@"author"];
    [request setPostValue:recordingView.titleField.text forKey:@"title"];
    
    if ([recordingView.tagsField.text length]==0){
        [request setPostValue:@"none" forKey:@"tags"];
    }
    else {
        [request setPostValue:recordingView.tagsField.text forKey:@"tags"];
    }
    
    if ([recordingView.commentField.text length]==0){
        [request setPostValue:recordingView.commentField.text forKey:@"none"];
    }
    else {
        if ([recordingView.commentField.text isEqualToString:@"description (optional)"]==TRUE){
            [request setPostValue:@"none" forKey:@"description"];
        }
        else {
            [request setPostValue:recordingView.commentField.text forKey:@"description"];
        }
    }
    
    [request setPostValue:station.unique_id forKey:@"station"];
    if (self.thread!=nil){
        [request setPostValue:self.thread forKey:@"replyTo"];
    }
    
    NSString *admins = @"";
    for (NSString *admin in station.admins){
        if ([admin length]>1){
            NSString *entry = [NSString stringWithFormat:@"%@,", admin];
            admins = [admins stringByAppendingString:entry];
        }
    }
    admins = [admins substringToIndex:[admins length]-1]; //remove last comma
    [request setPostValue:admins forKey:@"admins"];
    
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [request setPostValue:appDelegate.host.email forKey:@"sender"];

    [request setPostValue:self.butterflyMgr.host.email forKey:@"sender"];

    [request startAsynchronous];
    [loading show];
}

- (void)submit
{
    if (recorder==nil){ //only works if not recording
        NSString *filePath = [self createFilePath:fileName];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        if (fileData){
//            if ([recordingView.tagsField.text length]==0 || [recordingView.titleField.text length]==0 || [recordingView.commentField.text length]==0 || [recordingView.authorField.text length]==0){
            
            if ([recordingView.titleField.text length]==0 || [recordingView.authorField.text length]==0){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Please fill in the Title and From all fields." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
            else{
                if (req!=nil){
                    req.delegate = nil;
                    [req cancel];
                    [req release];
                }
                
                req = [[BRNetworkOp alloc] initWithAddress:@"http://www.butterflyradio.com/api/upload?type=track" parameters:nil];
                req.delegate = self;
                [req setHttpMethod:@"GET"];
                [req sendRequest];
                [loading show];
            }
            
        }
        else{ //show no file alert
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No File" message:@"Please record an audio file to submit." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
    else {
        NSLog(@"STILL RECORDING! CANNOT SEND");
    }
}

- (void)updateButton
{
    
}

- (void)clearBtnPressed
{
    if (state==StateInactive){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are You Sure?" message:@"This will permanently erase any recorded track." delegate:self cancelButtonTitle:@"yes" otherButtonTitles:@"no", nil];
        [alert show];
        [alert release];
    }
}

- (void)startRecording
{
    NSLog(@"START RECORDER! ");
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    NSString *filePath = [self createFilePath:fileName];
    
    if (recorder==nil){
        NSLog(@"START RECORDER: INSTANTIATE RECORDER");
        NSError *error = nil;
        recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:filePath] settings:recordSettings error:&error];
        if (error){
            NSLog(@"ERROR: %@", [error localizedDescription]);
        }
        else{
            recorder.delegate = self;
            if ([recorder prepareToRecord] == TRUE){ 
                [self stopTimer];
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"Recording" object:nil]];
                [recorder record]; 
                NSLog(@"recording");
                recordingView.backgroundColor = [UIColor blueColor];
                
                timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
            }
            else {
                int errorCode = CFSwapInt32HostToBig ([error code]); 
                NSLog(@"Recording Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode); 
            }
        }
    }
    [recordingView.mainButton setBackgroundImage:[UIImage imageNamed:@"btStop@2x.png"] forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kInterruptionNotification object:nil]];
    state = StateRecording;
}

- (void)playFile
{
    NSString *filePath = [self createFilePath:fileName];
    NSData *dataSize = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
    NSLog(@"playing: %d", dataSize.length);
    if (dataSize.length>0){
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        if (audioPlayer==nil){
            NSError *error;
            audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:&error];
            audioPlayer.delegate = self;
            audioPlayer.numberOfLoops = 0;
        }
        [audioPlayer play];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No File" message:@"There is no file recorded." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)mainbtnPressed
{
    if (state==StateInactive){
        NSLog(@"mainbtnPressed: INACTIVE");
        if ([self checkFile]==FALSE){ // start the recorder
            [self startRecording];
        }
        else{ //play back audio
            NSLog(@"mainbtnPressed: PLAY BACK");
            if (audioPlayer==nil){ [self playFile]; } //start from beginning
            else{ [audioPlayer play]; } //resume from pause
            [recordingView.mainButton setBackgroundImage:[UIImage imageNamed:@"btPause@2x.png"] forState:UIControlStateNormal];
            state = StatePlaying;
        }
    }
    else{
        if (state==StateRecording){
            NSLog(@"mainbtnPressed: RECORDING - STOP");
            [self reset];
            [recordingView.mainButton setBackgroundImage:[UIImage imageNamed:@"btPlay@2x.png"] forState:UIControlStateNormal];
        }
        else{
            if (state==StatePlaying){
                NSLog(@"mainbtnPressed: PLAYING - PAUSE");
                [recordingView.mainButton setBackgroundImage:[UIImage imageNamed:@"btPlay@2x.png"] forState:UIControlStateNormal];
                [audioPlayer pause];
                state = StateInactive;
            }
        }
    }
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"alertView clickedButtonAtIndex: %d", buttonIndex);
    if (buttonIndex==0){
        [self startOver];
        [recordingView.mainButton setBackgroundImage:[UIImage imageNamed:@"btRecord@2x.png"] forState:UIControlStateNormal];
    }
}


- (void)requestData:(NSArray *)pkg //returns [address, data]
{
    if (pkg!=nil){
        NSString *json = [[NSString alloc] initWithData:[pkg objectAtIndex:1] encoding:NSUTF8StringEncoding];
        NSDictionary *d = [json JSONValue];
        if (d==nil){
            [req sendRequest];
        }
        else{
            d = [d objectForKey:@"results"];
            NSString *confirmation = [d objectForKey:@"confirmation"];
            if ([confirmation isEqualToString:@"success"]){
                self.upload = [d objectForKey:@"upload string"];
                [self uploadTrack];
            }
            else{
                [loading hide];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error. Please try again." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        }
    }
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"audioRecorderDidFinishRecording:");
    
    [recordingView activateUploadButton];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_radio.png"]];
    
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"audioRecorderEncodeErrorDidOccur: %@", [error localizedDescription]);
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_radio.png"]];
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
    NSLog(@"audioRecorderBeginInterruption:");
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_radio.png"]];
    
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withFlags:(NSUInteger)flags
{
    NSLog(@"audioRecorderEndInterruption:");
}


#pragma mark -  AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"audioPlayerDidFinishPlaying:");
    [self stopTimer];
    [audioPlayer stop];
    
    [self reset];
    [recordingView.mainButton setBackgroundImage:[UIImage imageNamed:@"btPlay@2x.png"] forState:UIControlStateNormal];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"audioPlayerDecodeErrorDidOccur: %@", [error localizedDescription]);
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    NSLog(@"audioRecorderEndInterruption:");
    [self stopTimer];
    [audioPlayer pause];
    
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags
{
    NSLog(@"audioPlayerEndInterruption:");
    [audioPlayer play];
    
}


#pragma mark - ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *json = [request responseString];
    NSLog(@"RECORD VIEW CONTROLLER - requestFinished: %@", json);
    
    [loading hide];
    
    NSDictionary *d = [json JSONValue];
    if (d==nil){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error. Please try again." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else{
        d = [d objectForKey:@"results"];
        NSLog(@"%@", [d description]);
        NSString *confirmation = [d objectForKey:@"confirmation"];
        if ([confirmation isEqualToString:@"success"]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Announcement Submitted" message:@"Your announcement was submitted. An admin will review it shortly. Thank you." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
            [self dismissModalViewControllerAnimated:YES];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error with the submisssion. Please try again" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        
//        [self startOver];

    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"RECORD VIEW CONTROLLER - requestFailed: %@", [error localizedDescription]);
    [loading hide];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error. Please try again." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
