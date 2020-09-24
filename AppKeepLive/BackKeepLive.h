//
//  BackKeepLive.h
//  yxBox
//
//  Created by jsl on 2020/9/2.
//  Copyright © 2020 Dana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface BackKeepLive : NSObject
/**
 app要保活更长时间,需要在后台采用在后台播放一段静音文件或者设置一段音频文件,
 目前在7p,8p,iphonex测试通过,平均保活1个小时
http://192.168.251.162:8090/pages/viewpage.action?pageId=11633093
 */
///程序非激活
- (void)applicationWillResignActive:(UIApplication *)application;
///程序激活
- (void)applicationDidBecomeActive:(UIApplication *)application;
///app 后台保活任务开启,remain保留保活时间,以分钟为单位
-(void)applicationDidEnterBackground:(UIApplication *)app remainsInteral:(int)remain;
///app 后台保活任务关闭
-(void)applicationWillEnterForeground:(UIApplication *)app;
///程序终止
- (void)applicationWillTerminate:(UIApplication *)app;
@end

NS_ASSUME_NONNULL_END
