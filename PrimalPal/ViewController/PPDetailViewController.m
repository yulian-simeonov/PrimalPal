//
//  PPDetailViewController.m
//  PrimalPal
//
//  Created by Yulian Simeonov on 8/6/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import "PPDetailViewController.h"

#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>
#import "SVProgressHUD.h"
#import <FSNConnection.h>
#import "UIImageView+WebCache.h"
#import <RMDateSelectionViewController/RMDateSelectionViewController.h>

@interface PPDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate, RMDateSelectionViewControllerDelegate> {
    CGFloat cookWebViewHeight;
    CGFloat ingWebViewHeight;
    UIWebView *ingWebView;
    UIWebView *cookWebView;
}
@property (weak, nonatomic) IBOutlet UITableView *detailTable;
@property (weak, nonatomic) IBOutlet UIView *detailView;
@property (strong, nonatomic) NSDictionary *recipeDict;

@property (weak, nonatomic) IBOutlet UILabel *preperationtimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cooktimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *servesLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *preperationtimeLabel1;
@property (weak, nonatomic) IBOutlet UILabel *cooktimeLabel1;
@property (weak, nonatomic) IBOutlet UILabel *servesLabel1;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel1;
@property (weak, nonatomic) IBOutlet UIImageView *foodImageView;
@property (weak, nonatomic) IBOutlet UIButton *planButton;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIButton *uparrowButton;
@property (weak, nonatomic) IBOutlet UIButton *downarrowButton;

@end

@implementation PPDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self makeGetRecipeConnection] start];
    
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [_uparrowButton addGestureRecognizer:panGes];
    
    UIPanGestureRecognizer *panGes1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan1:)];
    [_downarrowButton addGestureRecognizer:panGes1];
}

#pragma mark - UIPanGestureRecognizer Delegate
- (void)pan:(UIPanGestureRecognizer *)gesture
{
    static CGPoint originalCenter;
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        originalCenter = _detailView.center;
        gesture.view.layer.shouldRasterize = YES;
    }
    if (gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translate = [gesture translationInView:_detailView.superview];
        _detailView.center = CGPointMake(originalCenter.x, originalCenter.y + translate.y);
    }
    if (gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateFailed ||
        gesture.state == UIGestureRecognizerStateCancelled)
    {
        _detailView.layer.shouldRasterize = NO;
        if (_detailView.frame.origin.y > -40) {
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = _detailView.frame;
                frame.origin.y = 64;
                _detailView.frame = frame;
            }];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = _detailView.frame;
                frame.origin.y = -440;
                _detailView.frame = frame;
            }];
        }
        
    }
}

