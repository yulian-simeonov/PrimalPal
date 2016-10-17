//
//  Utilities.m
//  PrimalPal
//
//  Created by YulianMobile on 5/11/13.
//  Copyright (c) 2013 YulianMobile. All rights reserved.
//

#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>
//#import "Macro.h"

#define kPaddingBtnTitle    10

@implementation Utilities

#pragma mark Shadow Rendering


+ (void) cosmeticNaviView: (UIView*)viewNavi {

//    NSString *font = @"Helvetica-Bold";
//    CGFloat size = 13.0;
//    
//    for (id subView in viewNavi.subviews) {
//        if ([subView isKindOfClass:[UIView class]])
//            [self cosmeticView:subView];
//        if (subView == nil || ![subView isKindOfClass:[UIButton class]])
//            continue;
//        UIButton *btn = (UIButton *) subView;
//        NSString *strTitle = (NSString*)[subView titleForState:UIControlStateNormal];
//        if (strTitle == nil || [strTitle isEqualToString:@""])
//            continue;
//        
//        CGSize textSize = [strTitle sizeWithFont:[UIFont fontWithName:font size:size]];
//        CGRect frame = btn.frame;
//        [btn.titleLabel setFont:[UIFont fontWithName:font size:size]];
//        frame.size.width = textSize.width + kPaddingBtnTitle*2;
//        btn.frame = frame;
//    }
}

+ (void)drawSideAndBottomDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y - 5.0f,
                                          rect.size.width,
                                          rect.size.height + 5.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)drawSideAndTopDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y - 10.0f, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y,
                                          rect.size.width,
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (NSString*) convertBoolToString:(NSString*) strBool {
    
    return [strBool isEqualToString:@"Y"] ? @"Yes" : @"No";
}

+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y - 5.0f,
                                          rect.size.width,
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)addBottomDropShadowToNavigationBarForNavigationController:(UINavigationController *)navigationController {
    UIView *gradientView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, navigationController.navigationBar.frame.size.height, navigationController.navigationBar.frame.size.width, 3.0f)];
    [gradientView setBackgroundColor:[UIColor clearColor]];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = gradientView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    [gradientView.layer insertSublayer:gradient atIndex:0];
    navigationController.navigationBar.clipsToBounds = NO;
    [navigationController.navigationBar addSubview:gradientView];
}

+ (void) cosmeticImageView:(UIImageView*)imgView {
    
    imgView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    imgView.layer.shadowOffset = CGSizeMake(1, 2);
    imgView.layer.shadowOpacity = 1;
    imgView.layer.shadowRadius = 1.0;
    //white border part
    [imgView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [imgView.layer setBorderWidth: 1.5];
}

+ (void) cosmeticLabel:(UILabel*)imgView {
    
    imgView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    imgView.layer.shadowOffset = CGSizeMake(1, 4);
    imgView.layer.shadowOpacity = 1;
    imgView.layer.shadowRadius = 1.0;
    //white border part
    [imgView.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [imgView.layer setBorderWidth: 1];
}

+ (void) cosmeticView:(UIView*)imgView {
    
    imgView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    imgView.layer.shadowOffset = CGSizeMake(1, 1);
    imgView.layer.shadowOpacity = 1;
    imgView.layer.shadowRadius = 1.0;
    //white border part
    [imgView.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [imgView.layer setBorderWidth: 1];
}

+ (void) cosmeticButton: (UIButton*)btn {
    
    btn.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    btn.layer.shadowOffset = CGSizeMake(1, 2);
    btn.layer.shadowOpacity = 1;
    btn.layer.shadowRadius = 1.0;
    //white border part
    [btn.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [btn.layer setBorderWidth: 1.5];
}

+ (UIImage *)makeRoundedImage:(UIImage *) image
                      radius: (float) radius;
{
    CALayer *imageLayer = [CALayer layer];
    imageLayer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    imageLayer.contents = (id) image.CGImage;
    
    imageLayer.masksToBounds = YES;
    imageLayer.cornerRadius = radius;
    
    UIGraphicsBeginImageContext(image.size);
    [imageLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

+ (UIImage *)scale:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (BOOL) isValidString:(NSString*) str {
    
    if ([str isEqualToString:@""] || [str isEqualToString:@" "])
        return NO;
    else
        return YES;
}

+ (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
//+ (void) showAvatar:(UIImageView*) imgView ImgName:(NSString*)strImgName {
//
//    [imgView loadFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", AVATAR_URL, strImgName]]];
//}
+ (void) showMsg:(NSString*)strMsg {

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kTitle_APP message:strMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+ (NSDate*) getDateFromString:(NSString*)aString withFormat:(NSString*)aFormat
{
	NSDate *retVal = nil;
	if (aFormat!=nil && [aFormat length] > 0)
    {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:aFormat];
		retVal = [formatter dateFromString:aString];
    }
	
	return retVal;
}

@end
