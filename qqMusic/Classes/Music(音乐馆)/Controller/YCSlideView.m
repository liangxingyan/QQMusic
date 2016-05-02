//
//  YCSlideView.m
//  youzer
//
//  Created by 王禹丞 on 15/12/16.
//  Copyright © 2015年 QXSX. All rights reserved.
//

#import "YCSlideView.h"

#define UIColorRGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define kWindowWidth                        ([[UIScreen mainScreen] bounds].size.width)

#define kWindowHeight                       ([[UIScreen mainScreen] bounds].size.height)

//#define KTopViewHight 0

@interface YCSlideView()<UIScrollViewDelegate>



@end


@implementation YCSlideView


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


//设置顶部按钮的布局
- (void)confingTopView{

    CGRect topViewFrame = CGRectMake(0, 0, kWindowWidth-100, 44);
    
    // 按钮宽度,应该用topViewFrame的宽度除以_vcArray个数
    CGFloat buttonWight = topViewFrame.size.width /_vcArray.count;
    
    // 按钮高度
    
    CGFloat buttonhight = 44;

    
    
    self.topView = [[UIView alloc]initWithFrame:topViewFrame];
//    self.topView.backgroundColor = [UIColor redColor];
   

//    [self addSubview:self.topView];

//    //小滑块的宽度
//    self.slideView = [[UIView alloc] initWithFrame:CGRectMake(0, 44-2, buttonWight, 3)];
//    
//    //滑块的颜色
//    [_slideView setBackgroundColor:UIColorRGBA(239, 93, 58, 1)];
//    
//    //加到顶部视图
//   [_topView  addSubview:self.slideView];
 
     //添加按钮
    
    for (int i = 0; i < self.vcArray.count ; i ++) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * buttonWight, 0, buttonWight, buttonhight)];
        
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWight, buttonhight)];
        
        button.tag = i;
       
        NSString * buttonTitle =  [self.vcArray[i] allKeys][0];
        
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        
        button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        
        [button setTitleColor:UIColorRGBA(184, 196, 204, 1) forState:UIControlStateNormal];
        
        if (i == 0) {
            
            [button setTitleColor:UIColorRGBA(232, 234, 234, 1) forState:UIControlStateNormal];

        }
        
        [button addTarget:self action:@selector(tabButton:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
        [_btnArray addObject:button];
        
        [_topView addSubview:view];
    
}
    
    
//        //那根线
//        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,44 - 1 , kWindowWidth, 1)];
//    
//        lineView.backgroundColor = UIColorRGBA(239, 93, 58, 1);
//    
//        [_topView addSubview:lineView];

}

- (void)configBottomView{

    //
//    CGRect  bottomScrollViewFrame = CGRectMake(0, KTopViewHight, kWindowWidth, kWindowHeight - KTopViewHight);
    //滑动视图
    CGRect  bottomScrollViewFrame = CGRectMake(0, 0, kWindowWidth, kWindowHeight);
    
    self.bottomScrollView = [[UIScrollView alloc]initWithFrame:bottomScrollViewFrame];
    
    [self addSubview:_bottomScrollView];
    
    for (int i = 0; i < self.vcArray.count ; i ++) {
    
//     CGRect  VCFrame = CGRectMake(i * kWindowWidth, 0, kWindowWidth, bottomScrollViewFrame.size.height);
     CGRect  VCFrame = CGRectMake(i * kWindowWidth, 0, kWindowWidth, bottomScrollViewFrame.size.height);
        NSString * key = [self.vcArray[i] allKeys][0];
        
        UIViewController * vc = _vcArray[i][key] ;
        
        vc.view.frame = VCFrame;
        
        [self.bottomScrollView addSubview:vc.view];
    }

    //滑动内容的宽度，高度
    self.bottomScrollView.contentSize = CGSizeMake(self.vcArray.count * kWindowWidth, 0);

    self.bottomScrollView.pagingEnabled = YES;
    
    //隐藏水平
    self.bottomScrollView.showsHorizontalScrollIndicator = YES;
    
    //隐藏垂直
    self.bottomScrollView.showsVerticalScrollIndicator = NO;

    self.bottomScrollView.directionalLockEnabled = NO;
    
    self.bottomScrollView.bounces = NO;

    self.bottomScrollView.delegate =self;

}


//滑动时按钮标题的颜色和滑块滑动的距离
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGRect frame = _slideView.frame;
    
    frame.origin.x = scrollView.contentOffset.x / (_vcArray.count+1.5);
    
//        frame.origin.x = _topView.frame.origin.x/_vcArray.count;
    
    _slideView.frame = frame;
    
    int pageNum = scrollView.contentOffset.x / kWindowWidth;
    
    for (UIButton * btn in _btnArray) {
        
        if (btn.tag == pageNum ) {
            
            [btn setTitleColor:UIColorRGBA(232, 234, 234, 1) forState:UIControlStateNormal];
            
        }else{
        
             [btn setTitleColor:UIColorRGBA(184, 196, 204, 1) forState:UIControlStateNormal];
        
        }
        
        
    }
    
    
}

-(void) tabButton: (id) sender{
   
    UIButton *button = sender;
  
    [button setTitleColor:UIColorRGBA(232, 234, 234, 1) forState:UIControlStateNormal];
    
    for (UIButton * btn in _btnArray) {
        
        if (button != btn ) {
            
            [btn setTitleColor:UIColorRGBA(184, 196, 204, 1) forState:UIControlStateNormal];

        }
        
        
    }
    
    //这里修改了点击按钮后的位置，-60刚好解决
    [_bottomScrollView setContentOffset:CGPointMake(button.tag * kWindowWidth, -60) animated:YES];
}

@end
