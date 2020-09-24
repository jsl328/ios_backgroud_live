
//
//  YXAppDelegate.m
//  TestAppFrame
//
//  Created by Dana on 2020/7/23.
//  Copyright © 2020 Dana. All rights reserved.
//

#import "AppDelegate.h"
#import "YXAppDelegateProtocol.h"
#import "YXMainSingleWebViewNavigation.h"
#import "YXMainMutiWebViewNavigation.h"
#import "YXEntryPathManager.h"
#import "YXPushManager.h"
#import "YXVersionManager.h"

#import <UserNotifications/UserNotifications.h>

#import "YXLogMeManager.h"

#if __has_include(<YXCoreBase/YXCoreBase.h>)
#import <Networking/Networking.h>
#import <YXCoreBase/YXCoreBase.h>
#import <YXStatistics/YXStatistics.h>
#import <YXBaseDefine/YXBaseDefine.h>
#import <YXSafeCenter/YXSafeCenter.h>
#import <YXH5Container/YXH5Container.h>
#import <YXDeviceOS/YXDeviceOS.h>
#import <YXSecurity/YXSecurity.h>
#import <YXApp/YXApp-Swift.h>
#else
#import "Networking.h"
#import "YXCoreBase.h"
#import "YXStatistics.h"
#import "YXBaseDefine.h"
#import "YXSafeCenter.h"
#import "YXH5Container.h"
#import "YXDeviceOS.h"
#import "YXSecurity.h"
#import "yxBox-Swift.h"
#endif

#import "AppDelegate+JPush.h"
#import "AppDelegate+GTPush.h"
#import "AppDelegate+Advertisement.h"
#import "AppDelegate+Introduce.h"
#import "AppDelegate+ContinuousLive.h"


//编码规范见本工程文档:README.md
@interface AppDelegate ()<YXAppDelegateProtocol,UIApplicationDelegate,UNUserNotificationCenterDelegate>

//异步初始化方法，优化启动时间
- (void)asyncInitsAfterLaunch;


/// 执行类方法,无参数
/// @param className 类名
/// @param selector 类方法名
- (void)safePerformClassSelector:(NSString*)className selector:(NSString *)selector;

/// 执行实例方法,无参数
/// @param className 类名
/// @param selector 类方法名
- (void)performInstanceSelector:(NSString*)className selector:(NSString *)selector;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"keepScreenOn"];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    NSDLog(@"home__path===%@",NSHomeDirectory());
    
    
    /*************** begin 首页出来前必须完成的逻辑 函数调用先后顺序不可调换 begin****/
    
    //重刷app通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadApp:) name:YXVersionManagerNeedReloadApp object:nil];
    
    //拷贝包资源到沙盒
    [YXHTMLResourceManager copyBundleResource];
    
    
    //读配置
    [YXConfigManager getInstance];
    
    //启动路径配置
    [self setupMutiAppPath];
    
    
    //网络初始化
    [YXNetWorkManager setup:[YXConfigTool gatewayUrl] baseHeader:[self netWorkBaseHeader]];
    [YXNetWorkManager setDeviceId:[SystemInfoUtil deviceID] publicKey:yxPublicKey];
    
    //国密:NationalEncyptFactory 国际的:InternationalEncryptFactory
    if ([[YXConfigTool encryptType] isEqualToString:@"1"]) {
        [YXNetWorkManager setYXEncryptFactory:[NationalEncyptFactory new]];
    }else if ([[YXConfigTool encryptType] isEqualToString:@"0"])
    {
        [YXNetWorkManager setYXEncryptFactory:[InternationalEncryptFactory new]];
    }
    
    /***************end 首页出来前必须完成的逻辑 函数调用先后顺序不可调换 end****/
    
    if([launchOptions.allKeys containsObject:UIApplicationLaunchOptionsRemoteNotificationKey])
    {
        [YXPushManager shareInstance].launchOptionsRemote = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    }

    _window.rootViewController = [self rootNavigation];
    [_window makeKeyAndVisible];
    
    

    
    //分享模块初始化
    [self safePerformClassSelector:@"YXShareManager" selector:@"registPlatforms"];
    
    
    //开启日志采集
    if ([self checkClassIfExist:@"YusysIO"]) {
        [YusysIO sendCrashEnabel:YES];
        [YusysIO appLaunch];
    }

    
    //语音识别初始化
    [self safePerformClassSelector:@"YXVoiceManager" selector:@"installAK"];

    
    [self addAdvertisement];
    
    //异步初始化方法放这，优化启动时间
    [self asyncInitsAfterLaunch];
    
    [self processIntroduceView];
    
    [YXDeviceManager sharedInstance].runtime.arguments = launchOptions ? launchOptions : [[NSMutableDictionary alloc] init];
    [YXDeviceManager sharedInstance].runtime.launcher = [[YXDeviceManager sharedInstance] launcher:launchOptions];
    
     
