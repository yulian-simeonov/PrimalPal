//
//  PPDetailViewController.h
//  PrimalPal
//
//  Created by Yulian Simeonov on 8/6/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPDetailViewController : UIViewController

@property (readwrite, nonatomic) NSInteger recipeIndex;
@property (readwrite, nonatomic) NSInteger favId;
@property (readwrite, nonatomic) BOOL isFromMealplan;

@end
