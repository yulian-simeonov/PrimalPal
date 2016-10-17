//
//  PPLoginViewController.m
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/23/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import "PPLoginViewController.h"

#import <FSNConnection.h>
#import <SVProgressHUD.h>
#import <CSNotificationView.h>
#import "PPUserModel.h"
#import "TBIAPHelper.h"
#import "PPSignupViewController.h"

@interface PPLoginViewController () <UITextFieldDelegate> {
    NSArray *_products;
}

@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;

@end

@implementation PPLoginViewController

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
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_usernameTextfield resignFirstResponder];
    [_passwordTextfield resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_usernameTextfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_passwordTextfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    // Apply ClearButton To TextField
    [self applyClearButton];
    
    [self reload];
}

- (void)reload {
    _products = nil;
    [[TBIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
        }
        [SVProgressHUD dismiss];
    }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Make Apply ClearButton to UITextField
- (void)applyClearButton {
    CGFloat myWidth = 24.0f;
    CGFloat myHeight = 24.0f;
    UIButton *myButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, myWidth, myHeight)];
    [myButton setImage:[UIImage imageNamed:@"clearbutton"] forState:UIControlStateNormal];
    [myButton addTarget:self action:@selector(doClear:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *passButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, myWidth, myHeight)];
    [passButton setImage:[UIImage imageNamed:@"clearbutton"] forState:UIControlStateNormal];
    [passButton addTarget:self action:@selector(doClear:) forControlEvents:UIControlEventTouchUpInside];
    
    myButton.tag = 1;
    _usernameTextfield.rightView = myButton;
    _usernameTextfield.rightViewMode = UITextFieldViewModeWhileEditing;
    
    passButton.tag = 2;
    _passwordTextfield.rightView = passButton;
    _passwordTextfield.rightViewMode = UITextFieldViewModeWhileEditing;
}

- (void)doClear:(id)sender {
    if ([sender tag] == 1)
        _usernameTextfield.text = @"";
    else
        _passwordTextfield.text = @"";
}

#pragma mark - UITextfieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        self.view.frame = frame;
    }];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = -100;
        self.view.frame = frame;
    }];
    return YES;
}

#pragma mark - UIButton Action
- (IBAction)onClickLogin:(id)sender {
    if (![Utilities isValidString:_usernameTextfield.text] || ![Utilities isValidString:_passwordTextfield.text]) {
        [CSNotificationView showInViewController:self
                                       tintColor:LOGO_COLOR
                                           image:nil
                                         message:MESSAGE_FILLINTHEINPUTFIELD
                                        duration:2.0f];
        return;
    }
    FSNConnection *connection = [self makeLoginConnection];
    [connection start];
}
- (IBAction)onClickFacebookLogin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onClickSignup:(id)sender {
    
}
- (IBAction)onClickForgotpassword:(id)sender {
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@""]];
}

#pragma mark - API Call For Login
//-----------------------------------------------------------------------------------------
- (FSNConnection *) makeLoginConnection {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_LOGIN]]; // API url
    NSDictionary *parameters = @{@"email":_usernameTextfield.text,
                                 @"password":_passwordTextfield.text}; // API parameters
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
                      NSLog(@"Login Response : %@", responseDict);
                      if (responseDict != nil) {
                          if (responseDict[@"data"]) {
                              PPUserModel *userModel = [[PPUserModel alloc] init];
                              NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:responseDict[@"data"]];
                              [dict setObject:_usernameTextfield.text forKey:@"Username"];
                              [dict setObject:_usernameTextfield.text forKey:@"Email"];
                              [dict setObject:_passwordTextfield.text forKey:@"Password"];
                              userModel = [userModel userModelFromDictionary:dict];
                              if (userModel.isAuthenticated) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                                  // Set Looged In YES
                                  [SharedDataManager instance].isLoggedIn = YES;
                                  [[SharedDataManager instance] saveUserInfo];
                                  [SharedDataManager instance].userModel = userModel;
                                  [[SharedDataManager instance] saveUserModel];
                                  
                                  [[NSNotificationCenter defaultCenter] postNotificationName:kNotiLoggedIn object:nil];
                              } else {
                                  [Utilities showMsg:MESSAGE_AUTHFAILED];
                              }
                          }
                      } else {
                          [Utilities showMsg:MESSAGE_AUTHFAILED];    
                      }
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
