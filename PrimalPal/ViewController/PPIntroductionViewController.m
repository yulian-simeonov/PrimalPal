//
//  PPIntroductionViewController.m
//  PrimalPal
//
//  Created by Yulian Simeonov on 7/31/14.
//  Copyright (c) 2014 YulianMobile. All rights reserved.
//

#import "PPIntroductionViewController.h"

@interface PPIntroductionViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *animationImageView;

@end

@implementation PPIntroductionViewController

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
    // Do any additional setup after loading the view from its nib.
    _animationImageView.animationDuration = 1;
    _animationImageView.animationImages = @[[UIImage imageNamed:@"swipe_1"], [UIImage imageNamed:@"swipe_2"]];
    _animationImageView.animationRepeatCount = 5;
    [_animationImageView startAnimating];
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(removeIntroductionView) userInfo:nil repeats:NO];
    
    [SharedDataManager instance].introductionViewedCount = [SharedDataManager instance].introductionViewedCount + 1;
}

- (void)removeIntroductionView {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL completion) {
        [self.view removeFromSuperview];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
