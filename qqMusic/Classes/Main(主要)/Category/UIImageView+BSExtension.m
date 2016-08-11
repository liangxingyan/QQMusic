//
//  UIImageView+BSExtension.m
//  百思不得姐
//
//  Created by lxy on 16/6/7.
//  Copyright © 2016年 lxy. All rights reserved.
//

#import "UIImageView+BSExtension.h"
#import "UIImageView+WebCache.h"
#import "UIImage+Extension.h"

@implementation UIImageView (BSExtension)

// 设置圆角图像
- (void)setHeader:(NSString *)url {
    
    UIImage *placeholder = [[UIImage imageNamed:@"avatar_default_small"] circleImage];
    [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        // 有可能头像为nil, 如果为nil就给占位图片
        self.image =  image ? [image circleImage] : placeholder;
    }];
}

@end