#if TARGET_IPHONE_SIMULATOR//模拟器

#elif TARGET_OS_IPHONE//真机

    if (NEED_GETUI_PUSH) {
        //注册个推
        [self geTuiConfigPluginsApplication:application didFinishLaunchingWithOptions:launchOptions];
    }
    if (NEED_JPUSH) {
        //注册极光
        [self jPushConfigPluginsApplication:application didFinishLaunchingWithOptions:launchOptions];
    }
 
    
#endif
    

    {
        //license校验
        BOOL isValid = [[YXLogMeManager shareManager] startLogMe];
        if (!isValid) {
            NSLog(@"license校验失败");
            //防调试
            NSArray *arrTest = @[@"1"];
            NSString *crash = [arrTest objectAtIndex:99];
            exit(0);
            abort();
        }
    }
    
    return [self YXapplication:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSDLog(@"%s",__FUNCTION__);
    
    
#if TARGET_IPHONE_SIMULATOR//模拟器
#elif TARGET_OS_IPHONE//真机
    //个推引用
    //        [self geTuiapplicationWillResignActive:application];
#endif
    
    [self YXapplicationWillResignActive:application];
    //后台保活相关
    [self liveApplicationWillResignActive:application];
}



//程序进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSDLog(@"%s",__FUNCTION__);
    /*设置应用程序退到后台关闭屏幕常亮和屏幕亮度*/
    
    [UIApplication sharedApplication].idleTimerDisabled=NO;//开启自动休眠
    
    if ([self checkClassIfExist:@"YusysIO"]) {
        [YusysIO enterBackground];
    }
    
#if TARGET_IPHONE_SIMULATOR//模拟器
    
#elif TARGET_OS_IPHONE//真机
    
#if NEED_GETUI_PUSH
    //个推引用
    [self geTuiapplicationDidEnterBackground:application];
#endif
    
#if NEED_JPUSH
    
    //jPush
    [self jPushapplicationDidEnterBackground:application];
    
#endif
    
#endif
    [self YXapplicationDidEnterBackground:application];
    [self liveApplicationDidEnterBackground:application];
}

//程序进入前台
- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    if ([self checkClassIfExist:@"YusysIO"]) {
        [YusysIO enterForeground];
    }
    
    BOOL idleTime = [[NSUserDefaults standardUserDefaults] boolForKey:@"keepScreenOn"];
    if (idleTime == YES) {
        [UIApplication sharedApplication].idleTimerDisabled=YES;//保存常亮
    }else{
        [UIApplication sharedApplication].idleTimerDisabled=NO;//开启自动休眠
        
    }
    NSDLog(@"%s",__FUNCTION__);
#if TARGET_IPHONE_SIMULATOR//模拟器
    
#elif TARGET_OS_IPHONE//真机
    
#if NEED_GETUI_PUSH
    //个推引用
    [self geTuiapplicationWillEnterForeground:application];
#endif
    
#if NEED_JPUSH
    //Jpush
    [self jPushapplicationWillEnterForeground:application];
#endif
    
#endif
    
    [self YXapplicationWillEnterForeground:application];
    [self liveApplicationWillEnterForeground:application];
}

//程序被激活
- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSDLog(@"%s",__FUNCTION__);
#if TARGET_IPHONE_SIMULATOR//模拟器
    
#elif TARGET_OS_IPHONE//真机
    
#if NEED_GETUI_PUSH
    //个推引用
    [self geTuiapplicationDidBecomeActive:application];
#endif
    
#if NEED_JPUSH
    //jpush
    [self jPushapplicationDidBecomeActive:application];
#endif
    
#endif
    [self YXapplicationDidBecomeActive:application];
    [self liveApplicationDidBecomeActive:application];
}

//终止
- (void)applicationWillTerminate:(UIApplication *)application {
    
    //[YusysIO appExit];
    NSDLog(@"%s",__FUNCTION__);
#if TARGET_IPHONE_SIMULATOR//模拟器
    
#elif TARGET_OS_IPHONE//真机
    
#if NEED_GETUI_PUSH
    //个推引用
    [self geTuiapplicationWillTerminate:application];
#endif
    
#if NEED_JPUSH
    //jpush
    [self jPushapplicationWillTerminate:application];
#endif
    
#endif
    
    [self YXapplicationWillTerminate:application];
    
    [self liveAplicationWillTerminate:application];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    NSDLog(@"---url:%@ --",url);
    [YXDeviceManager sharedInstance].runtime.arguments = [[YXDeviceManager sharedInstance] arguments:url];
    [YXDeviceManager sharedInstance].runtime.launcher = [[YXDeviceManager sharedInstance] launcher:options];
    
    [self YXapplication:app openURL:url options:options];
    return YES;
}

