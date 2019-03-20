//
//  Y-StockChartView.m
//  BTC-Kline
//
//  Created by yate1996 on 16/4/30.
//  Copyright © 2016年 yate1996. All rights reserved.
//

#import "Y_StockChartView.h"
#import "Y_KLineView.h"
#import "Masonry.h"
#import "Y_StockChartSegmentView.h"
#import "Y_StockChartGlobalVariable.h"


static NSInteger const Y_StockChartSegmentIndicatorIndex = 3000;

@interface Y_StockChartView() <Y_StockChartSegmentViewDelegate>

/**
 *  K线图View
 */
@property (nonatomic, strong) Y_KLineView *kLineView;

/**
 *  底部主选择View
 */
@property (nonatomic, strong) Y_StockChartSegmentView *segmentView;

@property (nonatomic, strong) UIView *moreSegmentView;
@property (nonatomic, strong) UIButton *moreSelectedBtn;
@property (nonatomic, strong) UIView *indicatorSegmentView;
@property (nonatomic, strong) UIButton *indicatorSelectedBtn;
@property (nonatomic, strong) UIButton *indicatorSegmentSelectedBtnOne;
@property (nonatomic, strong) UIButton *indicatorSegmentSelectedBtnTwo;
//kline时间类型0~9  time  1 15 4h 5 30 60 1d 1w 1m
@property (nonatomic, assign) NSInteger klineTime;
//当前是否显示
@property (nonatomic, assign) BOOL isShowMoreSegmentView;
@property (nonatomic, assign) BOOL isShowindicatorSegmentView;


/**
 *  图表类型
 */
@property(nonatomic,assign) Y_StockChartCenterViewType currentCenterViewType;

/**
 *  当前索引
 */
@property(nonatomic,assign,readwrite) NSInteger currentIndex;
@end


@implementation Y_StockChartView

- (Y_KLineView *)kLineView
{
    if(!_kLineView)
    {
        _kLineView = [Y_KLineView new];
        [_kLineView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_kLineView];
        self.targetLineStatus = Y_StockChartTargetLineStatusAccessoryClose;
        _kLineView.isFullScreen = self.isFullScreen;
        if (_isFullScreen) {
            [_kLineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.right.left.equalTo(self);
                make.bottom.equalTo(@-32);
            }];
        }else{
            [_kLineView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.right.left.equalTo(self);
                make.top.equalTo(self.segmentView.mas_bottom);
            }];
        }
        
    }
    return _kLineView;
}

- (Y_StockChartSegmentView *)segmentView
{
    if(!_segmentView)
    {
        _segmentView = [Y_StockChartSegmentView new];
        _segmentView.isFullScreen = self.isFullScreen;
        _segmentView.delegate = self;
        [self addSubview:_segmentView];
        if (_isFullScreen) {
            [_segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.left.bottom.equalTo(self);
                make.top.equalTo(self.kLineView.mas_bottom);
                make.height.equalTo(@32);
            }];
        }
        else{
            [_segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.left.top.equalTo(self);
                make.height.equalTo(@32);
            }];
        }
    }
    return _segmentView;
}

