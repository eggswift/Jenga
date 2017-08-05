//
//  JGLayoutElement.m
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
#import "JGLayoutCommit.h"
#import <pthread.h>
#import "JGLayoutElement+Internal.h"

/*
@interface JGLayoutElement () {
    NSMutableArray <JGLayoutElement *> *_children;
    pthread_mutex_t _lock;
    YGNodeRef _nodeRef;
    BOOL _needUpdate;
    JGLayoutCommit *_commit;
}
*/

@implementation JGLayoutElement

- (instancetype)init {
    if (self = [super init]) {
        pthread_mutex_init(&_lock, NULL);
        
        self->_enabled = YES;
        self->_needUpdate = NO;
        self->_nodeRef = YGNodeNew();
        self->_children = [NSMutableArray array];
        
        YGNodeSetContext(_nodeRef, (__bridge void *)(self));
    }
    return self;
}

- (void)dealloc {
    if (_nodeRef != NULL) {
        YGNodeFree(_nodeRef);
    }
    pthread_mutex_destroy(&_lock);
}

#pragma mark - Incremental

/**
    删除nodeRef的所有叶节点

    @param node nodeRef
 */
JENGA_STATIC_INLINE
void YGRemoveAllChildren(const YGNodeRef node) {
    if (node == NULL) {
        return;
    }
    
    while (YGNodeGetChildCount(node) > 0) {
        YGNodeRemoveChild(node, YGNodeGetChild(node, YGNodeGetChildCount(node) - 1));
    }
}

/*
    如果_dirty为YES表示当前element为dirty;
    如果当前nodeRef为Dirty表示当前element为dirty;
    如果当前element的commit与缓存commit不同，则表示当前element为dirty;
 */
- (void)markDirty {
    self->_needUpdate = YES;
}

/**
    判断当前可用的children list是否和上次相同
    如果相同则返回NO,否则返回YES.

 @return BOOL
 */
- (BOOL)isHierachyDirty {
    if (_commit == nil) {
        return YES;
    }
    if (![[[JGLayoutCommit alloc] initWithElement:self] isEqualToCommit:_commit]) {
        return YES;
    }
    
    return NO;
}

/**
    重新挂载节点
    Discuss: 这里从root节点开始mount？ 还是从当前节点开始mount？
 */
- (void)attachNodes {
    if (!self.enabled) {
        return;
    }
    
    YGNodeRef nodeRef = self->_nodeRef;
    NSArray <JGLayoutElement *> *availableChildren = self.availableChildren;
    BOOL isLeaf = availableChildren.count == 0;
    
    // 由于自定义MeasureFunction的nodeRef比较特殊, 不会自动为其标记为Dirty, 这里针对这种情况进行处理.
    BOOL needUpdate = NO;
    if (self.isRoot) {
        needUpdate = self->_needUpdate;
    } else {
        if (!self->_needUpdate) {
            self->_needUpdate = self.parent->_needUpdate;
        }
        needUpdate = self.parent->_needUpdate;
    }
    if (needUpdate) {
        YGNodeMarkDirty(nodeRef);
    }

    if (isLeaf) {
        // 如果是叶节点, 删除所有子节点
        if (YGNodeGetChildCount(nodeRef) > 0) {
            YGRemoveAllChildren(nodeRef);
        }
        // 叶节点更新measure function
        if (self.measureHandler) {
            if (YGNodeGetMeasureFunc(nodeRef) == NULL) {
                YGNodeSetMeasureFunc(nodeRef, JENMeasureFunction);
            }
        } else {
            if (YGNodeGetMeasureFunc(nodeRef) != NULL) {
                YGNodeSetMeasureFunc(nodeRef, NULL);
            }
        }
    } else {
        // 更新measure function
        if (YGNodeGetMeasureFunc(nodeRef) != NULL) {
            YGNodeSetMeasureFunc(nodeRef, NULL);
        }
        
        BOOL isHierachyDirty = [self isHierachyDirty];
        if (isHierachyDirty) {
            YGRemoveAllChildren(nodeRef);
        }
        [availableChildren enumerateObjectsUsingBlock:^(JGLayoutElement * _Nonnull element, NSUInteger idx, BOOL * _Nonnull stop) {
            [element attachNodes];
            if (isHierachyDirty) {
                YGNodeInsertChild(_nodeRef, element->_nodeRef, YGNodeGetChildCount(_nodeRef));
            }
        }];
    }
    
    // 本次mount后重置dirty
    self->_needUpdate = NO;
}

