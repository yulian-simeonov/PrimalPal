//
//  SharedDataManager.h
//  InteractivePress
//
//  Created by Yulian Simeonov on 6/19/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
	kLandscapeAndPortrait = 0,
    kLandscapeOnly,
    kPortraitOnly
} ScreenRotationMode;

@class PPUserModel;
@interface SharedDataManager : NSObject

@property (nonatomic, strong) SharedDataManager *sharedDataObj;
@property (assign, nonatomic) BOOL isLoggedIn;
@property (assign, nonatomic) ScreenRotationMode screenRotationMode;
@property (strong, nonatomic) NSString *identifierStr;
@property (assign, nonatomic) NSInteger introductionViewedCount;

@property (strong, nonatomic) PPUserModel *userModel;

+ (instancetype)instance;
- (void)saveUserInfo;
- (void)saveUserModel;
- (void)buyProduct;

@end
