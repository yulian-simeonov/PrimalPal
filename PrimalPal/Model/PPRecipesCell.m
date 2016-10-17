//
//  PPRecipesCell.m
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/30/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import "PPRecipesCell.h"

#import "UIImageView+WebCache.h"
#import "DWTagList.h"
#import "PPRecipesViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <FSNConnection.h>
#import "SVProgressHUD.h"
#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>
#import <RMDateSelectionViewController/RMDateSelectionViewController.h>

#define MARGIN 5.0

@interface PPRecipesCell () <DWTagListDelegate, RMDateSelectionViewControllerDelegate> {
    NSInteger favId;
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *captionLabel;

@end

@implementation PPRecipesCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:34/255.0f green:34/255.0f blue:35/255.0f alpha:1.0f];
        self.layer.borderColor = [UIColor colorWithRed:85/255.0f green:85/255.0f blue:85/255.0f alpha:1.0f].CGColor;
        self.layer.borderWidth = 1.0f;
    // Create ImageView
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        
    // Create Description Label
        self.captionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.captionLabel.font = [UIFont fontWithName:@"GillSans-Light" size:15.0f];
        self.captionLabel.numberOfLines = 0;
        self.captionLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.captionLabel];
        
    // Create Tag list View
        _tagList = [[DWTagList alloc] initWithFrame:CGRectZero];
        [_tagList setAutomaticResize:YES];
        [_tagList setTagDelegate:self];
        // Customisation
        [_tagList setCornerRadius:11];
        [_tagList setBorderColor:[UIColor colorWithRed:104/255.0f green:186/255.0f blue:106/255.0f alpha:1.0F].CGColor];
        [_tagList setBorderWidth:1.0f];
        [_tagList setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_tagList];
        
    // Create Plan Button and Fav Button
        self.planButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.planButton.layer.borderWidth = 1.0f;
        self.planButton.layer.borderColor = [UIColor colorWithRed:85/255.0f green:85/255.0f blue:85/255.0f alpha:1.0f].CGColor;
        [self.planButton setBackgroundImage:[UIImage imageNamed:@"btn_plan"] forState:UIControlStateNormal];
        [self.planButton setBackgroundImage:[UIImage imageNamed:@"btn_plan_h"] forState:UIControlStateSelected];
        [self.planButton addTarget:self action:@selector(onClickPlan:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.planButton];
        
        self.favButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.favButton setBackgroundImage:[UIImage imageNamed:@"btn_fav"] forState:UIControlStateNormal];
        [self.favButton setBackgroundImage:[UIImage imageNamed:@"btn_fav_h"] forState:UIControlStateSelected];
        self.favButton.layer.borderWidth = 1.0f;
        self.favButton.layer.borderColor = [UIColor colorWithRed:85/255.0f green:85/255.0f blue:85/255.0f alpha:1.0f].CGColor;
        [self.favButton addTarget:self action:@selector(onClickFav:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.favButton];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.captionLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width - MARGIN * 2;
    CGFloat top = MARGIN;
    CGFloat left = MARGIN;
    
    // Image
    CGFloat height = 0.0;
    
    height += MARGIN;
    
    CGFloat ratio = [self.object[@"ratio"] floatValue];
    // Image
    CGFloat scaledHeight = floorf(width * ratio);
    height += scaledHeight;
    
    self.imageView.frame = CGRectMake(left, top, width, scaledHeight);
    
    // Label
    CGSize labelSize = CGSizeZero;
    
    labelSize = [_captionLabel.text boundingRectWithSize:CGSizeMake(width, INT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:_captionLabel.font}
                                                     context:nil].size;
    
    top = self.imageView.frame.origin.y + self.imageView.frame.size.height + MARGIN;
    self.captionLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    
    top = self.imageView.frame.origin.y + self.imageView.frame.size.height + MARGIN + labelSize.height + MARGIN;
    _tagList.frame = CGRectMake(left, top, width, _tagList.frame.size.height);
    
    top = self.imageView.frame.origin.y + self.imageView.frame.size.height + MARGIN + labelSize.height + MARGIN + _tagList.frame.size.height;
    self.planButton.frame = CGRectMake(0, top, 97, 26);
    self.favButton.frame = CGRectMake(96, top, self.frame.size.width-96, 26);
}

