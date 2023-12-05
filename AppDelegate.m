//
//  AppDelegate.m
//  Demo
//
//  Created by 程小康 on 2022/11/3.
//

#import "AppDelegate.h"
#import "KSPassportController.h"
#import "OverseaController.h"
#import "SeayooAccountController.h"
#import <OmniAPI/OmniAPI-Swift.h>

@interface AppDelegate ()
@property (nonatomic, assign) Boolean isLandScape;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.isLandScape = [Utils isLandScape];
    self.window = [[UIWindow alloc] initWithFrame: UIScreen.mainScreen.bounds];
    
    UIViewController *vc;
    switch ([Utils getChannelType]) {
        case Passport:
            vc = [[KSPassportController alloc] init];
            break;
        case Oversea:
            vc = [[OverseaController alloc] init];
            break;
        default:
            vc = [[SeayooAccountController alloc] init];
            break;
    }
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    [[OmniSDKv3 shared] application:application didFinishLaunchingWithOptions:launchOptions];
    return YES;
}


#pragma mark - UISceneSession lifecycle

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    [[OmniSDKv3 shared] application:app open:url options:options];
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return self.isLandScape ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskPortrait;
}


@end
