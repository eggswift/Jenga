//
//  JENDefines.h
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

#define force_inline __inline__ __attribute__((always_inline))
#define JENGA_STATIC_INLINE	static force_inline

typedef NS_ENUM(NSUInteger, JGDirectionType) {
    JGDirectionInherit,
    JGDirectionLTR,
    JGDirectionRTL,
};

typedef NS_ENUM(NSUInteger, JGFlexDirectionType) {
    JGFlexDirectionColumn,
    JGFlexDirectionColumnReverse,
    JGFlexDirectionRow,
    JGFlexDirectionRowReverse,
};

typedef NS_ENUM(NSUInteger, JGJustifyType) {
    JGJustifyFlexStart,
    JGJustifyCenter,
    JGJustifyFlexEnd,
    JGJustifySpaceBetween,
    JGJustifySpaceAround,
};

typedef NS_ENUM(NSUInteger, JGFlexAlignType) {
    JGFlexAlignAuto,
    JGFlexAlignFlexStart,
    JGFlexAlignCenter,
    JGFlexAlignFlexEnd,
    JGFlexAlignStretch,
    JGFlexAlignBaseline,
    JGFlexAlignSpaceBetween,
    JGFlexAlignSpaceAround,
};

typedef NS_ENUM(NSUInteger, JGPositionType) {
    JGPositionRelative,
    JGPositionAbsolute,
};

typedef NS_ENUM(NSUInteger, JGFlexWrapType) {
    JGFlexNotWarp,
    JGFlexWrap,
    JGFlexWrapReverse,
};

typedef YGValue JGValue;

JENGA_STATIC_INLINE
CGFloat JGScaleValue(CGFloat value) {
    static CGFloat scale;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(){
        scale = [UIScreen mainScreen].scale;
    });
    
    return round(value * scale) / scale;
}

JENGA_STATIC_INLINE
JGValue JGValueMake(CGFloat value, YGUnit unit) {
    JGValue v = {value, unit};
    return v;
}

JENGA_STATIC_INLINE
JGValue JGValuePoint(CGFloat value) {
#if DEBUG
    if (value < 0) {
        NSLog(@"JGValuePoint value must greater than 0.");
    }
#endif
    JGValue v = {value, YGUnitPoint};
    return v;
}

JENGA_STATIC_INLINE
JGValue JGValuePercent(CGFloat value) {
#if DEBUG
    if (value > 1 || value < 0) {
        NSLog(@"JGValuePercent value must between 0 and 1.");
    }
#endif
    JGValue v = {value, YGUnitPercent};
    return v;
}

static const JGValue JGValueUndefined = {YGUndefined, YGUnitUndefined};
static const JGValue JGValueAuto = {YGUndefined, YGUnitAuto};

typedef struct JGEdgeInsets {
    CGFloat left, top, right, bottom, start, end, horizontal, vertical, all;
} JGEdgeInsets;
// 这个函数会报错 太tm奇怪
//NSString *NSStringFromJGEdgeInsets( JGEdgeInsets insets) {
//    return [NSString stringWithFormat:@"(left = %f)",insets.left];
//}


typedef struct JGEdgeInsetsValue {
    JGValue left, top, right, bottom, start, end, horizontal, vertical, all;
} JGEdgeInsetsValue;

JENGA_STATIC_INLINE
JGEdgeInsetsValue JGEdgeInsetsValueMake(JGValue top, JGValue left, JGValue bottom, JGValue right) {
    JGEdgeInsetsValue insets = {
        .top = top,
        .left = left,
        .bottom = bottom,
        .right = right
    };
    return insets;
}

JENGA_STATIC_INLINE
JGEdgeInsetsValue JGEdgeInsetsValueLTRMake(JGValue top, JGValue start, JGValue bottom, JGValue end) {
    JGEdgeInsetsValue insets = {
        .top = top,
        .start = start,
        .bottom = bottom,
        .end = end
    };
    return insets;
}

JENGA_STATIC_INLINE
JGEdgeInsetsValue JGEdgeInsetsValueBasisMake(JGValue horizontal, JGValue vertical) {
    JGEdgeInsetsValue insets = {
        .horizontal = horizontal,
        .vertical = vertical
    };
    return insets;
}

JENGA_STATIC_INLINE JGEdgeInsetsValue JGEdgeInsetsValueAllMake(JGValue all) {
    JGEdgeInsetsValue insets = {
        .all = all,
    };
    return insets;
}

struct JGPosition {
    CGFloat left;
    CGFloat top;
    CGFloat right;
    CGFloat bottom;
};
typedef struct JGPosition JGPosition;

struct JGRect {
    JGPosition origin;
    CGSize size;
};
typedef struct JGRect JGRect;

