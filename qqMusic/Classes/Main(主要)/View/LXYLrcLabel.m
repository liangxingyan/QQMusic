//
//  LXYLrcLabel.m
//  qqMusic
//
//  Created by mac2 on 16/8/10.
//  Copyright © 2016年 lxy. All rights reserved.
//

#import "LXYLrcLabel.h"

@implementation LXYLrcLabel


- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // 获取需要画的区域
    CGRect fillRect = CGRectMake(0, 0, self.bounds.size.width * self.progress, self.bounds.size.height);
    [[UIColor colorWithRed:45/255.0 green:183/255.0 blue:101/255.0 alpha:1] set];
    // 添加区域
    UIRectFillUsingBlendMode(fillRect, kCGBlendModeSourceIn);
    
}

@end
