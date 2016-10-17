//
//  TBIAPHelper.m
//  TrainBreath
//
//  Created by Yulian Simeonov on 8/12/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import "TBIAPHelper.h"
#import <StoreKit/StoreKit.h>

// 2
@interface TBIAPHelper () <SKProductsRequestDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

@implementation TBIAPHelper {
    
}

+ (TBIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static TBIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.Monthly",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
