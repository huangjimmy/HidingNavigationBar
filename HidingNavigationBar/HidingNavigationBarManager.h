//
//  HidingNavTabBarManager.h
//  HidingNavigationBarSample
//
//  Created by huangshaojun on 3/10/16.
//  Copyright © 2016 Tristan Himmelman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HidingViewController.h"

@class HidingNavigationBarManager;

typedef enum : NSUInteger {
    HidingNavigationBarStateClosed = 1,
    HidingNavigationBarStateContracting,
    HidingNavigationBarStateExpanding,
    HidingNavigationBarStateOpen,
} HidingNavigationBarState;

@protocol HidingNavigationBarManagerDelegate <NSObject>
@optional
- (void)hidingNavigationBarManagerDidUpdateScrollViewInsetsManager:(HidingNavigationBarManager*)hidingNavTabBarManager;
- (void)hidingNavigationBarManagerDidChangeStateManager:(HidingNavigationBarManager*)hidingNavigationBarManager toState:(HidingNavigationBarState)state;

@end



@interface HidingNavigationBarManager : NSObject<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIViewController *viewController;

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, weak) UIView *extensionView;

@property (nonatomic, weak) UIView *scrollViewHeaderView;
@property (nonatomic, weak) UIView *scrollViewFooterView;

@property (nonatomic, assign) CGFloat expansionResistance;
@property (nonatomic, assign) CGFloat contractionResistance;

@property (nonatomic, weak) id<HidingNavigationBarManagerDelegate> delegate;

@property (nonatomic, weak) UIRefreshControl *refreshControl;

@property (nonatomic, strong) HidingViewController *navBarController;
@property (nonatomic, strong) HidingViewController *extensionController;
@property (nonatomic, strong) HidingViewController *tabBarController;

@property (nonatomic, assign) CGFloat topInset;
@property (nonatomic, assign) CGFloat previousYOffset;
@property (nonatomic, assign) CGFloat resistanceConsumed;
@property (nonatomic, assign) BOOL isUpdatingValues;

@property (nonatomic, assign) HidingNavigationBarState currentState;
@property (nonatomic, assign) HidingNavigationBarState previousState;

- (id)initWithViewController:(UIViewController*)viewController scrollView:(UIScrollView*)scrollView;
//If you have a custom top navigation bar other than system default navigation bar
- (void)manageTopBar:(UIView*)view;
- (void)manageBottomBar:(UIView*)view;
- (void)addExtensionView:(UIView*)view;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidLayoutSubviews;
- (void)viewWillDisappear:(BOOL)animated;
- (void)updateValues;
- (void)shouldScrollToTop;
- (void)contract;
- (void)expand;
- (void)applicationDidBecomeActive;



@end
