//
//  AudioFile.m
//  Audio
//
//  Created by Denny Kwon on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioFile.h"
#include <sys/xattr.h>

@implementation AudioFile

@synthesize url;
@synthesize author;
@synthesize name;
@synthesize fileIndex;
@synthesize image;
@synthesize playbacks;
@synthesize bytes;
@synthesize format;
@synthesize urlConnection;
@synthesize ad;
@synthesize used;
@synthesize delegate;
@synthesize leftoff;
@synthesize duration;
@synthesize delta;
@synthesize index;
@synthesize queueNext;
@synthesize playing;
@synthesize link;
@synthesize date;
@synthesize tags;
@synthesize full;
@synthesize description;
@synthesize thread;

- (id)init
{
    self = [super init];
    if (self){
        playing = FALSE;
        used = FALSE;
        queueNext = FALSE;
        full = FALSE;
        index = 0;
        format = FileFormatMP3;
    }
    return self;
}

- (NSMutableDictionary *)getFileInfo
{
    NSLog(@"AUDIO FILE - getFileInfo");
    
    NSString *u = nil;
    if (url==nil){ u = @"none"; }
    else{ u = [NSString stringWithFormat:@"%@", url]; }
    
    NSString *n = nil;
    if (name==nil){ n = @"none"; }
    else{ n = [NSString stringWithFormat:@"%@", name]; }
    
    NSString *a = nil;
    if (author==nil){ a = @"none"; }
    else{ a = [NSString stringWithFormat:@"%@", author]; }
    
    NSString *i = nil;
    if (fileIndex==nil){ i = @"none"; }
    else{ i = [NSString stringWithFormat:@"%@", fileIndex]; }
    
    NSString *img = nil;
    if (image==nil){ img = @"none"; }
    else{ img = [NSString stringWithFormat:@"%@", image]; }
    
    NSString *l = nil;
    if (link==nil){ l = @"none"; }
    else{ l = [NSString stringWithFormat:@"%@", link]; }
    
    NSString *k = nil;
    if (self.ad==TRUE){ k = @"yes"; }
    else{ k = @"no"; }
    
    NSString *dt = nil;
    if (self.date==nil){
        dt = @"none";
    }
    else {
        dt = [NSString stringWithFormat:@"%@", date];
    }

    
    NSMutableDictionary *d = [NSMutableDictionary dictionary];
    [d setObject:dt forKey:@"date"];
    [d setObject:u forKey:@"url"];
    [d setObject:n forKey:@"name"];
    [d setObject:a forKey:@"author"];
    [d setObject:i forKey:@"index"];
    [d setObject:img forKey:@"image"];
    [d setObject:l forKey:@"link"];
    [d setObject:k forKey:@"ad"];
    return d;
}

- (BOOL)checkSavedFiles
{
    NSLog(@"AUDIO FILE: checkSavedFiles");
    BOOL found;
    
    if (self.ad==TRUE){
        found = FALSE;
    }
    else{
        NSString *filePath = [self createFilePath:self.url];
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data==nil){ NSLog(@"AUDIO FILE - NO SAVED FILE"); found = FALSE; }
        else{
            NSLog(@"AUDIO FILE - USING SAVED FILE");
            self.full = TRUE;
            found = TRUE;
            self.bytes = [NSMutableData dataWithData:data];
            if (playing){
                if (ad==FALSE){ [delegate fileSize:self.bytes.length]; }
            }
            
            [self calculateFileDuration:filePath];
        }
    }
    return found;
}

- (void)calculateFileDuration:(NSString *)filePath
{
    AudioFileID fileID;
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    OSStatus result = AudioFileOpenURL((CFURLRef)fileUrl, kAudioFileReadPermission, 0, &fileID);
    
    if (result==noErr){
        NSTimeInterval seconds;
        UInt32 propertySize = sizeof(seconds);
        
        result = AudioFileGetProperty (fileID, kAudioFilePropertyEstimatedDuration, &propertySize, &seconds);
        if (result==noErr){
            self.duration = seconds;
            self.delta = (self.bytes.length / self.duration);
            self.delta *= 0.5f;
            NSLog(@"AUDIO FILE - seconds=%f, delta=%.2f", self.duration, self.delta);
        }
        else{ NSLog(@"AUDIO FILE - ERROR: %ld", result); }
    }
}

- (void)downloadData
{
    if (urlConnection==nil){
        NSLog(@"AUDIO FILE - downloadData");
        NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        [req setTimeoutInterval:600];
        
        //    if (urlConnection!=nil) { [urlConnection release]; urlConnection = nil; }
        urlConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
        if (urlConnection==nil){ NSLog(@"AUDIO FILE - connnection failed"); } //FAIL
        else{
            if (bytes==nil){ bytes = [[NSMutableData alloc] init]; }
        }
    }
}

