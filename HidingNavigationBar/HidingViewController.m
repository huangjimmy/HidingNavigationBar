//
//  HidingNavTabViewController.m
//  HidingNavigationBarSample
//
//  Created by huangshaojun on 3/10/16.
//  Copyright © 2016 Tristan Himmelman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "HidingViewController.h"


@interface HidingViewController()

- (void)updateSubviewsToAlpha:(CGFloat)alpha;

@end

@implementation HidingViewController

- (id)init{
    self = [super init];
    
    if (self) {
        self.contractsUpwards = YES;
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        self.view.backgroundColor = [UIColor clearColor];
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    }
    
    return self;
}

- (id)init:(UIView*)view{
    self = [super init];
    
    if (self) {
        self.contractsUpwards = YES;
        self.view = view;
    }
    
    return self;
}

- (CGPoint)expandedCenterValue{
    if (self.expandedCenter) {
        return self.expandedCenter(self.view);
    }
    
    return CGPointMake(0, 0);
}

- (CGFloat)contractionAmountValue{
    return self.view.bounds.size.height;
}

- (CGPoint)contractedCenterValue{
    if (self.contractsUpwards) {
        return CGPointMake(self.expandedCenterValue.x, self.expandedCenterValue.y - self.contractionAmountValue);
    }
    
    return CGPointMake(self.expandedCenterValue.x, self.expandedCenterValue.y + self.contractionAmountValue);
}

- (BOOL)isContracted{
    return fabs(self.view.center.y - self.contractedCenterValue.y) < FLT_EPSILON;
}

- (BOOL)isExpanded{
    return fabs(self.view.center.y - self.expandedCenterValue.y) < FLT_EPSILON;
}

- (CGFloat)totalHeight{
    CGFloat height = self.expandedCenterValue.y - self.contractedCenterValue.y;
    if (self.child) {
        return self.child.totalHeight + height;
    }
    
    return height;
}

- (void)setAlphaFadeEnabled:(BOOL)alphaFadeEnabled{
    _alphaFadeEnabled = alphaFadeEnabled;
    
    if (!_alphaFadeEnabled) {
        [self updateSubviewsToAlpha:1.0];
    }
}

- (CGFloat)updateYOffset:(CGFloat)delta{
    CGFloat deltaY = delta;
    if (self.child && deltaY < 0) {
        deltaY = [self.child updateYOffset:deltaY];
        self.child.view.hidden = deltaY < 0;
    }
    
    CGFloat newYOffset = self.view.center.y + deltaY;
    CGFloat newYCenter = MAX(MIN(self.expandedCenterValue.y, newYOffset), self.contractedCenterValue.y);
    
    if (!self.contractsUpwards) {
        newYOffset = self.view.center.y - deltaY;
        newYCenter = MIN(MAX(self.expandedCenterValue.y, newYOffset), self.contractedCenterValue.y);
    }
    
    self.expectedYCenter = newYCenter;
    self.view.center = CGPointMake(self.view.center.x, newYCenter);
    
    if (self.alphaFadeEnabled) {
        CGFloat newAlpha = 1.0 - (self.expandedCenterValue.y - self.view.center.y)*2/self.contractionAmountValue;
        newAlpha = MIN(MAX(FLT_EPSILON, newAlpha), 1.0);
        [self updateSubviewsToAlpha:newAlpha];
    }
    
    CGFloat residual = newYOffset - newYCenter;
    
    if (self.child && deltaY > 0 && residual > 0) {
        residual = [self.child updateYOffset:residual];
        self.child.view.hidden = residual - (newYOffset - newYCenter) > 0;
    }
    
    return residual;
}

- (CGFloat)snapContracted:(BOOL)contracted completion:(void (^)(void))completion{
    
    __block CGFloat deltaY = 0;
    
    [UIView animateWithDuration:0.2 delay:0 options:0 animations:^{
        if (self.child) {
            if (contracted && self.child.isContracted) {
                deltaY = [self contract];
            }
            else{
                deltaY = [self expand];
            }
        }
        else{
            if (contracted) {
                deltaY = [self contract];
            }
            else{
                deltaY = [self expand];
            }
        }
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
    
    return deltaY;
}

- (CGFloat)expand{
    self.view.hidden = NO;
    
    if (self.alphaFadeEnabled) {
        [self updateSubviewsToAlpha:1.0];
        self.navSubviews = nil;
    }
    
    CGFloat amountToMove = self.expandedCenterValue.y - self.view.center.y;
    
    self.view.center = [self expandedCenterValue];
    
    if (self.child) {
        amountToMove += [self.child expand];
    }
    
    return amountToMove;
}

- (CGFloat)contract{
    if (self.alphaFadeEnabled) {
        [self updateSubviewsToAlpha:0];
    }
    
    CGFloat amountToMove = self.contractedCenterValue.y - self.view.center.y;
    self.view.center = [self contractedCenterValue];
    
    return amountToMove;
}

- (void)updateSubviewsToAlpha:(CGFloat)alpha{
    if (self.navSubviews == nil) {
        NSMutableArray *navSubviews = [[NSMutableArray alloc] init];
        
        for (UIView *subView in self.view.subviews) {
            BOOL isBackgroundView = subView == self.view.subviews[0];
            BOOL isViewHidden = subView.hidden || subView.alpha < FLT_EPSILON;
            
            if (!isBackgroundView && !isViewHidden) {
                [navSubviews addObject:subView];
            }
        }
        
        self.navSubviews = navSubviews;
        
        for (UIView *subView in self.navSubviews) {
            subView.alpha = alpha;
        }
    }
}
@end
