//
//  JGLayoutAbility.h
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

#import "JGLayoutElement.h"

@protocol JGLayoutAbility;
typedef id<JGAssignability> JengaElement;
typedef id<JGLayoutAbility> Jenga;

NS_ASSUME_NONNULL_BEGIN

@protocol JGLayoutAbility <NSObject>

@property (nonatomic, strong, readonly) JGLayoutElement *jg_layout;
@property (nonatomic, strong, readonly) NSArray <Jenga> *jg_children;
@property (nonatomic, assign, readwrite) CGRect frame;

- (JGLayoutElement *)jg_makeFlexlayout:(void(^)(JengaElement jenga))layout;

- (void)jg_applyLayout;
- (void)jg_applyLayouWithSize:(CGSize)size;

- (void)jg_activate;
- (void)jg_deactivate;
- (void)jg_install;
- (void)jg_uninstall;

@end

NS_ASSUME_NONNULL_END
