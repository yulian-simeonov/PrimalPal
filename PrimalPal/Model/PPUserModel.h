//
//  PPUserModel.h
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/24/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PPUserModel : NSObject

@property (nonatomic, assign) BOOL isAuthenticated;
@property (nonatomic, assign) BOOL isPaid;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *password;

- (PPUserModel *)userModelFromDictionary:(NSDictionary *)dict;
- (NSDictionary *)convertToDictionary;

@end
