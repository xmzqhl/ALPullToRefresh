//
//  ALPullToRefreshView.m
//  PullToRefreshView
//
//  Created by Arien Lau on 14-3-10.
//  Copyright (c) 2014年 Arien Lau. All rights reserved.
//

#import "ALPullToRefreshView.h"

#define RGB_Color(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define LastPullDownKey @"ALLastPullDownTime"
#define AnimationDuration 0.18f
#define LastPullingUpKey @"ALLastPullingUpTime"

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
        if(_style ==  ALPullViewStylePullDown) {
            self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
        } else if (_style == ALPullViewStylePullUp) {
        }
        _statusLabel = [[UILabel alloc] init];
        if (_style == ALPullViewStylePullUp) {
           _statusLabel.frame = CGRectMake(0, 10, frame.size.width, 20);
        } else if (_style == ALPullViewStylePullDown) {
            _statusLabel.frame = CGRectMake(0, frame.size.height - 50, frame.size.width, 20);
        }
        _statusLabel.textColor = (color ? color : [UIColor blackColor]);
        _statusLabel.font = [UIFont boldSystemFontOfSize:13];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_statusLabel];
        
        _lastUpdatedLabel = [[UILabel alloc] init];
        _lastUpdatedLabel.backgroundColor = [UIColor clearColor];
        _lastUpdatedLabel.frame = (_style == ALPullViewStylePullDown) ? CGRectMake(0, frame.size.height - 30, frame.size.width, 20) : CGRectMake(0, 30, frame.size.width, 20);
        _lastUpdatedLabel.textColor = (color ? color : [UIColor blackColor]);
        _lastUpdatedLabel.textAlignment = NSTextAlignmentCenter;
        _lastUpdatedLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_lastUpdatedLabel];
        
        _arrowImage = [CALayer layer];
        _arrowImage.frame = (_style == ALPullViewStylePullDown) ? CGRectMake(25.0f, frame.size.height - 65.0f, 30.0f, 55.0f) : CGRectMake(25.0f, 5, 30.0f, 55.0f);
        _arrowImage.contentsGravity = kCAGravityResizeAspect;
        _arrowImage.contents = (__bridge id)(([UIImage imageNamed:imageName].CGImage));
        _arrowImage.contentsScale = [UIScreen mainScreen].scale;
        _arrowImage.transform = (_style == ALPullViewStylePullDown) ? CATransform3DIdentity : CATransform3DMakeRotation((M_PI/180) * 180.0f, 0, 0, 1);
        [self.layer addSublayer:_arrowImage];
        
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.frame = (_style == ALPullViewStylePullDown) ? CGRectMake(25, frame.size.height - 38, 20, 20) : CGRectMake(25, 18, 20, 20);
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
                [CATransaction setAnimationDuration:AnimationDuration];
                _arrowImage.hidden = NO;
                _arrowImage.transform = (_style == ALPullViewStylePullDown) ? CATransform3DIdentity : CATransform3DMakeRotation((M_PI/180) * 180.0f, 0, 0, 1);
                [CATransaction commit];
            }
            _statusLabel.text = (_style == ALPullViewStylePullDown) ? NSLocalizedString(@"pull to refresh", @"下拉可以刷新") : NSLocalizedString(@"pulling to release", @"上拉可以显示更多");
            [self setLastUpdatedLabelText];
            [_indicator stopAnimating];
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            _arrowImage.hidden = NO;
            _arrowImage.transform = (_style == ALPullViewStylePullDown) ? CATransform3DIdentity : CATransform3DMakeRotation((M_PI/180) * 180.f, 0, 0, 1);
            [CATransaction commit];
            break;
        }
        case ALPullStateLoading:
        {
            _statusLabel.text = NSLocalizedString(@"alStateLoading", @"");
            [_indicator startAnimating];
            //如果直接hidden，效果不好，会有影像残留，这样子是瞬间消失。
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
            [CATransaction setAnimationDuration:AnimationDuration];
            _arrowImage.transform = (_style == ALPullViewStylePullDown) ? CATransform3DMakeRotation((M_PI/180) * 180.0f, 0, 0, 1) : CATransform3DIdentity;
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
    NSString *lastTime = (_style == ALPullViewStylePullDown) ? [defaults valueForKey:LastPullDownKey] : [defaults valueForKey:LastPullingUpKey];
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
    if (_style == ALPullViewStylePullDown) {
        [UIView animateWithDuration:0.3 animations:^{
            scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } completion:^(BOOL finished) {
            [self setStateNormal];
        }];
    } else if (_style == ALPullViewStylePullUp) {
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
            if ((_style == ALPullViewStylePullDown && scrollView.contentOffset.y <= -65.0) || (_style == ALPullViewStylePullUp && scrollView.contentOffset.y >= (65.0 + scrollView.contentSize.height - scrollView.frame.size.height))) {
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
    if ((_style == ALPullViewStylePullDown && scrollView.contentOffset.y < -65.0 && !isLoading) || (_style == ALPullViewStylePullUp && !isLoading && scrollView.contentOffset.y >= (65.0 + scrollView.contentSize.height - scrollView.frame.size.height) && !isLoading)) {
        [self setStateLoading];
        if ([_delegate respondsToSelector:@selector(ALPullToRefreshViewDidRefresh:)]) {
            [_delegate ALPullToRefreshViewDidRefresh:self];
        }
        [self setLastLoadingTime];
        [UIView animateWithDuration:0.3 animations:^{
            scrollView.contentInset = (_style == ALPullViewStylePullDown) ? UIEdgeInsetsMake(65, 0, 0, 0) : UIEdgeInsetsMake(0, 0, 65, 0);
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
    [[NSUserDefaults standardUserDefaults] setObject:loadingDate forKey:(_style == ALPullViewStylePullDown) ? LastPullDownKey : LastPullingUpKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
