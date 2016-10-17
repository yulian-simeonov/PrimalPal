//
//  PPMealPlanViewController.m
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/23/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import "PPFavViewController.h"

#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>
#import "INSSearchBar.h"
#import <CCBottomRefreshControl/UIScrollView+BottomRefreshControl.h>
#import <FSNConnection.h>
#import "PPMealplanTableViewCell.h"
#import "PPIntroductionViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "PPDetailViewController.h"

@interface PPFavViewController () <INSSearchBarDelegate, UITableViewDataSource, UITableViewDelegate> {
    NSInteger selIdx;
}

@property (nonatomic, strong) INSSearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *mealPlanArray;
@property (nonatomic, strong) UIRefreshControl *bottomRefreshControl;

@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITableView *mealplanTable;

@end

@implementation PPFavViewController

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
    // Create Logout Notification
    self.sidePanelController.allowLeftSwipe = NO;
    self.sidePanelController.allowRightSwipe = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivedLogoutNoti) name:kNotiLogout object:nil];
    
    _bottomRefreshControl = [UIRefreshControl new];
    
    [self createSearchBar];
    
    _mealplanTable.editing = NO;
    
    _mealPlanArray = [NSMutableArray new];
    
    // Show Introduction View for Swipe Animation
    NSLog(@"%ld", (long)[SharedDataManager instance].introductionViewedCount);
    if ([SharedDataManager instance].introductionViewedCount < 3) {
        PPIntroductionViewController *introductionView = [PPIntroductionViewController new];
        [[UIApplication sharedApplication].delegate.window addSubview:introductionView.view];
    }
    [[self makeGetMealPlanConnection] start];
}

#pragma mark - Create Search Bar
- (void)createSearchBar {
    self.searchBar = [[INSSearchBar alloc] initWithFrame:CGRectMake(20, 0, 44.0f, CGRectGetHeight(_searchView.frame))];
    self.searchBar.searchField.placeholder = @"Search for recipes in your meal plan...";
    
    [self.searchBar.searchField setValue:[UIFont fontWithName:@"IowanOldStyle-Italic" size:16.0]
                              forKeyPath:@"_placeholderLabel.font"];
    [self.searchBar.searchField setValue:[UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1.0]
                              forKeyPath:@"_placeholderLabel.textColor"];
	self.searchBar.delegate = self;
	[self.searchView addSubview:self.searchBar];
}

- (IBAction)onClickTextfield:(id)sender {
    [_searchBar showSearchBar:nil];
}

#pragma mark - search bar delegate

- (CGRect)destinationFrameForSearchBar:(INSSearchBar *)searchBar
{
	return CGRectMake(0, 0, CGRectGetWidth(self.searchView.bounds), CGRectGetHeight(_searchView.frame));
}

- (void)searchBar:(INSSearchBar *)searchBar willStartTransitioningToState:(INSSearchBarState)destinationState
{
	// Do whatever you deem necessary.
}

- (void)searchBar:(INSSearchBar *)searchBar didEndTransitioningFromState:(INSSearchBarState)previousState
{
	// Do whatever you deem necessary.
}

- (void)searchBarDidTapReturn:(INSSearchBar *)searchBar
{
	// Do whatever you deem necessary.
	// Access the text from the search bar like searchBar.searchField.text
    [searchBar.searchField resignFirstResponder];
}

- (void)searchBarTextDidChange:(INSSearchBar *)searchBar
{
	// Do whatever you deem necessary.
	// Access the text from the search bar like searchBar.searchField.text
}

#pragma mark - Received logout Notification
- (void)onReceivedLogoutNoti {
    [self.navigationController popToRootViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiShowLogin object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
#pragma mark - UIButton Action
- (IBAction)onClickHamburger:(id)sender {
    [[(JASidePanelController*)self.navigationController sidePanelController] toggleRightPanel:nil];
}

- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (void)removeDelButton:(NSInteger)index{
    for (int i=0; i<_mealPlanArray.count; i++) {
        if (i != index) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            PPMealplanTableViewCell *cell = (PPMealplanTableViewCell *)[_mealplanTable cellForRowAtIndexPath:indexPath];
            [UIView animateWithDuration:0.2 animations:^{
                cell.delButton.alpha = 0.0;
            }];
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [_searchBar.searchField resignFirstResponder];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selIdx = indexPath.row;
    // You can do something when the user taps on a collectionViewCell here
    [self performSegueWithIdentifier:@"ShowDetailFromFav" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _mealPlanArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"MealPlanTableViewCell";
    PPMealplanTableViewCell *cell = (PPMealplanTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];

    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PPMealplanTableViewCell" owner:self options:nil] objectAtIndex:0];
        cell.mealImage.layer.cornerRadius = 30.0f;
    }
    [cell fillViewWithObject:_mealPlanArray[indexPath.row]];
    cell.parentDelegate = self;
    cell.tag = indexPath.row;
    cell.indexLabel.text = [NSString stringWithFormat:@"%d.", (int)indexPath.row+1];
    [cell.delButton addTarget:self action:@selector(onClickDelCell:) forControlEvents:UIControlEventTouchUpInside];
    cell.delButton.tag = indexPath.row;
    return cell;
}

- (void)onClickDelCell:(id)sender {
    NSInteger idx = [sender tag];
    
    NSDictionary *dict = _mealPlanArray[idx];
    [[self makeDelMealPlanConnection:[dict[@"id"] integerValue]] start];
    
    [_mealPlanArray removeObjectAtIndex:idx];
    [_mealplanTable reloadData];
    
}
//-----------------------------------------------------------------------------------------
#pragma mark - API Call For Get MealPlan
//-----------------------------------------------------------------------------------------
- (FSNConnection *) makeGetMealPlanConnection {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_GETMEALPLAN]]; // API url // API parameters
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodPOST
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
                      NSLog(@"Get MealPlan Response : %@", responseDict);
                      
                      if (responseDict != nil) {
                          [_mealPlanArray removeAllObjects];
                          for (NSDictionary *dict in responseDict[@"data"]) {
                              [_mealPlanArray addObjectsFromArray:dict[@"recipes"]];
                          }
                          [_mealplanTable reloadData];
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

- (FSNConnection *) makeDelMealPlanConnection:(NSInteger)index {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_DELMEALPLAN]]; // API url // API parameters
    NSDictionary *parameters = @{@"urp_id" : [NSNumber numberWithInteger:index]};
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
                      NSLog(@"Get MealPlan Response : %@", responseDict);
                      
                  }
                    progressBlock:^(FSNConnection *c) {
                        NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
                    }];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[PPDetailViewController class]]) {
        PPDetailViewController *detailVC = (PPDetailViewController *)segue.destinationViewController;
        NSDictionary *item = _mealPlanArray[selIdx];
        detailVC.recipeIndex = [item[@"recipe_id"] integerValue];
        detailVC.favId = [item[@"fav_id"] isKindOfClass:[NSNull class]] ? -1 : [item[@"fav_id"] integerValue];
        detailVC.isFromMealplan = YES;
    }
}

@end
