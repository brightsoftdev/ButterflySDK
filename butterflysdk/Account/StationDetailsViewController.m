//
//  StationDetailsViewController.m
//  butterflyradio
//
//  Created by Denny Kwon on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StationDetailsViewController.h"

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


@implementation UITextField (UITextFieldCategory)
+ (UITextField *)textFieldwithFrame:(CGRect)frame placeholder:(NSString *)p
{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.borderStyle = UITextBorderStyleNone;
    textField.placeholder = p;
    textField.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    return [textField autorelease];
}
@end

@interface StationDetailsViewController ()

@end

@implementation StationDetailsViewController
@synthesize station;
@synthesize nameField;
@synthesize tagsField;
@synthesize imgPicker;

- (CGRect)adjustFrame:(UIImage *)img;
{
    CGRect frame = image.frame;
    CGFloat width = img.size.width;
    CGFloat height = img.size.height;
    CGFloat max = (kMaxDimen-20);
    
    double scale;
    if (width>max){
        scale = max/width;
        width = max;
        height *= scale;
    }
    if (height>max){
        scale = max/height;
        height = max;
        width *= scale;
    }
    
    frame.size.width = width;
    frame.size.height = height;
    return frame;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Details";
        self.hidesBottomBarWhenPushed = YES;
//        categories = [[NSArray alloc] initWithObjects:@"advice", @"comedy", @"misc", @"politics", @"sports", nil];
        categories = kCategories;
        queue = [[NSOperationQueue alloc] init];
        newImgData = nil;
    }
    return self;
}

- (id)initWithManager:(ButterflyManager *)mgr
{
    self = [super init];
    if (self) {
        self.title = @"Details";
        self.hidesBottomBarWhenPushed = YES;
        categories = kCategories;
        queue = [[NSOperationQueue alloc] init];
        newImgData = nil;
    }
    return self;
}

- (void)dealloc
{
    if (newImgData!=nil){
        [newImgData release];
    }
    station.delegate = nil;
    self.imgPicker = nil;
    [station release];
    [nameField release];
    [image release];
    [tagsField release];
    [categoryLabel release];
    [categoriesPicker release];
    [categories release];
    [descriptionField release];
    [loading release];
    [queue release];
    [super dealloc];
}

- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    
    
    descriptionField = [[UITextView alloc] initWithFrame:CGRectMake(10, 115, frame.size.width-20, 117)];
    descriptionField.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    descriptionField.backgroundColor = [UIColor yellowColor];
    descriptionField.delegate = self;
    [view addSubview:descriptionField];
    
    image = [[UIImageView alloc] initWithFrame:CGRectMake(10, 240, 100, 100)];
    image.backgroundColor = [UIColor blackColor];
    image.image = [UIImage imageNamed:@"Icon@2x.png"];
    [view addSubview:image];
    
    UIButton *btnChangeImg = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnChangeImg.frame = CGRectMake(10, 370, frame.size.width-20, 35);
    [btnChangeImg setBackgroundImage:[UIImage imageNamed:@"btn_base_gray@2x.png"] forState:UIControlStateNormal];
    [btnChangeImg setTitle:@"change image" forState:UIControlStateNormal];
    [btnChangeImg setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnChangeImg.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    [btnChangeImg addTarget:self action:@selector(photoBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnChangeImg];
    
    
    self.view = view;
    [view release];
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kMainBackground]];
    descriptionField.delegate = self;
    descriptionField.text = station.description;
    
    UIBarButtonItem *btnUpdate = [[UIBarButtonItem alloc] initWithTitle:@"update" style:UIBarButtonItemStyleBordered target:self action:@selector(update:)];
    btnUpdate.tintColor = [UIColor blueColor];
    self.navigationItem.rightBarButtonItem = btnUpdate;
    [btnUpdate release];
    
    DetailBackground *nameBg = [DetailBackground backgroundWithFrame:CGRectMake(0, 0, 320, 35)];
    [nameBg.btnLabel setTitle:@"Name" forState:UIControlStateNormal];
    self.nameField = [UITextField textFieldwithFrame:CGRectMake(80, 5, 225, 25) placeholder:@"name"];
    nameField.borderStyle = UITextBorderStyleNone;
    nameField.delegate = self;
    nameField.text = station.name;
    [nameBg addSubview:nameField];
    [self.view addSubview:nameBg];

    DetailBackground *tagsBg = [DetailBackground backgroundWithFrame:CGRectMake(0, 35, 320, 35)];
    [tagsBg.btnLabel setTitle:@"Tags" forState:UIControlStateNormal];
    self.tagsField = [UITextField textFieldwithFrame:CGRectMake(80, 5, 225, 25) placeholder:@"tags"];
    tagsField.borderStyle = UITextBorderStyleNone;
    tagsField.delegate = self;
    tagsField.text = [station tagsString];
    [tagsBg addSubview:tagsField];
    [self.view addSubview:tagsBg];
    
    DetailBackground *categoryBg = [DetailBackground backgroundWithFrame:CGRectMake(0, 70, 320, 35)];
    [categoryBg.btnLabel setTitle:@"Category" forState:UIControlStateNormal];
    categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 225, 25)];
    categoryLabel.font = tagsField.font;
    categoryLabel.text = station.category;
    categoryLabel.backgroundColor = [UIColor clearColor];
    [categoryBg addSubview:categoryLabel];
    
    UIButton *btnSelectCategory = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSelectCategory.frame = CGRectMake(230, 5, 80, 25);
    [btnSelectCategory setTitle:@"change" forState:UIControlStateNormal];
    [btnSelectCategory setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSelectCategory addTarget:self action:@selector(selectCategory) forControlEvents:UIControlEventTouchUpInside];
    [btnSelectCategory setBackgroundImage:[UIImage imageNamed:@"btn_base_gray@2x.png"] forState:UIControlStateNormal];
    [categoryBg addSubview:btnSelectCategory];
    [self.view addSubview:categoryBg];
    
    UIImage *shadow = [UIImage imageNamed:@"dropShadow.png"];
    UIImageView *dropShadow = [[UIImageView alloc] initWithImage:shadow];
    dropShadow.frame = CGRectMake(0, categoryBg.frame.origin.y+categoryBg.frame.size.height, shadow.size.width, shadow.size.height);
    [self.view addSubview:dropShadow];
    [dropShadow release];
    
    categoriesPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 150)];
    categoriesPicker.showsSelectionIndicator = YES;
    categoriesPicker.delegate = self;
    categoriesPicker.dataSource = self;
    [self.view addSubview:categoriesPicker];
    
    loading = [[LoadingIndicator alloc] initWithFrame:self.view.frame];
    loading.hidden = YES;
    [self.view addSubview:loading];
    
    if (station.imgData==nil){
        station.delegate = self;
        [station fetchImage];
        [loading show];
        //show loading
    }
    else{
//        image.image = [UIImage imageWithData:station.imgData];
        [self imageReady:nil];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}

