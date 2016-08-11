//
//  MusicModel.h
//  qqMusic
//
//  Created by lxy on 16/4/29.
//  Copyright © 2016年 lxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicModel : NSObject

@property(nonatomic, copy)  NSString *name; // 歌曲名字
@property(nonatomic, copy)  NSString *mp3Url;// 歌曲地址
@property(nonatomic, assign)NSInteger songID; // 歌曲 id（唯一）
@property(nonatomic, copy)  NSString *picUrl; //歌曲图片地址
@property(nonatomic, copy)  NSString *blurPicUrl; // 歌曲模糊图片地址
@property(nonatomic, copy)  NSString *album; // 所属的专辑
@property(nonatomic, copy)  NSString *singer; // 演唱者
@property(nonatomic, assign)NSInteger duration;   // 时长
@property(nonatomic, copy)  NSString *artists_name; // 同 singer 都是演唱者
@property(nonatomic, copy)  NSString *lyric;  // 歌词

@end
