//
//  DetailBackground.h
//  butterflyradio
//
//  Created by Denny Kwon on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"

@interface DetailBackground : UIView {
    
    UIButton *btnLabel;
    
}

@property (retain, nonatomic) UIButton *btnLabel;
+ (DetailBackground *)backgroundWithFrame:(CGRect)frame;
@end
