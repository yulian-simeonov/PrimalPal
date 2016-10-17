//
//  PPCheckinViewController.m
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/23/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import "PPCheckinViewController.h"

#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>
#import "PPiFlatSegmentedControl.h"
#import "NSString+FontAwesome.h"
#import "MSSimpleGauge.h"
#import "MSGradientArcLayer.h"
#import <FSNConnection.h>
#import <SVProgressHUD.h>

@interface PPCheckinViewController () <UIPickerViewDataSource, UIPickerViewDelegate> {
    NSInteger selSegmentIndex;
    BOOL isYes;
}

@property (nonatomic) MSSimpleGauge *completionChart;
@property (weak, nonatomic) IBOutlet UILabel *completionLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftdayLabel;
@property (weak, nonatomic) IBOutlet UIView *confirmView;
@property (strong, nonatomic) PPiFlatSegmentedControl *timeSegment;
@property (weak, nonatomic) IBOutlet UILabel *goalLabel;
@property (weak, nonatomic) IBOutlet UIView *setgoalView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *dayleftView;
@property (strong, nonatomic) NSDictionary *checkinDict;
@end

@implementation PPCheckinViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (IS_PHONE5 == 0) {
        _dayleftView.frame = CGRectMake(_dayleftView.frame.origin.x, 284, _dayleftView.frame.size.width, _dayleftView.frame.size.height);
    }
    
    self.sidePanelController.allowLeftSwipe = YES;
    self.sidePanelController.allowRightSwipe = YES;
    
    // Create Logout Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivedLogoutNoti) name:kNotiLogout object:nil];
    // Create Segement Button
    [self createSegementButton];
    // Create Percentage Chart
    [self createPercentageChart];
    [self changeCompletionPercent:0];
    
    [self.view bringSubviewToFront:_setgoalView];
    [[self makeGetConnection] start];
}

#pragma mark - Update View Contents
- (void)updateView:(NSDictionary *)dataDict {
    CGFloat percent = 0.0;
    switch (selSegmentIndex) {
        case 0:
            percent = [dataDict[@"weekPercent"] floatValue];
            break;
        case 1:
            percent = [dataDict[@"goalPercent"] floatValue];
            break;
        case 2:
            percent = [dataDict[@"totalPercent"] floatValue];
            break;
        default:
            break;
    }

    if (selSegmentIndex == 0 || selSegmentIndex == 2) {
        NSInteger leftdata = [dataDict[@"daysLeft"] integerValue];
        _leftdayLabel.text = [NSString stringWithFormat:@"%d days left to meet your goal", leftdata];
        [self changeCompletionPercent:percent];
    }
    else if (selSegmentIndex == 1)
        _goalLabel.text = [NSString stringWithFormat:@"%d", (int)percent];
}

#pragma mark - Create Percentage Chart
- (void)changeCompletionPercent:(CGFloat)percent {
    [self.completionChart setValue:percent animated:YES];
    _completionLabel.text = [NSString stringWithFormat:@"%.2f%%", percent];
}

- (void)createPercentageChart {
    self.completionChart = [[MSSimpleGauge alloc] initWithFrame:CGRectMake(25, 144, 270, 136)];
    self.completionChart.value = 0;
    self.completionChart.fillGradient = [MSGradientArcLayer defaultGradient];
    self.completionChart.backgroundGradient = [MSGradientArcLayer backgroundGradient];
    self.completionChart.backgroundArcStrokeColor = [UIColor clearColor];
    self.completionChart.startAngle = 0;
    self.completionChart.endAngle = 180;
    [self.view addSubview:self.completionChart];
}

