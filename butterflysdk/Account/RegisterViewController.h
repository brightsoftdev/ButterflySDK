//
//  RegisterViewController.h
//  butterflyradio
//
//  Created by Denny Kwon on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailBackground.h"
#import "ButterflyViewController.h"

@protocol RegisterViewControllerDelegate <NSObject>
- (void)registrationComplete;
@end


@interface RegisterViewController : ButterflyViewController <UITextFieldDelegate, BRNetworkOpDelegate> {
    
    IBOutlet UILabel *descriptionLabel;
    UITextField *nameField;
    UITextField *emailField;
    BRNetworkOp *req;
    LoadingIndicator *loading;
    NSString *emailHost;
    BOOL clearCookies;
}

@property (assign) id delegate; //previous view controller
@property (copy, nonatomic) NSString *emailHost;
@property (retain, nonatomic) UITextField *nameField;
@property (retain, nonatomic) UITextField *emailField;
- (IBAction)registerBtnPressed:(UIButton *)btn;
- (IBAction)appstoreBtnPressed:(UIButton *)btn;
@end
