//
//  PPMealplanTableViewCell.h
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/31/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PPMealplanTableViewCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *mealImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UIButton *delButton;

@property (nonatomic, strong) id parentDelegate;

- (void)fillViewWithObject:(id)object;

@end
