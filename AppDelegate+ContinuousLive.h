//
//  AppDelegate+ContinuousLive.h
//  yxBox
//
//  Created by jsl on 2020/9/5.
//  Copyright © 2020 Dana. All rights reserved.
//

#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (ContinuousLive)
///程序非激活
- (void)liveApplicationWillResignActive:(UIApplication *)application;
///程序激活
- (void)liveApplicationDidBecomeActive:(UIApplication *)application;
///程序进入后台
- (void)liveApplicationDidEnterBackground:(UIApplication *)application;
///程序进入前台
- (void)liveApplicationWillEnterForeground:(UIApplication *)application;
///程序终止
- (void)liveAplicationWillTerminate:(UIApplication *)application;
@end

NS_ASSUME_NONNULL_END
