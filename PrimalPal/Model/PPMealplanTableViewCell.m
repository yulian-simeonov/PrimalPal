//
//  PPMealplanTableViewCell.m
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/31/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import "PPMealplanTableViewCell.h"
#import "PPMealPlanViewController.h"
#import "UIImageView+WebCache.h"

@implementation PPMealplanTableViewCell

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
    PPMealPlanViewController *delegate = (PPMealPlanViewController *)self.parentDelegate;
    [delegate removeDelButton:self.tag];
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
    [_mealImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, object[@"thumbnail"]]]];
    _nameLabel.text = [NSString stringWithFormat:@"%@", object[@"name"]];
}

@end
