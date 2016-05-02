//
//  YCSlideView.m
//  youzer
//
//  Created by 王禹丞 on 15/12/16.
//  Copyright © 2015年 QXSX. All rights reserved.
//

#import "SongYCSlideView.h"

#define UIColorRGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define kWindowWidth                        ([[UIScreen mainScreen] bounds].size.width)

#define kWindowHeight                       ([[UIScreen mainScreen] bounds].size.height)

#define KTopViewHight 50

@interface SongYCSlideView()<UIScrollViewDelegate>

@property (nonatomic,strong) UIScrollView * bottomScrollView;

@property (nonatomic,strong) UIView * topView;

@property (nonatomic,strong) UIScrollView * topScrollView;

@property (nonatomic,strong) UIView * slideView;

@property (nonatomic,strong) NSMutableArray * btnArray;

@end


@implementation SongYCSlideView


- (instancetype)initWithFrame:(CGRect)frame WithViewControllers:(NSArray *)viewControllers{
  
    if (self = [super initWithFrame:frame]) {
        
        self.vcArray = viewControllers;
        
    }
   
    return self;
}

- (void)setVcArray:(NSArray *)vcArray{

    _vcArray = vcArray;
    
    _btnArray = [NSMutableArray array];
    
    [self confingTopView];
    
    [self configBottomView];

}



- (void)confingTopView{

    // 按钮宽度
    
    CGFloat buttonWight = kWindowWidth / _vcArray.count;
    
    // 按钮高度
    
    CGFloat buttonhight = KTopViewHight - 4;

    
    CGRect topViewFrame = CGRectMake(0, 0, kWindowWidth, KTopViewHight);
    
    self.topView = [[UIView alloc]initWithFrame:topViewFrame];
    self.topView.backgroundColor = UIColorRGBA(29, 50, 68, 1);

    [self addSubview:self.topView];

    //滑块的部分
    self.slideView = [[UIView alloc] initWithFrame:CGRectMake(0, KTopViewHight - 3, buttonWight, 3)];
    
    [_slideView setBackgroundColor:UIColorRGBA(45, 255, 97, 1)];
    
   [_topView  addSubview:self.slideView];
 
     //添加按钮
    
    for (int i = 0; i < self.vcArray.count ; i ++) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * buttonWight, 0, buttonWight, buttonhight)];
        
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWight, buttonhight)];
        
        button.tag = i;
       
        NSString * buttonTitle =  [self.vcArray[i] allKeys][0];
        
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        
        [button setTitleColor:UIColorRGBA(184, 196, 204, 1) forState:UIControlStateNormal];
        
        if (i == 0) {
            
            [button setTitleColor:UIColorRGBA(45, 255, 97, 1) forState:UIControlStateNormal];

        }
        
        [button addTarget:self action:@selector(tabSongButton:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
        [_btnArray addObject:button];
        
        [_topView addSubview:view];
    
}
 
//        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,KTopViewHight - 1 , kWindowWidth, 1)];
//    
//        lineView.backgroundColor = UIColorRGBA(239, 93, 58, 1);
//    
//        [_topView addSubview:lineView];

}

- (void)configBottomView{

    
    CGRect  bottomScrollViewFrame = CGRectMake(0, KTopViewHight, kWindowWidth, kWindowHeight-KTopViewHight);
    
    self.bottomScrollView = [[UIScrollView alloc]initWithFrame:bottomScrollViewFrame];
    
    [self addSubview:_bottomScrollView];
    
    for (int i = 0; i < self.vcArray.count ; i ++) {
    
     CGRect  VCFrame = CGRectMake(i * kWindowWidth, 0, kWindowWidth, bottomScrollViewFrame.size.height);
    
        NSString * key = [self.vcArray[i] allKeys][0];
        
        UIViewController * vc = _vcArray[i][key] ;
        
        vc.view.frame = VCFrame;
        
        [self.bottomScrollView addSubview:vc.view];
    }

    //高度也挺重要
    self.bottomScrollView.contentSize = CGSizeMake(self.vcArray.count * kWindowWidth, kWindowHeight);


    self.bottomScrollView.pagingEnabled = YES;
    
    self.bottomScrollView.showsHorizontalScrollIndicator = YES;
    
    self.bottomScrollView.showsVerticalScrollIndicator = YES;

    self.bottomScrollView.directionalLockEnabled = YES;
    
    self.bottomScrollView.bounces = NO;

    self.bottomScrollView.delegate =self;

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGRect frame = _slideView.frame;
    
    frame.origin.x = scrollView.contentOffset.x/_vcArray.count;
    
    _slideView.frame = frame;
    
    int pageNum = scrollView.contentOffset.x / kWindowWidth;
    
    for (UIButton * btn in _btnArray) {
        
        if (btn.tag == pageNum ) {
            
            [btn setTitleColor:UIColorRGBA(45, 255, 97, 1) forState:UIControlStateNormal];
            
        }else{
        
             [btn setTitleColor:UIColorRGBA(184, 196, 204, 1) forState:UIControlStateNormal];
        
        }
        
        
    }
    
    
}

-(void) tabSongButton: (id) sender{
   
    UIButton *button = sender;
  
    [button setTitleColor:UIColorRGBA(45, 255, 97, 1) forState:UIControlStateNormal];
    
    for (UIButton * btn in _btnArray) {
        
        if (button != btn ) {
            
            [btn setTitleColor:UIColorRGBA(184, 196, 204, 1) forState:UIControlStateNormal];

        }
        
        
    }

    [_bottomScrollView setContentOffset:CGPointMake(button.tag * kWindowWidth, 0) animated:NO];
}


@end
