//
//  HYCircleProgressView.m
//  HYCircleProgressView-master
//
//  Created by 黄海燕 on 16/8/12.
//  Copyright © 2016年 huanghy. All rights reserved.
//

#import "HYCircleProgressView.h"
#import "Utilities.h"

#define kDuration 0.5
#define kDefaultLineWidth 2

@interface HYCircleProgressView()

@property (nonatomic,strong) CAShapeLayer *backgroundLayer;
@property (nonatomic,strong) CAShapeLayer *progressLayer;
@property (nonatomic,strong) UILabel *progressLabel;
@property (nonatomic,assign) CGFloat sumSteps;
@property (nonatomic,strong) NSTimer *timer;

@end

@implementation HYCircleProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self createSubViews];
        //init default variable
        self.backgroundLineWidth = kDefaultLineWidth;
        self.progressLineWidth = kDefaultLineWidth;
        self.percentage = 0;
        self.offset = 0;
        self.sumSteps = 0;
        self.step = 0.1;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.clipsToBounds = YES;
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self createSubViews];
        //init default variable
        self.backgroundLineWidth = kDefaultLineWidth;
        self.progressLineWidth = kDefaultLineWidth;
        self.percentage = 0;
        self.offset = 0;
        self.sumSteps = 0;
        self.step = 0.1;
    }
    return self;
}

- (void)createSubViews
{
    self.progressLabel.text = @"0%";
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.progressLabel];
    
    _backgroundLayer = [CAShapeLayer layer];
    _backgroundLayer.frame = self.bounds;
    _backgroundLayer.fillColor = nil;
    _backgroundLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    
    _progressLayer = [CAShapeLayer layer];
    _progressLayer.frame = self.bounds;
    _progressLayer.fillColor = nil;
    _progressLayer.strokeColor = [UIColor redColor].CGColor;
    
    [self.layer addSublayer:_backgroundLayer];
    [self.layer addSublayer:_progressLayer];
}

- (void)setFontWithSize:(CGFloat)size{
    self.progressLabel.font = [UIFont systemFontOfSize:size];
}

#pragma mark - draw circleLine
- (void)setBackgroundCircleLine
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.center.x - self.frame.origin.x, self.center.y - self.frame.origin.y)
                                          radius:(self.bounds.size.width - _backgroundLineWidth)/2 - _offset
                                      startAngle:0
                                        endAngle:M_PI*2
                                       clockwise:YES];
    
    _backgroundLayer.path = path.CGPath;
}

- (void)setProgressCircleLine
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.center.x - self.frame.origin.x, self.center.y - self.frame.origin.y)
                                          radius:(self.frame.size.width - _progressLineWidth)/2 - _offset
                                      startAngle:-M_PI_2
                                        endAngle:-M_PI_2 + M_PI *2
                                       clockwise:YES];
    
    _progressLayer.path = path.CGPath;
}

#pragma mark -setter and get method
- (UILabel *)progressLabel
{
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.bounds.size.width -100)/2, (self.bounds.size.height - 100)/2, 100, 100)];
    }
    return _progressLabel;
}

- (void)setDigitTintColor:(UIColor *)digitTintColor
{
    _digitTintColor = digitTintColor;
    _progressLabel.textColor = _digitTintColor;
}

- (void)setBackgroundLineWidth:(CGFloat)backgroundLineWidth
{
    _backgroundLineWidth = backgroundLineWidth;
    _backgroundLayer.lineWidth = _backgroundLineWidth;
    [self setBackgroundCircleLine];
}

- (void)setProgressLineWidth:(CGFloat)progressLineWidth
{
    _progressLineWidth = progressLineWidth;
    _progressLayer.lineWidth = _progressLineWidth;
    [self setProgressCircleLine];
}

- (void)setPercentage:(CGFloat)percentage
{
    /*
     * 自己加的
     */
    _sumSteps = 0;
    
    _percentage = percentage;
}

- (void)setBackgroundStrokeColor:(UIColor *)backgroundStrokeColor
{
    _backgroundStrokeColor = backgroundStrokeColor;
    _backgroundLayer.strokeColor = _backgroundStrokeColor.CGColor;
}

- (void)setProgressStrokeColor:(UIColor *)progressStrokeColor
{
    _progressStrokeColor = progressStrokeColor;
    _progressLayer.strokeColor = _progressStrokeColor.CGColor;
}

#pragma mark - progress animated YES or NO
- (void)setProgress:(CGFloat)percentage animated:(BOOL)animated
{
    self.percentage = percentage;
    _progressLayer.strokeEnd = _percentage;
    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = [NSNumber numberWithFloat:0.0];
        animation.toValue = [NSNumber numberWithFloat:_percentage];
        animation.duration = kDuration;
        //start timer
        _timer = [NSTimer scheduledTimerWithTimeInterval:_step
                                                  target:self
                                                selector:@selector(numberAnimation)
                                                userInfo:nil
                                                 repeats:YES];
        
        
        [_progressLayer addAnimation:animation forKey:@"strokeEndAnimation"];
    }else{
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _progressLabel.text = [NSString stringWithFormat:@"%.0f%%",_percentage*100];
        [CATransaction commit];
    }
}

- (void)numberAnimation
{
    _sumSteps += _step;
    float sumSteps = (_percentage/kDuration)*_sumSteps;
    _progressLabel.text = [NSString stringWithFormat:@"%.0f%%",sumSteps*100];
    if (_sumSteps >= kDuration) {
        //close timer
        [_timer invalidate];
        _timer = nil;
        return;
    }
}

@end
