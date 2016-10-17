//
//  PPMealplanTableViewCell.h
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/31/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPShoppinglistViewCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *checkButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *delButton;

@property (nonatomic, strong) id parentDelegate;
@property (nonatomic, strong) id object;

- (void)fillViewWithObject:(id)object;
- (IBAction)onClickCheckBox:(id)sender;

@end
