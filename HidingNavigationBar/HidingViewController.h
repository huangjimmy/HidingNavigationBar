//
//  HidingViewController.h
//  HidingNavigationBarSample
//
//  Created by huangshaojun on 3/10/16.
//  Copyright © 2016 Tristan Himmelman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HidingViewController : NSObject

@property (nonatomic, strong) HidingViewController *child;
@property (nonatomic, weak) NSArray<UIView*> *navSubviews;
@property (nonatomic, strong) UIView *view;


@property (nonatomic, copy) CGPoint(^expandedCenter)(UIView*);

@property (nonatomic, assign) CGFloat expectedYCenter;
@property (nonatomic, assign) BOOL alphaFadeEnabled;
@property (nonatomic, assign) BOOL contractsUpwards;

- (id)init:(UIView*)view;
- (id)init;

- (CGPoint)expandedCenterValue;
- (CGFloat)contractionAmountValue;
- (CGPoint)contractedCenterValue;
- (BOOL)isContracted;
- (BOOL)isExpanded;
- (CGFloat)totalHeight;
- (CGFloat)updateYOffset:(CGFloat)delta;
- (CGFloat)snapContracted:(BOOL)contracted completion:(void(^)(void))completion;
- (CGFloat)expand;
- (CGFloat)contract;
@end
