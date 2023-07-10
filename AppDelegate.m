//
//  AppDelegate.m
//  Demo
//
//  Created by 程小康 on 2022/11/3.
//

#import "AppDelegate.h"
#import "DomesticController.h"
@interface AppDelegate ()
@property (nonatomic, assign) Boolean isLandScape;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.isLandScape = [Utils isLandScape];
    self.window = [[UIWindow alloc] initWithFrame: UIScreen.mainScreen.bounds];
    
    DomesticController *vc = [[DomesticController alloc] init];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    return self.isLandScape ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskPortrait;
}


@end
