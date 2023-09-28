//
//  DomesticController.m
//  OmniSDKDemo
//
//  Created by 程小康 on 2023/2/9.
//

#import "DomesticController.h"

#define kProdHostUrl @"https://a2.xgsdk.seayoo.com"

@interface DomesticController ()

@end

@implementation DomesticController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.items = @[
        @{@"登录":NSStringFromSelector(@selector(login))},
        @{@"登出":NSStringFromSelector(@selector(logout))},
        @{@"支付":NSStringFromSelector(@selector(pay))},
        @{@"用户信息":NSStringFromSelector(@selector(getUserInfo))},
        @{@"进入游戏":NSStringFromSelector(@selector(enterGame))},
        @{@"创建角色":NSStringFromSelector(@selector(createRole))},
        @{@"注销账号":NSStringFromSelector(@selector(deleteAccount))},
        @{@"用户中心":NSStringFromSelector(@selector(openUserInfo))},
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

//进入游戏
- (void)enterGame{
    OmniSDKEnterGameEvent *event = [[OmniSDKEnterGameEvent alloc] init];
    event.roleInfo = [self roleInfo];
    [[OmniSDKv3 shared] trackEventWithEvent:event];
}

//创建角色
- (void)createRole{
    OmniSDKCreateRoleEvent *event = [[OmniSDKCreateRoleEvent alloc] init];
    event.roleInfo = [self roleInfo];
    [[OmniSDKv3 shared] trackEventWithEvent:event];
}

- (void)roleLevelUp{
    OmniSDKRoleLevelUpEvent *event = [[OmniSDKRoleLevelUpEvent alloc] init];
    event.roleInfo = [self roleInfo];
    [[OmniSDKv3 shared] trackEventWithEvent:event];
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

#pragma mark - Other Function

- (OmniSDKPurchaseOptions *)purchaseOptionsWith:(NSString *)productID totalAmount:(CGFloat)totalAmount productDes:(NSString *)productDes productName:(NSString *)productName{
    OmniSDKPurchaseOptions *options = [[OmniSDKPurchaseOptions alloc] init];
    options.productId = productID;
    options.productName = productName;
    options.productDesc = productDes;
    options.productUnitPrice = totalAmount;
    options.purchaseAmount = totalAmount;
    options.purchaseQuantity = 1;
    options.purchaseCallbackUrl = [self gameCallbackUrl];
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

- (OmniSDKRoleInfo *)roleInfo{
    OmniSDKRoleInfo *role = [[OmniSDKRoleInfo alloc] init];
    role.userId = @"123";
    role.gameRoleId = @"11";
    role.gameRoleName = @"小王";
    role.gameRoleLevel = @"4";
    role.gameRoleVipLevel = @"v8";
    role.gameServerName = @"1服";
    role.gameServerId = @"8区";
    role.extJson = @"";
    return role;
}

- (NSString *)gameCallbackUrl{
    NSString *sdkHostDomain = self.serverUrl == nil ? kProdHostUrl : self.serverUrl;
    NSString *gameCallbackUrl = [sdkHostDomain stringByAppendingString:@"/mock/recharge/notify"];
    return  gameCallbackUrl;
}

@end

