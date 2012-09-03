//
//  RecordView.h
//  butterflyradio
//
//  Created by Denny Kwon on 4/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.


#import <UIKit/UIKit.h>
#import "ToolBar.h"
#import "Globals.h"

@protocol RecordViewDelegate <NSObject>
//- (void)btnPressed:(NSString *)btnTitle;
- (void)mainbtnPressed;
@end

#define kMaxTime @"time - 5:00"

@interface RecordView : UIView <UITextFieldDelegate, UITextViewDelegate, ToolBarDelegate> {
    
    id delegate;
    UITextField *authorField;
    UITextField *titleField;
    UITextField *tagsField;
    UITextView *commentField;
    UILabel *timeLabel;
    
    UIButton *mainButton;
    
}

@property (assign) id delegate;
@property (retain, nonatomic) UITextField *authorField;
@property (retain, nonatomic) UITextField *titleField;
@property (retain, nonatomic) UITextField *tagsField;
@property (retain, nonatomic) UITextView *commentField;
@property (retain, nonatomic) UIButton *mainButton;
@property (retain, nonatomic) UILabel *timeLabel;
- (void)activateUploadButton;
- (void)clear;
- (void)setBtnImage:(UIImage *)img;
@end
