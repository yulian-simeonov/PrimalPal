//
//  PPMealplanTableViewCell.m
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/31/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import "PPShoppinglistViewCell.h"
#import "PPShoppinglistViewController.h"
#import "SVProgressHUD.h"
#import <FSNConnection.h>

@implementation PPShoppinglistViewCell

- (void)awakeFromNib
{
    // Initialization code
    UISwipeGestureRecognizer* gestureL;
    gestureL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)];
    gestureL.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:gestureL];
    
    UISwipeGestureRecognizer* gestureR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)];
    gestureR.direction = UISwipeGestureRecognizerDirectionRight; // default
    [self addGestureRecognizer:gestureR];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)swipeLeft {
    NSLog(@" *** SWIPE LEFT ***");
    PPShoppinglistViewController *delegate = (PPShoppinglistViewController *)self.parentDelegate;
    NSInteger section = self.tag / 1000;
    NSInteger row = self.tag % 1000;
    [delegate removeDelButton:row section:section];
    [UIView animateWithDuration:0.5 animations:^{
        _delButton.alpha = 1.0f;
    }];
}

- (void)swipeRight {
    NSLog(@" *** SWIPE RIGHT ***");
    [UIView animateWithDuration:0.2 animations:^{
        _delButton.alpha = 0.0f;
    }];
}

- (void)fillViewWithObject:(id)object {
    self.object = object;
    _nameLabel.text = object[@"name"];
    _checkButton.selected = [object[@"bought"] boolValue];
}

- (void)callBuyConnection {
    [[self makeBuyConnection] start];
}

#pragma mark - UIButton Action

- (IBAction)onClickCheckBox:(id)sender {
    [_checkButton setSelected:![_checkButton isSelected]];
    [self performSelectorInBackground:@selector(callBuyConnection) withObject:nil];
//    [self performSelector:@selector(callBuyConnection)];
}
- (IBAction)onClickDel:(id)sender {
    [[self makeDelConnection] start];
}

#pragma mark - API call for fav add or del function
- (FSNConnection *) makeBuyConnection {
    
    [SVProgressHUD show];
    NSURL *url;
    NSDictionary *parameters;

    NSArray *urpArray = self.object[@"urp_id"];
    NSString *ingredientString = [NSString stringWithFormat:@"%@", self.object[@"ingredient_id"]];
    NSString *urpString = [NSString stringWithFormat:@"[%@]", [urpArray componentsJoinedByString:@","]];
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_BUYSHOPPINGLIST]]; // API url // API parameters
    parameters = @{@"urp_id" : urpString,
                   @"ingredient_id" : ingredientString};
    
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
                      NSLog(@"Buy Shoppinglist Response : %@", responseDict);
                      if (responseDict == nil) {
                          NSLog(@"Successfully removed");
                      } else {
                          if (responseDict != nil) {
                             
                          } else {
                              [self.checkButton setSelected:!self.checkButton.selected];
                              [Utilities showMsg:MESSAGE_AUTHFAILED];
                          }
                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

- (FSNConnection *) makeDelConnection {
    
    [SVProgressHUD show];
    NSURL *url;
    NSDictionary *parameters;
    
    NSArray *urpArray = self.object[@"urp_id"];
    NSString *ingredientString = [NSString stringWithFormat:@"%@", self.object[@"ingredient_id"]];
    NSString *urpString = [NSString stringWithFormat:@"[%@]", [urpArray componentsJoinedByString:@","]];
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_DELSHOPPINGLIST]]; // API url // API parameters
    parameters = @{@"urp_id" : urpString,
                   @"ingredient_id" : ingredientString};
    
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
                      NSLog(@"Del Shoppinglist Response : %@", responseDict);
                      if (responseDict == nil) {
                          NSLog(@"Successfully removed");
                          [[self.parentDelegate makeGetShoppinglistConnection] start];
                      } else {
                          if (responseDict != nil) {
                              
                          } else {
                              [self.checkButton setSelected:!self.checkButton.selected];
                              [Utilities showMsg:MESSAGE_AUTHFAILED];
                          }
                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

@end