- (NSData *)getData
{
	int max; int offSet = 40000;
	if (format == FileFormatMP3){ offSet = 170000; }
	if (leftoff+offSet < bytes.length){ max = leftoff+offSet; }
	else { 
        max = bytes.length; 
    }
    NSLog(@"AUDIO FILE: getData - %d to %d", leftoff, max);
    
	NSRange range;
	range.location = leftoff;
	range.length = (max-leftoff);
	leftoff = max;
	return [bytes subdataWithRange:range];
}

- (void)incrementIndex
{
    //gets called every second during playback by the streamer.
    //the file then updates the player with current location.
    self.index++;
    int d = (index * delta);
    [delegate progressUpdate:d];
    
    double percentage = (self.index*self.delta)/self.bytes.length;
    NSLog(@"AUDIO FILE - incrementIndex: percentage = %.2f", percentage);
    
    if (percentage>1.05){ [delegate skip]; } //backup plan - just in case the normal 'file finished' doesn't get called.
    
    
    if (urlConnection==nil){ //only run this test when the download is complete, or the file is from cache
//        double almostDone = 0.75*(self.delta * self.duration);
        if (percentage>=0.8){
            if (queueNext==FALSE && urlConnection==nil){
                [delegate almostDone]; //get the next file ready
                queueNext = TRUE;
            }
        }
    }
}

- (void)flush
{
    NSLog(@"AUDIO FILE - flush");
    if (bytes!=nil){ [bytes release]; bytes = nil; }
    leftoff = 0;
}

- (void)dealloc
{
    NSLog(@"AUDIO FILE: %@ - dealloc", self.name);
    if (urlConnection != nil){ [urlConnection release]; urlConnection = nil; }
    self.thread = nil;
    if (bytes!=nil){ [bytes release]; }
    if (link!=nil){ [link release]; }
    if (date!=nil){ [date release]; }
    [url release];
    [author release];
    [name release];
    [fileIndex release];
    [image release];
    [tags release];
    [description release];
    [super dealloc];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

- (NSString *)createFilePath:(NSString *)fileName
{
	fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"+"];
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
	NSLog(@"AUDIO FILE - createFilePath: filepath = %@", filePath);
	return filePath;
}

- (void)reset
{
    if (urlConnection!=nil){ //this calls if the user skips over this file while it is still downloading;
        [urlConnection cancel];
        [urlConnection release];
        urlConnection = nil;
        
        if (bytes!=nil){ //data is only partially downloaded so release it and nil it out.
            [bytes release];
            bytes = nil;
        }
    }
    
    self.delegate = nil;
    queueNext = FALSE;
    playing = FALSE;
    self.ad = FALSE;
    self.full  = FALSE;
    leftoff = 0;
    index = 0;
}


#pragma mark - URLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"AUDIO PLAYER - connection didReceiveResponse: %@", [response MIMEType]);
    NSString *mimetype = [response MIMEType];
    if ([mimetype hasPrefix:@"audio"]==FALSE){
        [urlConnection cancel]; [urlConnection release]; urlConnection = nil;
        self.used = TRUE;
        [delegate fileFailed:[self.fileIndex intValue]];
        
        //Need to alert the player here that this file is corrupted (returning HTML) and cannot be accessed
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [bytes appendData:data];
    NSLog(@"- - - - - - - - connection didReceiveData: %d - - - - - - - - ", bytes.length);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"- - - - - - - - connectionDidFinishLoading: - - - - - - - - ");
    self.full = TRUE;
//    if (bytes.length>400000){
    if (bytes.length>1000){
        NSString *filePath = [self createFilePath:self.url];
        [self.bytes writeToFile:filePath atomically:YES];
        [self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:filePath]]; //this prevents files from being backed up on itunes and iCloud
        [self calculateFileDuration:filePath];
        if (self.ad==FALSE){
            
            //Check saved file size here.  If over 50 saves files, remove the earliest file.
///            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *docPath = [paths objectAtIndex:0];
            NSError *error = nil;
            NSArray *cache = (NSArray *)[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[NSBundle bundleWithPath:docPath] bundlePath] error:&error];
            if (error==nil){
                NSLog(@"AUDIO FILE: cached: %d %@", [cache count], [cache description]);
                if ([cache count]>kFileMax){
                    NSString *filepath = [self createFilePath:[cache objectAtIndex:0]];
                    [[NSFileManager defaultManager] removeItemAtPath:filepath error:&error]; //this removes files
                }
            }
        }
        else{ //remove ad from memory once the file length is calculated - we DON'T want to cache the ads!
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]; //this removes files
        }
    }
    
    [urlConnection cancel]; [urlConnection release]; urlConnection = nil;
    if (playing){
        if (ad==FALSE){
            [delegate fileSize:self.bytes.length];
        }
    }

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"connection didFailWithError: %@", [error localizedDescription]);
    [urlConnection cancel]; [urlConnection release]; urlConnection = nil;
    if (bytes!=nil){ [bytes release]; bytes = nil; }
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [req setTimeoutInterval:600];
    
    urlConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    if (urlConnection==nil){ NSLog(@"AUDIO FILE - connnection failed"); } //FAIL
    else{
        if (bytes==nil){ bytes = [[NSMutableData alloc] init]; }
    }

}






@end