- (void)fillViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    [super fillViewWithObject:object inColumnWidth:columnWidth];
    
    CGFloat width = columnWidth - MARGIN * 2;
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", SERVER_URL, object[@"thumbnail"]]];
    
    self.imageView.alpha = 0;
    [self.imageView sd_setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"img_thumb"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [UIView animateWithDuration:0.3 animations:^{
            self.imageView.alpha = 1.0;
        }];
    }];

    self.captionLabel.text = [object objectForKey:@"name"];
    
    // Set Tag list contents
    _tagList.frame = CGRectMake(0, 0, width, 0);
    [_tagList setAutomaticResize:YES];
    NSArray *array = object[@"tag_names"];
    [_tagList setTags:array];
    
    
    [self.favButton setSelected:![[object objectForKey:@"fav_id"] isKindOfClass:[NSNull class]]];
}

+ (CGFloat)heightForViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    CGFloat height = 0.0;
    CGFloat width = columnWidth - MARGIN * 2;
    
    height += MARGIN;
    
    CGFloat ratio = [object[@"ratio"] floatValue];
    // Image
    CGFloat scaledHeight = floorf(width * ratio);
    height += scaledHeight;
    
    // Label
    NSString *caption = [object objectForKey:@"name"];
    CGSize labelSize = CGSizeZero;
    UIFont *labelFont = [UIFont fontWithName:@"GillSans-Light" size:15.0f];
    labelSize = [caption boundingRectWithSize:CGSizeMake(width, INT_MAX)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{NSFontAttributeName:labelFont}
                                                             context:nil].size;
    height += labelSize.height;
    height += MARGIN;
    
    // Calculate Taglist Height
    DWTagList *taglist = [[DWTagList alloc] initWithFrame:CGRectMake(0, 0, width, 0.0f)];
    [taglist setAutomaticResize:YES];
    NSArray *array = object[@"tag_names"];
    [taglist setTags:array];
    height += taglist.frame.size.height;
    
    height += MARGIN + 26;
    
    return height;
}
#pragma mark - TaglistDelegate
- (void)selectedTag:(NSString *)tagName
{
    PPRecipesViewController *parent = (PPRecipesViewController *)self.parentDelegate;
    [parent onTagSelected:tagName];
}
#pragma mark - Button Action
- (void)onClickPlan:(id)sender {
    if ([[self.object objectForKey:@"course_id"] isKindOfClass:[NSNull class]]) {
        [Utilities showMsg:@"No Course Id"];
        return;
    }
    RMDateSelectionViewController *dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
    dateSelectionVC.delegate = self;
    
    //You can enable or disable bouncing and motion effects
//    dateSelectionVC.disableBouncingWhenShowing = YES;
//    dateSelectionVC.disableMotionEffects = YES;
    
    [dateSelectionVC show];
    
    //You can access the actual UIDatePicker via the datePicker property
    dateSelectionVC.datePicker.datePickerMode = UIDatePickerModeDate;
    dateSelectionVC.datePicker.tintColor = [UIColor whiteColor];
//    dateSelectionVC.datePicker.date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    
    //You can also adjust colors (enabling example will result in a black version)
    dateSelectionVC.tintColor = [UIColor whiteColor];
    dateSelectionVC.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1];
}
- (void)onClickFav:(id)sender {
    [sender setSelected:![sender isSelected]];

    if (![sender isSelected])
        [[self makeFavConnection:[self.object[@"fav_id"] integerValue] isAdd:NO] start];
    else
        [[self makeFavConnection:[self.object[@"id"] integerValue] isAdd:YES] start];
}

