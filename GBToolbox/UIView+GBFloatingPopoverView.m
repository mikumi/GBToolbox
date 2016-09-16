//
//  UIView+GBFloatingPopoverView.m
//  GBToolbox
//
//  Created by Luka Mirosevic on 16/09/16.
//  Copyright © 2016 Goonbee e.U. All rights reserved.
//

#import "UIView+GBFloatingPopoverView.h"

#import "GBCAAnimationDelegateHandler.h"

static NSTimeInterval kFadeInDuration =     0.3;
static NSTimeInterval kFadeOutDuration =    0.3;
static NSTimeInterval kShowDuration =       3.0;

static NSString *kAnimationKey =            @"com.goonbee.GBToolbox.FloatingPopoverAnimation";

@implementation UIView (GBFloatingPopoverView)

#pragma mark - Life

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - API

- (void)floatOnView:(nonnull UIView *)targetView animated:(BOOL)animated context:(nonnull id)context layoutConfigurationBlock:(nullable GBFloatingPopoverAutolayoutConfigurationBlock)layoutBlock {
    if (!targetView) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"`view` cannot be nil." userInfo:nil];
    if (!context) @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"`context` cannot be nil." userInfo:nil];
    
    // get the old view
    UIView *existingView = [self.class _viewForContext:context];
    
    // compute our params for the animation
    BOOL isOldViewAnimating = !![existingView.layer animationForKey:kAnimationKey];
    CGFloat currentAlpha = isOldViewAnimating ? ((NSNumber *)[existingView.layer.presentationLayer valueForKeyPath:@"opacity"]).doubleValue : 0.0;
    NSTimeInterval remainingFadeInAnimationTime = (1.0 - currentAlpha) * kFadeInDuration;    
    BOOL isDifferentView = (existingView != self);
    
    // clean up old view if the new one coming in is different
    if (isDifferentView) {
        [existingView.layer removeAnimationForKey:kAnimationKey];
        [existingView removeFromSuperview];
    }
    
    // add and lay out the new view if it is different
    if (self.superview != targetView) {
        [targetView addSubview:self];
        if (layoutBlock) layoutBlock(self);
    }
    
    // create and schedule the new animation
    CAKeyframeAnimation *newAnimation = [CAKeyframeAnimation animation];
    newAnimation.keyPath = @"opacity";
    newAnimation.values = @[@(currentAlpha), @1, @1, @0];
    NSTimeInterval totalDuration = remainingFadeInAnimationTime + kShowDuration + kFadeOutDuration;
    NSTimeInterval normalizedPostFadeInKeyTime = remainingFadeInAnimationTime / totalDuration;
    NSTimeInterval normalisedPostFreezeKeyTime = (remainingFadeInAnimationTime + kShowDuration) / totalDuration;
    newAnimation.keyTimes = @[@0, @(normalizedPostFadeInKeyTime), @(normalisedPostFreezeKeyTime), @1];
    newAnimation.duration = totalDuration;
    newAnimation.removedOnCompletion = YES;
    __weak typeof(self) weakSelf = self;
    newAnimation.delegate = [GBCAAnimationDelegateHandler delegateWithDidStart:nil didStop:^(CAAnimation *animation, BOOL finished) {
        // if this animation ran it's natural course
        if (finished) {
            // remove this view from the superview
            [weakSelf removeFromSuperview];
            [weakSelf.class _removeViewForContext:context];
        }
    }];
    [self.layer addAnimation:newAnimation forKey:kAnimationKey];
    
    // remember the new view
    [self.class _setView:self forContext:context];
}

#pragma mark - Private: Contexts Map

static NSMapTable *_contextToViewsMap;

+ (nullable UIView *)_viewForContext:(id)context {
    return [_contextToViewsMap objectForKey:context];
}

+ (void)_setView:(nonnull UIView *)view forContext:(nonnull id)context {
    // always lazy create it
    if (!_contextToViewsMap) {
        _contextToViewsMap = [NSMapTable strongToWeakObjectsMapTable];
    }
    
    [_contextToViewsMap setObject:view forKey:context];
}

+ (void)_removeViewForContext:(id)context {
    [_contextToViewsMap removeObjectForKey:context];
    
    // if we have no more keys, then clean up the mapTable as well
    if (_contextToViewsMap.count == 0) {
        _contextToViewsMap = nil;
    }
}

@end
