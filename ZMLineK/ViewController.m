//
//  ViewController.m
//  ZMLineK
//
//  Created by Zhimi on 2019/3/19.
//  Copyright © 2019 hexuren. All rights reserved.
//

#import "ViewController.h"
#import "Y_StockChartView.h"
#import "Y_KLineModel.h"
#import "Y_KLineGroupModel.h"
#import "NetWorking.h"
#import "LineKFullScreenViewController.h"
#import "UIViewController+INMOChildViewControlers.h"


typedef NS_ENUM(NSInteger, KLineTimeType) {
    KLineTimeTypeMinute = 100,
    KLineTimeTypeMinute5,
    KLineTimeTypeMinute15,
    KLineTimeTypeMinute30,
    KLineTimeTypeHour,
    KLineTimeTypeHour4,
    KLineTimeTypeDay,
    KLineTimeTypeWeek,
    KLineTimeTypeMonth,
    KLineTimeTypeOther
};

@interface ViewController ()<Y_StockChartViewDelegate,Y_StockChartViewDataSource>

@property (weak, nonatomic) IBOutlet Y_StockChartView *lineKView;
@property (strong, nonatomic) LineKFullScreenViewController *lineKFullScreenViewController;
@property (assign, nonatomic) BOOL isShowKLineFullScreenViewController;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) Y_KLineGroupModel *groupModel;
@property (nonatomic, assign) int klineRequestID;
@property (nonatomic, copy) NSMutableDictionary <NSString*, Y_KLineGroupModel*> *modelsDict;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentIndex = -1;
    _lineKView.backgroundColor = [UIColor whiteColor];
    _lineKView.isFullScreen = NO;
    _isShowKLineFullScreenViewController = NO;
    _lineKView.itemModels = @[
                              [Y_StockChartViewItemModel itemModelWithTitle:@"分时" type:Y_StockChartcenterViewTypeKline],
                              [Y_StockChartViewItemModel itemModelWithTitle:@"15分" type:Y_StockChartcenterViewTypeKline],
                              [Y_StockChartViewItemModel itemModelWithTitle:@"4小时" type:Y_StockChartcenterViewTypeKline],
                              [Y_StockChartViewItemModel itemModelWithTitle:@"1天" type:Y_StockChartcenterViewTypeKline],
                              [Y_StockChartViewItemModel itemModelWithTitle:@"更多" type:Y_StockChartcenterViewTypeOther],
                              [Y_StockChartViewItemModel itemModelWithTitle:@"指标" type:Y_StockChartcenterViewTypeOther],
                              [Y_StockChartViewItemModel itemModelWithTitle:@"" type:Y_StockChartcenterViewTypeOther],
                              ];
    _lineKView.dataSource = self;
    _lineKView.delegate = self;
    [self addLinesView];
    
}


- (void)addLinesView {
    CGFloat white = _lineKView.bounds.size.height /4;
    CGFloat height = _lineKView.bounds.size.width /4;
    //横格
    for (int i = 0;i < 4;i++ ) {
        UIView *hengView = [[UIView alloc] initWithFrame:CGRectMake(0, white * (i + 1),_lineKView.bounds.size.width , 1)];
        hengView.backgroundColor = UIColorFromHex(0xf3f3f3);
        [_lineKView addSubview:hengView];
        [_lineKView sendSubviewToBack:hengView];
    }
    //竖格
    for (int i = 0;i< 4;i++ ) {
        
        UIView *shuView = [[UIView alloc]initWithFrame:CGRectMake(height * (i + 1), 47, 1, _lineKView.bounds.size.height - 62)];
        shuView.backgroundColor = UIColorFromHex(0xf3f3f3);
        [_lineKView addSubview:shuView];
        [_lineKView sendSubviewToBack:shuView];
    }
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(5, 245, 73, 20)];
    [logo setImage:CF_IMAGE(@"logo")];
    [_lineKView addSubview:logo];
    [_lineKView sendSubviewToBack:logo];
}

- (NSMutableDictionary<NSString *,Y_KLineGroupModel *> *)modelsDict {
    if (!_modelsDict) {
        _modelsDict = @{}.mutableCopy;
    }
    return _modelsDict;
}


- (void)reloadData {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"type"] = self.type;
    param[@"market"] = @"btc_usdt";
    param[@"size"] = @"1000";
    [NetWorking requestWithApi:@"http://api.bitkk.com/data/v1/kline" param:param thenSuccess:^(NSDictionary *responseObject) {
        Y_KLineGroupModel *groupModel = [Y_KLineGroupModel objectWithArray:responseObject[@"data"]];        self.groupModel = groupModel;
        [self.modelsDict setObject:groupModel forKey:self.type];
        
        [self.lineKView reloadData];
    } fail:^{
        
    }];
}

- (void)showKLineFullScreenViewController{
    if (!_lineKFullScreenViewController) {
        _lineKFullScreenViewController = [LineKFullScreenViewController loadFromStoryboard];;
    }
    DefineWeakSelf;
    _lineKFullScreenViewController.onClickBackButton = ^(LineKFullScreenViewController *controller) {
        CGRect tempFrame = CGRectMake(SCREEN_WIDTH * 2, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        if (weakSelf.lineKFullScreenViewController.view.frame.origin.x == 0) {
            [UIView animateWithDuration:0.35 animations:^{
                weakSelf.lineKFullScreenViewController.view.frame = tempFrame;
            } completion:^(BOOL finished) {
                weakSelf.isShowKLineFullScreenViewController = NO;
                [weakSelf containerRemoveChildViewController:weakSelf.lineKFullScreenViewController];
            }];
        }
    };
    _lineKFullScreenViewController.view.frame = CGRectMake(SCREEN_WIDTH*2, 0, SCREEN_WIDTH, SCREEN_HEIGHT );
    [_lineKFullScreenViewController.view setNeedsLayout];
    CGRect tempFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    if (_lineKFullScreenViewController.view.frame.origin.x > SCREEN_WIDTH) {
        [UIView animateWithDuration:0.35 animations:^{
            weakSelf.lineKFullScreenViewController.view.frame = tempFrame;
        } completion:^(BOOL finished) {
            
        }];
        _isShowKLineFullScreenViewController = YES;
        [self containerAddChildViewController:_lineKFullScreenViewController parentView:self.view];
    }
}


#pragma mark - Y_StockChartViewDataSource

-(id)stockDatasWithIndex:(NSInteger)index {
    NSString *type;
    switch (index) {
        case 0:{type = @"1min";}
            break;
        case 1:type = @"15min";
            break;
        case 2:type = @"4hour";
            break;
        case 3:type = @"1day";
            break;
        case 4:type = @"1min";
            break;
        case 5:type = @"5min";
            break;
        case 6:type = @"30min";
            break;
        case 7:type = @"1day";
            break;
        case 8:type = @"1week";
            break;
        case 9:type = @"1month";
            break;
        default:
            break;
    }
    
    self.currentIndex = index;
    self.type = type;
    if (index == 0 || index == 1 || index == 2 || index == 3) {
            _lineKView.isMoreTimeDataUpdate = NO;
    }
    else{
        _lineKView.isMoreTimeDataUpdate = YES;
    }
    if(![self.modelsDict objectForKey:type]){
        [self reloadData];
    }
    else{
        return [self.modelsDict objectForKey:type].models;
    }
    return nil;
}



#pragma mark - Y_StockChartViewDelegate

- (void)onClickFullScreenButtonWithTimeType:(Y_StockChartCenterViewType )timeType{
    if (!_isShowKLineFullScreenViewController) {
        [self showKLineFullScreenViewController];
    }
}


@end
