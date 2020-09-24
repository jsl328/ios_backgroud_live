//
//  BackKeepLive.m
//  yxBox
//
//  Created by jsl on 2020/9/2.
//  Copyright © 2020 Dana. All rights reserved.
//

#import "BackKeepLive.h"
#import "AppDelegate.h"
#import "YXAudioInBackgroundPlayer.h"

static NSString *const kBgTaskName = @"com.yusys.yump.prod.AppRunInBackground";

@interface BackKeepLive ()
{
    __block UIBackgroundTaskIdentifier _backIden;
    UIApplication *_app;
    NSTimeInterval timeRemain;
    NSTimer *_timer;
}
@end

@implementation BackKeepLive
///程序非激活
- (void)applicationWillResignActive:(UIApplication *)application{
    //[_timer invalidate];
    //_timer =nil;
}
///程序激活
- (void)applicationDidBecomeActive:(UIApplication *)application{
    [[YXAudioInBackgroundPlayer sharedInstance].player play];
    [YXAudioInBackgroundPlayer sharedInstance].needRunInBackground =YES;
    [self setupTimer];
}
///app 后台保活任务开启,remain保留保活时间,以分钟为单位
-(void)applicationDidEnterBackground:(UIApplication *)app remainsInteral:(int)remain{
    [self audioBackgroundAutoPlayer:app remainsInteral:remain];
}

-(void)audioBackgroundAutoPlayer:(UIApplication *)app remainsInteral:(int)remain{
    _app = app;
    _backIden = [_app beginBackgroundTaskWithName:kBgTaskName expirationHandler:^{
       if ([YXAudioInBackgroundPlayer sharedInstance].needRunInBackground) {
           [[YXAudioInBackgroundPlayer sharedInstance].player play];
       }
       if (_backIden != UIBackgroundTaskInvalid) {
           [[UIApplication sharedApplication] endBackgroundTask:_backIden];
           _backIden = UIBackgroundTaskInvalid;
       }
    }];
    if (_backIden == UIBackgroundTaskInvalid) {
        NSLog(@"failed to start background task!");
    }
    
//    _backIden = [_app beginBackgroundTaskWithExpirationHandler:^{
//        [_app endBackgroundTask:_backIden];
//        _backIden = UIBackgroundTaskInvalid;
//
//        if ([QiAudioPlayer sharedInstance].needRunInBackground) {
//           [[QiAudioPlayer sharedInstance].player play];
//        }
//        if (_backIden != UIBackgroundTaskInvalid) {
//           [[UIApplication sharedApplication] endBackgroundTask:_backIden];
//           _backIden = UIBackgroundTaskInvalid;
//       }
//    }];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
//         dispatch_async(dispatch_get_main_queue(), ^{
//                float remainTimeIncrent = remain*60;//这里默认是3分钟=180s
//                float remainTime = [_app backgroundTimeRemaining];//这里默认是3分钟=180s
//                float rmTotal =remainTimeIncrent +remainTime;
//                while ( _backIden!= UIBackgroundTaskInvalid &&rmTotal>0 )  {
//                    [NSThread sleepForTimeInterval:1.0];
//                    NSLog(@"###!!!BackgroundTimeRemaining: %f",rmTotal);
//                    if (self.player) {
//                       [self.player play];
//                    }
//                    [_app beginBackgroundTaskWithExpirationHandler:nil];
//                    rmTotal --;
//                };
//                if (_backIden != UIBackgroundTaskInvalid){
//                    [_app endBackgroundTask:_backIden];
//                    _backIden = UIBackgroundTaskInvalid;
//                }
//            });
//    });
}
///app 后台保活任务关闭
-(void)applicationWillEnterForeground:(UIApplication *)app{
    _app = app;
    if ([YXAudioInBackgroundPlayer sharedInstance].needRunInBackground) {
        [[YXAudioInBackgroundPlayer sharedInstance].player pause];
    }
    if (_backIden != UIBackgroundTaskInvalid){
        [_app endBackgroundTask:_backIden];
        _backIden = UIBackgroundTaskInvalid;
    }
    _app = nil;
}
///程序终止
- (void)applicationWillTerminate:(UIApplication *)app{
    _app = app;
    if ([YXAudioInBackgroundPlayer sharedInstance].needRunInBackground) {
        [[YXAudioInBackgroundPlayer sharedInstance].player pause];
    }
    [_timer invalidate];
    _timer =nil;
}
#pragma mark - 定时器
- (void)setupTimer {
    _timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerEvent:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    [_timer fire];
}

- (void)timerEvent:(id)sender {
//    NSLog(@"定时器运行中");
}

@end
