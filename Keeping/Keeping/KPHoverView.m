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
    KPHoverHeaderState _headerState;
    CGFloat lastOffsetY;
}

- (instancetype)initWithFrame:(CGRect)frame andBaseTop:(CGFloat)baseTop{
    self.baseInsetTop = baseTop;
    return [self initWithFrame:CGRectMake(frame.origin.x,
                                          frame.origin.y + baseTop,
                                          frame.size.width,
                                          frame.size.height)];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self commonInit];
    }
    return self;
}

- (void)commonInit{
    self.isShow = NO;
    self.backgroundColor = [Utilities getColor];
    self.layer.cornerRadius = 10.0;
    self.layer.masksToBounds = YES;
    _headerState = KPHoverHeaderStateIdle;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.isShow) {
        [self show];
    }
}

- (void)show{
    self.isShow = YES;
    [_headerScrollView setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.5 animations:^{
        self.headerScrollView.contentInset = UIEdgeInsetsMake(self.frame.size.height + 10.0 + self.baseInsetTop, 0, 0, 0);
        self.frame = CGRectMake(self.frame.origin.x,
                                -self.frame.size.height - self.baseInsetTop,
                                UIScreen.mainScreen.bounds.size.width - 20.0,
                                self.frame.size.height);
        [self->_headerScrollView setUserInteractionEnabled:YES];
    }];
    [self vibrateWithStyle:UIImpactFeedbackStyleMedium];
}

- (void)hide{
    self.isShow = NO;
    [_headerScrollView setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.5 animations:^{    
        self.headerScrollView.contentInset = UIEdgeInsetsMake(self.baseInsetTop, 0, 0, 0);
        self.frame = CGRectMake(self.frame.origin.x,
                                -self.frame.size.height - self.baseInsetTop,
                                UIScreen.mainScreen.bounds.size.width - 20.0,
                                self.frame.size.height);
        [self->_headerScrollView setUserInteractionEnabled:YES];
    }];
    [self vibrateWithStyle:UIImpactFeedbackStyleMedium];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if(change[NSKeyValueChangeNewKey] != nil){
        NSValue *value = (NSValue *)change[NSKeyValueChangeNewKey];
        CGPoint point = value.CGPointValue;
        [self adjustStateWithContentOffset:point.y];
    }
}

- (void)adjustStateWithContentOffset:(CGFloat)offsety{
    lastOffsetY = offsety;
    
    //当前的偏移量
    CGFloat contentOffsetY = self.headerScrollView.contentOffset.y;
    
    //header 完全出现时的contentOffset.y
    CGFloat headerCompleteDisplayContentOffsetY = -self.frame.size.height / 4.0;
    if(self.headerScrollView.isDragging == YES){//如果正在拖拽
        //如果当前状态是 KPHoverStateIdle(闲置状态或者叫正常状态) && header 已经全部显示
        if(_headerState == KPHoverHeaderStateIdle && contentOffsetY < headerCompleteDisplayContentOffsetY){
            //将状态设置为松开就可以进行刷新的状态
            _headerState = KPHoverHeaderStatePulling;
        }else if(_headerState == KPHoverHeaderStatePulling && contentOffsetY > headerCompleteDisplayContentOffsetY){//如果当前状态是 KPHoverStatePulling(松开就可以进行刷新的状态) && header只显示了一部分(用户往上滑动了)
            _headerState = KPHoverHeaderStateIdle;
        }else if(_headerState == KPHoverHeaderStateRefreshing && contentOffsetY > headerCompleteDisplayContentOffsetY * 4.0){
            _headerState = KPHoverHeaderStateIdle;
            [self hide];
        }
    }else{//如果松开了手
        if(_headerState == KPHoverHeaderStatePulling){//如果是下拉状态.让它进入刷新状态
            _headerState = KPHoverHeaderStateRefreshing;
            [self show];
        }
    }
}

@end
