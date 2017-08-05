//
//  JGLayoutElement.h
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

#import "JGDefines.h"
#import "JGAssignability.h"

NS_ASSUME_NONNULL_BEGIN

@interface JGLayoutElement : NSObject <JGAssignability>

JG_ASSIGNABILITY_PROPERTIES

#pragma mark - Calculate Result
@property (nonatomic, assign, readonly) CGRect frame;
@property (nonatomic, assign, readonly) BOOL hadOverflow;
@property (nonatomic, assign, readonly) YGDirection resolvedDirection;
@property (nonatomic, assign, readonly) JGRect calculatedFrame;
@property (nonatomic, assign, readonly) JGDirectionType calculatedDirection;
@property (nonatomic, assign, readonly) JGEdgeInsets calculatedMargin;
@property (nonatomic, assign, readonly) JGEdgeInsets calculatedBorder;
@property (nonatomic, assign, readonly) JGEdgeInsets calculatedPadding;


#pragma mark - Incremental
@property (nonatomic, weak, readwrite, nullable) id context;
- (void)markDirty;
- (JGLayoutElement *)calculateLayoutThatFits:(CGSize)constrainedSize;


#pragma mark - Tree
@property (nonatomic, assign, readonly) BOOL isRoot;
@property (nonatomic, assign, readonly) BOOL isLeaf;
@property (nonatomic, weak, readwrite, nullable) JGLayoutElement *parent;
@property (nonatomic, strong, readwrite) NSArray <JGLayoutElement *> *children;
@property (nonatomic, copy, readwrite) CGSize (^measureHandler) (CGSize);

- (BOOL)containsChild:(JGLayoutElement *)node;
- (void)addChild:(JGLayoutElement *)node;
- (void)addChildren:(NSArray <JGLayoutElement *> *)nodes;
- (void)insertChild:(JGLayoutElement *)node atIndex:(NSInteger)idx;
- (void)insertChildren:(NSArray <JGLayoutElement *> *)nodes atIndex:(NSInteger)idx;
- (void)removeChild:(JGLayoutElement *)node;
- (void)removeChildren:(NSArray *)nodes;
- (void)removeAllChildren;
- (nullable JGLayoutElement *)childAtIndex:(NSUInteger)idx;
- (NSArray <JGLayoutElement *> *)availableChildren;
- (NSArray <JGLayoutElement *> *)allChildren;

@end

NS_ASSUME_NONNULL_END