- (UIView *)moreSegmentView
{
    if(!_moreSegmentView)
    {
        _moreSegmentView = [UIView new];
        _moreSegmentView.backgroundColor = UIColorFromHexWithAlpha(0x353442, 0.7);
        
        NSArray *titleArr = @[@"1分",@"5分",@"30分",@"1小时",@"1周",@"1月"];
        DefineWeakSelf;
        __block UIButton *preBtn;
        [titleArr enumerateObjectsUsingBlock:^(NSString*  _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:gMainColor forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            btn.tag = Y_StockChartSegmentIndicatorIndex + 100 + idx;
            [btn addTarget:self action:@selector(event_segmentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:title forState:UIControlStateNormal];
            [weakSelf.moreSegmentView addSubview:btn];
            
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(weakSelf.moreSegmentView).multipliedBy(1.0f/6);
                make.height.equalTo(weakSelf.moreSegmentView);
                make.top.equalTo(weakSelf.moreSegmentView);
                if(preBtn)
                {
                    make.left.equalTo(preBtn.mas_right);
                } else {
                    make.left.equalTo(weakSelf.moreSegmentView);
                }
            }];
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor clearColor];
            [weakSelf.moreSegmentView addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(btn);
                make.top.equalTo(btn.mas_bottom);
                make.height.equalTo(@0.5);
            }];
            preBtn = btn;
        }];
        [self addSubview:_moreSegmentView];
        _moreSegmentView.hidden = YES;
        self.isShowMoreSegmentView = NO;
        if (_isFullScreen) {
            [_moreSegmentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.left.equalTo(self);
                make.bottom.equalTo(self).offset(-32);
                make.height.equalTo(@42);
            }];
        }
        else{
            [_moreSegmentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.left.equalTo(self);
                make.top.equalTo(self).offset(32);
                make.height.equalTo(@42);
            }];
        }
       
    }
    return _moreSegmentView;
}


- (UIView *)indicatorSegmentView
{
    if(!_indicatorSegmentView)
    {
        _indicatorSegmentView = [UIView new];
        NSArray *titleArr = @[@"主图",@"MA",@"EMA",@"BOLL",@"隐藏",@"副图",@"MACD",@"KDJ",@"隐藏"];
        __block UIButton *preBtn;
        DefineWeakSelf;
        [titleArr enumerateObjectsUsingBlock:^(NSString*  _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:gMainColor forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:13];
            if (idx == 0 || idx == 5) {
                btn.tag = Y_StockChartSegmentIndicatorIndex;
            }
            else{
                btn.tag = Y_StockChartSegmentIndicatorIndex + idx;
            }
            [btn addTarget:self action:@selector(event_segmentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTitle:title forState:UIControlStateNormal];
            [weakSelf.indicatorSegmentView addSubview:btn];
            if (idx < 5){
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(weakSelf.indicatorSegmentView).multipliedBy(1.0f/6);
                    make.height.equalTo(@36);
                    make.top.equalTo(weakSelf.indicatorSegmentView);
                    if (idx == 4) {
                        make.right.equalTo(weakSelf.indicatorSegmentView);
                    }
                    else{
                        if(preBtn)
                        {
                            make.left.equalTo(preBtn.mas_right);
                        } else {
                            make.left.equalTo(weakSelf.indicatorSegmentView);
                        }
                    }
                    
                }];
            }
            else{
                [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(weakSelf.indicatorSegmentView).multipliedBy(1.0f/6);
                    make.height.equalTo(@36);
                    make.top.equalTo(weakSelf.indicatorSegmentView).offset(36);
                    if (idx == 8) {
                        make.right.equalTo(weakSelf.indicatorSegmentView);
                    }
                    else{
                        if(preBtn && (idx != 5))
                        {
                            make.left.equalTo(preBtn.mas_right);
                        } else {
                            make.left.equalTo(weakSelf.indicatorSegmentView);
                        }
                    }
                    
                }];
            }
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor clearColor];
            [weakSelf.indicatorSegmentView addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(btn);
                make.top.equalTo(btn.mas_bottom);
                make.height.equalTo(@0.5);
            }];
            preBtn = btn;
        }];
//        UIButton *firstBtn = _indicatorSegmentView.subviews[2];
//        [firstBtn setSelected:YES];
//        _indicatorSegmentSelectedBtnOne = firstBtn;
        
//        UIButton *firstBtn2 = _indicatorSegmentView.subviews[16];
////        [firstBtn2 setSelected:YES];
//        _indicatorSegmentSelectedBtnTwo = firstBtn2;
        _indicatorSegmentView.backgroundColor = UIColorFromHexWithAlpha(0x353442, 0.7);
        [self addSubview:_indicatorSegmentView];
        _indicatorSegmentView.hidden = YES;
        if (_isFullScreen) {
            [_indicatorSegmentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.left.equalTo(self);
                make.bottom.equalTo(self).offset(-32);
                make.height.equalTo(@72);
            }];
        }
        else{
            [_indicatorSegmentView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.left.equalTo(self);
                make.top.equalTo(self).offset(32);
                make.height.equalTo(@72);
            }];
        }
    }
    return _indicatorSegmentView;
}

