//
//  LauchImagePicker.m
//  app
//
//  Created by Denny Kwon on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LauchImagePicker.h"

@implementation LauchImagePicker

- (id)initWithTarget:(id)t action:(SEL)cbk sourceType:(UIImagePickerControllerSourceType)s
{
    self = [super init];
    if (self){
        target = t;
        action = cbk;
        source = s;
    }
    return  self;
}

- (void)main
{
    NSLog(@"LAUNCH IMAGE PICKER:@");
    
    if (![self isCancelled]){
        UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
        imgPicker.sourceType = source;
        if (source==UIImagePickerControllerSourceTypeCamera){
            imgPicker.allowsEditing = YES;
            imgPicker.showsCameraControls = YES;
        }
        

        
//        UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 427)];
//        UIView *overlay = [[UIView alloc] initWithFrame:imgPicker.view.frame];
//        overlay.backgroundColor = [UIColor clearColor];
        
//        UIImageView *topBar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 57)];
////        topBar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"camtop.png"]];
//        topBar.image = [UIImage imageNamed:@"camtop.png"];
//        [overlay addSubview:topBar];
//        [topBar release];

//        UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, overlay.frame.size.height-50, 370, 50)];
//        bottomBar.backgroundColor = [UIColor whiteColor];
//        
//        UIButton *btnShoot = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        btnShoot.backgroundColor = [UIColor greenColor];
//        btnShoot.frame = CGRectMake(10, 10, 100, 30);
//        [btnShoot addTarget:imgPicker action:@selector(takePicture) forControlEvents:UIControlEventTouchUpInside];
//        
//        [bottomBar addSubview:btnShoot];
//        [overlay addSubview:bottomBar];
//        [bottomBar release];
        
//        imgPicker.cameraOverlayView = overlay;
//        [overlay release];
        
        [target performSelectorOnMainThread:action withObject:imgPicker waitUntilDone:NO];
        [imgPicker release];
    }
}


@end