- (JGLayoutElement *)calculateLayoutThatFits:(CGSize)constrainedSize {
    if (!self.enabled) {
        return self;
    }
    [self attachNodes];
    YGNodeCalculateLayout(_nodeRef,
                          constrainedSize.width,
                          constrainedSize.height,
                          (YGDirection)self.direction);
    // 更新缓存的children list.
    self->_commit = [JGLayoutCommit layoutElementWithElement:self];
    
    return self;
}

#pragma mark - TREE
- (BOOL)isRoot {
    pthread_mutex_lock(&_lock);
    if (self.parent == nil) {
        pthread_mutex_unlock(&_lock);
        return YES;
    }
    pthread_mutex_unlock(&_lock);
    return NO;
}

- (BOOL)isLeaf {
    pthread_mutex_lock(&_lock);
    if (self.children.count == 0) {
        pthread_mutex_unlock(&_lock);
        return YES;
    }
    pthread_mutex_unlock(&_lock);
    if (self.availableChildren.count == 0) {
        return YES;
    }
    return NO;
}

- (void)setChildren:(NSArray<JGLayoutElement *> *)children {
    if (!children || ![children isKindOfClass:[NSArray class]]) {
        pthread_mutex_lock(&_lock);
        [self->_children removeAllObjects];
        pthread_mutex_unlock(&_lock);
        return;
    }
    pthread_mutex_lock(&_lock);
    self->_children = [NSMutableArray arrayWithArray:children];
    pthread_mutex_unlock(&_lock);
}

- (BOOL)containsChild:(JGLayoutElement *)element {
    pthread_mutex_lock(&_lock);
    BOOL isContain = [self->_children containsObject:element];
    pthread_mutex_unlock(&_lock);
    return isContain;
}

- (void)addChild:(JGLayoutElement *)element {
    pthread_mutex_lock(&_lock);
    [self->_children addObject:element];
    element.parent = self;
    pthread_mutex_unlock(&_lock);
}

- (void)addChildren:(NSArray <JGLayoutElement *> *)nodes {
    for (JGLayoutElement *node in nodes) {
        [self addChild:node];
    }
}

- (void)insertChild:(JGLayoutElement *)element atIndex:(NSInteger)idx {
    pthread_mutex_lock(&_lock);
    [self->_children insertObject:element atIndex:idx];
    element->_parent = self;
    pthread_mutex_unlock(&_lock);
}

- (void)insertChildren:(NSArray *)nodes atIndex:(NSInteger)idx {
    for (JGLayoutElement *node in nodes) {
        [self insertChild:node atIndex:idx];
    }
}

- (void)removeChild:(JGLayoutElement *)element {
    if (![self containsChild:element]) {
        return;
    }
    pthread_mutex_lock(&_lock);
    element->_parent = nil;
    [self->_children removeObject:element];
    pthread_mutex_unlock(&_lock);
}

- (void)removeChildren:(NSArray *)nodes {
    for (JGLayoutElement *node in nodes) {
        [self removeChild:node];
    }
}

- (void)removeAllChildren {
    pthread_mutex_lock(&_lock);
    [self->_children removeAllObjects];
    pthread_mutex_unlock(&_lock);
}

- (nullable JGLayoutElement *)childAtIndex:(NSUInteger)idx {
    pthread_mutex_lock(&_lock);
    if (idx >= self->_children.count) {
        pthread_mutex_unlock(&_lock);
        return nil;
    }
    JGLayoutElement *node = [self->_children objectAtIndex:idx];
    pthread_mutex_unlock(&_lock);
    return node;
}

- (NSArray <JGLayoutElement *> *)allChildren {
    pthread_mutex_lock(&_lock);
    NSArray *children = [NSArray arrayWithArray:self->_children];
    pthread_mutex_unlock(&_lock);
    return children;
}

