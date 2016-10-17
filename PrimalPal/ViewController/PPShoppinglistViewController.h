//
//  PPShoppinglistViewController.h
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/23/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSNConnection;
@interface PPShoppinglistViewController : UIViewController

- (void)removeDelButton:(NSInteger)selIdx section:(NSInteger)section;
- (FSNConnection *) makeGetShoppinglistConnection;

@end
