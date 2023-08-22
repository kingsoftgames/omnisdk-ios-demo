//
//  DomesticController.m
//  OmniSDKDemo
//
//  Created by 程小康 on 2023/2/9.
//

#import "DomesticController.h"

#define kDevHostUrl @"https://a2.xgsdk.dev.seayoo.com"
#define kProdHostUrl @"https://a2.xgsdk.seayoo.com"
#define kOmniSDKAppId @"OmniSDKAppId"

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
    options.toastEnabled = YES;
    options.toastDurationSeconds = 2;
    options.logCollectEnabled = YES;
    options.logFileEnabled = YES;
    options.storeKit2Enabled = NO;
    [[OmniSDK shared] sdkInitializeWithOptions:options delegate: self];
}

//登录
- (void)login{
    [OmniSDK.shared accountLogin:@"" :self];
}

//登出
- (void)logout{
    [OmniSDK.shared accountLogout];
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

    NSString *json = [self productWith:productID totalAmount:totalAmount productDes:productDes productName:productName];
    [OmniSDK.shared pay:json];
}

//获取用户信息
- (void)getUserInfo{
    if (!self.isLogin){
        [Utils showAlertWithContrller:self msg:@"请先登录"];
        return;
    }
    NSString *json = [OmniSDK.shared getUserInfo];
    [self logCallBack:@"获取用户信息" msg:json];
}

//进入游戏
- (void)enterGame{
    [OmniSDK.shared onEnterGame:self.testUserInfo];
}

//创建角色
- (void)createRole{
    [OmniSDK.shared onCreateRole:self.testUserInfo];
}

//注销账号
- (void)deleteAccount{
    [OmniSDK.shared accountDelete:@""];
}

//用户中心
- (void)openUserInfo{
    [OmniSDK.shared updateUserInfo:self];
}

// 分享
- (void)share{
//    NSURL *serverUrl = [NSURL URLWithString:@"https://static.runoob.com/images/demo/demo2.jpg"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sharePicture.png" ofType:nil];
    NSURL *localUrl = [NSURL fileURLWithPath:path];
    OmniSDKShareOptions *option = [[OmniSDKShareOptions alloc] initWithPlatform:PlatformSystem text:@"我是测试内容" url: localUrl];
    [[OmniSDK shared] socialShareWithOptions:option controller:self];
}

#pragma mark - Other Function

- (NSString *)productWith:(NSString *)productID totalAmount:(CGFloat)totalAmount productDes:(NSString *)productDes productName:(NSString *)productName{
    NSDictionary *dict = @{
        @"roleId":@"123",
        @"serverId" : @"123",
        @"gameCallbackUrl" : [self gameCallbackUrl],
        @"productId" : productID,
        @"productDesc" : productDes,
        @"gameTradeNo" : [Utils getCurrentTimes],
        @"totalAmount" : @(totalAmount),
        @"paidAmount" : @(totalAmount),
        @"productQuantity" : @(1),
        @"zoneId" : @"1服",
        @"roleName" : @"王宝强",
        @"roleLevel" : @"6",
        @"roleVipLevel" : @"11",
        @"productName" : productName,
        @"productUnit" : @"钻石",
        @"productUnitPrice" : @(totalAmount),
    };
    NSString *json = [Utils convertDictToJsonString:dict];
    return json;
}

- (NSString *)gameCallbackUrl{
    NSString *sdkHostDomain = [Utils isEqualWithServerUrl: kDevHostUrl] ? kDevHostUrl : kProdHostUrl;
    NSString *gameCallbackUrl = [sdkHostDomain stringByAppendingString:@"/mock/recharge/notify"];
    return  gameCallbackUrl;
}

@end
