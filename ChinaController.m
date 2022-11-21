//
//  ChinaController.m
//  OmniSDKDemo
//
//  Created by 程小康 on 2022/7/26.
//

#import "ChinaController.h"
#import <OmniAPI/OmniAPI-Swift.h>

@interface ChinaController ()<OmniSDKCallBackDelegate>

@end

@implementation ChinaController

{
    UIButton *payBtn;
    UIButton *payBtn2;
    UITextView *textView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSDK];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self addLogConsole];
    LogUtil.logClosure = ^(NSString * _Nonnull str) {
        NSString *log = self -> textView.text;
        log = [log stringByAppendingFormat:@"\n--------%@---------\n",[self currentTime]];
        log = [log stringByAppendingString:str];
        self->textView.text = log;
        NSLog(@"%@",str);
        self -> textView.layoutManager.allowsNonContiguousLayout = NO;
        [self -> textView scrollRangeToVisible: NSMakeRange(log.length + 90, 1)];
    };
    
    
    [self addSubViews];
}

//初始化
- (void)initSDK{

    [[OmniSDK shared] sdkInitializeWithDelegate:self];
    
}
//登录
- (void)login:(UIButton *)btn{
    [OmniSDK.shared accountLogin:@"" :self];
    
}
//登出
- (void)logout{
    
    [OmniSDK.shared accountLogout];
}
//支付
- (void)pay:(UIButton *)btn{
    NSString *productID;
    CGFloat totalAmount;
    NSString *productDes;
    if (btn.tag == 1) {
        productID = @"omniDemo.product6";
        totalAmount = 600;
        productDes = @"60钻石";
    }else{
        productID = @"omniDemo.product30";
        totalAmount = 3000;
        productDes = @"300钻石";
    }
    
    NSDictionary *dict = @{
        @"roleId":@"123",
        @"serverId" : @"123",
        @"gameCallbackUrl" : @"https://api.seayoo.io/omni/pout/test/cp_notify_ok",
        @"productId" : productID,
        @"productDesc" : productDes,
        @"gameTradeNo" : [self getCurrentTimes],
        @"totalAmount" : @(totalAmount),
        @"paidAmount" : @(totalAmount),
        @"productQuantity" : @(1),
        @"zoneId" : @"1服",
        @"roleName" : @"王宝强",
        @"roleLevel" : @"1",
        @"roleVipLevel" : @"10",
        @"productName" : @"钻石",
        @"productUnit" : @"元",
        @"productUnitPrice" : @(totalAmount),
    };
    
    NSString *json = [self converDictToJsonString:dict];
    
    
    [OmniSDK.shared pay:json];
    
}



#pragma mark - 回调代理


- (void)onInitNotifierSuccess {
    NSString *str = [NSString stringWithFormat:@"OmniSDK回调:%s",__func__];
    [LogUtil postLog:str];
    [self login:nil];
}

- (void)onInitNotifierFailureWithResult:(NSString *)result{
    [LogUtil postLog:result];
}

//账号相关回调
- (void)onAccountBindCancel{
    NSString *str = [NSString stringWithFormat:@"OmniSDK回调:%s",__func__];
    [LogUtil postLog:str];
}


- (void)onAccountBindFailureWithResult:(NSString * _Nonnull)result {
    [LogUtil postLog:result];
}


- (void)onAccountBindSuccess {
//    [LogUtil postLog:result];
}


- (void)onAccountDeleteFailureWithResult:(NSString * _Nonnull)result {
    [LogUtil postLog:result];
}


- (void)onAccountDeleteSuccess {
    
}


- (void)onAccountKickedOutWithResult:(BOOL)result {
    NSString *user = [[OmniSDK shared] getUserInfo];
    [LogUtil postLog:user];
}

#pragma mark - 登录
- (void)onAccountLoginCancel {
    NSString *str = [NSString stringWithFormat:@"OmniSDK回调:%s",__func__];
    [LogUtil postLog:str];
}


- (void)onAccountLoginSuccess {
    payBtn.hidden = NO;
    payBtn2.hidden = NO;
    NSString *str = [NSString stringWithFormat:@"OmniSDK回调:%s",__func__];
    [LogUtil postLog:str];
    NSString *a = [[OmniSDK shared] getUserInfo];
    [LogUtil postLog:a];
    
    [self enterGame];
    [self createRole];
}

