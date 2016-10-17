//
//  PPShoppinglistViewController.m
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/23/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import "PPShoppinglistViewController.h"

#import <JASidePanelController.h>
#import <UIViewController+JASidePanel.h>
#import "PPShoppinglistViewCell.h"
#import "PPIntroductionViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <FSNConnection.h>

@interface PPShoppinglistViewController () <UITableViewDataSource, UITableViewDelegate> {

}
@property (weak, nonatomic) IBOutlet UITableView *shoppinglistTable;
@property (nonatomic, strong) NSMutableArray *shoppinglistArray;
@end

@implementation PPShoppinglistViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceivedLogoutNoti) name:kNotiLogout object:nil];
    
    self.sidePanelController.allowLeftSwipe = NO;
    self.sidePanelController.allowRightSwipe = NO;
    NSArray *array1 = @[@"Chicken breast(2x)", @"Pecans", @"Lettuce", @"Strawberries", @"Apples", @"Salad Dressing"];
    NSArray *array2 = @[@"Lobster Tails", @"Fresh Salmon"];
    _shoppinglistArray = [NSMutableArray arrayWithArray:@[@{@"array":array1}, @{@"array":array2}]];
    [_shoppinglistTable reloadData];
    
    NSLog(@"%ld", (long)[SharedDataManager instance].introductionViewedCount);
    if ([SharedDataManager instance].introductionViewedCount < 3) {
        PPIntroductionViewController *introductionView = [PPIntroductionViewController new];
        [[UIApplication sharedApplication].delegate.window addSubview:introductionView.view];
    }
    [[self makeGetShoppinglistConnection] start];
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
- (void)removeDelButton:(NSInteger)selIdx section:(NSInteger)section {
    for (int sect=0; sect<2; sect++) {
        int rows = sect == 0 ? 6 : 2;
        for (int row=0; row<rows; row++) {
            if (sect != section || row != selIdx) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:sect];
                PPShoppinglistViewCell *cell = (PPShoppinglistViewCell *)[_shoppinglistTable cellForRowAtIndexPath:indexPath];
                [UIView animateWithDuration:0.2 animations:^{
                    cell.delButton.alpha = 0.0f;
                }];
            }
        }
    }
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
    PPShoppinglistViewCell *cell = (PPShoppinglistViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell onClickCheckBox:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 50)];
    
    UIView *banner = [[UIView alloc] initWithFrame:CGRectMake(9, 49, 270, 1)];
    [banner setBackgroundColor:[UIColor grayColor]];
    [headView addSubview:banner];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(7, 20, 260, 26)];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont fontWithName:@"GillSans" size:17.0F]];
    NSDictionary *dict = _shoppinglistArray[section];
    titleLabel.text = dict[@"name"];
    [headView addSubview:titleLabel];
    
    return headView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _shoppinglistArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = _shoppinglistArray[section][@"items"];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ShoppingListTableViewCell";
    PPShoppinglistViewCell *cell = (PPShoppinglistViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PPShoppinglistViewCell" owner:self options:nil] objectAtIndex:0];
        cell.tag = indexPath.section * 1000 + indexPath.row;
    }
    cell.parentDelegate = self;
//    cell.delButton.tag = indexPath.section * 1000 + indexPath.row;
//    cell.checkButton.tag = indexPath.section * 1000 + indexPath.row;
//    [cell.checkButton addTarget:self action:@selector(onClickCheck:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.delButton addTarget:self action:@selector(onClickDelCell:) forControlEvents:UIControlEventTouchUpInside];

    NSArray *array = _shoppinglistArray[indexPath.section][@"items"];
    [cell fillViewWithObject:array[indexPath.row]];
    return cell;
}

- (void)onClickCheck:(id)sender {
    [sender setSelected:![sender isSelected]];
    NSInteger row = [sender tag] % 1000;
    NSInteger section = [sender tag] / 1000;
    NSLog(@"Check Selected row : %ld, section : %ld", (long)row, (long)section);
}

- (void)onClickDelCell:(id)sender {
    NSInteger row = [sender tag] % 1000;
    NSInteger section = [sender tag] / 1000;
    NSLog(@"Del Selected row : %ld, section : %ld", (long)row, (long)section);
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:_shoppinglistArray[section][@"array"]];
    [array removeObjectAtIndex:row];
    NSDictionary *dict = @{@"array":array};
    [_shoppinglistArray replaceObjectAtIndex:section withObject:dict];
    
    [_shoppinglistTable reloadData];
}
//-----------------------------------------------------------------------------------------
#pragma mark - API Call For Get ShoppingList
//-----------------------------------------------------------------------------------------
- (FSNConnection *) makeGetShoppinglistConnection {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, API_GETSHOPPINGLIST]]; // API url // API parameters
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMMM, yyyy"];
    
    NSDictionary *parameters = @{@"end_date" : @"7",
                                 @"start_date" : [dateFormatter stringFromDate:[NSDate date]]
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
                      NSLog(@"Get ShoppingList Response : %@", responseDict);
                      [_shoppinglistArray removeAllObjects];
                      if (responseDict != nil) {
                          [_shoppinglistArray addObjectsFromArray:responseDict[@"data"][@"categories"]];
                          [_shoppinglistTable reloadData];
                      } else {
                          [Utilities showMsg:MESSAGE_AUTHFAILED];
//                          [self.sidePanelController showCenterPanelAnimated:NO];
//                          [[NSNotificationCenter defaultCenter] postNotificationName:kNotiLogout object:nil];
                      }
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