#pragma mark - Create Segment Button
- (void)createSegementButton {
    _timeSegment = [[PPiFlatSegmentedControl alloc]
                                         initWithFrame:CGRectMake(20, 84, 280, 40)
                                         items:@[
  @{@"text":@"WEEKLY",@"icon":@"icon-facebook"},
  @{@"text":@"GOAL",@"icon":@"icon-facebook"},
  @{@"text":@"TOTAL",@"icon":@"icon-facebook"}]
                                         iconPosition:IconPositionRight
                                         andSelectionBlock:^(NSUInteger segmentIndex) {
                                             [self onSelectedSegment:segmentIndex];
                                                                          } iconSeparation:5];
    
    _timeSegment.color=[UIColor colorWithRed:61.0f/255.0 green:61.0f/255.0 blue:61.0f/255.0 alpha:1];
    _timeSegment.borderWidth=0.5;
    _timeSegment.borderColor=[UIColor colorWithRed:86.0f/255.0 green:86.0f/255.0 blue:88.0f/255.0 alpha:1];
    _timeSegment.selectedColor=[UIColor colorWithRed:34.0f/255.0 green:34.0f/255.0 blue:36.0f/255.0 alpha:1];
    _timeSegment.textAttributes=@{
                                NSForegroundColorAttributeName:[UIColor whiteColor]};
    _timeSegment.selectedTextAttributes=@{
                                        NSForegroundColorAttributeName:[UIColor whiteColor]};
    [_timeSegment setEnabled:YES forSegmentAtIndex:2];
    selSegmentIndex = 2;
    [self.view addSubview:_timeSegment];
}

- (void)onSelectedSegment:(NSUInteger)segmentIndex {
    selSegmentIndex = segmentIndex;
    
    [self updateView:_checkinDict];
    
    if (segmentIndex == 1) {
        [UIView animateWithDuration:0.3 animations:^{
            _setgoalView.alpha = 1.0f;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            _setgoalView.alpha = 0.0f;
        }];
    }
    
}
#pragma mark - Received logout Notification
- (void)onReceivedLogoutNoti {
    [self.navigationController popToRootViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiShowLogin object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton Action
- (IBAction)onClickHamburger:(id)sender {
    [[(JASidePanelController*)self.navigationController sidePanelController] toggleRightPanel:nil];
}

- (IBAction)onClickYes:(id)sender {
    isYes = YES;
    [[self makeUpdateConnection:isYes] start];
//    [UIView animateWithDuration:0.3 animations:^{
//        CGRect frame = _confirmView.frame;
//        frame.origin.x = -320;
//        _confirmView.frame = frame;
//    }];
}

- (IBAction)onClickNo:(id)sender {
    isYes = NO;
    [[self makeUpdateConnection:isYes] start];
//    [UIView animateWithDuration:0.3 animations:^{
//        CGRect frame = _confirmView.frame;
//        frame.origin.x = -320;
//        _confirmView.frame = frame;
//    }];
}
- (IBAction)onClickSetgoal:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        _setgoalView.alpha = 0.0f;
    }];
    [[self makeSetGoalConnection] start];
     [_timeSegment setEnabled:YES forSegmentAtIndex:2];
    selSegmentIndex = 2;
}
- (IBAction)onClickConfirm:(id)sender {
    [[self makeUpdateConnection:isYes] start];
     [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _confirmView.frame;
        frame.origin.x = 0;
        _confirmView.frame = frame;
    }];
}
- (IBAction)onClickUnConfirm:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _confirmView.frame;
        frame.origin.x = 0;
        _confirmView.frame = frame;
    }];
}

- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIPickerViewDataSource, UIPickerViewDelegate
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 100;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%d", row+1];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    _goalLabel.text = [NSString stringWithFormat:@"%d", row+1];
}