- (NSArray <JGLayoutElement *> *)availableChildren {
    NSMutableArray *availableChildren = [NSMutableArray array];
    NSArray *children = [self allChildren];
    [children enumerateObjectsUsingBlock:^(JGLayoutElement * _Nonnull element, NSUInteger idx, BOOL * _Nonnull stop) {
        if (element.enabled) {
            [availableChildren addObject:element];
        }
    }];
    return [availableChildren copy];
}

#pragma mark -
#pragma mark 计算属性设置方法
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wenum-conversion"

#define JG_NODE_STYLE_PROPERTY_GET_METHOD(property_type, lowercased_name, capitalized_name) \
- (property_type)lowercased_name {return (property_type)YGNodeStyleGet##capitalized_name(_nodeRef);}

#define JG_NODE_STYLE_PROPERTY_SET_METHOD(property_type, lowercased_name, capitalized_name) \
- (void)set##capitalized_name:(property_type)lowercased_name{YGNodeStyleSet##capitalized_name(_nodeRef, lowercased_name);}

#define JG_NODE_STYLE_PROPERTY_SET_VALUE_METHOD(lowercased_name, capitalized_name) \
- (void)set##capitalized_name:(YGValue)lowercased_name{ \
switch (lowercased_name.unit) { \
case YGUnitPoint: YGNodeStyleSet##capitalized_name(_nodeRef, lowercased_name.value); break; \
case YGUnitPercent: YGNodeStyleSet##capitalized_name##Percent(_nodeRef, lowercased_name.value); break; \
default: NSAssert(NO, @"Not implemented"); } \
}

#define JG_NODE_STYLE_PROPERTY_READWRITE_METHOD(property_type, lowercased_name, capitalized_name) \
JG_NODE_STYLE_PROPERTY_GET_METHOD (property_type, lowercased_name, capitalized_name) \
JG_NODE_STYLE_PROPERTY_SET_METHOD (property_type, lowercased_name, capitalized_name) \

#define JG_NODE_STYLE_PROPERTY_VALUE_READWRITE_METHOD(property_type, lowercased_name, capitalized_name) \
JG_NODE_STYLE_PROPERTY_GET_METHOD(property_type, lowercased_name, capitalized_name) \
JG_NODE_STYLE_PROPERTY_SET_VALUE_METHOD(lowercased_name, capitalized_name)

