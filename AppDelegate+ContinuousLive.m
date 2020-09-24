//
//  AppDelegate+ContinuousLive.m
//  yxBox
//
//  Created by jsl on 2020/9/5.
//  Copyright © 2020 Dana. All rights reserved.
//

#import "AppDelegate+ContinuousLive.h"
#import "BackKeepLive.h"
#import "YXAudioInBackgroundPlayer.h"
#import <objc/message.h>

@interface AppDelegate ()
@end

@implementation AppDelegate (ContinuousLive)

/// 执行实例方法,有参数
/// @param className 类名
/// @param selector 实例方法名
///// @param app 实例方法参数1
//- (void)performInstanceSelector:(NSString*)className selector:(NSString *)selector app:(id)app{
//
//}
//
///// 执行实例方法,有参数
///// @param className 类名
///// @param selector 实例方法名
///// @param app 实例方法参数1
///// @param remain 实例方法参数2
//- (void)performInstanceSelector:(NSString*)className selector:(NSString *)selector app:(id)app  carryingProps:(int)remain{
//
//}

///程序非激活
- (void)liveApplicationWillResignActive:(UIApplication *)application{
    [self performInstanceSelector:@"BackKeepLive" selector:@"applicationWillResignActive:" app:application];
}
///程序激活
- (void)liveApplicationDidBecomeActive:(UIApplication *)application{
    [self performInstanceSelector:@"BackKeepLive" selector:@"applicationDidBecomeActive:" app:application];
}
//程序进入后台
- (void)liveApplicationDidEnterBackground:(UIApplication *)application {
    NSDLog(@"%s",__FUNCTION__);
    [self performInstanceSelector:@"BackKeepLive" selector:@"applicationDidEnterBackground:remainsInteral:" app:application carryingProps:KEEPLIVEREMAINS];
}

//程序进入前台
- (void)liveApplicationWillEnterForeground:(UIApplication *)application {
    [self performInstanceSelector:@"BackKeepLive" selector:@"applicationWillEnterForeground:" app:application];
}
///程序终止
- (void)liveAplicationWillTerminate:(UIApplication *)application{
    [self performInstanceSelector:@"BackKeepLive" selector:@"liveAplicationWillTerminate:" app:application];
}

void (*jlt_msgsend)(id, SEL, UIApplication *,int) = (void (*)(id, SEL,UIApplication*,int))objc_msgSend;
void (*jltl_msgsend)(id, SEL, UIApplication *) = (void (*)(id, SEL,UIApplication*))objc_msgSend;
-(void)performInstanceSelector:(NSString *)className selector:(NSString *)selector app:(id)app{
    if (!className || !selector) {
        NSLog(@"类:%@ 或者方法:%@ 不存在",className,selector);
        return;
    }
    
    Class yxClass = NSClassFromString(className);
    SEL   sel = NSSelectorFromString(selector);
    if (yxClass && sel) {
        id cls = [[yxClass alloc] init];
        jltl_msgsend(cls, sel, app);
    }
}
- (void)performInstanceSelector:(NSString*)className selector:(NSString *)selector app:(id)app carryingProps:(int)remain{
    if (!className || !selector) {
        NSLog(@"类:%@ 或者方法:%@ 不存在",className,selector);
        return;
    }
    
    Class yxClass = NSClassFromString(className);
    SEL   sel = NSSelectorFromString(selector);
    if (yxClass && sel) {
        id cls = [[yxClass alloc] init];
        jlt_msgsend(cls, sel, app,remain);
    }
}

@end