#pragma mark - API call for fav add or del function
- (FSNConnection *) makeFavConnection:(NSInteger)recipeId isAdd:(BOOL)isAdd {

    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSURL *url;
    NSDictionary *parameters;
    if (isAdd) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_ADDFAV]]; // API url // API parameters
        parameters = @{@"recipe_id":[NSString stringWithFormat:@"%ld", (long)recipeId]};
    }
    else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_DELFAV]]; // API
        parameters = @{@"fav_id":[NSString stringWithFormat:@"%ld", (long)recipeId]};
    }
    
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodPOST
                          headers:nil
                       parameters:parameters
                       parseBlock:^id(FSNConnection *c, NSError **error) {
                           NSDictionary *d = [c.responseData dictionaryFromJSONWithError:error];
                           if (!d) return nil;
                           
                           // example error handling.
                           // since the demo ships with invalid credentials,
                           // running it will demonstrate proper error handling.
                           // in the case of the 4sq api, the meta json in the response holds error strings,
                           // so we create the error based on that dictionary.
                           if (c.response.statusCode != 200) {
                               *error = [NSError errorWithDomain:@"FSAPIErrorDomain"
                                                            code:1
                                                        userInfo:[d objectForKey:@"meta"]];
                           }
                           return d;
                       }
                  completionBlock:^(FSNConnection *c) {
                      [SVProgressHUD dismiss];
                      NSDictionary *responseDict = (NSDictionary *)c.parseResult;
                      NSLog(@"Get Recipes Response : %@", responseDict);
                      if (!isAdd && responseDict == nil) {
                          NSLog(@"Successfully removed");
                      } else {
                          if (responseDict != nil) {
                              if (responseDict[@"data"] != nil) {
                                  favId = [responseDict[@"data"] integerValue];
                                  NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.object];
                                  [dict setObject:[NSNumber numberWithInteger:favId] forKey:@"fav_id"];
                                  self.object = dict;
                              } else {
                                  [self.favButton setSelected:!self.favButton.selected];
                              }
                          } else {
                              [self.favButton setSelected:!self.favButton.selected];
                              [Utilities showMsg:MESSAGE_AUTHFAILED];
                          }
                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

- (FSNConnection *) makePlanConnection:(NSInteger)recipeId dateString:(NSString *)dateString {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSURL *url;
    url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_PLANMEAL]];
    NSDictionary *parameters;
    parameters = @{@"plan_date" : dateString,
                   @"recipe_id" : [NSString stringWithFormat:@"%d", recipeId],
                   @"course_id" : [NSString stringWithFormat:@"%@", self.object[@"course_id"]]
                   };
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodPOST
                          headers:nil
                       parameters:parameters
                       parseBlock:^id(FSNConnection *c, NSError **error) {
                           NSDictionary *d = [c.responseData dictionaryFromJSONWithError:error];
                           if (!d) return nil;
                           
                           // example error handling.
                           // since the demo ships with invalid credentials,
                           // running it will demonstrate proper error handling.
                           // in the case of the 4sq api, the meta json in the response holds error strings,
                           // so we create the error based on that dictionary.
                           if (c.response.statusCode != 200) {
                               *error = [NSError errorWithDomain:@"FSAPIErrorDomain"
                                                            code:1
                                                        userInfo:[d objectForKey:@"meta"]];
                           }
                           return d;
                       }
                  completionBlock:^(FSNConnection *c) {
                      [SVProgressHUD dismiss];
                      NSDictionary *responseDict = (NSDictionary *)c.parseResult;
                      NSLog(@"Get Recipes Response : %@", responseDict);
//                      if (responseDict != nil) {
//                          if (responseDict[@"data"] != nil) {
//                              favId = [responseDict[@"data"] integerValue];
//                              NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.object];
//                              [dict setObject:[NSNumber numberWithInteger:favId] forKey:@"fav_id"];
//                              self.object = dict;
//                          } else {
//                              [self.favButton setSelected:!self.favButton.selected];
//                          }
//                      } else {
//                          [self.favButton setSelected:!self.favButton.selected];
//                          [Utilities showMsg:MESSAGE_AUTHFAILED];
//                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}
#pragma mark - RMDAteSelectionViewController Delegates
- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSDate *)aDate {
    _planButton.selected = YES;
    NSLog(@"Successfully selected date: %@", aDate);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setDateFormat:@"dd MMMM, yyyy"];
    [[self makePlanConnection:[self.object[@"id"] integerValue] dateString:[dateFormatter stringFromDate:aDate]] start];
}

- (void)dateSelectionViewControllerDidCancel:(RMDateSelectionViewController *)vc {
    NSLog(@"Date selection was canceled");
}

@end

