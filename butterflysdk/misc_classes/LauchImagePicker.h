//
//  LauchImagePicker.h
//  app
//
//  Created by Denny Kwon on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LauchImagePicker : NSOperation {
    id target;
    SEL action;
    UIImagePickerControllerSourceType source;
}

- (id)initWithTarget:(id)t action:(SEL)cbk sourceType:(UIImagePickerControllerSourceType)s;
@end
