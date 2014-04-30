//
//  ALPullToRefreshView.m
//  PullToRefreshView
//
//  Created by Arien Lau on 14-3-10.
//  Copyright (c) 2014年 Arien Lau. All rights reserved.
//

#import "ALPullToRefreshView.h"
#if !__has_feature(objc_arc)
    #error This file must be compiled with ARC.Use -fobjc-arc flag (or convert project to ARC)
#endif

#define RGB_Color(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define kALLastPullDownKey @"ALLastPullDownTime"
#define kALLastPullUpKey   @"ALLastPullingUpTime"
#define kAnimationDuration 0.18f

static CGFloat const kALPullSizeToRefresh = 65.0f;

typedef NS_ENUM(NSInteger, ALPullState) {
    ALPullStateLoading,
    ALPullStateNormal,
    ALPullStatePulling,
};

@interface ALPullToRefreshView ()
{
    ALPullState _state;
    ALPullViewStyle _style;
}
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *lastUpdatedLabel;
@property (nonatomic, strong) CALayer *arrowImage;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@end

@implementation ALPullToRefreshView

//- (void)dealloc {
//    NSLog(@"%s", __FUNCTION__);
//}

- (id)initWithFrame:(CGRect)frame imageName:(NSString *)imageName textColor:(UIColor *)color viewStyle:(ALPullViewStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = RGB_Color(226, 231, 237, 1.0);
        _style = style;
        if(_style ==  ALViewStylePullDown) {
//            self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        } else if (_style == ALViewStylePullUp) {

        }
        _statusLabel = [[UILabel alloc] init];
        if (_style == ALViewStylePullUp) {
           _statusLabel.frame = CGRectMake(0, 10, frame.size.width, 20);
        } else if (_style == ALViewStylePullDown) {
            _statusLabel.frame = CGRectMake(0, frame.size.height - 50, frame.size.width, 20);
            _statusLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        }
        _statusLabel.textColor = (color ? color : [UIColor blackColor]);
        _statusLabel.font = [UIFont boldSystemFontOfSize:13];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_statusLabel];
        
        _lastUpdatedLabel = [[UILabel alloc] init];
        _lastUpdatedLabel.backgroundColor = [UIColor clearColor];
        _lastUpdatedLabel.frame = (_style == ALViewStylePullDown) ? CGRectMake(0, frame.size.height - 30, frame.size.width, 20) : CGRectMake(0, 30, frame.size.width, 20);
        _lastUpdatedLabel.autoresizingMask = (_style == ALViewStylePullDown) ?UIViewAutoresizingFlexibleTopMargin : UIViewAutoresizingNone;
        _lastUpdatedLabel.textColor = (color ? color : [UIColor blackColor]);
        _lastUpdatedLabel.textAlignment = NSTextAlignmentCenter;
        _lastUpdatedLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_lastUpdatedLabel];
        
        _arrowImage = [CALayer layer];
        _arrowImage.frame = (_style == ALViewStylePullDown) ? CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f) : CGRectMake(25.0f, 5, 30.0f, 55.0f);
        _arrowImage.contentsGravity = kCAGravityResizeAspect;
        _arrowImage.contents = (__bridge id)(([UIImage imageNamed:imageName].CGImage));
        _arrowImage.contentsScale = [UIScreen mainScreen].scale;
        _arrowImage.transform = (_style == ALViewStylePullDown) ? CATransform3DIdentity : CATransform3DMakeRotation((M_PI/180) * 180.0f, 0, 0, 1);
        [self.layer addSublayer:_arrowImage];
        
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.frame = (_style == ALViewStylePullDown) ? CGRectMake(25, frame.size.height - 38, 20, 20) : CGRectMake(25, 18, 20, 20);
        _indicator.autoresizingMask = (_style == ALViewStylePullDown) ?UIViewAutoresizingFlexibleTopMargin : UIViewAutoresizingNone;
        [self addSubview:_indicator];
        
        _state = ALPullStateNormal;
        [self setStateNormal];
    }
    return self;
}

- (void)setState:(ALPullState)state
{
    switch (state) {
        case ALPullStateNormal:
        {
            if (_state == ALPullStatePulling) {
                [CATransaction begin];
                [CATransaction setAnimationDuration:kAnimationDuration];
                _arrowImage.hidden = NO;
                _arrowImage.transform = (_style == ALViewStylePullDown) ? CATransform3DIdentity : CATransform3DMakeRotation((M_PI/180) * 180.0f, 0, 0, 1);
                [CATransaction commit];
            }
            _statusLabel.text = (_style == ALViewStylePullDown) ? NSLocalizedString(@"pull to refresh", @"下拉可以刷新") : NSLocalizedString(@"pulling to release", @"上拉可以显示更多");
            [self setLastUpdatedLabelText];
            [_indicator stopAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowImage.hidden = NO;
            _arrowImage.transform = (_style == ALViewStylePullDown) ? CATransform3DIdentity : CATransform3DMakeRotation((M_PI/180) * 180.f, 0, 0, 1);
            [CATransaction commit];
            break;
        }
        case ALPullStateLoading:
        {
            _statusLabel.text = NSLocalizedString(@"alStateLoading", @"");
            [_indicator startAnimating];
            //如果直接hidden，效果不好，会有影像残留，这样子会瞬间消失。
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowImage.hidden = YES;
            [CATransaction commit];
            break;
        }
        case ALPullStatePulling:
        {
            _statusLabel.text = NSLocalizedString(@"release to refresh", @"");
            [_indicator stopAnimating];
            [CATransaction begin];
            [CATransaction setAnimationDuration:kAnimationDuration];
            _arrowImage.transform = (_style == ALViewStylePullDown) ? CATransform3DMakeRotation((M_PI/180) * 180.0f, 0, 0, 1) : CATransform3DIdentity;
            [CATransaction commit];
           break;
        }
        default:
            break;
    }
    
    _state = state;
}

- (void)setLastUpdatedLabelText
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastTime = [defaults valueForKey:(_style == ALViewStylePullDown) ? kALLastPullDownKey : kALLastPullUpKey];
    if (lastTime) {
        NSString *nowTime = [[self commonDateFormatter] stringFromDate:[NSDate date]];
        if ([[lastTime substringToIndex:10] isEqualToString:[nowTime substringToIndex:10]]) {
            _lastUpdatedLabel.text = [NSString stringWithFormat:@"上次刷新:今天 %@", [lastTime substringFromIndex:10]];
        } else {
            _lastUpdatedLabel.text = [NSString stringWithFormat:@"上次刷新:%@", lastTime];
        }
    }
    else {
        _lastUpdatedLabel.text = @"";
    }
}

