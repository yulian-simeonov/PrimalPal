//
//  PPUserModel.m
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/24/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import "PPUserModel.h"

@implementation PPUserModel

- (PPUserModel *)userModelFromDictionary:(NSDictionary *)dict {
    if (dict == nil) {
        _firstName = @"";
        _email = @"";
        _userName = @"";
        _password = @"";
        _isAuthenticated = NO;
        _isPaid = NO;
        return self;
    }
    _firstName = [dict objectForKey:@"FirstName"];
    _email = [dict objectForKey:@"Email"];
    _userName = [dict objectForKey:@"Username"];
    _password = [dict objectForKey:@"Password"];
    _isAuthenticated = [[dict objectForKey:@"Authenticated"] boolValue];
    _isPaid = [[dict objectForKey:@"IsPaid"] boolValue];
    return self;
}

- (NSDictionary *)convertToDictionary {
    NSDictionary *dict = @{@"FirstName" : _firstName,
                           @"Email" : _email,
                           @"Username" : _userName,
                           @"Password" : _password,
                           @"Authenticated" : [NSNumber numberWithBool:_isAuthenticated],
                           @"IsPaid" : [NSNumber numberWithBool:_isPaid]};
    return dict;
}

@end