#pragma mark - 自定义方法
- (void)setupMutiAppPath
{
    [YXEntryPathManager shareInstance];
}

- (void)asyncInitsAfterLaunch{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //模糊应用预览
        [[VisualEffectManager sharedInstance] registerVisualEffect];
        //启动网络监测
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            [[NSNotificationCenter defaultCenter] postNotificationName:YXEventLisenerNetWorkDidChange object:@{@"status":[NSString stringWithFormat:@"%ld",(long)status+1]}];
        }];
        

        //初始化，载入匹配文件
        [YXWebManager sharedInstance];
        
        //注册百度OCR
        [self safePerformClassSelector:@"YXOCRManager" selector:@"installAK"];
        
        //全局卡顿
        
        [YXVersionManager checkVersionFromeServer];
        
        // [self installDemoPDF];
        
        
    });
}


- (NSDictionary *)netWorkBaseHeader
{
    NSMutableDictionary *headers = [NSMutableDictionary new];
    [headers setSafeObject:[SystemInfoUtil deviceID] forKey:@"deviceId"];
    [headers setSafeObject:@"1001" forKey:@"channelId"];
    [headers setSafeObject:[SystemInfoUtil platform] forKey:@"platform"];
    [headers setSafeObject:@"zh-CN" forKey:@"appLang"];
    
    [headers setSafeObject:[SystemInfoUtil appId] forKey:@"appId"];
    
    
    [headers setSafeObject:[NSString stringWithFormat:@"%@-%.0f",[SystemInfoUtil appVersionCode],[YXConfigTool offId]] forKey:@"appVer"];
    
    
    return headers;
}

- (UINavigationController *)rootNavigation
{
    
#if MUTI_WEBVIEW_HOME
    return (UINavigationController *)[[YXMainMutiWebViewNavigation new] getMainViewController];
    
#else
    return (UINavigationController *)[[YXMainSingleWebViewNavigation new] getMainViewController];
#endif
}

- (void)reloadApp:(NSNotification *)noti
{
    //比较版本号
    _window.rootViewController = [self rootNavigation];
}


-(BOOL)checkClassIfExist:(NSString *)className
{
    Class yxClass = NSClassFromString(className);
    if (yxClass) {
        id instance = [yxClass new];
        if (instance) {
            return YES;
        }
    }
    return NO;
}


///执行类方法
- (void)safePerformClassSelector:(NSString*)className selector:(NSString *)selector
{
    if (!className || !selector) {
        NSLog(@"类:%@ 或者方法:%@ 不能为空",className,selector);
        return;
    }
    
    Class yxClass = NSClassFromString(className);
    SEL   sel = NSSelectorFromString(selector);
    if (yxClass && sel) {
        [yxClass performSelector:sel];
    }else
    {
        NSLog(@"类:%@ 或者方法:%@ 不存在",className,selector);
    }
    
}

///执行实例方法
- (void)performInstanceSelector:(NSString*)className selector:(NSString *)selector
{
    if (!className || !selector) {
        NSLog(@"类:%@ 或者方法:%@ 不存在",className,selector);
        return;
    }
    
    Class yxClass = NSClassFromString(className);
    SEL   sel = NSSelectorFromString(selector);
    if (yxClass && sel) {
        [[yxClass new] performSelector:sel];
    }
    
}


#pragma mark - 模板方法,供子类覆盖,不要写任何代码逻辑在这
- (BOOL)YXapplication:(nonnull UIApplication *)application didFinishLaunchingWithOptions:(nonnull NSDictionary *)launchOption {
    return YES;
}

- (void)YXapplicationWillResignActive:(nonnull UIApplication *)application {
    
}

- (void)YXapplicationDidEnterBackground:(nonnull UIApplication *)application {
    
}

- (void)YXapplicationWillEnterForeground:(nonnull UIApplication *)application {
    
}

- (void)YXapplicationDidBecomeActive:(nonnull UIApplication *)application {
    
}


- (void)YXapplicationWillTerminate:(nonnull UIApplication *)application {
    
}

- (BOOL)YXapplication:(nonnull UIApplication *)app openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    return YES;
}
@end
