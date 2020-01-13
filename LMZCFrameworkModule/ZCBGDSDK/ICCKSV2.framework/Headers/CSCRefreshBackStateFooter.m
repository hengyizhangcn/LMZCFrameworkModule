//
//  CSCRefreshBackStateFooter.m
//  CSCRefreshExample
//
//  Created by CSC Lee on 15/6/13.
//  Copyright © 2015年 小码哥. All rights reserved.
//

#import "CSCRefreshBackStateFooter.h"

@interface CSCRefreshBackStateFooter()
{
    /** 显示刷新状态的label */
    __unsafe_unretained UILabel *_stateLabel;
}
/** 所有状态对应的文字 */
@property (strong, nonatomic) NSMutableDictionary *stateTitles;
@end

@implementation CSCRefreshBackStateFooter
#pragma mark - 懒加载
- (NSMutableDictionary *)stateTitles
{
    if (!_stateTitles) {
        self.stateTitles = [NSMutableDictionary dictionary];
    }
    return _stateTitles;
}

- (UILabel *)stateLabel
{
    if (!_stateLabel) {
        [self addSubview:_stateLabel = [UILabel mj_label]];
    }
    return _stateLabel;
}

#pragma mark - 公共方法
- (void)setTitle:(NSString *)title forState:(CSCRefreshState)state
{
    if (title == nil) return;
    self.stateTitles[@(state)] = title;
    self.stateLabel.text = self.stateTitles[@(self.state)];
}

- (NSString *)titleForState:(CSCRefreshState)state {
  return self.stateTitles[@(state)];
}

#pragma mark - 重写父类的方法
- (void)prepare
{
    [super prepare];
    
    // 初始化间距
    self.labelLeftInset = CSCRefreshLabelLeftInset;
    
    // 初始化文字
    [self setTitle:[NSBundle mj_localizedStringForKey:CSCRefreshBackFooterIdleText] forState:CSCRefreshStateIdle];
    [self setTitle:[NSBundle mj_localizedStringForKey:CSCRefreshBackFooterPullingText] forState:CSCRefreshStatePulling];
    [self setTitle:[NSBundle mj_localizedStringForKey:CSCRefreshBackFooterRefreshingText] forState:CSCRefreshStateRefreshing];
    [self setTitle:[NSBundle mj_localizedStringForKey:CSCRefreshBackFooterNoMoreDataText] forState:CSCRefreshStateNoMoreData];
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    if (self.stateLabel.constraints.count) return;
    
    // 状态标签
    self.stateLabel.frame = self.bounds;
}

- (void)setState:(CSCRefreshState)state
{
    CSCRefreshCheckState
    
    // 设置状态文字
    self.stateLabel.text = self.stateTitles[@(state)];
}
@end
