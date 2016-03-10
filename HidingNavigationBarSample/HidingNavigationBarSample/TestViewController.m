//
//  TestViewController.m
//  HidingNavigationBarSample
//
//  Created by HUANG,Shaojun on 3/10/16.
//  Copyright © 2016 Tristan Himmelman. All rights reserved.
//

#import "TestViewController.h"
#import "HidingNavigationBarManager.h"

@interface TestViewController ()<HidingNavigationBarManagerDelegate>
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) HidingNavigationBarManager *hidingNavManager;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationBarTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *navigationBar;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hidingNavManager = [[HidingNavigationBarManager alloc] initWithViewController:self scrollView:self.scrollView];
    [self.hidingNavManager manageTopBar:self.navigationBar];
    [self.hidingNavManager manageBottomBar:self.tabBar];
    [self.navigationController setNavigationBarHidden:YES];
    self.hidingNavManager.delegate = self;
    self.scrollView.layer.borderWidth = 2;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 20000);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 200, 200, 200)];
    view.backgroundColor = [UIColor redColor];
    [self.scrollView addSubview:view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)hidingNavigationBarManagerDidChangeStateManager:(HidingNavigationBarManager *)hidingNavigationBarManager toState:(HidingNavigationBarState)state{
    self.navigationBarTopConstraint.constant = self.hidingNavManager.navBarController.expectedYCenter - self.navigationBar.frame.size.height/2;
    self.scrollBottomConstraint.constant = self.view.frame.size.height - self.tabBar.frame.origin.y - 49;
    self.scrollTopConstraint.constant = self.navigationBar.frame.origin.y;
    [self.view setNeedsUpdateConstraints];
}

- (void)hidingNavigationBarManagerDidUpdateScrollViewInsetsManager:(HidingNavigationBarManager *)hidingNavTabBarManager{
    self.navigationBarTopConstraint.constant = self.hidingNavManager.navBarController.expectedYCenter - self.navigationBar.frame.size.height/2;
    self.scrollBottomConstraint.constant = self.view.frame.size.height - self.tabBar.frame.origin.y - 49;
    self.scrollTopConstraint.constant = self.navigationController.navigationBar.frame.origin.y - [UIApplication sharedApplication].statusBarFrame.size.height;
    [self.view setNeedsUpdateConstraints];
}
@end