- (void)setItemModels:(NSArray *)itemModels {
    _itemModels = itemModels;
    if(itemModels){
        NSMutableArray *items = [NSMutableArray array];
        for(Y_StockChartViewItemModel *item in itemModels){
            [items addObject:item.title];
        }
        self.segmentView.items = items;
        Y_StockChartViewItemModel *firstModel = itemModels.firstObject;
        self.currentCenterViewType = firstModel.centerViewType;
    }
    if(self.dataSource){
        if (!self.isFullScreen) {
            self.segmentView.selectedIndex = 2;
            self.klineTime = 2;
            self.kLineView.lineKTime = 2;
        }
        else{
            self.segmentView.selectedIndex = 6;
            self.klineTime = 6;
            self.kLineView.lineKTime = 6;
        }
    }
}

- (void)setDataSource:(id<Y_StockChartViewDataSource>)dataSource {
    _dataSource = dataSource;
    if(self.itemModels)
    {
        if (!self.isFullScreen) {
            self.segmentView.selectedIndex = 2;
            self.klineTime = 2;
            self.kLineView.lineKTime = 2;
        }
        else{
            self.segmentView.selectedIndex = 6;
            self.klineTime = 6;
            self.kLineView.lineKTime = 6;
        }
    }
}

- (void)reloadData {
    self.isShowMoreSegmentView = YES;
    self.segmentView.selectedIndex = self.segmentView.selectedIndex;
    if (self.isMoreTimeDataUpdate && self.currentIndex == 4 && self.isFullScreen != YES) {
        id stockData = [self.dataSource stockDatasWithIndex:self.klineTime];
        if(!stockData) {
            return;
        }
        self.kLineView.kLineModels = (NSArray *)stockData;
        self.kLineView.targetLineStatus = self.targetLineStatus;
        if (self.klineTime == 0) {
            self.kLineView.MainViewType = Y_StockChartcenterViewTypeTimeLine;
        }
        [self.kLineView reDraw];
    }
}

#pragma mark - 代理方法

