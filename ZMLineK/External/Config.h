//
//  config.h
//  ElectricityPatrolSystem
//
//  Created by apple on 16/5/10.
//  Copyright © 2016年 KevinWu. All rights reserved.
//

#ifndef config_h
#define config_h

#define CurrentAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define APIVersion @"1.0.0"

#define APPDELEGATE ((AppDelegate *)[UIApplication sharedApplication].delegate)
#define AUTOLANGUAGE(a) [LocalizationManager getStringByKey:a]

#define CF_IMAGE(name) [UIImage imageNamed:(name)]
#define CF_IMAGEURL(imgUrlStr) [NSURL URLWithString:(imgUrlStr)]


#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

//我的界面宽度
#define MINE_VC_WIDTH 300

//沙盒中Preferences文件夹的路径
#define PREFERENCES_PATH [NSString stringWithFormat:@"%@/Preferences",NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0]]

#endif /* config_h */