- (void)setStateNormal
{
    [self setState:ALPullStateNormal];
}

- (void)setStatePulling
{
    [self setState:ALPullStatePulling];
}

- (void)setStateLoading
{
    [self setState:ALPullStateLoading];
}

- (void)ALPullToRefreshViewDidFinishLoading:(UIScrollView *)scrollView
{
    if (_style == ALViewStylePullDown) {
        self.frame = CGRectMake(0, -CGRectGetHeight(scrollView.frame), CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame));
        _arrowImage.frame = (_style == ALViewStylePullDown) ? CGRectMake(25.0f, scrollView.frame.size.height - 65.0f, 30.0f, 55.0f) : CGRectMake(25.0f, 5, 30.0f, 55.0f);
        [UIView animateWithDuration:0.3 animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } completion:^(BOOL finished) {
            [self setStateNormal];
        }];
    } else if (_style == ALViewStylePullUp) {
        self.frame = CGRectMake(self.frame.origin.x, scrollView.contentSize.height, CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame));
        [UIView animateWithDuration:0.3 animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } completion:^(BOOL finished) {
            [self setStateNormal];
        }];
    }
}

- (void)ALPullToRefreshViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.isDragging) {
        BOOL isLoading = NO;
        if ([_delegate respondsToSelector:@selector(ALPullToRefreshViewIsLoading:)]) {
            isLoading = [_delegate ALPullToRefreshViewIsLoading:self];
        }
        if (!isLoading) {
            if ((_style == ALViewStylePullDown && scrollView.contentOffset.y <= - kALPullSizeToRefresh) || (_style == ALViewStylePullUp && scrollView.contentOffset.y >= (kALPullSizeToRefresh + scrollView.contentSize.height - scrollView.frame.size.height))) {
                    [self setStatePulling];
            } else {
                [self setStateNormal];
            }
        }
    }
}

- (void)ALPullToRefreshViewDidEndDrag:(UIScrollView *)scrollView
{
    BOOL isLoading = NO;
    if ([_delegate respondsToSelector:@selector(ALPullToRefreshViewIsLoading:)]) {
        isLoading = [_delegate ALPullToRefreshViewIsLoading:self];
    }
    if ((_style == ALViewStylePullDown && scrollView.contentOffset.y < -kALPullSizeToRefresh && !isLoading) || (_style == ALViewStylePullUp && !isLoading && scrollView.contentOffset.y >= (kALPullSizeToRefresh + scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds)))) {
        [self setStateLoading];
        if ([_delegate respondsToSelector:@selector(ALPullToRefreshViewDidRefresh:)]) {
            [_delegate ALPullToRefreshViewDidRefresh:self];
        }
        [self setLastLoadingTime];
        [UIView animateWithDuration:0.3 animations:^{
            //以下两个变量是为了防止内容过少时候，contentSize小于scrollView的大小的情况。
            CGFloat spaceToBottom = scrollView.bounds.size.height - scrollView.contentSize.height;
            BOOL flag = spaceToBottom > 0 ? YES : NO;
            scrollView.contentInset = (_style == ALViewStylePullDown) ? UIEdgeInsetsMake(kALPullSizeToRefresh, 0, 0, 0) : UIEdgeInsetsMake(0, 0, flag ? (kALPullSizeToRefresh + spaceToBottom) : kALPullSizeToRefresh, 0);
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (NSDateFormatter *)commonDateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    return formatter;
}

- (void)setLastLoadingTime
{
    NSString *loadingDate = [[self commonDateFormatter] stringFromDate:[NSDate date]];
    loadingDate = [NSString stringWithFormat:@"%@", loadingDate];
    [[NSUserDefaults standardUserDefaults] setObject:loadingDate forKey:(_style == ALViewStylePullDown) ? kALLastPullDownKey : kALLastPullUpKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (_style == ALViewStylePullUp && [newSuperview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)newSuperview;
        if (CGRectGetHeight(scrollView.bounds) > scrollView.contentSize.height) {
            self.frame = CGRectMake(0, CGRectGetHeight(scrollView.bounds), CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame));
        }
    }
}

- (void)layoutSubviews
{
    if (_style == ALViewStylePullUp && [self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (CGRectGetHeight(scrollView.bounds) > scrollView.contentSize.height) {
            self.frame = CGRectMake(0, CGRectGetHeight(scrollView.bounds), CGRectGetWidth(scrollView.frame), CGRectGetHeight(scrollView.frame));
        }
    }
}

@end
