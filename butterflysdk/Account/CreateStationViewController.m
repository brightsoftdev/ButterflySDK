//
//  CreateStationViewController.m
//  butterflyradio
//
//  Created by Denny Kwon on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.


#import "CreateStationViewController.h"

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


@interface CreateStationViewController ()

@end

@implementation CreateStationViewController
@synthesize nameField;
@synthesize host;
@synthesize categoryLabel;
@synthesize tagsField;
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"New Station";
        self.hidesBottomBarWhenPushed = YES;
        categories = kCategories;
    }
    return self;
}

- (id)initWithManager:(ButterflyManager *)mgr
{
    self = [super initWithManager:self.butterflyMgr];
    if (self) {
        self.title = @"New Station";
        self.hidesBottomBarWhenPushed = YES;
        categories = kCategories;
    }
    return self;
}

- (void)dealloc
{
    [loading release];
    [host release];
    [categoryLabel release];
    [categories release];
    [tagsField release];
    [super dealloc];
}



- (void)loadView
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:kMainBackground]];
    view.tag = 1111;
	
    DetailBackground *nameBg = [DetailBackground backgroundWithFrame:CGRectMake(0, 0, 320, 35)];
    [nameBg.btnLabel setTitle:@"Name" forState:UIControlStateNormal];
    self.nameField = [UITextField textFieldwithFrame:CGRectMake(80, 5, 225, 25) placeholder:@"name"];
    nameField.borderStyle = UITextBorderStyleNone;
    nameField.delegate = self;
    [nameBg addSubview:nameField];
    [view addSubview:nameBg];
    
    DetailBackground *tagsBg = [DetailBackground backgroundWithFrame:CGRectMake(0, 35, 320, 35)];
    [tagsBg.btnLabel setTitle:@"Tags" forState:UIControlStateNormal];
    self.tagsField = [UITextField textFieldwithFrame:CGRectMake(80, 5, 225, 25) placeholder:@"tags (seprated by commas)"];
    tagsField.borderStyle = UITextBorderStyleNone;
    tagsField.delegate = self;
//    tagsField.text = [station tagsString];
    [tagsBg addSubview:tagsField];
    [view addSubview:tagsBg];

    
    DetailBackground *categoryBg = [DetailBackground backgroundWithFrame:CGRectMake(0, 70, 320, 35)];
    [categoryBg.btnLabel setTitle:@"Category" forState:UIControlStateNormal];
    categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 225, 25)];
    categoryLabel.font = [UIFont fontWithName:kFont size:14.0f];
    categoryLabel.text = @"misc";
    categoryLabel.backgroundColor = [UIColor clearColor];
    [categoryBg addSubview:categoryLabel];
    
    UIButton *btnSelectCategory = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSelectCategory.frame = CGRectMake(230, 5, 80, 25);
    [btnSelectCategory setTitle:@"change" forState:UIControlStateNormal];
    [btnSelectCategory setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSelectCategory addTarget:self action:@selector(selectCategory) forControlEvents:UIControlEventTouchUpInside];
    [btnSelectCategory setBackgroundImage:[UIImage imageNamed:@"btn_base_gray@2x.png"] forState:UIControlStateNormal];
    [categoryBg addSubview:btnSelectCategory];
    [view addSubview:categoryBg];

    
    UIImage *shadow = [UIImage imageNamed:@"dropShadow.png"];
    UIImageView *dropShadow = [[UIImageView alloc] initWithImage:shadow];
    dropShadow.frame = CGRectMake(0, categoryBg.frame.origin.y+categoryBg.frame.size.height, shadow.size.width, shadow.size.height);
    [view addSubview:dropShadow];
    [dropShadow release];


    categoriesPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, frame.size.height, 320, 150)];
    categoriesPicker.showsSelectionIndicator = YES;
    categoriesPicker.delegate = self;
    categoriesPicker.dataSource = self;
    [view addSubview:categoriesPicker];
    
    frame.origin.y = 0.0f;
    loading = [[LoadingIndicator alloc] initWithFrame:frame];
    loading.hidden = YES;
    [view addSubview:loading];
    
    self.view = view;
    [view release];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *btnCreateStation = [[UIBarButtonItem alloc] initWithTitle:@"create" style:UIBarButtonItemStyleBordered target:self action:@selector(create)];
    btnCreateStation.tintColor = [UIColor greenColor];
    self.navigationItem.rightBarButtonItem = btnCreateStation;
    [btnCreateStation release];
}

- (void)selectCategory
{
    NSLog(@"selectCategory");
    [self.nameField resignFirstResponder];
    [self.tagsField resignFirstResponder];

    [self slidePicker:254.0f];
}


- (void)create
{
    if ([nameField.text length]==0 || [tagsField.text length]==0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing Value" message:@"Please complete all fields." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else{
        if (req!=nil){
            [req cancel];
            req.delegate = nil;
            [req release];
        }
        
        NSString *url = [NSString stringWithFormat:@"http://%@/api/station", kUrl];
        NSMutableDictionary *params = params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"yes", @"hidden", nameField.text, @"name", host.email, @"email", tagsField.text, @"tags", categoryLabel.text, @"category", @"create", @"action", nil];
        
//        if ([self.butterflyMgr.host.email isEqualToString:kAppHost]==FALSE){
//            NSString *appHost = [NSString stringWithFormat:@"%@", kAppHost];
//            [params setObject:appHost forKey:@"appHost"];
//        }

        if ([self.butterflyMgr.host.email isEqualToString:self.butterflyMgr.appHost]==FALSE){
            NSString *appHost = [NSString stringWithFormat:@"%@", self.butterflyMgr.appHost];
            [params setObject:appHost forKey:@"appHost"];
        }

        req = [[BRNetworkOp alloc] initWithAddress:url parameters:params];
        req.delegate = self;
        [req sendRequest];
        [loading show];
    }
}

- (void)requestData:(NSArray *)pkg //returns [address, data]
{
    if (pkg!=nil){
        NSString *json = [[NSString alloc] initWithData:[pkg objectAtIndex:1] encoding:NSUTF8StringEncoding];
        NSDictionary *d = [json JSONValue];
        if (d==nil){
            
        }
        else{
            [loading hide];
            d = [d objectForKey:@"results"];
            NSLog(@"%@", [d description]);
            NSString *success = [d objectForKey:@"success"];
            if ([success isEqualToString:@"yes"]){
                NSDictionary *hostInfo = [d objectForKey:@"host"];
                [self.host populate:hostInfo];
                [self.delegate stationCreated];
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kRefreshNotification object:nil]];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        [json release];
    }
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



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UIResponder Touch Methods
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *tchd = [touches anyObject];
	if (tchd.view.tag==1111){
		[nameField resignFirstResponder];
		[tagsField resignFirstResponder];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

@end
