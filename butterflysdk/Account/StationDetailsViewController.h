//
//  StationDetailsViewController.h
//  butterflyradio
//
//  Created by Denny Kwon on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import <UIKit/UIKit.h>
#import "ButterflyViewController.h"
#import "DetailBackground.h"
#import "ASIFormDataRequest.h"
#import "LauchImagePicker.h"


@interface StationDetailsViewController : ButterflyViewController <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, ASIHTTPRequestDelegate, BRNetworkOpDelegate> {
    
    UIImageView *image;
    UITextView *descriptionField;
    
    UITextField *nameField;
    UITextField *tagsField;
    UILabel *categoryLabel;
    
    Station *station;
    UIPickerView *categoriesPicker;
    NSArray *categories;
    LoadingIndicator *loading;
    NSOperationQueue *queue;
    
    UIImagePickerController *imgPicker;
    NSData *newImgData;
    BRNetworkOp *req;
}

- (void)photoBtnPressed;
@property (retain, nonatomic) UIImagePickerController *imgPicker;
@property (retain, nonatomic) Station *station;
@property (retain, nonatomic) UITextField *nameField;
@property (retain, nonatomic) UITextField *tagsField;
@end
