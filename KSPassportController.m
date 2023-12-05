//
//  DomesticController.m
//  OmniSDKDemo
//
//  Created by 程小康 on 2023/2/9.
//  金山通行证接入代码示例 (OmniSDKChannel=kspassport)

#import "KSPassportController.h"

@interface KSPassportController ()

@end

@implementation KSPassportController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.items = @[
        @{@"登录":NSStringFromSelector(@selector(login))},
        @{@"登出":NSStringFromSelector(@selector(logout))},
        @{@"支付":NSStringFromSelector(@selector(pay))},
        @{@"用户信息":NSStringFromSelector(@selector(getUserInfo))},
        @{@"注销账号":NSStringFromSelector(@selector(deleteAccount))},
        @{@"用户中心":NSStringFromSelector(@selector(openUserInfo))},
        @{@"预加载广告":NSStringFromSelector(@selector(preLoadAD))},
        @{@"显示广告":NSStringFromSelector(@selector(showAD))},
        @{@"分享":NSStringFromSelector(@selector(share))}
    ];
    [self initSDK];
}

//初始化
- (void)initSDK{
    OmniSDKOptions *options = [[OmniSDKOptions alloc] init];
    options.delegate = self;
    [[OmniSDKv3 shared] startWithOptions:options];
}

//登录
- (void)login{
    [[OmniSDKv3 shared] loginWithController:self options:nil];
}

//登出
- (void)logout{
    if (!self.isLogin) {
        [self.console updateLogWithLevel:INFO message:@"未登录"];
        return;
    }
    [[OmniSDKv3 shared] logout];
}

//支付
- (void)pay{
    if (!self.isLogin) {
        [Utils showAlertWithContrller:self msg:@"请先登录"];
        return;
    }
    
    [self selectProduct:^(NSString * _Nonnull productPrice, NSString * _Nonnull paidPrice) {
        [self payWithProductPrice:productPrice paidPrice:paidPrice];
    }];
}

- (void)payWithProductPrice:(NSString *)productPrice paidPrice:(NSString *)paidPrice{
    NSString *productID = [NSString stringWithFormat:@"omniDemo.product%@",productPrice];
    CGFloat totalAmount = paidPrice.floatValue;
    NSString *productDes = [NSString stringWithFormat:@"充值%@元获得%ld钻石", productPrice,productPrice.integerValue * 10];
    NSString *productName = [NSString stringWithFormat:@"%ld钻石", productPrice.integerValue * 10];

    OmniSDKPurchaseOptions *options = [self purchaseOptionsWith:productID totalAmount:totalAmount productDes:productDes productName:productName];
    [[OmniSDKv3 shared] purchaseWithOptions:options];
}

//获取用户信息
- (void)getUserInfo{
    if (!self.isLogin){
        [Utils showAlertWithContrller:self msg:@"请先登录"];
        return;
    }
    OmniSDKLoginInfo *info = [[OmniSDKv3 shared] getLoginInfo];
    NSString *msg = [NSString stringWithFormat:@"userId = %@, token = %@", info.userId, info.token];
    [self logCallBack:@"获取用户信息" msg:msg];
}

//注销账号
- (void)deleteAccount{
    [[OmniSDKv3 shared] deleteAccountWithOptions:nil];
}

//用户中心
- (void)openUserInfo{
    [[OmniSDKv3 shared] openAccountCenterWithController:self];
}

// 分享
- (void)share{
//    NSURL *serverUrl = [NSURL URLWithString:@"https://static.runoob.com/images/demo/demo2.jpg"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sharePicture.png" ofType:nil];
    NSURL *localUrl = [NSURL fileURLWithPath:path];
    OmniSDKSocialShareOptions *opt = [[OmniSDKSocialShareOptions alloc] init];
    opt.linkUrl = localUrl;
    opt.text = @"我是测试内容";
    opt.platform = OmniSDKSocialSharePlatformSystem;
    [[OmniSDKv3 shared] socialShareWithController:self options:opt];
}

// 预加载广告
- (void)preLoadAD{
    OmniSDKAdOptions *option = [[OmniSDKAdOptions alloc] init];
    option.placementId = @"test_ios_RV_1";
    [[OmniSDKv3 shared] preloadAdWithController:self options:option callback:^(OmniSDKPreloadAdResult * _Nullable result, OmniSDKError * _Nullable error) {
        if (error != nil) {
            // 失败
            NSInteger code = error.code; // 错误码
            NSString *message = error.message; // 错误信息
            NSString *detailMessage = error.description; // 错误详细信息
            [self logCallBack:@"预加载广告失败" msg:message];
            return;
        }
        NSString *placementId = result.placementId;
        [self logCallBack:@"预加载广告" msg:placementId];
    }];
}

// 显示广告
- (void)showAD{
    OmniSDKAdOptions *option = [[OmniSDKAdOptions alloc] init];
    option.placementId = @"test_ios_RV_1";
    [[OmniSDKv3 shared] showAdWithController:self options:option callback:^(OmniSDKShowAdResult * _Nullable result, OmniSDKError * _Nullable error) {
        if (error != nil) {
            // 失败
            NSInteger code = error.code; // 错误码
            NSString *message = error.message; // 错误信息
            NSString *detailMessage = error.description; // 错误详细信息
            [self logCallBack:@"显示广告失败" msg:message];
            return;
        }
        OmniSDKShowAdStatus status = result.status;
        NSString *adToken = result.token;
        NSString *str = [NSString stringWithFormat:@"广告显示状态=%d token=%@", status, adToken];
        [self logCallBack:@"显示广告成功" msg:str];
    }];
}

#pragma mark - Other Function

- (OmniSDKPurchaseOptions *)purchaseOptionsWith:(NSString *)productID totalAmount:(CGFloat)totalAmount productDes:(NSString *)productDes productName:(NSString *)productName{
    OmniSDKPurchaseOptions *options = [[OmniSDKPurchaseOptions alloc] init];
    options.productId = productID;
    options.productName = productName;
    options.productDesc = productDes;
    options.productUnitPrice = totalAmount;
    options.purchaseAmount = totalAmount;
    options.purchaseQuantity = 1;
    options.purchaseCallbackUrl = @"https://a2.xgsdk.seayoo.com/mock/recharge/notify";
    options.gameOrderId = [Utils getCurrentTimes];
    options.gameCurrencyUnit = @"魔石";
    options.gameRoleId = @"123";
    options.gameRoleName = @"小王";
    options.gameRoleLevel = @"99";
    options.gameRoleVipLevel = @"v8";
    options.gameZoneId = @"1区";
    options.gameServerId = @"8服";
    options.extJson = @"";
    self.purchaseOptions = options;
    return options;
}

@end

