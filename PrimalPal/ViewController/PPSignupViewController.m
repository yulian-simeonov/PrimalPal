//
//  PPSignupViewController.m
//  PrimalPal
//
//  Created by Yulian Simeonov on 10/18/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import "PPSignupViewController.h"

#import <FSNConnection.h>
#import <SVProgressHUD.h>
#import "Utilities.h"
#import <CSNotificationView/CSNotificationView.h>
#import "SharedDataManager.h"
#import "PPUserModel.h"

@interface PPSignupViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *fnameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *lnameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;

@end

@implementation PPSignupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_fnameTextfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_lnameTextfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_emailTextfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [_passwordTextfield setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_fnameTextfield resignFirstResponder];
    [_emailTextfield resignFirstResponder];
    [_lnameTextfield resignFirstResponder];
    [_passwordTextfield resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) onClickSignUp:(id)sender {
    if (![Utilities isValidString:_fnameTextfield.text] || ![Utilities isValidString:_lnameTextfield.text] || ![Utilities isValidString:_passwordTextfield.text]) {
        if (![Utilities validateEmailWithString:_emailTextfield.text]) {
            [CSNotificationView showInViewController:self
                                           tintColor:LOGO_COLOR
                                               image:nil
                                             message:MESSAGE_VALIDEMAIL
                                            duration:2.0f];
            return;
        }
        [CSNotificationView showInViewController:self
                                       tintColor:LOGO_COLOR
                                           image:nil
                                         message:MESSAGE_FILLINTHEINPUTFIELD
                                        duration:2.0f];
        return;
    }
    [[self makeSignupConnection] start];
}

- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    _fnameTextfield.rightView = myButton;
    _fnameTextfield.rightViewMode = UITextFieldViewModeWhileEditing;
    
    passButton.tag = 2;
    _lnameTextfield.rightView = passButton;
    _lnameTextfield.rightViewMode = UITextFieldViewModeWhileEditing;
}

- (void)doClear:(id)sender {
    if ([sender tag] == 1)
        _fnameTextfield.text = @"";
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

#pragma mark - API Call For Signup
//-----------------------------------------------------------------------------------------
- (FSNConnection *) makeSignupConnection {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@?first_name=%@&last_name=%@&email=%@&password=%@", SERVER_URL, API_SIGNUP, _fnameTextfield.text, _lnameTextfield.text, _emailTextfield.text, _passwordTextfield.text]]; // API url
//    NSDictionary *parameters = @{@"first_name":_fnameTextfield.text,
//                                 @"last_name":_lnameTextfield.text,
//                                 @"email":_lnameTextfield.text,
//                                 @"password":_passwordTextfield.text}; // API parameters
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodGET
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
                      NSLog(@"Signup Response : %@", responseDict);
                      if (responseDict != nil) {
                          if (responseDict[@"data"]) {
                              [CSNotificationView showInViewController:self
                                                             tintColor:LOGO_COLOR
                                                                 image:nil
                                                               message:MESSAGE_SIGNUPSUCCESS
                                                              duration:2.0f];

                              [[self makeLoginConnection] start];
                          }
                      } else {
                          [Utilities showMsg:MESSAGE_AUTHFAILED];
                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

- (FSNConnection *) makeLoginConnection {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_LOGIN]]; // API url
    NSDictionary *parameters = @{@"email":_emailTextfield.text,
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
                              [dict setObject:_emailTextfield.text forKey:@"Username"];
                              [dict setObject:_emailTextfield.text forKey:@"Email"];
                              [dict setObject:_passwordTextfield.text forKey:@"Password"];
                              userModel = [userModel userModelFromDictionary:dict];
                              if (userModel.isAuthenticated) {
                                  [self dismissViewControllerAnimated:YES completion:^{
                                  // Set Looged In YES
                                      [SharedDataManager instance].isLoggedIn = YES;
                                      [[SharedDataManager instance] saveUserInfo];
                                      [SharedDataManager instance].userModel = userModel;
                                      [[SharedDataManager instance] saveUserModel];
                                      [[NSNotificationCenter defaultCenter] postNotificationName:kNotiLoggedIn object:nil];
                                  }];
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