- (void)y_StockChartSegmentView:(Y_StockChartSegmentView *)segmentView clickSegmentButtonIndex:(NSInteger)index {
    self.currentIndex = index;
    if (!self.isFullScreen) {
        if (index == 4 ){//更多
            if (self.isShowMoreSegmentView == YES) {
                self.moreSegmentView.hidden = YES;
                self.isShowMoreSegmentView = NO;
                if (self.klineTime >= 0 && self.klineTime <= 3) {
                    self.segmentView.selectedIndex =  self.klineTime;
                    [self.segmentView setNeedsLayout];
                    
                }
                return;
            }
            if (self.klineTime <= 3) {
                [_moreSelectedBtn setSelected:NO];
                self.moreSegmentView.hidden = NO;
                self.isShowMoreSegmentView = YES;
            }
            else{
                if (self.isShowMoreSegmentView) {
                    self.moreSegmentView.hidden = YES;
                    self.isShowMoreSegmentView = NO;
                }
                else{
                    if (self.klineTime <= 3) {
                        [_moreSelectedBtn setSelected:NO];
                    }
                    self.moreSegmentView.hidden = NO;
                    self.isShowMoreSegmentView = YES;
                }
            }
            self.indicatorSegmentView.hidden = YES;
            self.isShowindicatorSegmentView = NO;
            UIButton *btn = [self.segmentView viewWithTag:2005];
            btn.selected = NO;
            [btn.titleLabel setFont:PFMFontWithSize(13)];
            [self bringSubviewToFront:self.moreSegmentView];
        }
        else if (index == 5 ){//指标
//            if (self.indicatorSegmentView.hidden == NO) {
//                self.indicatorSegmentView.hidden = YES;
//                return;
//            }
            if (self.klineTime >= 0 && self.klineTime <= 3) {
                self.segmentView.selectedIndex =  self.klineTime;
                [self.segmentView setNeedsLayout];
                
            }
            if (self.isShowindicatorSegmentView == YES) {
                self.indicatorSegmentView.hidden = YES;
                self.isShowindicatorSegmentView = NO;
                UIButton *btn = [self.segmentView viewWithTag:2005];
                btn.selected = NO;
                [btn.titleLabel setFont:PFMFontWithSize(13)];
            }
            else{
                self.indicatorSegmentView.hidden = NO;
                self.isShowindicatorSegmentView = YES;
                UIButton *btn = [self.segmentView viewWithTag:2005];
                btn.selected = YES;
                [btn.titleLabel setFont:PFRFontWithSize(13)];
                self.moreSegmentView.hidden = YES;
                self.isShowMoreSegmentView = NO;
                [self bringSubviewToFront:self.indicatorSegmentView];
            }
            
        }
        else if (index == 6 ){//全屏
            self.indicatorSegmentView.hidden = YES;
            self.isShowindicatorSegmentView = NO;
            UIButton *btn = [self.segmentView viewWithTag:2005];
            btn.selected = NO;
            [btn.titleLabel setFont:PFMFontWithSize(13)];
            self.moreSegmentView.hidden = YES;
            self.isShowMoreSegmentView = NO;
            if (self.delegate && [self.delegate respondsToSelector:@selector(onClickFullScreenButtonWithTimeType:)]) {
                NSInteger timeType = index;
                if ((index >= (Y_StockChartSegmentIndicatorIndex + 100)) && (index <= (Y_StockChartSegmentIndicatorIndex + 104))){
                    timeType = index - Y_StockChartSegmentIndicatorIndex - 100 + 3;
                }
                [self.delegate onClickFullScreenButtonWithTimeType:timeType];
            }
        }
        else { //分时、1分、15分、4小时
             self.klineTime = index;
            self.kLineView.lineKTime = self.klineTime;
            [self reloadDataWithTimeIndex:index];
            UIButton *btn = [self.segmentView viewWithTag:2004];
            [btn setTitle:@"更多" forState:UIControlStateNormal];
            [btn.titleLabel setFont:PFMFontWithSize(13)];
        }
    }
    else{
        if (index == 10 ){//指标
            self.indicatorSegmentView.hidden = NO;
            self.isShowindicatorSegmentView = YES;
            UIButton *btn = [self.segmentView viewWithTag:2005];
            btn.selected = YES;
            [btn.titleLabel setFont:PFRFontWithSize(13)];
            self.moreSegmentView.hidden = YES;
            self.isShowMoreSegmentView = NO;
            [self bringSubviewToFront:self.indicatorSegmentView];
        }
        else { //分时、1分、15分、1小时
            [self reloadDataWithTimeIndex:index];
            self.klineTime = index;
            self.kLineView.lineKTime = self.klineTime;
            [_moreSelectedBtn setSelected:NO];
        }
    }
    
}

- (void) reloadDataWithTimeIndex:(NSInteger )timeIndex {
    self.indicatorSegmentView.hidden = YES;
//    self.isShowindicatorSegmentView = NO;
    if (!self.isFullScreen) {
        UIButton *btn = [self.segmentView viewWithTag:2005];
        btn.selected = NO;
        [btn.titleLabel setFont:PFMFontWithSize(13)];
    }
    self.moreSegmentView.hidden = YES;
    self.isShowMoreSegmentView = NO;
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(stockDatasWithIndex:)]) {
        id stockData = [self.dataSource stockDatasWithIndex:timeIndex];
        if(!stockData) {
            return;
        }
        Y_StockChartCenterViewType type = Y_StockChartcenterViewTypeKline;
        if (timeIndex < [self.itemModels count]) {
            Y_StockChartViewItemModel *itemModel = self.itemModels[timeIndex];
             type = itemModel.centerViewType;
        }
        if(type != self.currentCenterViewType) {
            //移除当前View，设置新的View
            self.currentCenterViewType = type;
            switch (type) {
                case Y_StockChartcenterViewTypeKline:
                {
                    self.kLineView.hidden = NO;
                    [self bringSubviewToFront:self.segmentView];
                }
                    break;
                default:
                    break;
            }
        }
        if(type == Y_StockChartcenterViewTypeOther)
        {
            if (self.klineTime >= 4 && self.klineTime<= 9) {
                self.kLineView.kLineModels = (NSArray *)stockData;
                self.kLineView.MainViewType = Y_StockChartcenterViewTypeKline;
                self.kLineView.targetLineStatus = self.targetLineStatus;
                [self.kLineView reDraw];
            }
            
        } else {
            
            self.kLineView.kLineModels = (NSArray *)stockData;
            self.kLineView.MainViewType = type;
            if (self.klineTime == 0) {
                self.kLineView.MainViewType = Y_StockChartcenterViewTypeTimeLine;
            }
            self.kLineView.targetLineStatus = self.targetLineStatus;
            [self.kLineView reDraw];
        }
        [self bringSubviewToFront:self.segmentView];
    }
}

