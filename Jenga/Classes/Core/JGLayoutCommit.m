//
//  JGLayoutCommit.m
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

#import "JGLayoutCommit.h"
#import "JGLayoutElement.h"

@interface JGLayoutCommit ()
@property (nonatomic, strong, readwrite) NSPointerArray *commits;
@end

@implementation JGLayoutCommit

- (instancetype)init {
    if (self = [super init]) {
        _commits = [NSPointerArray pointerArrayWithOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

+ (instancetype)layoutElementWithElement:(JGLayoutElement *)element {
    JGLayoutCommit *commit = [[JGLayoutCommit alloc] initWithElement:element];
    return commit;
}

- (instancetype)initWithElement:(JGLayoutElement *)element {
    if (self = [self init]) {
        NSArray *availableChildren = [element availableChildren];
        [availableChildren enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.commits addPointer:(__bridge void *)(obj)];
        }];
    }
    
    return self;
}

- (BOOL)isEqualToCommit:(JGLayoutCommit *)object {
    BOOL isEqual = [self isEqual:object];
    if (isEqual) {
        isEqual = [self.commits isEqual:object.commits];
    }
    return isEqual;

}

@end
