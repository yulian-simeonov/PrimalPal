//
//  PPRecipesCell.h
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/30/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import "PSCollectionViewCell.h"

@class DWTagList;
@class FSNConnection;
@interface PPRecipesCell : PSCollectionViewCell

@property (nonatomic, strong) id parentDelegate;
@property (nonatomic, strong) DWTagList *tagList;
@property (nonatomic, strong) UIButton *planButton;
@property (nonatomic, strong) UIButton *favButton;

- (FSNConnection *) makePlanConnection:(NSInteger)recipeId dateString:(NSString *)dateString;

@end
