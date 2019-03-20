//
//  CFKLineFullScreenViewController.h
//
//  Created by Zhimi on 2018/9/3.
//  Copyright © 2018年 hexuren. All rights reserved.
//

#import "StoryboardLoader.h"

@interface LineKFullScreenViewController : UIViewController <StoryboardLoader>

@property (copy, nonatomic) void (^ onClickBackButton)(LineKFullScreenViewController *controller);

@end
