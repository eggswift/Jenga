//
//  JGLayoutElement+Debug.m
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

#import "JGLayoutElement+Debug.h"
#import "JGLayoutElement+Internal.h"

@implementation JGLayoutElement (Debug)

- (NSString *)pointerDesctiption {
    // JGLayoutElement: 0x6000000ee100
    NSString *pointerDesctiption = [NSString stringWithFormat:@"%@: %p",NSStringFromClass(self.class), self];
    
    return pointerDesctiption;
}

- (NSString *)frameDescription {
    // frame:{{0, 0}, {120, 120}}
    NSString *frameDescription = [NSString stringWithFormat:@"frame:%@",NSStringFromCGRect(self.frame)];
    return frameDescription;
}

- (NSString *)enableDescription {
    // enabled:true
    NSString *enableDescription = [NSString stringWithFormat:@"isEnabled:%@",self.enabled ? @"true" : @"false"];
    return enableDescription;
}


/*
    <JGLayoutElement: 0x6000000e1300  enabled:true frame:{{0, 0}, {120, 120}}>
 */
- (NSString *)description {
    return [NSString stringWithFormat:@"<%@  %@ %@>",[self pointerDesctiption], [self enableDescription], [self frameDescription]];
}

//    YGNodePrint(self->_nodeRef, YGPrintOptionsLayout);
//    YGNodePrint(self->_nodeRef, YGPrintOptionsStyle);
//    YGNodePrint(self->_nodeRef, YGPrintOptionsChildren);

@end