- (void)onAccountLoginFailureWithResult:(NSString *)result{
    NSString *str = [NSString stringWithFormat:@"OmniSDK回调:%s",__func__];
    [LogUtil postLog:str];
    [LogUtil postLog:result];
}


- (void)onAccountLogoutCancel {
    NSString *str = [NSString stringWithFormat:@"OmniSDK回调:%s",__func__];
    [LogUtil postLog:str];
}

#pragma mark - 支付
- (void)onPaySuccessWithResult:(NSString *)result{
    NSString *str = [NSString stringWithFormat:@"OmniSDK回调:%s",__func__];
    [LogUtil postLog:str];
    [LogUtil postLog:result];
    
    NSString *orderID = [self convertJsonStringToDict:result][@"order"][@"orderId"];
    
    NSString *userInfoJson = [OmniSDK.shared getUserInfo];
    NSDictionary *userDict = [self convertJsonStringToDict:userInfoJson];
    NSString *uid = userDict[@"uid"];
    
    NSDictionary *payInfo = @{
        @"uid": uid,
        @"productId": @"omniDemo.product6",
        @"productName": @"钻石",
        @"productDesc": @"60钻石",
        @"productUnit": @"元",
        @"productUnitPrice": @(6.0),
        @"productQuantity": @(1),
        @"totalAmount": @(6.0),
        @"payAmount": @(6.0),
        @"currencyName": @"CNY",
        @"roleId": @"123",
        @"roleName": @"王宝强",
        @"roleLevel": @"1",
        @"roleVipLevel": @"1",
        @"serverId": @"11",
        @"zoneId": @"22",
        @"partyName": @"斧头帮",
        @"virtualCurrencyBalance": @"999",
        @"customInfo": @"",
        @"gameTradeNo": [self getCurrentTimes],
        @"paymentTypeName": @"Apple",
        @"additionalParams": @"",
        @"platTradeNo": orderID
    };
    NSString *json = [self converDictToJsonString:payInfo];
    [OmniSDK.shared statisticsGameShippedFinish:json];
    [OmniSDK.shared statisticsPaidReportWithVolume:json];
    
}

- (void)onPayFailureWithResult:(NSString *)result{
    NSString *str = [NSString stringWithFormat:@"OmniSDK回调:%s",__func__];
    [LogUtil postLog:str];
    [LogUtil postLog:result];
}

- (void)onPayCancelWithResult:(NSString *)result{
    NSString *str = [NSString stringWithFormat:@"OmniSDK回调:%s",__func__];
    [LogUtil postLog:str];
    [LogUtil postLog:result];
}

#pragma mark - 登出
- (void)onAccountLogoutSuccess {
    payBtn.hidden = YES;
    payBtn2.hidden = YES;
    NSString *str = [NSString stringWithFormat:@"OmniSDK回调:%s",__func__];
    [LogUtil postLog:str];
}

- (void)onAccountLogoutFailureWithResult:(NSString * _Nonnull)result {
    NSString *str = [NSString stringWithFormat:@"OmniSDK回调:%s",__func__];
    [LogUtil postLog:str];
}




#pragma mark - 分享
- (void)onSocialShareCancel {
    NSString *str = [NSString stringWithFormat:@"OmniSDK回调:%s",__func__];
    [LogUtil postLog:str];
}


- (void)onSocialShareFailureWithResult:(NSString * _Nonnull)result {
    [LogUtil postLog:result];
}


- (void)onSocialShareSuccess {
    NSString *str = [NSString stringWithFormat:@"OmniSDK回调:%s",__func__];
    [LogUtil postLog:str];
}


- (void)copyLog{
    UIPasteboard.generalPasteboard.string = textView.text;
}

- (void)clearLog{
    textView.text = @"";
}

- (void)getUserInfo{
    NSString *json = [OmniSDK.shared getUserInfo];
    [LogUtil postLog:json];
}

