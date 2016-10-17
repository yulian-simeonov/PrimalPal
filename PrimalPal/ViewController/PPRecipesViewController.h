//
//  PPRecipesViewController.h
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/23/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPRecipesViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (readwrite, nonatomic) BOOL isFav;

- (void)onTagSelected:(NSString *)tagName;
- (void)showDatePicker ;

@end