#pragma mark - API Call For Login
//-----------------------------------------------------------------------------------------
- (FSNConnection *) makeUpdateConnection:(BOOL)value {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_CHECKINUPDATE]]; // API url
    NSDictionary *parameters = @{@"value":[NSNumber numberWithBool:value]}; // API parameters
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodPOST
                          headers:nil
                       parameters:parameters
                       parseBlock:^id(FSNConnection *c, NSError **error) {
                           NSDictionary *d = [c.responseData dictionaryFromJSONWithError:error];
                           if (!d) return nil;
                           
                           // example error handling.
                           // since the demo ships with invalid credentials,
                           // running it will demonstrate proper error handling.
                           // in the case of the 4sq api, the meta json in the response holds error strings,
                           // so we create the error based on that dictionary.
                           if (c.response.statusCode != 200) {
                               *error = [NSError errorWithDomain:@"FSAPIErrorDomain"
                                                            code:1
                                                        userInfo:[d objectForKey:@"meta"]];
                           }
                           return d;
                       }
                  completionBlock:^(FSNConnection *c) {
                      [SVProgressHUD dismiss];
                      NSDictionary *responseDict = (NSDictionary *)c.parseResult;
                      NSLog(@"Checkin Update Response : %@", responseDict);
                      [[self makeGetConnection] start];
//                      if (responseDict != nil) {
//                          if (responseDict[@"data"]) {
//                              _checkinDict = [NSDictionary dictionaryWithDictionary:responseDict[@"data"]
//                                              ];
//                              [self updateView:_checkinDict];
//                          }
//                      } else {
//                          [Utilities showMsg:MESSAGE_AUTHFAILED];
//                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

- (FSNConnection *) makeGetConnection{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_CHECKINGET]]; // API url
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodPOST
                          headers:nil
                       parameters:nil
                       parseBlock:^id(FSNConnection *c, NSError **error) {
                           NSDictionary *d = [c.responseData dictionaryFromJSONWithError:error];
                           if (!d) return nil;
                           
                           // example error handling.
                           // since the demo ships with invalid credentials,
                           // running it will demonstrate proper error handling.
                           // in the case of the 4sq api, the meta json in the response holds error strings,
                           // so we create the error based on that dictionary.
                           if (c.response.statusCode != 200) {
                               *error = [NSError errorWithDomain:@"FSAPIErrorDomain"
                                                            code:1
                                                        userInfo:[d objectForKey:@"meta"]];
                           }
                           return d;
                       }
                  completionBlock:^(FSNConnection *c) {
                      [SVProgressHUD dismiss];
                      NSDictionary *responseDict = (NSDictionary *)c.parseResult;
                      NSLog(@"CheckIn Get Response : %@", responseDict);
                      if (responseDict != nil) {
                          if (responseDict[@"data"]) {
                              _checkinDict = [NSDictionary dictionaryWithDictionary:responseDict[@"data"]];
                              [self updateView:_checkinDict];
                          }
                      } else {
                          [Utilities showMsg:MESSAGE_AUTHFAILED];
                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

- (FSNConnection *) makeSetGoalConnection {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_SETGOAL]]; // API url
    NSDictionary *parameters = @{@"scope" : @"goalPercent",
                                 @"value" : _goalLabel.text};
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodPOST
                          headers:nil
                       parameters:parameters
                       parseBlock:^id(FSNConnection *c, NSError **error) {
                           NSDictionary *d = [c.responseData dictionaryFromJSONWithError:error];
                           if (!d) return nil;
                           
                           // example error handling.
                           // since the demo ships with invalid credentials,
                           // running it will demonstrate proper error handling.
                           // in the case of the 4sq api, the meta json in the response holds error strings,
                           // so we create the error based on that dictionary.
                           if (c.response.statusCode != 200) {
                               *error = [NSError errorWithDomain:@"FSAPIErrorDomain"
                                                            code:1
                                                        userInfo:[d objectForKey:@"meta"]];
                           }
                           return d;
                       }
                  completionBlock:^(FSNConnection *c) {
                      [SVProgressHUD dismiss];
                      NSDictionary *responseDict = (NSDictionary *)c.parseResult;
                      NSLog(@"CheckIn Get Response : %@", responseDict);
                      [[self makeGetConnection] start];
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
