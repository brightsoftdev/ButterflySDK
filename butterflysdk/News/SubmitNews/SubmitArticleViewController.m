//
//  SubmitArticleViewController.m
//  butterflyradio
//
//  Created by Denny Kwon on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SubmitArticleViewController.h"

static NSString *file = @"picture.jpg";

@implementation UIImage (scale)
+ (UIImage*)imageWithImage:(UIImage*)img scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end

@interface SubmitArticleViewController ()

@end

@implementation SubmitArticleViewController
@synthesize station;
@synthesize imgPicker;
@synthesize ipAddress;

- (id)initWithManager:(ButterflyManager *)mgr
{
    self = [super initWithManager:mgr];
    if (self) {
        
        queue = [[NSOperationQueue alloc] init];
        mode = 0;
        self.ipAddress = @"0";
        
        NSString *filePath = [self createFilePath:file];
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]; //this removes files
    }
    return self;
}

- (void)dealloc
{
    [station release];
    [queue release];
    [image release];
    [btnSubmit release];
    [loading release];
    [original release];
    [imgPicker release];
    [ipAddress release];
    [linkView release];
    [super dealloc];
}

- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    frame.origin.y = 0.0f;
    UIViewAutoresizing resize = UIViewAutoresizingFlexibleHeight;
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = resize;
    view.backgroundColor = [UIColor blackColor];
//    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kMainBackground]];
    
    ToolBar *toolbar = [[ToolBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolbar.delegate = self;
    
    UIBarButtonItem *submit = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(submitArticle:)];
    toolbar.items = [NSArray arrayWithObjects:[toolbar.items objectAtIndex:0], [toolbar.items objectAtIndex:1], submit, nil];
    [submit release];
    [view addSubview:toolbar];
    [toolbar release];
    
    UISegmentedControl *typeSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Original", @"Link", nil]];
    typeSegment.frame = CGRectMake(80, 8, 160, 30);
    [typeSegment addTarget:self action:@selector(switchView:) forControlEvents:UIControlEventValueChanged];
    typeSegment.selectedSegmentIndex = 0;
    typeSegment.segmentedControlStyle = UISegmentedControlStyleBar;
    typeSegment.tintColor = [UIColor darkGrayColor];
    
    [toolbar addSubview:typeSegment];
    [typeSegment release];
    
    CGFloat y = toolbar.frame.size.height;
    original = [[OriginalView alloc] initWithFrame:CGRectMake(0, y, 320, frame.size.height-y)];
    original.titleLabel.text = [NSString stringWithFormat:@"submit original article: %@", station.name];
    original.delegate = self;
    [view addSubview:original];

    loading = [[LoadingIndicator alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [loading hide];
    [view addSubview:loading];
    
    linkView = [[LinkView alloc] initWithFrame:original.frame];
    linkView.titleLabel.text = [NSString stringWithFormat:@"submit link: %@", station.name];
    linkView.hidden = YES;
    [view addSubview:linkView];

    
    self.view = view;
    [view release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)rotateViews:(UIView *)show hidden:(UIView *)hide
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6f];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:hide cache:YES];
    hide.hidden = YES;
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6f];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:show cache:YES];
    show.hidden = NO;
    [UIView commitAnimations];
}

- (void)switchView:(UISegmentedControl *)sender
{
    NSLog(@"switchView");
    mode = sender.selectedSegmentIndex;
    if (mode==0){
        [self rotateViews:original hidden:linkView];
    }
    else{
        [self rotateViews:linkView hidden:original];
    }
}

- (void)launchCamera
{
    NSLog(@"launchCamera");
    LauchImagePicker *camera = [[LauchImagePicker alloc] initWithTarget:self action:@selector(cameraReady:) sourceType:UIImagePickerControllerSourceTypeCamera];
    [queue addOperation:camera];
    [camera release];
    loading.titleLabel.text = @"Launching Camera...";
    [loading show];
    
}

- (void)upload:(NSString *)uploadString filePath:(NSString *)path
{
    ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:uploadString]] autorelease];
    request.delegate = self;
    [request setPostValue:[station adminsString] forKey:@"admins"];
    [request setPostValue:station.unique_id forKey:@"station"];
    
    
    if (mode==0){ 
        if (path==nil){ //no image included
            [request setPostValue:@"no" forKey:@"image"];
        }
        else{ //include image
            [request setPostValue:@"yes" forKey:@"image"];
            [request setFile:path forKey:@"file"];
        }
        [request setPostValue:original.titleField.text forKey:@"title"];
        [request setPostValue:@"tag1,tag2,tag3" forKey:@"tags"];
        [request setPostValue:original.contentField.text forKey:@"content"];
        [request setPostValue:@"no" forKey:@"link"];
        [request setPostValue:original.authorField.text forKey:@"author"];
    }
    else{ 
        [request setPostValue:@"no" forKey:@"image"];
        [request setPostValue:linkView.titleField.text forKey:@"title"];
        [request setPostValue:@"tag1,tag2,tag3" forKey:@"tags"];
        [request setPostValue:linkView.contentField.text forKey:@"content"];
        [request setPostValue:@"yes" forKey:@"link"];
        [request setPostValue:linkView.authorField.text forKey:@"author"];
    }

    [request startAsynchronous];
    loading.titleLabel.text = @"Sending Article...";
    [loading show];
}

