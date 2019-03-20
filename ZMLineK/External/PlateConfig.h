//
//  PlateConfig.h
//  lantu
//
//  Created by hexuren on 16/2/20.
//  Copyright © 2016年 hexuren. All rights reserved.
//

#ifndef PlateConfig_h
#define PlateConfig_h

#define kRGBColor(R,G,B)   [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]

#define gCommonBackgroundColor UIColorFromHex(0xffffff)
#define gMainColor UIColorFromHex(0x4A90E2)
#define gThickLineColor UIColorFromHex(0xf2f2f2)
#define gThinLineColor UIColorFromHex(0xeeeeee)

#define gTextColorMain UIColorFromHex(0x4a4a4a)
#define gTextColorSub UIColorFromHex(0x999999)
#define gTextColor333 UIColorFromHex(0x333333)
#define gTextBuySub UIColorFromHex(0x00be66)
#define gTextSellSub UIColorFromHex(0xea573c)
#define gTextNoChangeSub UIColorFromHex(0x999999)
#define gTextColorSpecial UIColorFromHex(0xca0051)
#define gTextColorDetail UIColorFromHex(0xc8c8c8)
#define gBorderColorDetail UIColorFromHex(0xe8e8e8)

#define gFontSelected18 [UIFont systemFontOfSize:18.0]
#define gFontMain15 [UIFont systemFontOfSize:15.0]
#define gFontSub12 [UIFont systemFontOfSize:13.0]
#define gFontDetail10 [UIFont systemFontOfSize:10.5]

//iOS 11头部下拉刷新控件适配
#define AdjustsScrollViewInsetNever(controller,view) if(@available(iOS 11.0, *)) {view.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;} else if([controller isKindOfClass:[UIViewController class]]) {controller.automaticallyAdjustsScrollViewInsets = false;}

#define ifIsiPhoneX ([UIScreen mainScreen].bounds.size.height > 736 ? YES:NO)

//适配字体及屏幕宽高基于的宽度(6/6s)
#define FitScreenSize(size) ([CFBaseTool smartSizeCalculate:size])

#define PFRFontWithSize(s) (IOS_VERSION >= 9.0?[UIFont fontWithName:@"PingFangSC-Regular" size:(s)]:SysFontWithSize(s))
#define PFMFontWithSize(s) (IOS_VERSION >= 9.0?[UIFont fontWithName:@"PingFangSC-Medium" size:(s)]:SysFontWithSize(s))
#define PFSFontWithSize(s) (IOS_VERSION >= 9.0?[UIFont fontWithName:@"PingFangSC-Semibold" size:(s)]:SysFontWithSize(s))

#define SysFontWithSize(s)    [UIFont systemFontOfSize:(s)]

#endif /* PlateConfig_h */