- (void)selectCategory
{
    NSLog(@"selectCategory");
    [self slidePicker:254.0f];
}

- (void)slidePicker:(CGFloat)pos
{
    CGRect frame = categoriesPicker.frame;
    frame.origin.y = pos;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    categoriesPicker.frame = frame;
    [UIView commitAnimations];
}

- (void)update:(UIBarButtonItem *)btn
{
    if (newImgData==nil){
        NSString *url = [NSString stringWithFormat:@"http://%@/api/station", kUrl];
        ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]] autorelease];
        request.delegate = self;
        [request setPostValue:@"no" forKey:@"image"];
        [request setPostValue:station.unique_id forKey:@"station"];
        [request setPostValue:@"update" forKey:@"action"];
        [request setPostValue:nameField.text forKey:@"name"];
        [request setPostValue:tagsField.text forKey:@"tags"];
        [request setPostValue:descriptionField.text forKey:@"description"];
        [request setPostValue:categoryLabel.text forKey:@"category"];
        [request setPostValue:station.host forKey:@"email"];
        
        [request startAsynchronous];
    }
    else{
        //Get upload string first then POST image
        
        NSString *url = [NSString stringWithFormat:@"http://%@/api/upload?type=station", kUrl];
        req = [[BRNetworkOp alloc] initWithAddress:url parameters:nil];
        req.delegate = self;
        [req setHttpMethod:@"GET"];
        [req sendRequest];
    }
    loading.titleLabel.text = @"Updating Station...";
    [loading show];
}

- (void)photoBtnPressed
{
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Select Source" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"photo library", @"take photo", nil];
    actionsheet.frame = CGRectMake(0, 150, 320, 100);
    actionsheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionsheet showInView:[UIApplication sharedApplication].keyWindow];
    [actionsheet release];
}

