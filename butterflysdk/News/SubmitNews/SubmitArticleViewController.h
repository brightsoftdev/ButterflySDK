//
//  SubmitArticleViewController.h
//  butterflyradio
//
//  Created by Denny Kwon on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ToolBar.h"
#import "ASIFormDataRequest.h"
#import "OriginalView.h"
#import "LinkView.h"
#import "LauchImagePicker.h"
#import "ButterflyViewController.h"


@interface SubmitArticleViewController : ButterflyViewController <ToolBarDelegate, UITextFieldDelegate, UITextViewDelegate, ASIHTTPRequestDelegate, BRNetworkOpDelegate, OriginalViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    
    Station *station;
    
    UIImageView *image;
    UIButton *btnSubmit;
    
    LoadingIndicator *loading;
    int mode; // 0=original, 1=link
    OriginalView *original;
    LinkView *linkView;
    BRNetworkOp *req;
    
    NSOperationQueue *queue;
    UIImagePickerController *imgPicker;
    NSString *ipAddress;
}

@property (retain, nonatomic) UIImagePickerController *imgPicker;
@property (retain, nonatomic) Station *station;
@property (copy, nonatomic) NSString *ipAddress;
@end


@interface UIImage (scale)
+ (UIImage*)imageWithImage:(UIImage*)img scaledToSize:(CGSize)newSize;
@end