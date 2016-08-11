//
//  LXYLrc.m
//  qqMusic
//
//  Created by mac2 on 16/8/10.
//  Copyright © 2016年 lxy. All rights reserved.
//

#import "LXYLrc.h"

@implementation LXYLrc

- (instancetype)initWithLrcString:(NSString *)lrcString {
    
    if (self = [super init]) {
        
        NSArray *timeArray = [lrcString componentsSeparatedByString:@"]"];
        self.content = timeArray[1];
        NSString *str = timeArray[0];
        self.time = [self timeStringWithString:[str substringFromIndex:1]];
    }
    
    return self;
}

#pragma mark - 时间处理
- (NSTimeInterval)timeStringWithString:(NSString *)timeStr {
    NSInteger min = [[timeStr componentsSeparatedByString:@":"][0] integerValue];
    NSInteger second = [[timeStr substringWithRange:NSMakeRange(3, 2)] integerValue];
    NSInteger haomiao = [[timeStr componentsSeparatedByString:@"."][1] integerValue];
    return (min * 60 + second + haomiao * 0.01);
}


@end
