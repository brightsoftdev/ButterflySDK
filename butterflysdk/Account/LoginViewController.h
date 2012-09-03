//
//  LoginViewController.h
//  butterflyradio
//
//  Created by Denny Kwon on 6/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButterflyViewController.h"
#import "HostViewController.h"
#import "RegisterViewController.h"

@interface LoginViewController : ButterflyViewController <BRNetworkOpDelegate, UIWebViewDelegate, RegisterViewControllerDelegate> {
    
    BRNetworkOp *req;
    LoadingIndicator *loading;
    UIWebView *theWebview;
    
    UILabel *titleLabel;
    UILabel *descriptionLabel;
    UIButton *btnGoogle;
    UIButton *btnYahoo;
    
    BOOL loginOnAppear;
    
}

@property (retain, nonatomic) UIWebView *theWebview;
@property (retain, nonatomic) UIButton *btnGoogle;
@property (retain, nonatomic) UIButton *btnYahoo;
@property (copy, nonatomic) NSString *url;
- (void)btnPressed:(UIButton *)btn;
@end
