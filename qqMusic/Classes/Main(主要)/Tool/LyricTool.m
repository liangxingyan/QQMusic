//
//  LyricTool.m
//  qqMusic
//
//  Created by mac2 on 16/8/10.
//  Copyright © 2016年 lxy. All rights reserved.
//

#import "LyricTool.h"
#import "LXYLrc.h"

@implementation LyricTool

+ (NSArray *)lyricToolWithLrcname:(NSString *)lrc {
    
    
    // 拿到歌词的数组
    NSArray *lrcArray = [lrc componentsSeparatedByString:@"\n"];
    
    NSMutableArray *tempArray = [NSMutableArray array];
    
    // 遍历歌词转换模型
    for (NSString *lrcStr in lrcArray) {
        // 过滤
        
        if (![lrcStr hasPrefix:@"["]) {
            continue;
        }
        
        LXYLrc *lxylrc = [[LXYLrc alloc] initWithLrcString:lrcStr];
        
        [tempArray addObject:lxylrc];
    }
    return tempArray;
}

@end
