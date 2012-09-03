//
//  InviteAdminViewController.h
//  butterflyradio
//
//  Created by Denny Kwon on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButterflyViewController.h"
#import "DetailBackground.h"


@interface InviteAdminViewController : ButterflyViewController <UITextFieldDelegate, URLRequestDelegate> {
    Station *station;
    UITextField *emailField;
    URLRequest *req;
    LoadingIndicator *loading;
}

@property (retain, nonatomic) Station *station;
@property (retain, nonatomic) UITextField *emailField;
@end
