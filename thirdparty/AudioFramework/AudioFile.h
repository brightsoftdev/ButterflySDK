//  AudioFile.h
//  Audio
//  Created by Denny Kwon on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.


#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


typedef enum {
    FileFormatMP3 = 0,
    FileFormatM4A,
    FileFormatNeither,
} FileFormat ;

@protocol AudioFileDelegate <NSObject>
- (void)fileFailed:(int)index;
- (void)fileSize:(NSUInteger)s;
- (void)progressUpdate:(int)s;
- (void)almostDone;
- (void)skip;
@end

#define kFileMax 15

@interface AudioFile : NSObject {
    
    NSString *url;
    NSString *author;
    NSString *name;
    NSString *fileIndex; //position in the array
    NSString *image;
    NSString *link;
    NSString *date;
    NSString *description;
    NSString *thread;
    NSArray *tags;
    
    NSMutableData *bytes;
    NSURLConnection *urlConnection;
    
    FileFormat format;
    int leftoff;
    int playbacks;
    BOOL ad;
    BOOL used; //tracks whether the file has been played or not
    BOOL queueNext;
    BOOL playing;
    BOOL full; //TRUE when all data is downloaded or fetched from file
    
    id delegate;
    
    NSTimeInterval duration;
    double delta; // delta = total bytes / seconds.
    int index;
}

@property (nonatomic) int playbacks;
@property (nonatomic) int index;
@property (nonatomic) int leftoff;
@property (nonatomic) double delta;
@property (nonatomic) BOOL ad;
@property (nonatomic) BOOL used;
@property (nonatomic) BOOL queueNext;
@property (nonatomic) BOOL playing;
@property (nonatomic) BOOL full;
@property (nonatomic) FileFormat format;
@property (copy, nonatomic) NSString *thread;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *author;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *fileIndex;
@property (copy, nonatomic) NSString *image;
@property (copy, nonatomic) NSString *link;
@property (copy, nonatomic) NSString *date;
@property (copy, nonatomic) NSString *description;
@property (copy, nonatomic) NSArray *tags;
@property (retain, nonatomic) NSMutableData *bytes;
@property (retain, nonatomic) NSURLConnection *urlConnection;
@property (nonatomic) NSTimeInterval duration;
@property (assign) id delegate;
- (NSMutableDictionary *)getFileInfo;
- (NSData *)getData;
- (void)downloadData;
- (void)flush;
- (NSString *)createFilePath:(NSString *)fileName;
- (BOOL)checkSavedFiles;
- (void)calculateFileDuration:(NSString *)filePath;
- (void)incrementIndex;
- (void)reset;
@end
