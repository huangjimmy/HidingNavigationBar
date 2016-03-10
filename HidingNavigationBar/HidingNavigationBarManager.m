//
//  HidingNavTabBarManager.m
//  HidingNavigationBarSample
//
//  Created by huangshaojun on 3/10/16.
//  Copyright © 2016 Tristan Himmelman. All rights reserved.
//

#import "HidingNavigationBarManager.h"

@interface HidingNavigationBarManager()

- (BOOL)isViewControllerVisible;
- (CGFloat)statusBarHeight;
- (BOOL)shouldHandlesScrolling;
- (void)handleScrolling;
- (void)updateContentInsets;
- (void)updateScrollContentInsetTop:(CGFloat)top;
- (void)handleScrollingEnded:(CGFloat)velocity;

- (void)handlePanGesture:(UIGestureRecognizer*)gesture;

@end

@implementation HidingNavigationBarManager

- (id)initWithViewController:(UIViewController *)viewController scrollView:(UIScrollView *)scrollView{
    self = [super init];
    
    if (self) {
        
        self.previousYOffset = NAN;
        
        viewController.extendedLayoutIncludesOpaqueBars = YES;
        self.viewController = viewController;
        self.scrollView = scrollView;
        
        self.extensionController = [[HidingViewController alloc] init];
        [viewController.view addSubview:self.extensionController.view];
        
        UINavigationBar *navBar = self.viewController.navigationController.navigationBar;
        self.navBarController = [[HidingViewController alloc] init:navBar];
        self.navBarController.child = self.extensionController;
        self.navBarController.alphaFadeEnabled = YES;
        
        [viewController.tabBarController tabBar];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        panGesture.delegate = self;
        [scrollView addGestureRecognizer:panGesture];
        
        __weak typeof(self) myself = self;
        self.navBarController.expandedCenter = ^CGPoint(UIView *view){
            return CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds)+myself.statusBarHeight);
        };
        
        self.extensionController.expandedCenter = ^CGPoint(UIView *view){
            CGFloat topOffset = myself.navBarController.contractionAmountValue + myself.statusBarHeight;
            return CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds)+topOffset);
        };
        
        [self updateContentInsets];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)manageBottomBar:(UIView *)view{
    
    __weak typeof(self) myself = self;
    
    self.tabBarController = [[HidingViewController alloc] init:view];
    self.tabBarController.contractsUpwards = NO;
    self.tabBarController.expandedCenter = ^CGPoint(UIView *view){
        CGFloat height = myself.viewController.view.frame.size.height;
        return CGPointMake(CGRectGetMidX(view.bounds), height - CGRectGetMidY(view.bounds));
    };
}

- (void)addExtensionView:(UIView *)view{
    [self.extensionView removeFromSuperview];
    self.extensionView  = view;
    
    CGRect bounds = view.bounds;
    bounds.origin = CGPointZero;
    
    self.extensionView.frame = bounds;
    self.extensionController.view.frame = bounds;
    [self.extensionController.view addSubview:view];
    [self.extensionController expand];
    
    [self.extensionController.view.superview bringSubviewToFront:self.extensionController.view];
    [self updateContentInsets];
}

- (void)viewWillAppear:(BOOL)animated{
    [self expand];
}

- (void)viewDidLayoutSubviews{
    [self updateContentInsets];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self expand];
    
}

- (void)updateValues{
    self.isUpdatingValues = YES;
    
    BOOL scrolledToTop = NO;
    
    if (self.scrollView.contentInset.top == - self.scrollView.contentOffset.y) {
        scrolledToTop = YES;
    }
    
    if (self.extensionView) {
        CGRect frame = self.extensionController.view.frame;
        frame.size.width = self.extensionView.bounds.size.width;
        frame.size.height = self.extensionView.bounds.size.height;
        self.extensionController.view.frame = frame;
    }
    
    [self updateContentInsets];
    
    if (scrolledToTop) {
        CGPoint offset = self.scrollView.contentOffset;
        offset.y = -self.scrollView.contentInset.top;
        self.scrollView.contentOffset = offset;
    }
    
    self.isUpdatingValues = NO;
}

- (void)shouldScrollToTop{
    CGFloat top = self.statusBarHeight + self.navBarController.totalHeight;
    [self updateScrollContentInsetTop:top];
    
    [self.navBarController snapContracted:NO completion:nil];
    [self.tabBarController snapContracted:NO completion:nil];
}

- (void)contract{
    [self.navBarController contract];
    [self.tabBarController contract];
    
    self.previousYOffset = NAN;
    
    [self handleScrolling];
}

- (void)expand{
    [self.navBarController expand];
    [self.tabBarController expand];
    
    self.previousYOffset = NAN;
    
    [self handleScrolling];
}

- (void)applicationDidBecomeActive{
    [self.navBarController expand];
    [self.tabBarController expand];
}


- (BOOL)isViewControllerVisible{
    return self.viewController.isViewLoaded && self.viewController.view.window != nil;
}

- (CGFloat)statusBarHeight{
    if ([UIApplication sharedApplication].statusBarHidden) {
        return 0;
    }
    
    CGSize statusBarSize = [UIApplication sharedApplication].statusBarFrame.size;
    
    return MIN(statusBarSize.width, statusBarSize.height);
}

- (BOOL)shouldHandlesScrolling{
    if (self.scrollView.contentOffset.y <= -self.scrollView.contentInset.top && self.currentState == HidingNavigationBarStateOpen) {
        return NO;
    }
    
    if (self.refreshControl.refreshing) {
        return NO;
    }
    
    CGRect scrollFrame = UIEdgeInsetsInsetRect(self.scrollView.bounds, self.scrollView.contentInset);
    CGFloat scrollableAmount = self.scrollView.contentSize.height - CGRectGetHeight(scrollFrame);
    BOOL scrollViewIsSuffecientlyLong = scrollableAmount > self.navBarController.totalHeight * 3;
    
    return [self isViewControllerVisible] && scrollViewIsSuffecientlyLong && !self.isUpdatingValues;
}