- (void)pan1:(UIPanGestureRecognizer *)gesture
{
    static CGPoint originalCenter;
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        originalCenter = _detailView.center;
        gesture.view.layer.shouldRasterize = YES;
    }
    if (gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translate = [gesture translationInView:_detailView.superview];
        _detailView.center = CGPointMake(originalCenter.x, originalCenter.y + translate.y);
    }
    if (gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateFailed ||
        gesture.state == UIGestureRecognizerStateCancelled)
    {
        _detailView.layer.shouldRasterize = NO;
        NSLog(@"%f", _detailView.center.y);
        if (_detailView.frame.origin.y > -340) {
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = _detailView.frame;
                frame.origin.y = 64;
                _detailView.frame = frame;
            }];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                CGRect frame = _detailView.frame;
                frame.origin.y = -440;
                _detailView.frame = frame;
            }];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRecipeContents {
    self.title = _recipeDict[@"name"];
    
    [_foodImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", SERVER_URL, _recipeDict[@"thumbnail"]]] placeholderImage:[UIImage imageNamed:@"img_thumb"]];
    
    _nameLabel.text = _recipeDict[@"name"];
    _preperationtimeLabel.text = [NSString stringWithFormat:@"%@", _recipeDict[@"prep_time"]];
    _cooktimeLabel.text = [NSString stringWithFormat:@"%@", _recipeDict[@"cook_time"]];
    _servesLabel.text = [NSString stringWithFormat:@"%@", _recipeDict[@"servings"]];
    
    _nameLabel1.text = _recipeDict[@"name"];
    _preperationtimeLabel1.text = [NSString stringWithFormat:@"%@", _recipeDict[@"prep_time"]];
    _cooktimeLabel1.text = [NSString stringWithFormat:@"%@", _recipeDict[@"cook_time"]];
    _servesLabel1.text = [NSString stringWithFormat:@"%@", _recipeDict[@"servings"]];
    
    _favId = [_recipeDict[@"fav_id"] integerValue];
    cookWebView = [self createWebViewWithHTML:_recipeDict[@"cooking_process"]];
    ingWebView = [self createWebViewWithHTML:_recipeDict[@"ingredients"]];
    [self.favButton setSelected:_favId != 0];
}

#pragma mark - API Call For Get Recipe
//-----------------------------------------------------------------------------------------
- (FSNConnection *) makeGetRecipeConnection {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/%d", SERVER_URL, API_GETRECIPEDETAIL, _recipeIndex]]; // API url // API parameters

    return [FSNConnection withUrl:url
                           method:FSNRequestMethodGET
                          headers:nil
                       parameters:nil
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
                      
                      if (responseDict != nil) {
                          _recipeDict = responseDict[@"data"];
                          [self setRecipeContents];
                          [_detailTable reloadData];
                      } else {
                          [Utilities showMsg:MESSAGE_AUTHFAILED];
                          [self.sidePanelController showCenterPanelAnimated:NO];
                          [[NSNotificationCenter defaultCenter] postNotificationName:kNotiLogout object:nil];
                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

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
                          [[NSNotificationCenter defaultCenter] postNotificationName:kNotiFavChanged object:[NSNumber numberWithInt:-1]];
                      } else {
                          if (responseDict != nil) {
                              
                              if (responseDict[@"data"] != nil) {
                                  _favId = [responseDict[@"data"] integerValue];
                                  if (!_isFromMealplan)
                                      [[NSNotificationCenter defaultCenter] postNotificationName:kNotiFavChanged object:[NSNumber numberWithInt:_favId]];
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
                   @"course_id" : [NSString stringWithFormat:@"%@", _recipeDict[@"course_id"]]
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

#pragma mark - UIButton Action
- (IBAction)onClickHamburger:(id)sender {
    [[(JASidePanelController*)self.navigationController sidePanelController] toggleRightPanel:nil];
}

- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onClickPlan:(id)sender {
    if ([[_recipeDict objectForKey:@"course_id"] isKindOfClass:[NSNull class]]) {
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
- (IBAction)onClickFav:(id)sender {
    [sender setSelected:![sender isSelected]];
    
    if (![sender isSelected])
        [[self makeFavConnection:_favId isAdd:NO] start];
    else
        [[self makeFavConnection:[_recipeDict[@"id"] integerValue] isAdd:YES] start];
}
- (IBAction)onClickUp:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _detailView.frame;
        frame.origin.y = -440;
        _detailView.frame = frame;
    }];
}
- (IBAction)onClickDown:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = _detailView.frame;
        frame.origin.y = 64;
        _detailView.frame = frame;
    }];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (UIWebView *) createWebViewWithHTML:(NSString *)htmlString{
    //create the string
    NSMutableString *html = [NSMutableString stringWithString: @"<html><head><title></title></head><body style=\"background:transparent; font-family:GillSans; font-size:17.0f\"  text=\"#FFFFFF\">"];
    
    //continue building the string
    [html appendString:htmlString];
    [html appendString:@"</body></html>"];
    
    //instantiate the web view
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, _detailTable.frame.size.width, 0)];
    [webView setOpaque:NO];
    
    [webView setTintColor:[UIColor whiteColor]];
    webView.userInteractionEnabled = NO;
    //make the background transparent
    [webView setBackgroundColor:[UIColor clearColor]];
    webView.delegate = self;
    //pass the string to the webview
    [webView loadHTMLString:[html description] baseURL:nil];
    
    //add it to the subview
    return webView;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    CGRect frame = aWebView.frame;
    frame.size.height = 1;
    aWebView.frame = frame;
    
    CGSize fittingSize = [aWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    aWebView.frame = frame;
    
    if (aWebView == cookWebView)
        cookWebViewHeight = frame.size.height;
    else
        ingWebViewHeight = frame.size.height;
    [_detailTable reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_recipeDict != nil) {
        if (indexPath.section == 1) {
            return cookWebViewHeight;
        } else {
            return ingWebViewHeight;
        }
    }
    
    return 20.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    headView.backgroundColor = [UIColor clearColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont fontWithName:@"GillSans" size:17.0f]];
    label.text = section == 0 ? @"INGREDIENTS:" : @"COOKING INSTRUCTIONS:";
    [headView addSubview:label];
    
    UIView *bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 29, tableView.frame.size.width, 0.7)];
    bannerView.backgroundColor = [UIColor lightGrayColor];
    bannerView.alpha = 0.7;
    [headView addSubview:bannerView];
    
    return headView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"DetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        
    }
    if (_recipeDict != nil) {
        [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        if (indexPath.section == 1) {
            [cell.contentView addSubview:cookWebView];
        } else {
            [cell.contentView addSubview:ingWebView];
        }
    }
    return cell;
}
#pragma mark - RMDAteSelectionViewController Delegates
- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSDate *)aDate {
    _planButton.selected = YES;
    NSLog(@"Successfully selected date: %@", aDate);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMMM, yyyy"];
    [[self makePlanConnection:[_recipeDict[@"id"] integerValue] dateString:[dateFormatter stringFromDate:aDate]] start];
}

- (void)dateSelectionViewControllerDidCancel:(RMDateSelectionViewController *)vc {
    NSLog(@"Date selection was canceled");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
