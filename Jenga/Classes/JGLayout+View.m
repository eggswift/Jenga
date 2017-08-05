//
//  UIView+Jenga.m
//
//  Created by Vincent Li on 2017/8/3.
//  Copyright (c) 2013-2017 Jenga (https://github.com/eggswift/Jenga)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "JGLayout+View.h"
#import <objc/runtime.h>

@implementation UIView (JGLayout)

- (void)jg_applyLayouWithSize:(CGSize)size {
    [self.jg_layout calculateLayoutThatFits:size];
    [self jg_applyLayout];
}

- (void)jg_applyLayout {
    self.frame = self.jg_layout.frame;
    [self.jg_children enumerateObjectsUsingBlock:^(Jenga  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.jg_layout.enabled) {
            
        }
    }];
    
    for (Jenga jenga in self.jg_children) {
        jenga.frame = jenga.jg_layout.frame;
        [jenga jg_applyLayout];
    }
}

- (void)jg_activate {
    [self jg_install];
}

- (void)jg_deactivate {
    [self jg_uninstall];
}

- (void)jg_install {
    self.jg_layout.enabled = YES;
}

- (void)jg_uninstall {
    self.jg_layout.enabled = NO;
}

#pragma mark - SET/GET
- (void)setJg_layout:(JGLayoutElement *)layout {
    objc_setAssociatedObject(self, @selector(jg_layout), layout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (JGLayoutElement *)jg_layout {
    JGLayoutElement *layout = objc_getAssociatedObject(self, _cmd);
    if (!layout) {
        layout = [[JGLayoutElement alloc] init];
        layout.context = self;
        objc_setAssociatedObject(self, _cmd, layout, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return layout;
}

- (void)setJg_children:(NSArray <Jenga> *)children {
    if (self.jg_children == children) {
        return;
    }
    if ([self.jg_children isEqualToArray:children]) {
        return;
    }
    objc_setAssociatedObject(self, @selector(jg_children), children, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [self.jg_layout removeAllChildren];
    [children enumerateObjectsUsingBlock:^(Jenga  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSAssert([obj conformsToProtocol:@protocol(JGLayoutAbility)], @"Child %@ has no conformsToProtocol FBLayoutProtocol", self);
        [self.jg_layout addChild:obj.jg_layout];
    }];
}

- (NSArray<Jenga> *)jg_children {
    return objc_getAssociatedObject(self, _cmd) ? : [NSArray array];
}

- (JGLayoutElement *)jg_makeFlexlayout:(void(^)(JengaElement jenga))layout {
    // 清除当前layout
    self.jg_layout = nil;
    if (layout) {
        layout(self.jg_layout);
    }
    return self.jg_layout;
}

@end