- (void)handleScrolling{
    if (![self shouldHandlesScrolling]) {
        return;
    }
    
    if (!isnan(self.previousYOffset)) {
        CGFloat deltaY = self.previousYOffset - self.scrollView.contentOffset.y;
        
        CGFloat start = -self.topInset;
        
        if (self.previousYOffset < start) {
            deltaY = MIN(0, deltaY - self.previousYOffset - start);
        }
        
        CGFloat end = floorf(self.scrollView.contentSize.height - CGRectGetHeight(self.scrollView.bounds) + self.scrollView.contentInset.bottom - 0.5);
        
        if (self.previousYOffset > end) {
            deltaY = MAX(0, deltaY - self.previousYOffset + end);
        }
        
        if (fabs(deltaY) > FLT_EPSILON) {
            if (deltaY < 0) {
                self.currentState = HidingNavigationBarStateContracting;
            }
            else{
                self.currentState = HidingNavigationBarStateExpanding;
            }
        }
        
        if (self.currentState != self.previousState) {
            self.previousState = self.currentState;
            self.resistanceConsumed = 0;
        }
        
        if (self.currentState == HidingNavigationBarStateContracting) {
            CGFloat availableResistance = self.contractionResistance - self.resistanceConsumed;
            
            self.resistanceConsumed = MIN(self.contractionResistance, self.resistanceConsumed - deltaY);
            
            deltaY = MIN(0, availableResistance + deltaY);
        }
        else if (self.scrollView.contentOffset.y > -self.statusBarHeight){
            CGFloat availableResistance = self.expansionResistance - self.resistanceConsumed;
            self.resistanceConsumed = MIN(self.expansionResistance, self.resistanceConsumed + deltaY);
            
            deltaY = MAX(0, deltaY - availableResistance);

        }
        
        [self.navBarController updateYOffset:deltaY];
        [self.tabBarController updateYOffset:deltaY];
    }
    
    [self updateContentInsets];
    
    self.previousYOffset = self.scrollView.contentOffset.y;
    
    HidingNavigationBarState state = self.currentState;
    
    if (CGPointEqualToPoint(self.navBarController.view.center, self.navBarController.expandedCenterValue) && CGPointEqualToPoint(self.extensionController.view.center, self.extensionController.expandedCenterValue)) {
        self.currentState = HidingNavigationBarStateOpen;
    }
    else if (CGPointEqualToPoint(self.navBarController.view.center, self.navBarController.contractedCenterValue) && CGPointEqualToPoint(self.extensionController.view.center, self.extensionController.contractedCenterValue)){
        self.currentState = HidingNavigationBarStateClosed;
    }
    
    if (state != self.currentState) {
        [self.delegate hidingNavigationBarManagerDidChangeStateManager:self toState:self.currentState];
    }
}

- (void)updateContentInsets{
    CGFloat navBottomY = self.navBarController.view.frame.origin.y + self.navBarController.view.frame.size.height;
    CGFloat top = NAN;
    if (!self.extensionController.isContracted) {
        top = self.extensionController.view.frame.origin.y + self.extensionController.view.bounds.size.height;
    }
    else{
        top = navBottomY;
    }
    
    [self updateScrollContentInsetTop:top];
}

- (void)updateScrollContentInsetTop:(CGFloat)top{
    if (self.viewController.automaticallyAdjustsScrollViewInsets) {
        UIEdgeInsets contentInset = self.scrollView.contentInset;
        contentInset.top = top;
        self.scrollView.contentInset = contentInset;
    }
    
    UIEdgeInsets scrollInsets = self.scrollView.scrollIndicatorInsets;
    scrollInsets.top = top;
    self.scrollView.scrollIndicatorInsets = scrollInsets;
    [self.delegate hidingNavigationBarManagerDidUpdateScrollViewInsetsManager:self];
}

- (void)handleScrollingEnded:(CGFloat)velocity{
    CGFloat minVelocity = 500.0f;
    
    if (!self.isViewControllerVisible || (self.navBarController.isContracted && velocity < minVelocity)) {
        return;
    }
    
    self.resistanceConsumed = 0;
    
    if (self.currentState == HidingNavigationBarStateContracting || self.currentState == HidingNavigationBarStateExpanding || velocity > minVelocity) {
        BOOL contracting = self.currentState == HidingNavigationBarStateContracting;
        
        if (velocity > minVelocity) {
            contracting = NO;
        }
        
        CGFloat deltaY = [self.navBarController snapContracted:contracting completion:nil];
        BOOL tabBarShouldContract = deltaY < 0;
        [self.tabBarController snapContracted:tabBarShouldContract completion:nil];
        
        CGPoint newContentOffset = self.scrollView.contentOffset;
        newContentOffset.y -= deltaY;
        
        UIEdgeInsets contentInset = self.scrollView.contentInset;
        CGFloat top = contentInset.top + deltaY;
        
        [UIView animateWithDuration:0.2 animations:^{
            [self updateScrollContentInsetTop:top];
            self.scrollView.contentOffset = newContentOffset;
        }];
        
        self.previousYOffset = NAN;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer*)gesture{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.topInset = self.navBarController.view.frame.size.height + self.extensionController.view.bounds.size.height + self.statusBarHeight;
            [self handleScrolling];
            break;
        case UIGestureRecognizerStateChanged:
            [self handleScrolling];
            break;
        default:
            {
                CGFloat velocity = [gesture velocityInView:self.scrollView].y;
                [self handleScrollingEnded:velocity];
            
            }
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
@end