- (void)enterGame{
    NSDictionary *dict = @{
        @"uid":@"123",
        @"roleId":@"123",
        @"roleType":@"射手",
        @"roleLevel":@"4",
        @"roleVipLevel":@"3",
        @"serverId":@"1",
        @"zoneId":@"1",
        @"roleName":@"刘666",
        @"serverName":@"武汉区",
        @"zoneName":@"华中",
        @"partyName":@"华中一",
        @"gender":@"m",
        @"balance":@"10",
        @"ageInGame":@"12",
        @"accountAgeInGame":@"22",
        @"roleFigure":@"fat",
        @"ext":@""
    };
    NSString *json = [self converDictToJsonString:dict];
    [OmniSDK.shared onEnterGame:json];
    
}

- (void)createRole{
    NSDictionary *dict = @{
        @"uid":@"123",
        @"roleId":@"123",
        @"roleType":@"射手",
        @"roleLevel":@"4",
        @"roleVipLevel":@"3",
        @"serverId":@"1",
        @"zoneId":@"1",
        @"roleName":@"刘666",
        @"serverName":@"武汉区",
        @"zoneName":@"华中",
        @"partyName":@"华中一",
        @"gender":@"m",
        @"balance":@"10",
        @"ageInGame":@"12",
        @"accountAgeInGame":@"22",
        @"roleFigure":@"fat",
        @"ext":@""
    };
    NSString *json = [self converDictToJsonString:dict];
    [OmniSDK.shared onCreateRole:json];
}

- (void)checkOrderCount{
    [NSNotificationCenter.defaultCenter postNotificationName:@"queryOrderList" object:nil];
}

- (void)addSubViews{
    UIButton *guestLogin = [self addNewButton:@"登录" tag:0 sel:@selector(login:) relative:self.view column:1];
    
    UIButton *logout = [self addNewButton:@"登出" tag:0 sel:@selector(logout) relative:guestLogin column:1];
    payBtn = [self addNewButton:@"支付6元" tag:1 sel:@selector(pay:) relative:logout column:1];
    payBtn.hidden = YES;
    
    payBtn2 = [self addNewButton:@"支付30元" tag:2 sel:@selector(pay:) relative:payBtn column:1];
    payBtn2.hidden = YES;
    
    UIButton *userInfo = [self addNewButton:@"用户信息" tag:0 sel:@selector(getUserInfo) relative:payBtn2 column:1];
    UIButton *enterGame = [self addNewButton:@"进入游戏" tag:0 sel:@selector(enterGame) relative:userInfo column:1];
    
    UIButton *createRole = [self addNewButton:@"创建角色" tag:0 sel:@selector(createRole) relative:self.view column:2];
    UIButton *copyLog = [self addNewButton:@"复制日志" tag:0 sel:@selector(copyLog) relative:createRole column:2];
    UIButton *clearLog = [self addNewButton:@"清空日志" tag:0 sel:@selector(clearLog) relative:copyLog column:2];
    
}

- (UIButton *)addNewButton:(NSString *)title tag:(NSInteger)tag sel:(SEL)selector relative:(UIView *)relative column:(NSInteger)column{
    CGFloat width = 90;
    CGFloat height = 40;
    CGFloat x = 44 + 110*(column - 1);
    CGFloat y = 20 + ([relative isKindOfClass:[UIButton class]] ? CGRectGetMaxY(relative.frame) : 0);
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.numberOfLines = 0;
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    btn.backgroundColor = [UIColor yellowColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn.tag = tag;
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
    
}

-(NSString*)getCurrentTimes{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    
    NSTimeInterval a=[dat timeIntervalSince1970];
    
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    
    return timeString;
}

- (NSString *)currentTime{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"HH:mm:ss";
    return  [format stringFromDate:[NSDate date]];
}

- (void)addLogConsole{
    CGFloat width = 250;
    CGFloat height = UIScreen.mainScreen.bounds.size.height;
    CGFloat x = UIScreen.mainScreen.bounds.size.width - width - 44;
    textView = [[UITextView alloc] initWithFrame:CGRectMake(x, 0, width, height)];
    textView.editable = NO;
    textView.textColor = [UIColor blackColor];
    [self.view addSubview:textView];
}

- (NSString *)converDictToJsonString:(NSDictionary *)dict{
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingFragmentsAllowed error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

- (NSDictionary *)convertJsonStringToDict:(NSString *)json{
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
}

@end
