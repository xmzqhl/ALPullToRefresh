//
//  ALPullToRefreshView.h
//  PullToRefreshView
//
//  Created by Arien Lau on 14-3-10.
//  Copyright (c) 2014年 Arien Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ALPullToRefreshViewDelegate;

@interface ALPullToRefreshView : UIView

@property (nonatomic, assign) id<ALPullToRefreshViewDelegate>delegate;

/**
 @brief 初始化视图的唯一方式
 @param frame 指定试图的位置，一般该试图的父视图为UIScrollView,大小和父视图一直，y为负数。
 @param imageName 指定箭头所用图片的名称
 @param color 指定文字的颜色
 */
- (id)initWithFrame:(CGRect)frame imageName:(NSString *)imageName textColor:(UIColor *)color;
/**
 @brief 在加载完成的时候，主动调用该方法。
 */
- (void)ALPullToRefreshViewDidFinishLoading:(UIScrollView *)scrollView;

/**
 @brief 实现UIScrollView的scrollViewDidScroll:方法，来主动调用该函数
 */
- (void)ALPullToRefreshViewDidScroll:(UIScrollView *)scrollView;

/**
 @brief 实现UIScrollView的scrollViewDidEndDragging: willDecelerate:方法来调用此方法，通知试图用户手指已经离开屏幕
 */
- (void)ALPullToRefreshViewDidEndDrag:(UIScrollView *)scrollView;
@end


@protocol ALPullToRefreshViewDelegate <NSObject>
@required
/**
 @brief 询问当前是否正在加载
 */
- (BOOL)ALPullToRefreshViewIsLoading:(ALPullToRefreshView *)view;

/**
 @brief 页面进入正在加载的状态，应在此方法执行网络请求、后台加载大数据等操作,加载完毕后，应调用ALPullToRefreshViewDidFinishLoading:方法来通知试图已经加载完毕。
 */
- (void)ALPullToRefreshViewDidRefresh:(ALPullToRefreshView *)view;
@end
