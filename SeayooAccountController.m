//
//  SeayooAccountController.m
//  OmniSDKDemo
//
//  Created by Zhang Gang on 2023/11/11.
//

#import "SeayooAccountController.h"

@interface SeayooAccountController ()

@end

@implementation SeayooAccountController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.items = @[
        @{@"登录":NSStringFromSelector(@selector(login))}
    ];
    [self initSDK];
}

/// 初始化
- (void)initSDK{
    OmniSDKOptions *options = [[OmniSDKOptions alloc] init];
    options.delegate = self;
    [[OmniSDKv3 shared] startWithOptions:options];
}

///登录
- (void)login {
    [[OmniSDKv3 shared] loginWithController:self options:nil];
}

@end
