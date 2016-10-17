//
//  IAPHelper.h
//  TrainBreath
//
//  Created by Yulian Simeonov on 8/12/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <StoreKit/StoreKit.h>
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
@end
