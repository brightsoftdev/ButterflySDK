//
//  CommentViewController.h
//  butterflyradio
//
//  Created by Denny Kwon on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButterflyViewController.h"


@protocol CommentVCDelegate <NSObject>
- (void)resetComments:(NSDictionary *)reviews;
@end

@interface CommentViewController : ButterflyViewController <UITextFieldDelegate, BRNetworkOpDelegate, UITextViewDelegate> {
    
    UIView *top;
    UITextField *usernameField;
    UITextView *commentField;
    
    BRNetworkOp *req;
    Station *station;
    int rating;
    
    LoadingIndicator *loading;
    id delegate;
    int mode; //0=Station review, 1=Article review, 2=track review
    BOOL showStars;
}

@property (nonatomic) BOOL showStars;
@property (nonatomic) int mode;
@property (retain, nonatomic) Station *station;
@property (copy, nonatomic) NSString *uniqueID;
@property (assign) id delegate;
- (void)cancel;
- (void)btnTapped:(UIButton *)btn;
- (void)postComment;
@end
