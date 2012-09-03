//
//  ToolBar.h
//  frenchkiss
//
//  Created by Denny Kwon on 2/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.


#import <UIKit/UIKit.h>

@protocol ToolBarDelegate <NSObject>
- (void)exit;
- (void)showRadio;
@end

@interface ToolBar : UIToolbar {
    
    UILabel *titleLabel;
    id delegate;
}

@property (assign) id delegate;
@property (retain, nonatomic) UILabel *titleLabel;
@end
