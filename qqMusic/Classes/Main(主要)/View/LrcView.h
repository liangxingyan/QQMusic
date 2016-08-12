//
//  LrcView.h
//  qqMusic
//
//  Created by mac2 on 16/8/10.
//  Copyright © 2016年 lxy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LXYLrcLabel;

@interface LrcView : UIScrollView

/** 歌词label */
@property (nonatomic, strong) LXYLrcLabel *lrcLabel;
/** 歌词 */
@property(nonatomic, copy)  NSString *lyric;
/** 当前播放时间 */
@property (nonatomic, assign) NSTimeInterval currentTime;
// 存放音乐模型数据
@property (nonatomic, strong) NSArray *musicData;
// 换歌
@property (nonatomic, assign) NSInteger index;
/** 时间 */
@property (nonatomic, assign) NSTimeInterval duration;

@end
