//
//  CreateStationViewController.h
//  butterflyradio
//
//  Created by Denny Kwon on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButterflyViewController.h"
#import "DetailBackground.h"


@protocol CreateStationDelegate <NSObject>
- (void)stationCreated;
@end

@interface CreateStationViewController : ButterflyViewController <URLRequestDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
    BRNetworkOp *req;
    LoadingIndicator *loading;
    Host *host;
    
    UITextField *nameField;
    UITextField *tagsField;
    UILabel *categoryLabel;
    UIPickerView *categoriesPicker;
    NSArray *categories;
}

@property (assign) id delegate;
@property (retain, nonatomic) UITextField *nameField;
@property (retain, nonatomic) UITextField *tagsField;
@property (retain, nonatomic) UILabel *categoryLabel;
@property (retain, nonatomic) Host *host;
@end
