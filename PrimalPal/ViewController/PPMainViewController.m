//
//  PPMainViewController.m
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/23/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import "PPMainViewController.h"

@interface PPMainViewController ()

@end

@implementation PPMainViewController

-(void) awakeFromNib
{
    [self setRightPanel:[self.storyboard instantiateViewControllerWithIdentifier:kIdentifierSidemenuView]];
    [self setCenterPanel:[self.storyboard instantiateViewControllerWithIdentifier:kIdentifierCenteralView]];
    
    self.panningLimitedToTopViewController = NO;
}

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
