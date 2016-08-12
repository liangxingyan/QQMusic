//
//  AppDelegate.m
//  qqMusic
//
//  Created by lxy on 16/3/21.
//  Copyright © 2016年 lxy. All rights reserved.
//

#import "AppDelegate.h"
#import "MMExampleDrawerVisualStateManager.h"
#import "MMDrawerController.h"
#import "MMDrawerVisualState.h"
#import "leftViewController.h"
#import "FirstViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // 获取音频会话
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    // 设置后台播放类型
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    // 激活会话
    [session setActive:YES error:nil];
    
    //设置statusBar的风格
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //设置statusBar的隐藏属性
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    FirstViewController *firstViewController = [[FirstViewController alloc] init];
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:firstViewController];
    
    //4.创建左边抽拉视图
    leftViewController *leftVC = [[leftViewController alloc] init];
    UINavigationController *leftNavigation = [[UINavigationController alloc] initWithRootViewController:leftVC];
    
    //6.抽拉管理
    MMDrawerController *rootVC = [[MMDrawerController alloc] initWithCenterViewController:navigation leftDrawerViewController:leftNavigation];
    self.window.rootViewController = rootVC;
    //8.侧拉的宽度
    [rootVC setMaximumLeftDrawerWidth:230];
    //9.设置侧拉动画
    [rootVC setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [rootVC setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    //10.设置左滑打开左侧栏
    [[MMExampleDrawerVisualStateManager sharedManager] setRightDrawerAnimationType:MMDrawerAnimationTypeNone];
    
    [rootVC setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
       
        MMDrawerControllerDrawerVisualStateBlock block;
        block = [[MMExampleDrawerVisualStateManager sharedManager] drawerVisualStateBlockForDrawerSide:drawerSide];
        if (block) {
            block(drawerController, drawerSide, percentVisible);
        }
        
    }];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
