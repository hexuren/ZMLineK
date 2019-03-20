//
//  Y_StockChartSegmentView.m
//  BTC-Kline
//
//  Created by yate1996 on 16/5/2.
//  Copyright © 2016年 yate1996. All rights reserved.
//

#import "Y_StockChartSegmentView.h"
#import "Masonry.h"
#import "UIColor+Y_StockChart.h"
#import "UIButton+ImageTitleSpacing.h"


static NSInteger const Y_StockChartSegmentStartTag = 2000;

//static CGFloat const Y_StockChartSegmentIndicatorViewHeight = 2;
//
//static CGFloat const Y_StockChartSegmentIndicatorViewWidth = 40;

@interface Y_StockChartSegmentView()

@property (nonatomic, strong) UIButton *selectedBtn;

@end

@implementation Y_StockChartSegmentView

- (instancetype)initWithItems:(NSArray *)items
{
    self = [super initWithFrame:CGRectZero];
    if(self)
    {
        self.items = items;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.clipsToBounds = YES;
        self.backgroundColor = UIColorFromHex(0xf0f0f0);
    }
    return self;
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    if(items.count == 0 || !items)
    {
        return;
    }
    NSInteger index = 0;
    NSInteger count = items.count;
    UIButton *preBtn = nil;
    
    for (NSString *title in items)
    {
        UIButton *btn = [self private_createButtonWithTitle:title tag:Y_StockChartSegmentStartTag+index];
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor colorWithRed:52.f/255.f green:56.f/255.f blue:67/255.f alpha:1];
        [self addSubview:btn];
        [self addSubview:view];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.width.equalTo(self).multipliedBy(1.0f/count);
            make.height.equalTo(self);
            if(preBtn)
            {
                make.left.equalTo(preBtn.mas_right).offset(0.5);
            } else {
                make.left.equalTo(self);
            }
        }];
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(btn);
            make.top.equalTo(btn.mas_bottom);
            make.height.equalTo(@0.5);
        }];
        preBtn = btn;
        index++;
    }
}

#pragma mark 设置底部按钮index
- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    UIButton *btn = (UIButton *)[self viewWithTag:Y_StockChartSegmentStartTag + selectedIndex];
    NSAssert(btn, @"按钮初始化出错");
    [self event_segmentButtonClicked:btn];
}

- (void)setSelectedBtn:(UIButton *)selectedBtn
{
    if(_selectedBtn == selectedBtn)
    {
        if(selectedBtn.tag != Y_StockChartSegmentStartTag)
        {
            return;
        } else {
            
        }
    }
    [_selectedBtn setSelected:NO];
    [_selectedBtn.titleLabel setFont:PFRFontWithSize(13)];
    [selectedBtn setSelected:YES];
    [selectedBtn.titleLabel setFont:PFMFontWithSize(13)];
    _selectedBtn = selectedBtn;
    _selectedIndex = selectedBtn.tag - Y_StockChartSegmentStartTag;
    [self layoutIfNeeded];
}

#pragma mark - 私有方法
#pragma mark 创建底部按钮
- (UIButton *)private_createButtonWithTitle:(NSString *)title tag:(NSInteger)tag
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:gTextNoChangeSub forState:UIControlStateNormal];
    [btn setTitleColor:UIColorFromHex(0x353442) forState:UIControlStateSelected];
    btn.titleLabel.font = PFRFontWithSize(13);
    btn.tag = tag;
    [btn addTarget:self action:@selector(event_segmentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:title forState:UIControlStateNormal];
    if (!self.isFullScreen) {
        if (tag == 2004 || tag == 2005) {
            [btn setImage:CF_IMAGE(@"Stroke-ic") forState:UIControlStateNormal];
            [btn layoutButtonWithEdgeInsetsStyle:ZMButtonEdgeInsetsStyleRight imageTitleSpace:5.0];
        }
        else if (tag == 2006){
            [btn setImage:CF_IMAGE(@"transaction-fullscreen-ic") forState:UIControlStateNormal];
        }
    }
    else{
        if (tag == 2009) {
            [btn setImage:CF_IMAGE(@"Stroke-ic") forState:UIControlStateNormal];
            [btn layoutButtonWithEdgeInsetsStyle:ZMButtonEdgeInsetsStyleRight imageTitleSpace:5.0];
        }
    }
    return btn;
}

#pragma mark 底部按钮点击事件
- (void)event_segmentButtonClicked:(UIButton *)btn {
    if (btn.tag == 2005 || btn.tag == 2006) {
        if (self.isFullScreen) {
            self.selectedBtn = btn;
        }else{
            
        }
    }
    else{
       self.selectedBtn = btn;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(y_StockChartSegmentView:clickSegmentButtonIndex:)]) {
        [self.delegate y_StockChartSegmentView:self clickSegmentButtonIndex: btn.tag-Y_StockChartSegmentStartTag];
    }
}

@end
