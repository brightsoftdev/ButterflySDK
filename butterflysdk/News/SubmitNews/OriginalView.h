//
//  OriginalView.h
//  butterflyradio
//
//  Created by Denny Kwon on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.


#import <UIKit/UIKit.h>
#import "Globals.h"

@protocol OriginalViewDelegate <NSObject>
- (void)launchCamera;
@end

@interface OriginalView : UIView <UITextFieldDelegate, UITextViewDelegate>{
    
    UITextField *titleField;
    UITextField *authorField;
    UITextView *contentField;
    UILabel *titleLabel;
    
    UIButton *btn_selectImg;
    UIToolbar *doneToolbar; //this is the toolbar that lies right above the keyboard
    
    UIImageView *image;
    id delegate;
}

@property (assign) id delegate;
@property (retain, nonatomic) UILabel *titleLabel;
@property (retain, nonatomic) UIImageView *image;
@property (retain, nonatomic) UITextField *titleField;
@property (retain, nonatomic) UITextField *authorField;
@property (retain, nonatomic) UITextView *contentField;
@property (retain, nonatomic) UIButton *btn_selectImg;
@end
