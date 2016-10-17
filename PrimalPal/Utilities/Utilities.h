//
//  Utilities.h
//  PrimalPal
//
//  Created by YulianMobile on 5/11/13.
//  Copyright (c) 2013 YulianMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject

//@property (retain, nonatomic) BDKNotifyHUD *notifySuccess;
//@property (retain, nonatomic) BDKNotifyHUD *notifyFail;

+ (void) cosmeticView: (UIView*)viewNavi;
+ (void) cosmeticNaviView: (UIView*)viewNavi;
+ (void)drawSideAndBottomDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
+ (void)drawSideAndTopDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context;
+ (void)addBottomDropShadowToNavigationBarForNavigationController:(UINavigationController *)navigationController;
+ (void) cosmeticImageView:(UIImageView*)imgView;
+ (void) cosmeticButton: (UIButton*)btn;
+ (void) cosmeticLabel:(UILabel*)imgView;
+ (BOOL) isValidString:(NSString*) str;
+ (BOOL) validateEmailWithString:(NSString*)email;
+ (void) showMsg:(NSString*)strMsg;
+ (UIImage *)makeRoundedImage:(UIImage *) image radius: (float) radius;
+ (UIImage *)scale:(UIImage *)image toSize:(CGSize)size;
//+ (void) showAvatar:(UIImageView*) imgView ImgName:(NSString*)strImgName;
+ (NSString*) convertBoolToString:(NSString*) strBool;
@end