- (void)lauchCamera:(UIImagePickerControllerSourceType)sourceType
{
    NSLog(@"launchCamera");
    LauchImagePicker *camera = [[LauchImagePicker alloc] initWithTarget:self action:@selector(cameraReady:) sourceType:sourceType];
    [queue addOperation:camera];
    [camera release];
    if (sourceType==UIImagePickerControllerSourceTypeCamera){
        loading.titleLabel.text = @"Launching Camera...";
    }
    else {
        loading.titleLabel.text = @"Launching Photo Library...";
    }
    [loading show];
    
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

- (void)requestData:(NSArray *)pkg //returns [address, data]
{
    if (pkg!=nil){
        NSString *json = [[NSString alloc] initWithData:[pkg objectAtIndex:1] encoding:NSUTF8StringEncoding];
        NSDictionary *d = [json JSONValue];
        if (d==nil){
            [req sendRequest];
        }
        else{
            d = [d objectForKey:@"results"];
            NSLog(@"%@", [d description]);
            NSString *url = [d objectForKey:@"upload string"];
            ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]] autorelease];
            request.delegate = self;
            [request setPostValue:@"yes" forKey:@"image"];
            NSString *fileName = [station.unique_id stringByAppendingString:@".jpeg"];
            [request setData:newImgData withFileName:fileName andContentType:@"image/jpeg" forKey:@"file"];
            [request setPostValue:station.unique_id forKey:@"station"];
            [request setPostValue:@"update" forKey:@"action"];
            [request setPostValue:nameField.text forKey:@"name"];
            [request setPostValue:tagsField.text forKey:@"tags"];
            [request setPostValue:descriptionField.text forKey:@"description"];
            [request setPostValue:categoryLabel.text forKey:@"category"];
            [request setPostValue:station.host forKey:@"email"];
            
            [request startAsynchronous];
        }
        [json release];
    }
    
    
}

#pragma mark -  UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet clickedButtonAtIndex: %d", buttonIndex);
    if (buttonIndex==2){
        
    }
    else{
        UIImagePickerControllerSourceType sourceType;
        if (buttonIndex==0){ sourceType = UIImagePickerControllerSourceTypePhotoLibrary; }
        if (buttonIndex==1){ sourceType = UIImagePickerControllerSourceTypeCamera; }
        [self lauchCamera:sourceType];
        
    }
}


#pragma mark -  StationDelegate
- (void)imageReady:(NSString *)addr
{
    [loading hide];
    image.image = [UIImage imageWithData:station.imgData];;
    CGRect frame = [self adjustFrame:image.image];
    image.frame = frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6f];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:image cache:YES];
    image.frame = frame;
    [UIView commitAnimations];
}

- (void)stationInfoReady
{

}


#pragma mark -  UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [categories count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [categories objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *category = [categories objectAtIndex:row];
    categoryLabel.text = category;
    [self slidePicker:self.view.frame.size.height];
}



#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.navigationController setNavigationBarHidden:TRUE animated:YES];

}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self.navigationController setNavigationBarHidden:FALSE animated:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    BOOL confirmation = TRUE;
    if ([text isEqualToString:@"\n"]){
        confirmation = FALSE;
        [descriptionField resignFirstResponder];
    }
    return confirmation;
}


#pragma mark - ImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:NO];
    NSLog(@"%@", [info description]);
    UIImage *img = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    if (img==nil){ img = [info objectForKey:@"UIImagePickerControllerOriginalImage"]; }
    
    CGRect frame = [self adjustFrame:img];
    image.frame = frame;
    image.image = img;
    
    CGFloat w = img.size.width;
    CGFloat h = img.size.height;
    CGFloat max = 640.0f;
    double scale;
    if (w>max){
        scale = max/w;
        w = max;
        h *= scale;
    }
    if (h>max){
        scale = max/h;
        h = max;
        w *= scale;
    }
    
//    img = [UIImage imageWithImage:img scaledToSize:CGSizeMake(640.0f, 640.0f)];
    img = [UIImage imageWithImage:img scaledToSize:CGSizeMake(w, h)];
    
    newImgData = UIImageJPEGRepresentation(img, 0.45);
    [newImgData retain];
    
    NSLog(@"WIDTH = %.2f, HEIGHT  = %.2f, FILE SIZE = %d", img.size.width, img.size.height, newImgData.length);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [imgPicker dismissModalViewControllerAnimated:NO];
}



#pragma mark - ASIHTTPRequestDelegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *json = [request responseString];
    NSLog(@"STATION DETAILS VIEW CONTROLLER - requestFinished: %@", json);
    
    [loading hide];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Station Updated" message:@"Your station has been successfully updated." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
    [alert release];
    
    NSDictionary *d = [json JSONValue];
    if (d==nil){
        
    }
    else{
        d = [d objectForKey:@"results"];
        NSLog(@"%@", [d description]);
        
        NSDictionary *info = [d objectForKey:@"station"];
        [self.station populate:info];
        self.station.imgData = nil;
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kRefreshNotification object:nil]];
        
        station.delegate = self;
        [station fetchImage];

    }
}




- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