JENGA_STATIC_INLINE
void YGNodeStyleSetMarginValue(const YGNodeRef node, const YGEdge edge, const JGValue value) {
    switch (value.unit) {
        case YGUnitUndefined: {
            NSLog(@"Margin not support <YGUnitUndefined>");
        }
            break;
        case YGUnitAuto: {
            YGNodeStyleSetMarginAuto(node, edge);
        }
            break;
        case YGUnitPercent: {
            YGNodeStyleSetMarginPercent(node, edge, value.value);
        }
            break;
        case YGUnitPoint: {
            YGNodeStyleSetMargin(node, edge, value.value);
        }
            break;
        default:
            break;
    }
}

JENGA_STATIC_INLINE
void YGNodeStyleSetPositionValue(const YGNodeRef node, const YGEdge edge, const JGValue value) {
    switch (value.unit) {
        case YGUnitUndefined: {
            NSLog(@"Position not support <YGUnitUndefined>");
        }
            break;
        case YGUnitAuto: {
            NSLog(@"Position not support <YGUnitAuto>");
        }
            break;
        case YGUnitPercent: {
            YGNodeStyleSetPositionPercent(node, edge, value.value);
        }
            break;
        case YGUnitPoint: {
            YGNodeStyleSetPositionPercent(node, edge, value.value);
        }
            break;
        default:
            break;
    }
}

JENGA_STATIC_INLINE
void YGNodeStyleSetPaddingValue(const YGNodeRef node, const YGEdge edge, const JGValue value) {
    switch (value.unit) {
        case YGUnitUndefined: {
            NSLog(@"Padding not support <YGUnitUndefined>");
        }
            break;
        case YGUnitAuto: {
            NSLog(@"Padding not support <YGUnitAuto>");
        }
            break;
        case YGUnitPercent: {
            YGNodeStyleSetPaddingPercent(node, edge, value.value);
        }
            break;
        case YGUnitPoint: {
            YGNodeStyleSetPaddingPercent(node, edge, value.value);
        }
            break;
        default:
            break;
    }
}

JENGA_STATIC_INLINE
void YGNodeStyleSetMarginInsets(const YGNodeRef node, const JGEdgeInsetsValue value) {
    YGNodeStyleSetMarginValue(node, YGEdgeLeft, value.left);
    YGNodeStyleSetMarginValue(node, YGEdgeTop, value.top);
    YGNodeStyleSetMarginValue(node, YGEdgeRight, value.right);
    YGNodeStyleSetMarginValue(node, YGEdgeBottom, value.bottom);
    YGNodeStyleSetMarginValue(node, YGEdgeStart, value.start);
    YGNodeStyleSetMarginValue(node, YGEdgeEnd, value.end);
    YGNodeStyleSetMarginValue(node, YGEdgeHorizontal, value.horizontal);
    YGNodeStyleSetMarginValue(node, YGEdgeVertical, value.vertical);
    YGNodeStyleSetMarginValue(node, YGEdgeAll, value.all);
}

JENGA_STATIC_INLINE
void YGNodeStyleSetPositionInsets(const YGNodeRef node, const JGEdgeInsetsValue value) {
    YGNodeStyleSetPositionValue(node, YGEdgeLeft, value.left);
    YGNodeStyleSetPositionValue(node, YGEdgeTop, value.top);
    YGNodeStyleSetPositionValue(node, YGEdgeRight, value.right);
    YGNodeStyleSetPositionValue(node, YGEdgeBottom, value.bottom);
    YGNodeStyleSetPositionValue(node, YGEdgeStart, value.start);
    YGNodeStyleSetPositionValue(node, YGEdgeEnd, value.end);
    YGNodeStyleSetPositionValue(node, YGEdgeHorizontal, value.horizontal);
    YGNodeStyleSetPositionValue(node, YGEdgeVertical, value.vertical);
    YGNodeStyleSetPositionValue(node, YGEdgeAll, value.all);
}

JENGA_STATIC_INLINE
void YGNodeStyleSetPaddingInsets(const YGNodeRef node, const JGEdgeInsetsValue value) {
    YGNodeStyleSetPaddingValue(node, YGEdgeLeft, value.left);
    YGNodeStyleSetPaddingValue(node, YGEdgeTop, value.top);
    YGNodeStyleSetPaddingValue(node, YGEdgeRight, value.right);
    YGNodeStyleSetPaddingValue(node, YGEdgeBottom, value.bottom);
    YGNodeStyleSetPaddingValue(node, YGEdgeStart, value.start);
    YGNodeStyleSetPaddingValue(node, YGEdgeEnd, value.end);
    YGNodeStyleSetPaddingValue(node, YGEdgeHorizontal, value.horizontal);
    YGNodeStyleSetPaddingValue(node, YGEdgeVertical, value.vertical);
    YGNodeStyleSetPaddingValue(node, YGEdgeAll, value.all);
}

