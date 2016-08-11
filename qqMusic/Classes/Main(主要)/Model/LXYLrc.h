//
//  LXYLrc.h
//  qqMusic
//
//  Created by mac2 on 16/8/10.
//  Copyright © 2016年 lxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LXYLrc : NSObject

/** 时间 */
@property (nonatomic, assign) NSTimeInterval time;
/** 内容 */
@property (nonatomic, copy) NSString *content;

- (instancetype)initWithLrcString:(NSString *)lrcString;

@end