- (void)setMoreSelectedBtn:(UIButton *)moreSelectedBtn {
    [_moreSelectedBtn setSelected:NO];
    [moreSelectedBtn setSelected:YES];
    UIButton *btn = [self.segmentView viewWithTag:2004];
    if (moreSelectedBtn.tag == 3100) {
        [btn setTitle:@"1分" forState:UIControlStateNormal];
    }
    else if (moreSelectedBtn.tag == 3101) {
        [btn setTitle:@"5分" forState:UIControlStateNormal];
    }
    else if (moreSelectedBtn.tag == 3102) {
        [btn setTitle:@"30分" forState:UIControlStateNormal];
    }
    else if (moreSelectedBtn.tag == 3103) {
        [btn setTitle:@"1小时" forState:UIControlStateNormal];
    }
    else if (moreSelectedBtn.tag == 3104) {
        [btn setTitle:@"1周" forState:UIControlStateNormal];
    }
    else if (moreSelectedBtn.tag == 3105) {
        [btn setTitle:@"1月" forState:UIControlStateNormal];
    }
    _moreSelectedBtn = moreSelectedBtn;
    self.moreSegmentView.hidden = YES;
    self.isShowMoreSegmentView = NO;
}

- (void)setIndicatorSegmentSelectedBtnOne:(UIButton *)indicatorSegmentSelectedBtnOne {
    [_indicatorSegmentSelectedBtnOne setSelected:NO];
    [indicatorSegmentSelectedBtnOne setSelected:YES];
    _indicatorSegmentSelectedBtnOne = indicatorSegmentSelectedBtnOne;
}

- (void)setIndicatorSegmentSelectedBtnTwo:(UIButton *)indicatorSegmentSelectedBtnTwo {
    [_indicatorSegmentSelectedBtnTwo setSelected:NO];
    [indicatorSegmentSelectedBtnTwo setSelected:YES];
    _indicatorSegmentSelectedBtnTwo = indicatorSegmentSelectedBtnTwo;
}