//- (NSString *)createFilePath:(NSString *)fileName
//{
//	fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"+"];
//	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//	NSString *docPath = [paths objectAtIndex:0];
//	NSString *filePath = [docPath stringByAppendingPathComponent:fileName];
//	NSLog(@"filepath = %@", filePath);
//	return filePath;
//}

- (void)showMissingValueAlert
{
    [self showAlert:@"Missing Value" message:@"Please complete all fields (image optional)."];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Value" message:@"Please complete all fields (image optional)." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//    [alert show];
//    [alert release];
}

- (void)submitArticle:(UIBarButtonItem *)btn
{
    NSLog(@"submitArticle:");
    if (mode==0){ //original 
        if ([original.titleField.text length]==0 || [original.contentField.text length]==0 || [original.authorField.text length]==0){
            [self showMissingValueAlert];
        }
        else{
            NSString *filePath = [self createFilePath:file];
            NSData *imgData = [NSData dataWithContentsOfFile:filePath];
            if (imgData==nil){
                [self upload:@"http://www.butterflyradio.com/api/article" filePath:nil];
            }
            else{
                req = [[BRNetworkOp alloc] initWithAddress:@"http://www.butterflyradio.com/api/upload?type=article" parameters:nil];
                [req setHttpMethod:@"GET"];
                req.delegate = self;
                [req sendRequest];
                loading.titleLabel.text = @"Sending Article...";
                [loading show];
            }
        }
    }
    else{ //link
        if ([linkView.titleField.text length]==0 || [linkView.contentField.text length]==0 || [linkView.authorField.text length]==0){
            [self showMissingValueAlert];
        }
        else{
            [self upload:@"http://www.butterflyradio.com/api/article" filePath:nil];
        }
    }
}

- (void)requestData:(NSArray *)pkg //returns [address, data]
{
    if (pkg!=nil){
        NSString *json = [[NSString alloc] initWithData:[pkg objectAtIndex:1] encoding:NSUTF8StringEncoding];
        NSDictionary *d = [json JSONValue];
        [json release];
        if (d==nil){
            
        }
        else{
            d = [d objectForKey:@"results"];
            NSLog(@"%@", [d description]);
            NSString *confirmation = [d objectForKey:@"confirmation"];
            if ([confirmation isEqualToString:@"success"]){
                NSString *url = [d objectForKey:@"upload string"];
                [self upload:url filePath:[self createFilePath:file]];
                self.ipAddress = [d objectForKey:@"IP"];
            }
        }
    }
}

- (void)cameraReady:(UIImagePickerController *)picker
{
    [loading hide];
    if (picker){
        self.imgPicker = picker;
        imgPicker.delegate = self;
        [self presentModalViewController:imgPicker animated:NO];
    }
}

#pragma mark - ImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:NO];
    UIImage *img = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    CGFloat width = img.size.width;
    CGFloat height = img.size.height;
    CGFloat max = original.image.frame.size.height;
    
    double scale;
    if (height>max){
        scale = max/height;
        height = max;
        width *= scale;
    }
    
    original.image.image = img;
    CGRect frame = original.image.frame;
    frame.size.width = width;
    frame.size.height = height;
    original.image.frame = frame;
    
    NSString *filePath = [self createFilePath:file];
    img = [UIImage imageWithImage:img scaledToSize:CGSizeMake(640.0f, 640.0f)];
    NSData *imgData = UIImageJPEGRepresentation(img, 0.45);
    [imgData writeToFile:filePath atomically:YES];
    NSLog(@"WIDTH = %.2f, HEIGHT  = %.2f, FILE SIZE = %d", img.size.width, img.size.height, imgData.length);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [imgPicker dismissModalViewControllerAnimated:NO];
}



#pragma mark - ToolBar
- (void)exit
{
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)showRadio
{
    
}


#pragma mark - ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *json = [request responseString];
    NSLog(@"RECORD VIEW CONTROLLER - requestFinished: %@", json);
    
    [loading hide];
    NSDictionary *d = [json JSONValue];
    if (d==nil){
        [self showAlert:@"Error" message:@"There was an error. Please try again."];
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error. Please try again." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//        [alert show];
//        [alert release];
    }
    else{
        d = [d objectForKey:@"results"];
        NSLog(@"%@", [d description]);
        NSString *confirmation = [d objectForKey:@"confirmation"];
        if ([confirmation isEqualToString:@"success"]){
            [self showAlert:@"Article Submitted" message:@"Your article was submitted. An admin will review it shortly. Thank you."];

//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Article Submitted" message:@"Your article was submitted. An admin will review it shortly. Thank you." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//            [alert show];
//            [alert release];
            [self dismissModalViewControllerAnimated:YES];
            
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error. Please try again." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
}




- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
