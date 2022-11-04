//
//  AppDelegate.m
//  Demo
//
//  Created by 程小康 on 2022/11/3.
//

#import "AppDelegate.h"
#import "ChinaController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame: UIScreen.mainScreen.bounds];
    
    ChinaController *vc = [[ChinaController alloc] init];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return UIInterfaceOrientationMaskLandscape;
}


@end
