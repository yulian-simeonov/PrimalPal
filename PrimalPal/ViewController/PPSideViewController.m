//
//  PPSideViewController.m
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/22/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import "PPSideViewController.h"

#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>
#import "PPCheckinViewController.h"
#import "PPRecipesViewController.h"
#import "PPMealPlanViewController.h"
#import "PPShoppinglistViewController.h"
#import "PPFavViewController.h"

#import <FSNConnection.h>
#import <SVProgressHUD.h>
#import <CSNotificationView.h>
#import "SharedDataManager.h"
#import "PPUserModel.h"

@interface PPSideViewController ()
@property (weak, nonatomic) IBOutlet UIButton *checkinButton;
@property (weak, nonatomic) IBOutlet UIButton *recipesButton;
@property (weak, nonatomic) IBOutlet UIButton *mealplanButton;
@property (weak, nonatomic) IBOutlet UIButton *shoppinglistButton;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@property (nonatomic) id openRecipeObserver;

@end

@implementation PPSideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.openRecipeObserver = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    __weak typeof(self) weakSelf = self;
    self.openRecipeObserver = [[NSNotificationCenter defaultCenter]
                          addObserverForName:kNotiOpenRecipe
                          object:nil
                          queue:nil
                          usingBlock:^(NSNotification *note) {
                              [weakSelf onClickRecipes:nil];
                          }];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    NSLog(@"%f, %d", SCRN_HEIGHT, IS_PHONE5);
    if (SCRN_HEIGHT < 568) {
        _checkinButton.frame = CGRectMake(_checkinButton.frame.origin.x, 20, _checkinButton.frame.size.width, _checkinButton.frame.size.height);
        _recipesButton.frame = CGRectMake(_recipesButton.frame.origin.x, 20, _recipesButton.frame.size.width, _recipesButton.frame.size.height);
        _mealplanButton.frame = CGRectMake(_mealplanButton.frame.origin.x, 131, _mealplanButton.frame.size.width, _mealplanButton.frame.size.height);
        _shoppinglistButton.frame = CGRectMake(_shoppinglistButton.frame.origin.x, 139, _shoppinglistButton.frame.size.width, _shoppinglistButton.frame.size.height);
        _logoutButton.frame = CGRectMake(_logoutButton.frame.origin.x, 256, _logoutButton.frame.size.width, _logoutButton.frame.size.height);
        _settingsButton.frame = CGRectMake(_settingsButton.frame.origin.x, 372, _settingsButton.frame.size.width, _settingsButton.frame.size.height);
    }
}

#pragma mark - Handle Notification
- (void)handleNotification:(NSNotification *)noti {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIButton Action
- (IBAction) onClickCheckin:(id)sender {
    if (![SharedDataManager instance].userModel.isPaid) {
        [[SharedDataManager instance] buyProduct];
        return;
    }
    
    [self.sidePanelController showCenterPanelAnimated:YES];
    
    //Check if it is already open
    if( [[(UINavigationController*)self.sidePanelController.centerPanel topViewController] isMemberOfClass:[PPCheckinViewController class]]){
        return;
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *historyVC = [sb instantiateViewControllerWithIdentifier:kIdentifierCheckinView];
    [(UINavigationController*)self.sidePanelController.centerPanel pushViewController:historyVC animated:YES];
}

- (IBAction) onClickRecipes:(id)sender {
    [self.sidePanelController showCenterPanelAnimated:YES];
    
    //Check if it is already open
    if( [[(UINavigationController*)self.sidePanelController.centerPanel topViewController] isMemberOfClass:[PPRecipesViewController class]]){
        return;
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *historyVC = [sb instantiateViewControllerWithIdentifier:kIdentifierRecipesView];
    [(UINavigationController*)self.sidePanelController.centerPanel pushViewController:historyVC animated:YES];
}

- (IBAction) onClickMealplan:(id)sender {
    if (![SharedDataManager instance].userModel.isPaid) {
        [[SharedDataManager instance] buyProduct];
        return;
    }
    
    [self.sidePanelController showCenterPanelAnimated:YES];
    
    //Check if it is already open
    if( [[(UINavigationController*)self.sidePanelController.centerPanel topViewController] isMemberOfClass:[PPMealPlanViewController class]]){
        return;
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *historyVC = [sb instantiateViewControllerWithIdentifier:kIdentifierMealplanView];
    [(UINavigationController*)self.sidePanelController.centerPanel pushViewController:historyVC animated:YES];
}

- (IBAction) onClickShoppinglist:(id)sender {
    if (![SharedDataManager instance].userModel.isPaid) {
        [[SharedDataManager instance] buyProduct];
        return;
    }
    
    [self.sidePanelController showCenterPanelAnimated:YES];
    
    //Check if it is already open
    if( [[(UINavigationController*)self.sidePanelController.centerPanel topViewController] isMemberOfClass:[PPShoppinglistViewController class]]){
        return;
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *historyVC = [sb instantiateViewControllerWithIdentifier:kIdentifierShoppinglistView];
    [(UINavigationController*)self.sidePanelController.centerPanel pushViewController:historyVC animated:YES];
}

- (IBAction)onClickLogout:(id)sender {
    FSNConnection *connection = [self makeLogoutConnection];
    [connection start];
}

- (IBAction)onClickSetting:(id)sender {
    [self.sidePanelController showCenterPanelAnimated:YES];
    
    //Check if it is already open
    if( [[(UINavigationController*)self.sidePanelController.centerPanel topViewController] isMemberOfClass:[PPRecipesViewController class]]){
        return;
    }
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *historyVC = [sb instantiateViewControllerWithIdentifier:kIdentifierRecipesView];
    PPRecipesViewController *recipes = (PPRecipesViewController *)historyVC;
    recipes.isFav = YES;
    [(UINavigationController*)self.sidePanelController.centerPanel pushViewController:recipes animated:YES];
}
//-----------------------------------------------------------------------------------------
#pragma mark - API Call For Logout
//-----------------------------------------------------------------------------------------
- (FSNConnection *) makeLogoutConnection {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_LOGOUT]]; // API url
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
//                      NSDictionary *responseDict = (NSDictionary *)c.parseResult;
                      NSLog(@"Logout Response : %@", c.parseResult);
                      [self.sidePanelController showCenterPanelAnimated:NO];
                      
                      // Set Looged In NO
                      [SharedDataManager instance].isLoggedIn = NO;
                      [[SharedDataManager instance] saveUserInfo];
                      
                      [[NSNotificationCenter defaultCenter] postNotificationName:kNotiLogout object:nil];
//                      if (responseDict != nil) {
//                          if (responseDict[@"data"]) {
//                              [self.sidePanelController showCenterPanelAnimated:NO];
//                              [[NSNotificationCenter defaultCenter] postNotificationName:kNotiLogout object:nil];
//                          }
//                      } else {
//                          [Utilities showMsg:MESSAGE_AUTHFAILED];
//                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
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
