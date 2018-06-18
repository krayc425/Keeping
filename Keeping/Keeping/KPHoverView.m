//
//  KPHoverView.m
//  Keeping
//
//  Created by 宋 奎熹 on 2018/6/14.
//  Copyright © 2018 宋 奎熹. All rights reserved.
//

#import "KPHoverView.h"
#import "UIView+Extensions.h"
#import "Utilities.h"

typedef NS_ENUM(NSUInteger, KPHoverHeaderState){
    KPHoverHeaderStateIdle,         //闲置状态
    KPHoverHeaderStatePulling,      //松开就可以进行刷新的状态
    KPHoverHeaderStateRefreshing    //正在刷新中的状态
};

@implementation KPHoverView{
    CGFloat lastOffsetY;
    CGFloat bottom;
    BOOL shouldStop;
    BOOL isDown;
    
    CGFloat _edgeInsetsTop;
    KPHoverHeaderState _headerState;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        _isShow = NO;
        self.backgroundColor = [Utilities getColor];
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
        bottom = frame.size.height;
        _headerState = KPHoverHeaderStateIdle;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        _isShow = NO;
        self.backgroundColor = [Utilities getColor];
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
        bottom = self.frame.size.height;
        _headerState = KPHoverHeaderStateIdle;
    }
    return self;
}

- (void)show{
    [_headerScrollView setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.5 animations:^{
        self.headerScrollView.contentInset = UIEdgeInsetsMake(self.frame.size.height + 10.0, 0, 0, 0);
        self.frame = CGRectMake(self.frame.origin.x,
                                -self.frame.size.height,
                                self.frame.size.width,
                                self.frame.size.height);
        [self->_headerScrollView setUserInteractionEnabled:YES];
    }];
    _isShow = YES;
    shouldStop = NO;
    [self vibrateWithStyle:UIImpactFeedbackStyleMedium];
}

- (void)hide{
    [_headerScrollView setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.5 animations:^{
        self.headerScrollView.contentInset = UIEdgeInsetsZero;
        self.frame = CGRectMake(self.frame.origin.x,
                                - self.frame.size.height,
                                self.frame.size.width,
                                self.frame.size.height);
        [self->_headerScrollView setUserInteractionEnabled:YES];
    }];
    _isShow = NO;
    _headerState = KPHoverHeaderStateIdle;
    [self vibrateWithStyle:UIImpactFeedbackStyleMedium];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if(change[NSKeyValueChangeNewKey] != nil){
        [self adjustStateWithContentOffset];
    }
}

- (void)adjustStateWithContentOffset{
    //记录 scrollView原始的上边距.  方便刷新之后,把 scrollView 的contentInset改回这个位置.
    _edgeInsetsTop = self.headerScrollView.contentInset.top;
    
    //当前的偏移量
    CGFloat contentOffsetY = self.headerScrollView.contentOffset.y;
    //scrollView左上角 原始偏移量(默认是0),在有导航栏的情况下可能会被调整为64.
    CGFloat happenOffsetY = -self.headerScrollView.contentInset.top;
    
    //如果往上滑动,直接 return
    if (contentOffsetY > happenOffsetY) {
        if(_headerState == KPHoverHeaderStateRefreshing){
            [self hide];
        }
        return;
    }
    
    if (_headerState == KPHoverHeaderStateRefreshing) {
        return;
    }
    
    //header 完全出现时的contentOffset.y
    CGFloat headerCompleteDisplayContentOffsetY = -self.frame.size.height / 4.0;
//        NSLog(@"%f  %f  %f",contentOffsetY,happenOffsetY,headerCompleteDisplayContentOffsetY);
    if (self.headerScrollView.isDragging == YES) {//如果正在拖拽
        //如果当前状态是 KPHoverStateIdle(闲置状态或者叫正常状态) && header 已经全部显示
        if (_headerState == KPHoverHeaderStateIdle && contentOffsetY < headerCompleteDisplayContentOffsetY) {
            //将状态设置为  松开就可以进行刷新的状态
            _headerState = KPHoverHeaderStatePulling;
//                        NSLog(@"下拉状态");
        }else if (_headerState == KPHoverHeaderStatePulling && contentOffsetY > headerCompleteDisplayContentOffsetY){//如果当前状态是 KPHoverStatePulling(松开就可以进行刷新的状态) && header只显示了一部分(用户往上滑动了)
            _headerState = KPHoverHeaderStateIdle;
//                        NSLog(@"常态");
        }
    }else{//如果松开了手
        if (_headerState == KPHoverHeaderStatePulling) {//如果状态是1,下拉状态.让它进入刷新状态
            _headerState = KPHoverHeaderStateRefreshing;
//                        NSLog(@"刷新中");
            [self show];
        }
    }
}

@end