#define JG_NODE_STYLE_PROPERTY_INSETS_GET_METHOD(property_type, lowercased_name, capitalized_name) \
- (property_type)lowercased_name {return (property_type)YGNodeStyleGet##capitalized_name##Insets(_nodeRef);}

#define JG_NODE_STYLE_PROPERTY_INSETS_SET_METHOD(property_type, lowercased_name, capitalized_name) \
- (void)set##capitalized_name:(property_type)lowercased_name{YGNodeStyleSet##capitalized_name##Insets(_nodeRef, lowercased_name);}

#define JG_NODE_STYLE_PROPERTY_INSETS_READWRITE_METHOD(property_type, lowercased_name, capitalized_name) \
JG_NODE_STYLE_PROPERTY_INSETS_GET_METHOD (property_type, lowercased_name, capitalized_name) \
JG_NODE_STYLE_PROPERTY_INSETS_SET_METHOD (property_type, lowercased_name, capitalized_name) \

JG_NODE_STYLE_PROPERTY_READWRITE_METHOD(JGDirectionType, direction, Direction);
JG_NODE_STYLE_PROPERTY_READWRITE_METHOD(JGFlexDirectionType, flexDirection, FlexDirection);
JG_NODE_STYLE_PROPERTY_READWRITE_METHOD(JGJustifyType, justifyContent, JustifyContent);
JG_NODE_STYLE_PROPERTY_READWRITE_METHOD(JGFlexAlignType, alignContent, AlignContent);
JG_NODE_STYLE_PROPERTY_READWRITE_METHOD(JGFlexAlignType, alignItems, AlignItems);
JG_NODE_STYLE_PROPERTY_READWRITE_METHOD(JGFlexAlignType, alignSelf, AlignSelf);
JG_NODE_STYLE_PROPERTY_READWRITE_METHOD(JGPositionType, positionType, PositionType);
JG_NODE_STYLE_PROPERTY_READWRITE_METHOD(JGFlexWrapType, flexWrap, FlexWrap);

JG_NODE_STYLE_PROPERTY_READWRITE_METHOD(CGFloat, flex, Flex);
JG_NODE_STYLE_PROPERTY_READWRITE_METHOD(CGFloat, flexGrow, FlexGrow);
JG_NODE_STYLE_PROPERTY_READWRITE_METHOD(CGFloat, flexShrink, FlexShrink);
JG_NODE_STYLE_PROPERTY_VALUE_READWRITE_METHOD(JGValue, flexBasis, FlexBasis);

JG_NODE_STYLE_PROPERTY_VALUE_READWRITE_METHOD(JGValue, width, Width);
JG_NODE_STYLE_PROPERTY_VALUE_READWRITE_METHOD(JGValue, height, Height);
JG_NODE_STYLE_PROPERTY_VALUE_READWRITE_METHOD(JGValue, minWidth, MinWidth);
JG_NODE_STYLE_PROPERTY_VALUE_READWRITE_METHOD(JGValue, minHeight, MinHeight);
JG_NODE_STYLE_PROPERTY_VALUE_READWRITE_METHOD(JGValue, maxWidth, MaxWidth);
JG_NODE_STYLE_PROPERTY_VALUE_READWRITE_METHOD(JGValue, maxHeight, MaxHeight);

JG_NODE_STYLE_PROPERTY_READWRITE_METHOD(CGFloat, aspectRatio, AspectRatio);

JG_NODE_STYLE_PROPERTY_INSETS_READWRITE_METHOD(JGEdgeInsetsValue, position, Position);
JG_NODE_STYLE_PROPERTY_INSETS_READWRITE_METHOD(JGEdgeInsetsValue, margin, Margin);
JG_NODE_STYLE_PROPERTY_INSETS_READWRITE_METHOD(JGEdgeInsetsValue, padding, Padding);
JG_NODE_STYLE_PROPERTY_INSETS_READWRITE_METHOD(JGEdgeInsets, border, Border);

#pragma clang diagnostic pop

#pragma mark 获取计算结果
- (CGRect)frame {
    JGRect calculatedFrame = self.calculatedFrame;
    JGDirectionType direction = self.calculatedDirection;
    return CGRectMake(direction == JGDirectionLTR ? calculatedFrame.origin.left : calculatedFrame.origin.right,
                      calculatedFrame.origin.top,
                      calculatedFrame.size.width,
                      calculatedFrame.size.height);
}

- (JGRect)calculatedFrame {
    JGPosition origin = {
        .left = YGNodeLayoutGetLeft(_nodeRef),
        .right = YGNodeLayoutGetRight(_nodeRef),
        .top = YGNodeLayoutGetTop(_nodeRef),
        .bottom = YGNodeLayoutGetBottom(_nodeRef),
    };
    CGSize size = {
        .width = YGNodeLayoutGetWidth(_nodeRef),
        .height = YGNodeLayoutGetHeight(_nodeRef)
    };
    
    JGRect rect = {
        .origin = origin,
        .size = size
    };
    
    return rect;
}

- (BOOL)hadOverflow {
    BOOL hadeOverflow = YGNodeLayoutGetHadOverflow(_nodeRef);
    return hadeOverflow;
}

- (JGDirectionType)calculatedDirection {
    YGDirection direction = YGNodeLayoutGetDirection(_nodeRef);
    return (JGDirectionType)direction;
}

- (JGEdgeInsets)calculatedMargin {
    JGEdgeInsets insets = {
        .left = YGNodeLayoutGetMargin(_nodeRef, YGEdgeLeft),
        .right = YGNodeLayoutGetMargin(_nodeRef, YGEdgeRight),
        .top = YGNodeLayoutGetMargin(_nodeRef, YGEdgeTop),
        .bottom = YGNodeLayoutGetMargin(_nodeRef, YGEdgeBottom),
        .start = YGNodeLayoutGetMargin(_nodeRef, YGEdgeStart),
        .end = YGNodeLayoutGetMargin(_nodeRef, YGEdgeEnd),
        .horizontal = YGNodeLayoutGetMargin(_nodeRef, YGEdgeHorizontal),
        .vertical = YGNodeLayoutGetMargin(_nodeRef, YGEdgeVertical),
        .all = YGNodeLayoutGetMargin(_nodeRef, YGEdgeAll),
    };
    return insets;
}

- (JGEdgeInsets)calculatedBorder {
    JGEdgeInsets insets = {
        .left = YGNodeLayoutGetBorder(_nodeRef, YGEdgeLeft),
        .right = YGNodeLayoutGetBorder(_nodeRef, YGEdgeRight),
        .top = YGNodeLayoutGetBorder(_nodeRef, YGEdgeTop),
        .bottom = YGNodeLayoutGetBorder(_nodeRef, YGEdgeBottom),
        .start = YGNodeLayoutGetBorder(_nodeRef, YGEdgeStart),
        .end = YGNodeLayoutGetBorder(_nodeRef, YGEdgeEnd),
        .horizontal = YGNodeLayoutGetBorder(_nodeRef, YGEdgeHorizontal),
        .vertical = YGNodeLayoutGetBorder(_nodeRef, YGEdgeVertical),
        .all = YGNodeLayoutGetBorder(_nodeRef, YGEdgeAll),
    };
    return insets;
}

- (JGEdgeInsets)calculatedPadding {
    JGEdgeInsets insets = {
        .left = YGNodeLayoutGetPadding(_nodeRef, YGEdgeLeft),
        .right = YGNodeLayoutGetPadding(_nodeRef, YGEdgeRight),
        .top = YGNodeLayoutGetPadding(_nodeRef, YGEdgeTop),
        .bottom = YGNodeLayoutGetPadding(_nodeRef, YGEdgeBottom),
        .start = YGNodeLayoutGetPadding(_nodeRef, YGEdgeStart),
        .end = YGNodeLayoutGetPadding(_nodeRef, YGEdgeEnd),
        .horizontal = YGNodeLayoutGetPadding(_nodeRef, YGEdgeHorizontal),
        .vertical = YGNodeLayoutGetPadding(_nodeRef, YGEdgeVertical),
        .all = YGNodeLayoutGetPadding(_nodeRef, YGEdgeAll),
    };
    return insets;
}

JENGA_STATIC_INLINE
CGFloat JENMeasurePreferedValue(CGFloat constrainedSize, CGFloat measuredSize, YGMeasureMode measureMode) {
    CGFloat result;
    if (measureMode == YGMeasureModeExactly) {
        result = constrainedSize;
    } else if (measureMode == YGMeasureModeAtMost) {
        result = MIN(constrainedSize, measuredSize);
    } else {
        result = measuredSize;
    }
    
    return result;
}

JENGA_STATIC_INLINE
YGSize JENMeasureFunction(YGNodeRef nodeRef, float width, YGMeasureMode widthMode, float height, YGMeasureMode heightMode) {
    const CGFloat constrainedWidth = (widthMode == YGMeasureModeUndefined) ? CGFLOAT_MAX : width;
    const CGFloat constrainedHeight = (heightMode == YGMeasureModeUndefined) ? CGFLOAT_MAX: height;
    const CGSize constrainedSize = CGSizeMake(constrainedWidth, constrainedHeight);
    
    JGLayoutElement *node = (__bridge JGLayoutElement*) YGNodeGetContext(nodeRef);
    
    CGSize size = CGSizeMake(NAN, NAN);
    if (node && node != NULL) {
        if (node.measureHandler) {
            size = node.measureHandler(constrainedSize);
        }
//        else {
//            id <JGLayoutElementMeasureProtocol> measurer = node.measurer;
//            if (measurer) {
//                if ([measurer respondsToSelector:@selector(measureSizeThatFits:)]) {
//                    size = [measurer measureSizeThatFits:constrainedSize];
//                } else if ([measurer respondsToSelector:@selector(sizeThatFits:)]) {
//                    size = [measurer sizeThatFits:constrainedSize];
//                }
//            }
//        }
    }
    
    return (YGSize) {
        .width = JENMeasurePreferedValue(constrainedWidth, size.width, widthMode),
        .height = JENMeasurePreferedValue(constrainedHeight, size.height, heightMode),
    };
}


@end
