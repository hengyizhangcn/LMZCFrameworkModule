//
//  CSCEmptyBaseView.h
//  CSCEmptyViewDemo
//
//  Created by liyang on 2017/5/5.
//  Copyright © 2017年 liyang. All rights reserved.
//

#import "CSCEmptyBaseView.h"

@interface CSCEmptyBaseView ()

@end

@implementation CSCEmptyBaseView

#pragma mark - ------------------ Life Cycle ------------------
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
        [self prepare];
    }
    return self;
}

- (void)initialize{
}

- (void)prepare{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth |  UIViewAutoresizingFlexibleHeight;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIView *view = self.superview;
    //不是UIView，不做操作
    if (view && [view isKindOfClass:[UIView class]]){
        self.ly_width = view.ly_width;
        self.ly_height = view.ly_height;
    }
    
    [self setupSubviews];
}

- (void)setupSubviews{
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    //不是UIView，不做操作
    if (newSuperview && ![newSuperview isKindOfClass:[UIView class]]) return;
    
    if (newSuperview) {
        self.ly_width = newSuperview.ly_width;
        self.ly_height = newSuperview.ly_height;
    }
}

#pragma mark - ------------------ 实例化 ------------------
+ (instancetype)emptyActionViewWithImage:(UIImage *)image
                                titleStr:(NSString *)titleStr
                               detailStr:(NSString *)detailStr
                             btnTitleStr:(NSString *)btnTitleStr
                                  target:(id)target
                                  action:(SEL)action{
    
    CSCEmptyBaseView *emptyView = [[self alloc] init];
    [emptyView creatEmptyViewWithImage:image imageStr:nil titleStr:titleStr detailStr:detailStr btnTitleStr:btnTitleStr target:target action:action btnClickBlock:nil];
    
    return emptyView;
}

+ (instancetype)emptyActionViewWithImage:(UIImage *)image
                                titleStr:(NSString *)titleStr
                               detailStr:(NSString *)detailStr
                             btnTitleStr:(NSString *)btnTitleStr
                           btnClickBlock:(CSCActionTapBlock)btnClickBlock{
    
    CSCEmptyBaseView *emptyView = [[self alloc] init];
    [emptyView creatEmptyViewWithImage:image imageStr:nil titleStr:titleStr detailStr:detailStr btnTitleStr:btnTitleStr target:nil action:nil btnClickBlock:btnClickBlock];
    
    return emptyView;
}

+ (instancetype)emptyActionViewWithImageStr:(NSString *)imageStr
                                   titleStr:(NSString *)titleStr
                                  detailStr:(NSString *)detailStr
                                btnTitleStr:(NSString *)btnTitleStr
                                     target:(id)target
                                     action:(SEL)action{
    
    CSCEmptyBaseView *emptyView = [[self alloc] init];
    [emptyView creatEmptyViewWithImage:nil imageStr:imageStr titleStr:titleStr detailStr:detailStr btnTitleStr:btnTitleStr target:target action:action btnClickBlock:nil];
    
    return emptyView;
}

+ (instancetype)emptyActionViewWithImageStr:(NSString *)imageStr
                                   titleStr:(NSString *)titleStr
                                  detailStr:(NSString *)detailStr
                                btnTitleStr:(NSString *)btnTitleStr
                              btnClickBlock:(CSCActionTapBlock)btnClickBlock{
   
    CSCEmptyBaseView *emptyView = [[self alloc] init];
    [emptyView creatEmptyViewWithImage:nil imageStr:imageStr titleStr:titleStr detailStr:detailStr btnTitleStr:btnTitleStr target:nil action:nil btnClickBlock:btnClickBlock];
    
    return emptyView;
}

+ (instancetype)emptyViewWithImage:(UIImage *)image
                          titleStr:(NSString *)titleStr
                         detailStr:(NSString *)detailStr{
    
    CSCEmptyBaseView *emptyView = [[self alloc] init];
    [emptyView creatEmptyViewWithImage:image imageStr:nil titleStr:titleStr detailStr:detailStr btnTitleStr:nil target:nil action:nil btnClickBlock:nil];
    
    return emptyView;
}

+ (instancetype)emptyViewWithImageStr:(NSString *)imageStr
                             titleStr:(NSString *)titleStr
                            detailStr:(NSString *)detailStr{
    
    CSCEmptyBaseView *emptyView = [[self alloc] init];
    [emptyView creatEmptyViewWithImage:nil imageStr:imageStr titleStr:titleStr detailStr:detailStr btnTitleStr:nil target:nil action:nil btnClickBlock:nil];
    
    return emptyView;
}

+ (instancetype)emptyViewWithCustomView:(UIView *)customView{
    
    CSCEmptyBaseView *emptyView = [[self alloc] init];
    [emptyView creatEmptyViewWithCustomView:customView];
    
    return emptyView;
}

- (void)creatEmptyViewWithImage:(UIImage *)image imageStr:(NSString *)imageStr titleStr:(NSString *)titleStr detailStr:(NSString *)detailStr btnTitleStr:(NSString *)btnTitleStr target:(id)target action:(SEL)action btnClickBlock:(CSCActionTapBlock)btnClickBlock{
    
    _image = image;
    _imageStr = imageStr;
    _titleStr = titleStr;
    _detailStr = detailStr;
    _btnTitleStr = btnTitleStr;
    _actionBtnTarget = target;
    _actionBtnAction = action;
    _btnClickBlock = btnClickBlock;
    
    //内容物背景视图
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_contentView];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEmptyView:)];
    [self addGestureRecognizer:tap];
}

- (void)creatEmptyViewWithCustomView:(UIView *)customView{
    
    //内容物背景视图
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_contentView];
    }
    
    if (!_customView) {
        [_contentView addSubview:customView];
    }
    _customView = customView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEmptyView:)];
    [self addGestureRecognizer:tap];
}

#pragma mark - ------------------ Event Method ------------------
- (void)tapEmptyView:(UITapGestureRecognizer *)tap{
    if (_tapEmptyViewBlock) {
        _tapEmptyViewBlock();
    }
}

#pragma mark - ------------------ Setter ------------------

- (void)setImage:(UIImage *)image{
    _image = image;
    [self setNeedsLayout];
}
- (void)setImageStr:(NSString *)imageStr{
    _imageStr = imageStr;
    [self setNeedsLayout];
}
- (void)setTitleStr:(NSString *)titleStr{
    _titleStr = titleStr;
    [self setNeedsLayout];
}
- (void)setDetailStr:(NSString *)detailStr{
    _detailStr = detailStr;
    [self setNeedsLayout];
}
- (void)setBtnTitleStr:(NSString *)btnTitleStr{
    _btnTitleStr = btnTitleStr;
    [self setNeedsLayout];
}

@end
