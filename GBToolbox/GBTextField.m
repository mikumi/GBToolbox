//
//  GBTextField.m
//  Business cards
//
//  Created by Luka Mirosevic on 28/09/2012.
//  Copyright (c) 2012 Luka Mirosevic.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "GBTextField.h"

#import "GBMessageInterceptor.h"
#import "GBUtility_Common.h"

@interface GBTextField () <UITextFieldDelegate> {
    GBMessageInterceptor    *_delegateInterceptor;
    CGRect                  _leftViewFrame;
    CGRect                  _rightViewFrame;
}

@end

@implementation GBTextField

#pragma mark - custom accessors

-(CGRect)leftViewFrame {
    if (CGRectIsNull(_leftViewFrame)) {
        return [super leftViewRectForBounds:self.bounds];
    }
    else {
        return _leftViewFrame;
    }
}

-(CGRect)rightViewFrame {
    if (CGRectIsNull(_rightViewFrame)) {
        return [super rightViewRectForBounds:self.bounds];
    }
    else {
        return _rightViewFrame;
    }
}

-(void)setLeftViewFrame:(CGRect)leftViewFrame {
    _leftViewFrame = leftViewFrame;
    
    [self setNeedsDisplay];
}

-(void)setRightViewFrame:(CGRect)rightViewFrame {
    _rightViewFrame = rightViewFrame;
    
    [self setNeedsDisplay];
}

-(void)setLeftViewLeftOffset:(CGFloat)leftViewLeftOffset {
    _leftViewLeftOffset = leftViewLeftOffset;
}

-(void)setRightViewRightOffset:(CGFloat)rightViewRightOffset {
    _rightViewRightOffset = rightViewRightOffset;
}

#pragma mark - memory

-(void)_initRoutine {
    _delegateInterceptor = [GBMessageInterceptor new];
    _delegateInterceptor.middleMan = self;
    super.delegate = (id)_delegateInterceptor;
    
    _leftViewFrame = CGRectNull;
    _rightViewFrame = CGRectNull;
    
    _invalidatesIntrinsicContentSizeDuringEditing = YES;
    
    // need this one to trigger the intrinsic content size change
    [self addTarget:self action:@selector(_textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

-(id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self _initRoutine];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _initRoutine];
    }
    return self;
}

#pragma mark - left and right view positioning

-(CGRect)leftViewRectForBounds:(CGRect)bounds {
    return CGRectMake(self.leftViewFrame.origin.x + self.leftViewLeftOffset,
                      self.leftViewFrame.origin.y,
                      self.leftViewFrame.size.width,
                      self.leftViewFrame.size.height);
}

-(CGRect)rightViewRectForBounds:(CGRect)bounds {
    return CGRectMake(self.rightViewFrame.origin.x - self.rightViewRightOffset,
                      self.leftViewFrame.origin.y,
                      self.leftViewFrame.size.width,
                      self.leftViewFrame.size.height);
}

#pragma mark - padding

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + self.padding.left,
                      bounds.origin.y + self.padding.top,
                      bounds.size.width - (self.padding.right + self.padding.left),
                      bounds.size.height - (self.padding.bottom + self.padding.top));
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

#pragma mark - util

-(BOOL)isDirty {
    if (self.text && self.text.length > 0) {
        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - delegate overrides

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // defer this because if the delegate's method decides to query in this stack frame, then the returned text won't yet reflect the new change. We are going for didPress semantics rather than willPress.
    ExecuteSoon(^{
        //return
        if ([string isEqualToString:@"\n"]) {
            if ([[self delegate] respondsToSelector:@selector(textField:specialKeyPressed:)]) {
                [[self delegate] textField:self specialKeyPressed:GBSpecialKeyReturn];
            }
        }
        //normal letter
        else if (string.length > 0) {
            if ([[self delegate] respondsToSelector:@selector(textField:keyPressed:)]) {
                [[self delegate] textField:self keyPressed:string];
            }
        }
        //backspace
        else if (string.length == 0 && range.length == 1) {
            if ([[self delegate] respondsToSelector:@selector(textField:specialKeyPressed:)]) {
                [[self delegate] textField:self specialKeyPressed:GBSpecialKeyBackspace];
            }
        }
    });
    
    // forward original call
    if ([[self delegate] respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
        return [[self delegate] textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    else {
        return YES;
    }
}

#pragma mark - delegate hijacking
//these 2 hijack the original delegate, but that's ok because we forward all the original messages

-(void)setDelegate:(id<GBTextFieldDelegate>)delegate {
    [super setDelegate:nil];
    _delegateInterceptor.receiver = delegate;
    super.delegate = (id)_delegateInterceptor;
}

-(id<GBTextFieldDelegate>)delegate {
    return _delegateInterceptor.receiver;
}

#pragma mark - target/action

- (void)_textFieldDidChange:(id)sender {
    if (self.invalidatesIntrinsicContentSizeDuringEditing) {
        [sender invalidateIntrinsicContentSize];
    }
}

@end
