//
//  OverseaController.m
//  OmniSDKDemo
//
//  Created by 程小康 on 2023/4/14.
//

#import "OverseaController.h"

#define GUEST @"1"
#define APPLE @"7"
#define FACEBOOK @"3"
#define LINE @"23"
#define NAVER @"54"
#define GAMECENTER @"5"
#define SHARE_FACEBOOK @"1"
#define SHARE_LINE @"2"
#define DEFAULT @"0"

@interface OverseaController ()

@end

@implementation OverseaController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.items = @[
        @{@"登录":NSStringFromSelector(@selector(defaultLogin))},
        @{@"登出":NSStringFromSelector(@selector(logout))},
        @{@"账号中心":NSStringFromSelector(@selector(accountCenter))},
        @{@"支付":NSStringFromSelector(@selector(pay))},
        @{@"分享Facebook":NSStringFromSelector(@selector(shareFacebook))},
        @{@"分享Line":NSStringFromSelector(@selector(shareLine))},
    ];
    [self initSDK];
}

//初始化
- (void)initSDK{
    OmniSDKOptions *options = [[OmniSDKOptions alloc] init];
    options.toastEnabled = YES;
    options.logCollectEnabled = YES;
    options.logFileEnabled = YES;
    options.storeKit2Enabled = NO;
    [[OmniSDK shared] sdkInitializeWithOptions:options delegate: self];
}

- (void)defaultLogin {
    [self login: DEFAULT];
}

- (void)guestLogin {
    [self login: GUEST];
}

- (void)accountCenter {
    if (!self.isLogin) {
        [Utils showAlertWithContrller:self msg:@"请先登录"];
        return;
    }
    [[OmniSDK shared] updateUserInfo: self];
}

- (void)appleLogin {
    [self login: APPLE];
}

- (void)facebookLogin {
    [self login: FACEBOOK];
}

- (void)lineLogin {
    [self login: LINE];
}

- (void)naverLogin {
    [self login: NAVER];
}

- (void)gameCenterLogin {
    [self login: GAMECENTER];
}

- (void)login:(NSString *)type {
    NSDictionary *dict = @{
        @"accountType":type
    };
    NSString *json = [Utils convertDictToJsonString:dict];
    [[OmniSDK shared] accountLogin:json :self];
}

- (void)logout {
    if (!self.isLogin) {
        [Utils showAlertWithContrller:self msg:@"未登录"];
        return;
    }
    [[OmniSDK shared] accountLogout];
}

- (void)pay {
    NSDictionary *para = @{
        @"role_id":@"123",
        @"cp_order_id":[Utils getCurrentTimes],
        @"server_id":@"123",
        @"goods_id":@"com.oversea.product6",
        @"pay_description":@"test",
        @"notify_cp_url":@"https://api.seayoo.io/omni/pout/test/cp_notify_ok"
    };
    NSString *json = [Utils convertDictToJsonString:para];
    [OmniSDK.shared pay:json];
}

- (void)deleteAccount {
    NSDictionary *para = @{
        @"roleID":@"1234",
        @"serverID":@"asff"
    };
    NSString *json = [Utils convertDictToJsonString:para];
    [OmniSDK.shared accountDelete:json];
}

- (void)bindApple {
    [[OmniSDK shared] accountBind:APPLE];
}

- (void)bindFacebook {
    [[OmniSDK shared] accountBind:FACEBOOK];
}

- (void)bindLine {
    [[OmniSDK shared] accountBind:LINE];
}

- (void)bindNaver {
    [[OmniSDK shared] accountBind:NAVER];
}

- (void)shareFacebook {
    [[OmniSDK shared] socialShare:SHARE_FACEBOOK];
}

- (void)shareLine {
    [[OmniSDK shared] socialShare:SHARE_LINE];
}


@end
