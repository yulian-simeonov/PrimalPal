//
//  PPViewController.m
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/20/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import "PPDashboardViewController.h"

#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>
#import "UIView+Positioning.h"
#import "AnimatedTableCell.h"
#import "PPCheckinViewController.h"
#import "PPRecipesViewController.h"
#import "PPMealPlanViewController.h"
#import "PPShoppinglistViewController.h"
#import "PPLoginViewController.h"

#import <FSNConnection.h>
#import <SVProgressHUD.h>
#import "PPUserModel.h"
#import "IAPHelper.h"

#define tableViewCellHeight 125

@interface PPDashboardViewController () <UITableViewDataSource, UITableViewDelegate> {
    bool tableAnimated;
    NSArray *imageArray;
    BOOL isLoggedIn;
    NSInteger curIdx;
}

@property (weak, nonatomic) IBOutlet UITableView *dashboardTable;
@property (nonatomic) id openRecipeObserver;
@property (nonatomic) id loggedInObserver;

@end

@implementation PPDashboardViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self startTableViewAnimation:_dashboardTable];
}

- (void)dealloc {
    self.openRecipeObserver = nil;
    self.loggedInObserver = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    __weak typeof(self) weakSelf = self;
    self.openRecipeObserver = [[NSNotificationCenter defaultCenter]
                               addObserverForName:kNotiOpenRecipe
                               object:nil
                               queue:nil
                               usingBlock:^(NSNotification *note) {
                                   [weakSelf goToView:1];
                               }];
    
    self.sidePanelController.allowLeftSwipe = NO;
    self.sidePanelController.allowRightSwipe = NO;
    
    imageArray = @[@"btn_checkin", @"btn_recipes", @"btn_mealplan", @"btn_shoppinglist"];
    [_dashboardTable reloadData];
    
    if (![SharedDataManager instance].isLoggedIn) {
        [self performSegueWithIdentifier:@"ShowLoginView" sender:self];
    } else {
        [[SharedDataManager instance] buyProduct];
    }
    // Create Notification for ShowLogin
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivedShowLoginNoti) name:kNotiShowLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivedLogoutNoti) name:kNotiLogout object:nil];
    
    self.loggedInObserver = [[NSNotificationCenter defaultCenter]
                               addObserverForName:kNotiLoggedIn
                               object:nil
                               queue:nil
                               usingBlock:^(NSNotification *note) {
                                   [[SharedDataManager instance] buyProduct];
                               }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden { return NO; }

#pragma mark - On Received Notification
- (void)onReceivedShowLoginNoti {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginVC = [sb instantiateViewControllerWithIdentifier:kIdentifierLoginView];
    [self.navigationController presentViewController:[[UINavigationController alloc] initWithRootViewController:loginVC] animated:YES completion:nil];
}

- (void)onReceivedLogoutNoti {
    [self.navigationController popToRootViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiShowLogin object:nil];
}

- (void)productPurchased:(NSNotification *)notification {
    
//    NSString * productIdentifier = notification.object;
//    [Utilities showMsg:MESSAGE_PURCHASESUCCESS];
    [SharedDataManager instance].userModel.isPaid = YES;
    [[SharedDataManager instance] saveUserModel];
    
    [[self makeSetPaidConnection] start];
//    [self goToView:curIdx]
}

#pragma mark -
#pragma mark TableView DataSource Methods

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return imageArray.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"Cell";
    
    AnimatedTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[AnimatedTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell configureCellContentSizeWidth:tableView.frame.size.width height:tableViewCellHeight];

        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, tableViewCellHeight)];
        [button setImage:[UIImage imageNamed:imageArray[indexPath.row]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(onClickButtons:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = indexPath.row;
        [cell.atcContentView addSubview:button];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    [cell resetPosition];
    
    // Trigger tableView didLoad and then start animation
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        // Show once only
        if (!tableAnimated) [self startTableViewAnimation:tableView];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void) startTableViewAnimation:(UITableView *)table
{
    tableAnimated = YES;
    for (AnimatedTableCell *atCell in table.visibleCells) {
        if ([table.visibleCells indexOfObject:atCell] % 2 == 0)
            [atCell pushCellWithAnimation:YES direction:@"left"];
        else
            [atCell pushCellWithAnimation:YES direction:@"right"];
    }
}

- (void)onClickButtons:(id)sender {
    NSInteger index = [sender tag];
    curIdx = index;
    if (![SharedDataManager instance].userModel.isPaid && index != 1) {
//        [[self makeCheckConnection] start];
        [[SharedDataManager instance] buyProduct];
    } else {
        [self goToView:index];
    }
}

- (void)goToView:(NSInteger)index {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if (index == 0) {
        [self.sidePanelController showCenterPanelAnimated:YES];
        //Check if it is already open
        if( [[(UINavigationController*)self.sidePanelController.centerPanel topViewController] isMemberOfClass:[PPCheckinViewController class]]){
            return;
        }
        UIViewController *checkinVC = [sb instantiateViewControllerWithIdentifier:kIdentifierCheckinView];
        [(UINavigationController*)self.sidePanelController.centerPanel pushViewController:checkinVC animated:YES];
    } else if (index == 1) {
        [self.sidePanelController showCenterPanelAnimated:YES];
        //Check if it is already open
        if( [[(UINavigationController*)self.sidePanelController.centerPanel topViewController] isMemberOfClass:[PPRecipesViewController class]]){
            return;
        }
        UIViewController *recipesVC = [sb instantiateViewControllerWithIdentifier:kIdentifierRecipesView];
        [(UINavigationController*)self.sidePanelController.centerPanel pushViewController:recipesVC animated:YES];
    } else if (index == 2) {
        [self.sidePanelController showCenterPanelAnimated:YES];
        //Check if it is already open
        if( [[(UINavigationController*)self.sidePanelController.centerPanel topViewController] isMemberOfClass:[PPMealPlanViewController class]]){
            return;
        }
        UIViewController *mealplanVC = [sb instantiateViewControllerWithIdentifier:kIdentifierMealplanView];
        [(UINavigationController*)self.sidePanelController.centerPanel pushViewController:mealplanVC animated:YES];
    } else if (index == 3) {
        [self.sidePanelController showCenterPanelAnimated:YES];
        //Check if it is already open
        if( [[(UINavigationController*)self.sidePanelController.centerPanel topViewController] isMemberOfClass:[PPShoppinglistViewController class]]){
            return;
        }
        UIViewController *shoppinglistVC = [sb instantiateViewControllerWithIdentifier:kIdentifierShoppinglistView];
        [(UINavigationController*)self.sidePanelController.centerPanel pushViewController:shoppinglistVC animated:YES];
    }
}

- (void) replayAnimation
{
    [self startTableViewAnimation:_dashboardTable];
}

#pragma mark -
#pragma mark TableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableViewCellHeight;
}

#pragma mark - UIButton Action
- (IBAction)onClickHamburger:(id)sender {
    [[(JASidePanelController*)self.navigationController sidePanelController] toggleRightPanel:nil];
}


#pragma mark - API Call For Login
//-----------------------------------------------------------------------------------------
- (FSNConnection *) makeLoginConnection {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_LOGIN]]; // API url
    NSDictionary *parameters = @{@"email":[SharedDataManager instance].userModel.email,
                                 @"password":[SharedDataManager instance].userModel.password}; // API parameters
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
                      NSLog(@"Login Response : %@", responseDict);
                      if (responseDict != nil) {
                          if (responseDict[@"data"]) {
                              PPUserModel *userModel = [[PPUserModel alloc] init];
                              userModel = [userModel userModelFromDictionary:responseDict[@"data"]];
                              if (userModel.isAuthenticated) {
                                  [self dismissViewControllerAnimated:YES completion:nil];
                                  // Set Looged In YES
                                  [SharedDataManager instance].isLoggedIn = YES;
                                  [[SharedDataManager instance] saveUserInfo];
                                  isLoggedIn = YES;
                                  
                                  [[self makeCheckConnection] start];
                              } else {
                                  [Utilities showMsg:MESSAGE_AUTHFAILED];
                              }
                          }
                      } else {
                          [Utilities showMsg:MESSAGE_AUTHFAILED];
                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

- (FSNConnection *) makeCheckConnection {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_ISPAID]]; // API url
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
                      NSLog(@"Login Response : %@", responseDict);
                      if (responseDict != nil) {
                          if (responseDict[@"data"]) {
                              // Set Looged In YES
                              [SharedDataManager instance].userModel.isPaid = [responseDict[@"data"][@"AllowAccess"] boolValue];
                              [[SharedDataManager instance] saveUserModel];
                              if (![SharedDataManager instance].userModel.isPaid )
                                  [self buyProduct];
                              else
                                  [self goToView:curIdx];
                          }
                      } else {
                          [Utilities showMsg:MESSAGE_AUTHFAILED];
                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}

- (FSNConnection *) makeSetPaidConnection {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_SETPAID]]; // API url
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
                      NSLog(@"SetPaid Response : %@", responseDict);
                      if (responseDict != nil) {
                          if (responseDict[@"data"]) {
                              
                          }
                      } else {
                          [Utilities showMsg:MESSAGE_AUTHFAILED];
                      }
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}


- (void)buyProduct {
    if (![SharedDataManager instance].userModel.isPaid) {
        [[SharedDataManager instance] buyProduct];
    }
}

@end