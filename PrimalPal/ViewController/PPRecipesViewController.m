//
//  PPRecipesViewController.m
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/23/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import "PPRecipesViewController.h"

#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>
#import "INSSearchBar.h"
#import "PPRecipesCell.h"
#import "PSCollectionView.h"
#import "SVProgressHUD.h"
#import <CCBottomRefreshControl/UIScrollView+BottomRefreshControl.h>
#import <FSNConnection.h>
#import "PPDetailViewController.h"

#define kReloadCount 14

@interface PPRecipesViewController () <INSSearchBarDelegate, PSCollectionViewDelegate, PSCollectionViewDataSource> {
    NSInteger offset;
    NSInteger selIdx;
}

@property (nonatomic, retain) NSMutableArray *images;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (nonatomic, strong) INSSearchBar *searchBar;

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *recipesArray;
@property (nonatomic, strong) PSCollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *bottomRefreshControl;
@property (nonatomic, strong) UIRefreshControl *topRefreshControl;
@property (weak, nonatomic) IBOutlet UIView *datepickerView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation PPRecipesViewController

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
    self.sidePanelController.allowLeftSwipe = YES;
    self.sidePanelController.allowRightSwipe = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivedLogoutNoti) name:kNotiLogout object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivedFavChanged:) name:kNotiFavChanged object:nil];
    
    self.items = [NSMutableArray array];
    _recipesArray = [NSMutableArray array];
    
    _topRefreshControl = [[UIRefreshControl alloc] init];
    _bottomRefreshControl = [UIRefreshControl new];
    offset = 0;
    
    [self createSearchBar];
    [self createCollectionView];
    
    [self.view bringSubviewToFront:_datepickerView];
}

- (void)dataSourceDidLoad {
    for (int i=0; i<kReloadCount; i++) {
        int index = offset + i;
        if (index < _items.count) {
            [_recipesArray addObject:_items[index]];
        } else {
            offset = index;
            break;
        }
    }
    if (offset < _items.count) {
        offset += kReloadCount;
    }
    [self.collectionView reloadData];
    [_bottomRefreshControl endRefreshing];
}

- (void)dataSourceDidError {
    [self.collectionView reloadData];
}

#pragma mark - Load Collection View
- (void)createCollectionView {
    
    self.collectionView = [[PSCollectionView alloc] initWithFrame:CGRectMake(0, 130, self.view.frame.size.width, self.view.frame.size.height-130)];
    [self.view addSubview:self.collectionView];
    self.collectionView.collectionViewDelegate = self;
    self.collectionView.collectionViewDataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.numColsPortrait = 2;
    self.collectionView.numColsLandscape = 3;
    UILabel *loadingLabel = [[UILabel alloc] initWithFrame:self.collectionView.bounds];
    loadingLabel.text = @"Loading...";
    [loadingLabel setTextAlignment:NSTextAlignmentCenter];
    self.collectionView.loadingView = loadingLabel;
    [self performSelector:@selector(loadDataSource) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
    
    [_topRefreshControl addTarget:self action:@selector(refreshTop:)
             forControlEvents:UIControlEventValueChanged];
    self.collectionView.alwaysBounceVertical = YES;
//    [self.collectionView addSubview:_topRefreshControl];
    
    [_bottomRefreshControl addTarget:self action:@selector(refreshBottom:) forControlEvents:UIControlEventValueChanged];
	self.collectionView.bottomRefreshControl = _bottomRefreshControl;
}

- (void)refreshTop:(id)sender {
    NSLog(@"start refresh");
}

- (void)refreshBottom:(id)sender {
    NSLog(@"bottom refresh");
    [self loadDataSource];
}

- (void)loadDataSource {
    FSNConnection *connection = [self makeGetRecipesConnection];
    [connection start];
}

#pragma mark - PSCollectionViewDelegate and DataSource
- (NSInteger)numberOfViewsInCollectionView:(PSCollectionView *)collectionView {
    return [_recipesArray count];
}

- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView viewAtIndex:(NSInteger)index {
    [self hideDatePicker];
    [self.searchBar.searchField resignFirstResponder];
    
    NSDictionary *item = [_recipesArray objectAtIndex:index];
    
    PPRecipesCell *v = (PPRecipesCell *)[self.collectionView dequeueReusableView];
    if (!v) {
        v = [[PPRecipesCell alloc] initWithFrame:CGRectZero];
        v.parentDelegate = self;
    }
    
    [v fillViewWithObject:item inColumnWidth:self.collectionView.colWidth];
    
    return v;
}

- (CGFloat)heightForViewAtIndex:(NSInteger)index {
    NSDictionary *item = [_recipesArray objectAtIndex:index];
    
    return [PPRecipesCell heightForViewWithObject:item inColumnWidth:self.collectionView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectView:(PSCollectionViewCell *)view atIndex:(NSInteger)index {
    //    NSDictionary *item = [self.items objectAtIndex:index];
    selIdx = index;
    // You can do something when the user taps on a collectionViewCell here
    [self performSegueWithIdentifier:@"ShowDetailView" sender:self];
}

#pragma mark - Create Search Bar
- (void)createSearchBar {
    self.searchBar = [[INSSearchBar alloc] initWithFrame:CGRectMake(20, 0, 44.0f, CGRectGetHeight(_searchView.frame))];
    self.searchBar.searchField.placeholder = @"Search for recipes...";
    
    [self.searchBar.searchField setValue:[UIFont fontWithName:@"IowanOldStyle-Italic" size:17.0]
                              forKeyPath:@"_placeholderLabel.font"];
    [self.searchBar.searchField setValue:[UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1.0]
                              forKeyPath:@"_placeholderLabel.textColor"];
	self.searchBar.delegate = self;
	[self.searchView addSubview:self.searchBar];
}

- (IBAction)onClickTextfield:(id)sender {
    [_searchBar showSearchBar:nil];
}

#pragma mark - Received logout Notification
- (void)onReceivedLogoutNoti {
    [self.navigationController popToRootViewControllerAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiShowLogin object:nil];
}

- (void)onReceivedFavChanged:(NSNotification *)noti {
    NSLog(@"Fav is Added %d", [noti.object integerValue]);
    NSDictionary *item = [_recipesArray objectAtIndex:selIdx];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:item];
    if ([noti.object integerValue] == -1) {
        [dict setObject:[NSNull null] forKey:@"fav_id"];
    } else {
        [dict setObject:[NSNumber numberWithInteger:[noti.object integerValue]] forKey:@"fav_id"];
    }
    [_recipesArray replaceObjectAtIndex:selIdx withObject:dict];
    
    [_collectionView reloadData];
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
- (IBAction)onClickDone:(id)sender {
    [self hideDatePicker];
}

- (void)hideDatePicker {
    if (_datepickerView.frame.origin.y < SCRN_HEIGHT) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = _datepickerView.frame;
            frame.origin.y = SCRN_HEIGHT;
            _datepickerView.frame = frame;
        }];
    }
}