JENGA_STATIC_INLINE
void YGNodeStyleSetBorderInsets(const YGNodeRef node, const JGEdgeInsets value) {
    YGNodeStyleSetBorder(node, YGEdgeLeft, value.left);
    YGNodeStyleSetBorder(node, YGEdgeTop, value.top);
    YGNodeStyleSetBorder(node, YGEdgeRight, value.right);
    YGNodeStyleSetBorder(node, YGEdgeBottom, value.bottom);
    YGNodeStyleSetBorder(node, YGEdgeStart, value.start);
    YGNodeStyleSetBorder(node, YGEdgeEnd, value.end);
    YGNodeStyleSetBorder(node, YGEdgeHorizontal, value.horizontal);
    YGNodeStyleSetBorder(node, YGEdgeVertical, value.vertical);
    YGNodeStyleSetBorder(node, YGEdgeAll, value.all);
}

JENGA_STATIC_INLINE
JGEdgeInsetsValue YGNodeStyleGetMarginInsets(const YGNodeRef node) {
    JGEdgeInsetsValue insets = {
        .left = YGNodeStyleGetMargin(node, YGEdgeLeft),
        .right = YGNodeStyleGetMargin(node, YGEdgeRight),
        .top = YGNodeStyleGetMargin(node, YGEdgeTop),
        .bottom = YGNodeStyleGetMargin(node, YGEdgeBottom),
        .start = YGNodeStyleGetMargin(node, YGEdgeStart),
        .end = YGNodeStyleGetMargin(node, YGEdgeEnd),
        .horizontal = YGNodeStyleGetMargin(node, YGEdgeHorizontal),
        .vertical = YGNodeStyleGetMargin(node, YGEdgeVertical),
        .all = YGNodeStyleGetMargin(node, YGEdgeAll),
    };
    return insets;
}

JENGA_STATIC_INLINE
JGEdgeInsetsValue YGNodeStyleGetPositionInsets(const YGNodeRef node) {
    JGEdgeInsetsValue insets = {
        .left = YGNodeStyleGetPosition(node, YGEdgeLeft),
        .right = YGNodeStyleGetPosition(node, YGEdgeRight),
        .top = YGNodeStyleGetPosition(node, YGEdgeTop),
        .bottom = YGNodeStyleGetPosition(node, YGEdgeBottom),
        .start = YGNodeStyleGetPosition(node, YGEdgeStart),
        .end = YGNodeStyleGetPosition(node, YGEdgeEnd),
        .horizontal = YGNodeStyleGetPosition(node, YGEdgeHorizontal),
        .vertical = YGNodeStyleGetPosition(node, YGEdgeVertical),
        .all = YGNodeStyleGetPosition(node, YGEdgeAll),
    };
    return insets;
}

JENGA_STATIC_INLINE
JGEdgeInsetsValue YGNodeStyleGetPaddingInsets(const YGNodeRef node) {
    JGEdgeInsetsValue insets = {
        .left = YGNodeStyleGetPadding(node, YGEdgeLeft),
        .right = YGNodeStyleGetPadding(node, YGEdgeRight),
        .top = YGNodeStyleGetPadding(node, YGEdgeTop),
        .bottom = YGNodeStyleGetPadding(node, YGEdgeBottom),
        .start = YGNodeStyleGetPadding(node, YGEdgeStart),
        .end = YGNodeStyleGetPadding(node, YGEdgeEnd),
        .horizontal = YGNodeStyleGetPadding(node, YGEdgeHorizontal),
        .vertical = YGNodeStyleGetPadding(node, YGEdgeVertical),
        .all = YGNodeStyleGetPadding(node, YGEdgeAll),
    };
    return insets;
}

JENGA_STATIC_INLINE
JGEdgeInsets YGNodeStyleGetBorderInsets(const YGNodeRef node) {
    JGEdgeInsets insets = {
        .left = YGNodeStyleGetBorder(node, YGEdgeLeft),
        .right = YGNodeStyleGetBorder(node, YGEdgeRight),
        .top = YGNodeStyleGetBorder(node, YGEdgeTop),
        .bottom = YGNodeStyleGetBorder(node, YGEdgeBottom),
        .start = YGNodeStyleGetBorder(node, YGEdgeStart),
        .end = YGNodeStyleGetBorder(node, YGEdgeEnd),
        .horizontal = YGNodeStyleGetBorder(node, YGEdgeHorizontal),
        .vertical = YGNodeStyleGetBorder(node, YGEdgeVertical),
        .all = YGNodeStyleGetBorder(node, YGEdgeAll),
    };
    return insets;
}
