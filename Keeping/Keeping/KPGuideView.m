//
//  KPGuideView.m
//  Keeping
//
//  Created by 宋 奎熹 on 2018/5/28.
//  Copyright © 2018年 宋 奎熹. All rights reserved.
//

#import "KPGuideView.h"
#import "Utilities.h"

@interface KPGuideView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation KPGuideView

static const NSInteger NumberOfGuide = 5; //引导页数

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self addSubview:scrollView];
        
        scrollView.delegate = self;
        scrollView.backgroundColor = [UIColor whiteColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * NumberOfGuide, SCREEN_HEIGHT);
        scrollView.pagingEnabled = YES;
        UIButton *startBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 80, SCREEN_WIDTH, 80)];
        startBtn.titleLabel.font = [UIFont systemFontOfSize:20.0 weight:UIFontWeightBold];
        startBtn.backgroundColor = [Utilities getColor];
        [startBtn setTitle:@"去创建第一个任务吧！" forState:UIControlStateNormal];
        [startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [startBtn addTarget:self action:@selector(onFinishedButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:startBtn];
    
        for (int i=0; i<NumberOfGuide; i++) {
            UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            imgView.userInteractionEnabled = YES;
            
            imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Intro_Screen_%d", i + 1]];
            [scrollView addSubview:imgView];
        }
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 40.0f, SCREEN_HEIGHT - 100.0f, 80.0f, 10.0f)];
        [self addSubview:_pageControl];
        _pageControl.enabled = YES;
        _pageControl.numberOfPages = NumberOfGuide;
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [Utilities getColor];
    }
    return self;
}

- (void)onFinishedButtonPressed{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - 滑动代理

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat scrollViewW = scrollView.frame.size.width;
    CGFloat x = scrollView.contentOffset.x;
    int page = (x + scrollViewW / 2) / scrollViewW;
    _pageControl.currentPage = page;
}

@end