- (void)showDatePicker {
    if (_datepickerView.frame.origin.y >= SCRN_HEIGHT) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect frame = _datepickerView.frame;
            frame.origin.y = SCRN_HEIGHT-209;
            _datepickerView.frame = frame;
        }];
    }
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
    offset = 0;
    [self.items removeAllObjects];
    [self.recipesArray removeAllObjects];
    [self loadDataSource];
    [searchBar.searchField resignFirstResponder];
}

- (void)searchBarTextDidChange:(INSSearchBar *)searchBar
{
	// Do whatever you deem necessary.
	// Access the text from the search bar like searchBar.searchField.text
}

#pragma mark - On Tag Selected
- (void)onTagSelected:(NSString *)tagName {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
//                                                    message:[NSString stringWithFormat:@"You tapped tag %@", tagName]
//                                                   delegate:nil
//                                          cancelButtonTitle:@"Ok"
//                                          otherButtonTitles:nil];
//    [alert show];
}
//-----------------------------------------------------------------------------------------
#pragma mark - API Call For Login
//-----------------------------------------------------------------------------------------
- (FSNConnection *) makeGetRecipesConnection {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_GETRECIPES]]; // API url // API parameters
    NSString *offsetString = [NSString stringWithFormat:@"%d", offset];
    NSDictionary *parameters;
    if ([_searchBar.searchField.text isEqualToString:@""])
        parameters = _isFav ? @{@"offset":offsetString, @"fav":@"1"} : @{@"offset":offsetString};
    else
        parameters = _isFav ? @{@"offset":offsetString, @"fav":@"1", @"search_term":_searchBar.searchField.text} : @{@"offset":offsetString,
                       @"search_term":_searchBar.searchField.text};
    return [FSNConnection withUrl:url
                           method:FSNRequestMethodGET
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
                      
                      if (responseDict != nil) {
                          if (responseDict[@"data"]) {
                              [self.items addObjectsFromArray:responseDict[@"data"]];
                              [self dataSourceDidLoad];
                          }
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.destinationViewController isKindOfClass:[PPDetailViewController class]]) {
        PPDetailViewController *detailVC = (PPDetailViewController *)segue.destinationViewController;
        NSDictionary *item = [_recipesArray objectAtIndex:selIdx];
        detailVC.recipeIndex = [item[@"id"] integerValue];
        detailVC.favId = [item[@"fav_id"] isKindOfClass:[NSNull class]] ? -1 : [item[@"fav_id"] integerValue];
    }
}

@end
