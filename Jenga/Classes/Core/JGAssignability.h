//
//  JGLayoutAccessibility.h
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


// 可以设置的属性
// TODO:
// YG_NODE_PROPERTY(YGMeasureFunc, MeasureFunc, measureFunc);
// YG_NODE_PROPERTY(YGBaselineFunc, BaselineFunc, baselineFunc)
// YG_NODE_PROPERTY(YGPrintFunc, PrintFunc, printFunc);
// YG_NODE_PROPERTY(bool, HasNewLayout, hasNewLayout);
// YG_NODE_PROPERTY(YGNodeType, NodeType, nodeType);
// YG_NODE_STYLE_PROPERTY(YGOverflow, Overflow, overflow);
// YG_NODE_STYLE_PROPERTY(YGDisplay, Display, display);
#define JG_ASSIGNABILITY_PROPERTIES \
@property (nonatomic, assign, getter=isEnabled) BOOL enabled; \
\
@property (nonatomic, assign, readwrite) JGDirectionType direction; \
@property (nonatomic, assign, readwrite) JGFlexDirectionType flexDirection; \
@property (nonatomic, assign, readwrite) JGJustifyType justifyContent; \
@property (nonatomic, assign, readwrite) JGFlexAlignType alignContent; \
@property (nonatomic, assign, readwrite) JGFlexAlignType alignItems; \
@property (nonatomic, assign, readwrite) JGFlexAlignType alignSelf; \
@property (nonatomic, assign, readwrite) JGPositionType positionType; \
@property (nonatomic, assign, readwrite) JGFlexWrapType flexWrap; \
\
@property (nonatomic, assign, readwrite) CGFloat flex; \
@property (nonatomic, assign, readwrite) CGFloat flexGrow; \
@property (nonatomic, assign, readwrite) CGFloat flexShrink; \
@property (nonatomic, assign, readwrite) JGValue flexBasis; \
\
@property (nonatomic, assign, readwrite) JGEdgeInsetsValue position; \
@property (nonatomic, assign, readwrite) JGEdgeInsetsValue margin; \
@property (nonatomic, assign, readwrite) JGEdgeInsetsValue padding; \
@property (nonatomic, assign, readwrite) JGEdgeInsets border; \
\
@property (nonatomic, assign, readwrite) JGValue width; \
@property (nonatomic, assign, readwrite) JGValue height; \
@property (nonatomic, assign, readwrite) JGValue minWidth; \
@property (nonatomic, assign, readwrite) JGValue minHeight; \
@property (nonatomic, assign, readwrite) JGValue maxWidth; \
@property (nonatomic, assign, readwrite) JGValue maxHeight; \
\
@property (nonatomic, assign, readwrite) CGFloat aspectRatio; \


@protocol JGAssignability <NSObject>

JG_ASSIGNABILITY_PROPERTIES

@end

