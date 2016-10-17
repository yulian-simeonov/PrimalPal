//
//  PPMealPlanViewController.h
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/23/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPFavViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;

- (void)removeDelButton:(NSInteger)selIdx;

@end
