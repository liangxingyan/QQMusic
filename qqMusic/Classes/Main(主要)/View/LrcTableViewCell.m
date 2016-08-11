//
//  LrcTableViewCell.m
//  qqMusic
//
//  Created by mac2 on 16/8/10.
//  Copyright © 2016年 lxy. All rights reserved.
//

#import "LrcTableViewCell.h"
#import "LXYLrcLabel.h"
#import "Masonry.h"


@implementation LrcTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        LXYLrcLabel *lrcLabel = [[LXYLrcLabel alloc] init];
        lrcLabel.textColor = [UIColor whiteColor];
        lrcLabel.textAlignment = NSTextAlignmentCenter;
        lrcLabel.font = [UIFont systemFontOfSize:12];
        lrcLabel.numberOfLines = 0;
        self.lrcLabel = lrcLabel;
        [self.contentView addSubview:lrcLabel];
        lrcLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [lrcLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
        
    }
    
    return self;
}

+ (instancetype)lrcCellWithTableView:(UITableView *)talbeView {
    
    static NSString *ID = @"lrc";
    LrcTableViewCell *cell = [talbeView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[LrcTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return cell;
}

@end
