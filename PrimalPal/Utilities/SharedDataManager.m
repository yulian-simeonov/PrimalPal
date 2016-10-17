//
//  SharedDataManager.m
//  InteractivePress
//
//  Created by Yulian Simeonov on 6/19/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import "SharedDataManager.h"

#import "PPUserModel.h"
#import <FSNConnection.h>
#import <SVProgressHUD.h>
#import "TBIAPHelper.h"
#import "IAPHelper.h"

@interface SharedDataManager () <UIAlertViewDelegate> {
    
}

@end

@implementation SharedDataManager

+ (instancetype)instance {
	static SharedDataManager * _instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance = [[SharedDataManager alloc] init];
	});
	return _instance;
}

- (void)saveUserInfo {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:[NSString stringWithFormat:@"%d", self.isLoggedIn] forKey:@"IsLoggedIn"];
    [standardUserDefaults setObject:self.identifierStr forKey:@"Identifier"];
    [standardUserDefaults synchronize];
}

- (id)init {
	self = [super init];
	if (self) {
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
		self.isLoggedIn = [[standardUserDefaults objectForKey:@"IsLoggedIn"] boolValue];
        self.identifierStr = [standardUserDefaults objectForKey:@"Identifier"];
        self.userModel = [[[PPUserModel alloc] init] userModelFromDictionary:[standardUserDefaults objectForKey:@"UserModel"]];
        self.screenRotationMode = kLandscapeOnly;
        _introductionViewedCount = [[standardUserDefaults objectForKey:@"IntroductionViewedCount"] integerValue];
	}
	return self;
}

- (void)saveUserModel {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:[_userModel convertToDictionary]  forKey:@"UserModel"];
    [standardUserDefaults synchronize];
}

- (void)setIntroductionViewedCount:(NSInteger)introductionViewedCount {
    _introductionViewedCount = introductionViewedCount;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:[NSNumber numberWithInteger:_introductionViewedCount]  forKey:@"IntroductionViewedCount"];
    [standardUserDefaults synchronize];
}

- (void)buyProduct {
    [[self makeCheckConnection] start];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [SVProgressHUD show];
        [[TBIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success) {
                NSLog(@"%@", products);
                for (SKProduct *product in products) {
                    if ([product.productIdentifier isEqualToString:@"com.Monthly"]) {
//                        if (![[TBIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
                            [[TBIAPHelper sharedInstance] buyProduct:product];
//                        }
//                        else {
//                            [SharedDataManager instance].userModel.isPaid = YES;
//                            [[SharedDataManager instance] saveUserModel];
//                        }
                    }
                }
            }
            [SVProgressHUD dismiss];
        }];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotiOpenRecipe object:nil];
    }
}

- (void)checkIfPaid {
    [[self makeCheckConnection] start];
}

- (FSNConnection *) makeCheckConnection {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_ISPAID]]; // API url
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
                      NSLog(@"Login Response : %@", responseDict);
                      if (responseDict != nil) {
                          if (responseDict[@"data"]) {
                              // Set Looged In YES
                              if ([responseDict[@"data"][@"AllowAccess"] boolValue]) {
                                  [SharedDataManager instance].userModel.isPaid = YES;
                                  [[SharedDataManager instance] saveUserModel];
                              } else {
                                  
                                  [SharedDataManager instance].userModel.isPaid = NO;
                                  [[SharedDataManager instance] saveUserModel];
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kTitle_APP message:@"Thanks for signing up, you can search recipes but to take full advantage of the meal planner, check ins, and the shopping list you can become a full member. Subscribe Now!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Browse Recipes", @"Subscribe Now", nil];
                                  [alert show];
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

@end

