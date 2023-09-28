//
//  OverseaController.m
//  OmniSDKDemo
//
//  Created by 程小康 on 2023/4/14.
//

#import "OverseaController.h"

#define kProdHostUrl @"https://api.seayoo.io/omni"
#define kProductId @"com.oversea.product6"

@interface OverseaController ()

@end

@implementation OverseaController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.items = @[
        @{@"静默登录":NSStringFromSelector(@selector(login))},
        @{@"游客登录":NSStringFromSelector(@selector(loginGuest))},
        @{@"AppleID登录":NSStringFromSelector(@selector(loginApple))},
        @{@"Facebook登录":NSStringFromSelector(@selector(loginFacebook))},
        @{@"登出":NSStringFromSelector(@selector(logout))},
        @{@"账号中心":NSStringFromSelector(@selector(accountCenter))},
        @{@"关联账号":NSStringFromSelector(@selector(linkCustom))},
        @{@"关联Apple":NSStringFromSelector(@selector(linkApple))},
        @{@"关联Facebook":NSStringFromSelector(@selector(linkFacebook))},
        @{@"删除账号":NSStringFromSelector(@selector(deleteAccount))},
        @{@"恢复账号":NSStringFromSelector(@selector(restoreAccount))},
        @{@"支付":NSStringFromSelector(@selector(purchase))},
        @{@"分享Facebook":NSStringFromSelector(@selector(socialShareFacebook))},
    ];
    [self initSDK];
}

/// 初始化
- (void)initSDK{
    OmniSDKOptions *options = [[OmniSDKOptions alloc] init];
    options.delegate = self;
    [[OmniSDKv3 shared] startWithOptions:options];
}

///静默登录
- (void)login {
    [[OmniSDKv3 shared] loginWithController:self options:nil];
}

///游客登录
- (void)loginGuest {
    OmniSDKLoginOptions *options = [[OmniSDKLoginOptions alloc] initWithAuthMethod:OmniSDKAuthMethodGuest];
    [[OmniSDKv3 shared] loginWithController:self options:options];
}

///AppleID 登录
- (void)loginApple {
    OmniSDKLoginOptions *options = [[OmniSDKLoginOptions alloc] initWithAuthMethod:OmniSDKAuthMethodApple];
    [[OmniSDKv3 shared] loginWithController:self options:options];
}

///Facebook 登录
- (void)loginFacebook {
    OmniSDKLoginOptions *options = [[OmniSDKLoginOptions alloc] initWithAuthMethod:OmniSDKAuthMethodFacebook];
    [[OmniSDKv3 shared] loginWithController:self options:options];
}

///登出
- (void)logout {
    if (!self.isLogin) {
        [self.console updateLogWithLevel:INFO message:@"未登录"];
        return;
    }
    [[OmniSDKv3 shared] logout];
}

#pragma mark - 用户中心

- (void)accountCenter {
    if (!self.isLogin) {
        [Utils showAlertWithContrller:self msg:@"请先登录"];
        return;
    }
    [OmniSDKv3.shared openAccountCenterWithController:self];
}

#pragma mark - 应用内购买

/// 购买
- (void)purchase {
    if (!self.isLogin) {
        [Utils showAlertWithContrller:self msg:@"请先登录"];
        return;
    }
    NSString *gameTradeNo = [Utils getCurrentTimes];
    [OmniSDKv3.shared purchaseWithOptions:[self purchaseOptions:gameTradeNo]];
}

#pragma mark - 删除账号

/// 申请删除账号
- (void)deleteAccount {
    if (!self.isLogin) {
        [Utils showAlertWithContrller:self msg:@"请先登录"];
        return;
    }
    [OmniSDKv3.shared deleteAccountWithOptions:nil];
}

/// 恢复账号
- (void)restoreAccount {
    if (!self.isLogin) {
        [Utils showAlertWithContrller:self msg:@"请先登录"];
        return;
    }
    [OmniSDKv3.shared restoreAccountWithOptions:nil];
}

#pragma mark - 关联账号
/// 自定义关联
- (void)linkCustom {
    if (!self.isLogin) {
        [Utils showAlertWithContrller:self msg:@"请先登录"];
        return;
    }
    [OmniSDKv3.shared linkAccountWithOptions:nil];
}

/// 关联 AppleID
- (void)linkApple {
    OmniSDKLinkAccountOptions *options = [[OmniSDKLinkAccountOptions alloc] initWithIdp:OmniSDKIdentityProviderApple];
    [OmniSDKv3.shared linkAccountWithOptions:options];
}

/// 关联 Facebook
- (void)linkFacebook {
    OmniSDKLinkAccountOptions *options = [[OmniSDKLinkAccountOptions alloc] initWithIdp:OmniSDKIdentityProviderFacebook];
    [OmniSDKv3.shared linkAccountWithOptions:options];
}

#pragma mark - 分享

/// 系统分享
- (void)socialShareSystem {
    if (!self.isLogin) {
        [Utils showAlertWithContrller:self msg:@"请先登录"];
        return;
    }
    [self socialShare:OmniSDKSocialSharePlatformSystem];
}

/// 分享到 Facebook
- (void)socialShareFacebook {
    if (!self.isLogin) {
        [Utils showAlertWithContrller:self msg:@"请先登录"];
        return;
    }
    [self socialShare:OmniSDKSocialSharePlatformFacebook];
}

/// 分享到 Line
- (void)socialShareLine {
    if (!self.isLogin) {
        [Utils showAlertWithContrller:self msg:@"请先登录"];
        return;
    }
    [self socialShare:OmniSDKSocialSharePlatformLine];
}

- (void)socialShare:(OmniSDKSocialSharePlatform)platform {
    OmniSDKSocialShareOptions *options = [[OmniSDKSocialShareOptions alloc] init];
    options.platform = platform;
    options.linkUrl = [NSURL URLWithString:@"https://developers.facebook.com"];
    options.text = @"test share";
    options.imageUrl = [NSURL URLWithString:@"https://lmg.jj20.com/up/allimg/4k/s/02/2109250006343S5-0-lp.jpg"];
    [[OmniSDKv3 shared] socialShareWithController:self options:options];
}

#pragma mark - Other Function
    
- (OmniSDKPurchaseOptions *)purchaseOptions:(NSString *)gameOrder {
    OmniSDKPurchaseOptions *options = [[OmniSDKPurchaseOptions alloc] init];
    options.gameRoleId = @"123";
    options.gameOrderId = gameOrder;
    options.gameServerId = @"123";
    options.productId = kProductId;
    options.productDesc = @"test";
    options.purchaseCallbackUrl = [self gameCallbackUrl];
    self.purchaseOptions = options;
    return options;
}

- (NSString *)gameCallbackUrl {
    NSString *sdkHostDomain = self.serverUrl == nil ? kProdHostUrl : self.serverUrl;
    NSString *gameCallbackUrl = [sdkHostDomain stringByAppendingString:@"/pout/test/cp_notify_ok"];
    return  gameCallbackUrl;
}

@end
