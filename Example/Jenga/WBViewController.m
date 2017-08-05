//
//  WBViewController.m
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

#import "WBViewController.h"
#import "Jenga.h"

@interface WBViewController ()
{
    UILabel *a;
    JGLayoutElement *n;
    JGLayoutElement *_n1;
    JGLayoutElement *_n2;
    JGLayoutElement *_n3;
    JGLayoutElement *_n4;
}
@end

@implementation WBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    a = [UILabel new];
    a.text = @"一个";
    
    n = [[JGLayoutElement alloc] init];
    n.justifyContent = JGJustifyCenter;
    n.flexDirection = YGFlexDirectionRow;
    n.flexWrap = YGWrapWrap;
    
    JGLayoutElement *n1 = [[JGLayoutElement alloc] init];
    n1.width = JGValuePoint(120);
    n1.height = JGValuePoint(120);
    
    JGLayoutElement *n2 = [[JGLayoutElement alloc] init];
    n2.flex = 0;
    n2.flexGrow = 0;
//    n2.height = JGValuePoint(120);

    JGLayoutElement *n4 = [[JGLayoutElement alloc] init];
    n4.width = JGValuePoint(60);
    n4.height = JGValuePoint(60);
    n2.children = @[n4];
    
    
    JGLayoutElement *n3 = [[JGLayoutElement alloc] init];
    n3.width = JGValuePoint(120);
    n3.height = JGValuePoint(120);
    
    n.children = @[n1, n2, n3];
    
    [n calculateLayoutThatFits:CGSizeMake(200000, 200000)];
    
    a.text = @"一个大王";
    [n2 markDirty];
    [n calculateLayoutThatFits:CGSizeMake(200000, 200000)];
    
    
}

@end
