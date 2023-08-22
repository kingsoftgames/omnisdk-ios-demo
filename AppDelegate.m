//
//  AppDelegate.m
//  Demo
//
//  Created by 程小康 on 2022/11/3.
//

#import "AppDelegate.h"
#import "DomesticController.h"
#import "OverseaController.h"
#import <OmniAPI/OmniAPI-Swift.h>

@interface AppDelegate ()
@property (nonatomic, assign) Boolean isLandScape;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.isLandScape = [Utils isLandScape];
    self.window = [[UIWindow alloc] initWithFrame: UIScreen.mainScreen.bounds];
    self.window.rootViewController = [Utils isDomestic] ? [[DomesticController alloc] init] : [[OverseaController alloc] init];
    [self.window makeKeyAndVisible];
    [[OmniSDK shared] application:application didFinishLaunchingWithOptions:launchOptions];
    return YES;
}


#pragma mark - UISceneSession lifecycle

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    [[OmniSDK shared] application:app open:url options:options];
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return self.isLandScape ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskPortrait;
}


@end
