//
//  CFKLineFullScreenViewController.m
//
//  Created by Zhimi on 2018/9/3.
//  Copyright © 2018年 hexuren. All rights reserved.
//

#import "LineKFullScreenViewController.h"
#import "Y_StockChartView.h"
#import "Y_KLineGroupModel.h"
#import "Y_KLineModel.h"
#import "NetWorking.h"


@interface LineKFullScreenViewController ()<Y_StockChartViewDelegate,Y_StockChartViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *dealPairButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *changeLabel;
@property (weak, nonatomic) IBOutlet UILabel *highTitle;
@property (weak, nonatomic) IBOutlet UILabel *highLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowTitle;
@property (weak, nonatomic) IBOutlet UILabel *lowLabel;
@property (weak, nonatomic) IBOutlet UILabel *volTitle;
@property (weak, nonatomic) IBOutlet UILabel *volLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet Y_StockChartView *lineKView;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) Y_KLineGroupModel *groupModel;
@property (nonatomic, assign) int klineRequestID;
@property (nonatomic, copy) NSMutableDictionary <NSString*, Y_KLineGroupModel*> *modelsDict;


@end

@implementation LineKFullScreenViewController

+ (id)loadFromStoryboard{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return [sb instantiateViewControllerWithIdentifier:@"LineKFullScreenViewController"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    _lineKView.isFullScreen = YES;

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prefersStatusBarHidden];
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
    self.currentIndex = -1;
    _lineKView.backgroundColor = [UIColor whiteColor];
    _lineKView.isFullScreen = YES;
    _lineKView.itemModels = @[
                              [Y_StockChartViewItemModel itemModelWithTitle:@"分时" type:Y_StockChartcenterViewTypeKline],
                              [Y_StockChartViewItemModel itemModelWithTitle:@"1分" type:Y_StockChartcenterViewTypeKline],
                              [Y_StockChartViewItemModel itemModelWithTitle:@"5分" type:Y_StockChartcenterViewTypeKline],
                              [Y_StockChartViewItemModel itemModelWithTitle:@"15分" type:Y_StockChartcenterViewTypeKline],
                              [Y_StockChartViewItemModel itemModelWithTitle:@"30分" type:Y_StockChartcenterViewTypeKline],
                              [Y_StockChartViewItemModel itemModelWithTitle:@"1小时" type:Y_StockChartcenterViewTypeKline],
                              [Y_StockChartViewItemModel itemModelWithTitle:@"4小时" type:Y_StockChartcenterViewTypeKline],
                              [Y_StockChartViewItemModel itemModelWithTitle:@"1天" type:Y_StockChartcenterViewTypeKline],
                              [Y_StockChartViewItemModel itemModelWithTitle:@"1周" type:Y_StockChartcenterViewTypeKline],
                              [Y_StockChartViewItemModel itemModelWithTitle:@"1月" type:Y_StockChartcenterViewTypeKline],
                              [Y_StockChartViewItemModel itemModelWithTitle:@"指标" type:Y_StockChartcenterViewTypeOther],
                              ];
    _lineKView.dataSource = self;
    _lineKView.delegate = self;
    [self addLinesView];
}

- (IBAction)onClickCloseButton:(id)sender {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (self.onClickBackButton) {
        self.onClickBackButton(self);
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;//隐藏为YES，显示为NO
}

- (NSMutableDictionary<NSString *,Y_KLineGroupModel *> *)modelsDict {
    if (!_modelsDict) {
        _modelsDict = @{}.mutableCopy;
    }
    return _modelsDict;
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



#pragma mark - Y_StockChartViewDelegate

- (void)onClickFullScreenButtonWithTimeType:(Y_StockChartCenterViewType )timeType{
//    if (!_isShowKLineFullScreenViewController) {
//        [self showKLineFullScreenViewController];
//    }
}

#pragma mark - Y_StockChartViewDataSource

-(id) stockDatasWithIndex:(NSInteger)index{
    NSString *type;
    switch (index) {
        case 0:{type = @"1min";}
            break;
        case 1:type = @"1min";
            break;
        case 2:type = @"5min";
            break;
        case 3:type = @"15min";
            break;
        case 4:type = @"30min";
            break;
        case 5:type = @"1hour";
            break;
        case 6:type = @"4hour";
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
    _lineKView.isMoreTimeDataUpdate = NO;
    if(![self.modelsDict objectForKey:type]){
        [self reloadData];
    }
    else{
        return [self.modelsDict objectForKey:type].models;
    }
    return nil;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