#pragma mark 更多、指标action
- (void)event_segmentButtonClicked:(UIButton *)btn {
    if ((btn.tag == (Y_StockChartSegmentIndicatorIndex + 1)) || (btn.tag == (Y_StockChartSegmentIndicatorIndex + 2)) || (btn.tag == (Y_StockChartSegmentIndicatorIndex + 3)) ) {
        self.indicatorSegmentSelectedBtnOne = btn;
    }
    else if ((btn.tag > (Y_StockChartSegmentIndicatorIndex + 5)) &&  (btn.tag < (Y_StockChartSegmentIndicatorIndex + 8))){
        self.indicatorSegmentSelectedBtnTwo = btn;
    }
    else if ((btn.tag >= Y_StockChartSegmentIndicatorIndex + 100) ){
        self.moreSelectedBtn = btn;
    }    
    NSInteger index = btn.tag;
    //3001 macd  3002 kdj  3005ma 3   3006ema  4 3007boll 3008  6
    
    //3000  3001ma      3002ema  3003bool       4
    //5     3006macd    3007kdj                 3008
    if (index == 3003) {
        [Y_StockChartGlobalVariable setisBOLLLine:Y_StockChartTargetLineStatusBOLL];
        self.kLineView.targetLineStatus = Y_StockChartTargetLineStatusBOLL;
        if (self.klineTime == 0) {
            self.kLineView.MainViewType = Y_StockChartcenterViewTypeTimeLine;
        }
        [self.kLineView reDraw];
        self.indicatorSegmentView.hidden = YES;
        self.isShowindicatorSegmentView = NO;
        UIButton *btn = [self.segmentView viewWithTag:2005];
        btn.selected = NO;
        [self bringSubviewToFront:self.segmentView];
    }
    else  if(index >= 3000 && index <= 3008) {
        NSInteger lineIndex = index - 3000 + 1;
        if (index == 3000 || index == 3005) {
            return;
        }
        else if (index == 3004){
            lineIndex = 106;
        }
        else if (index == 3008){
            lineIndex = 102;
        }
        else if (index >= 3001 && index < 3004){
            lineIndex = index - 2900 + 2;
        }
        else{
            lineIndex = index - 2900 - 6;
        }
        self.kLineView.targetLineStatus = lineIndex;
        self.targetLineStatus = lineIndex;
        if (index == 3004) {
            self.targetLineStatus = Y_StockChartTargetLineStatusCloseMA;
            self.indicatorSegmentSelectedBtnOne = nil;
        }
        if (index == 3008) {
            self.targetLineStatus = Y_StockChartTargetLineStatusAccessoryClose;
            self.indicatorSegmentSelectedBtnTwo = nil;
        }
        [Y_StockChartGlobalVariable setisEMALine:self.targetLineStatus];
        if(lineIndex == Y_StockChartTargetLineStatusMA)
        {
            [Y_StockChartGlobalVariable setisEMALine:Y_StockChartTargetLineStatusMA];
        }
        else if(lineIndex == Y_StockChartTargetLineStatusCloseMA)
        {
            [Y_StockChartGlobalVariable setisEMALine:Y_StockChartTargetLineStatusCloseMA];
        }  else {
            [Y_StockChartGlobalVariable setisEMALine:Y_StockChartTargetLineStatusEMA];
        }
        if (self.klineTime == 0) {
            self.kLineView.MainViewType = Y_StockChartcenterViewTypeTimeLine;
        }
        [self.kLineView reDraw];
        self.indicatorSegmentView.hidden = YES;
        self.isShowindicatorSegmentView = NO;
        UIButton *btn = [self.segmentView viewWithTag:2005];
        btn.selected = NO;
        [self bringSubviewToFront:self.segmentView];
    }
    else if ((index >= (Y_StockChartSegmentIndicatorIndex + 100)) && (index <= (Y_StockChartSegmentIndicatorIndex + 105))) {
        //更多时间里的
        self.indicatorSegmentView.hidden = YES;
        self.isShowindicatorSegmentView = NO;
        UIButton *btn = [self.segmentView viewWithTag:2005];
        btn.selected = NO;
        if (self.isShowMoreSegmentView) {
            self.moreSegmentView.hidden = YES;
            self.isShowMoreSegmentView = NO;
        }
        else{
            self.moreSegmentView.hidden = NO;
            self.isShowMoreSegmentView = YES;
        }
        [self bringSubviewToFront:self.segmentView];
        NSInteger timeIndex = index - Y_StockChartSegmentIndicatorIndex - 100 + 4;
        self.klineTime = timeIndex;
        self.kLineView.lineKTime = self.klineTime;
        [self reloadDataWithTimeIndex:timeIndex];
    }
}

@end


/************************ItemModel类************************/
@implementation Y_StockChartViewItemModel

+ (instancetype)itemModelWithTitle:(NSString *)title type:(Y_StockChartCenterViewType)type
{
    Y_StockChartViewItemModel *itemModel = [Y_StockChartViewItemModel new];
    itemModel.title = title;
    itemModel.centerViewType = type;
    return itemModel;
}

@end
