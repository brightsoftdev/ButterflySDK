//
//  LinkView.h
//  butterflyradio
//
//  Created by Denny Kwon on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"

@interface LinkView : UIView <UITextFieldDelegate> {
    
    UITextField *titleField;
    UITextField *authorField;
    UITextField *contentField;
    
    UILabel *titleLabel;

}

@property (retain, nonatomic) UILabel *titleLabel;
@property (retain, nonatomic) UITextField *titleField;
@property (retain, nonatomic) UITextField *authorField;
@property (retain, nonatomic) UITextField *contentField;
@end
