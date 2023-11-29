//
//  BaseController.m
//  OmniSDKDemo
//
//  Created by 程小康 on 2023/2/9.
//

#import "BaseController.h"

#define kOmniSDKServerUrl @"OmniSDKServerUrl"
#define kCellBackgroundColor [UIColor colorWithRed:95/255.0 green:175/255.0 blue:135/255.0 alpha:1.0]

typedef void (^DidSelectIndexBlock)(NSInteger);

@interface BaseController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation BaseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self addLogConsole];
    [self addButtonContainerView];
    [self addVersionLabel];
    self.roleLevel = 1;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self getStatusBarHeight];
    [self setTableViewLayout];
    [self setCollectionViewLayout];
    [self setConsoleLayout];
    [self setVersionLayout];
}

#pragma mark - OmniSDKDelegate

- (void)onStartWithResult:(OmniSDKStartResult *)result error:(OmniSDKError *)error {
    NSString *msg = [NSString stringWithFormat:@"appId=%@, planId=%@, sdkVersion=%@", result.appId, result.planId, result.sdkVersion];
    [self logResultWithOperation:@"V3初始化" message:msg error:error];
}

- (void)onLoginWithResult:(OmniSDKLoginResult *)result error:(OmniSDKError *)error {
    
    NSString *msg = [NSString stringWithFormat:@"userId = %@", result.loginInfo.userId];
    [self logResultWithOperation:@"登录" message:msg error:error];
    
    if (error != nil) {
        // 失败
        NSInteger code = error.code; // 错误码
        NSString *message = error.message; // 错误信息
        NSString *detailMessage = error.description; // 错误详细信息
        if (code == OmniSDKErrorCodeUserCancelled) {
            NSLog(@"canceled");
        }
        return;
    }
    
    // 成功（根据实际需求取 result 中的参数）
    NSString *userId = result.loginInfo.userId; // 用户ID
    NSString *token = result.loginInfo.token; // 用户令牌
    NSString *channelId = result.loginInfo.channelId; // 渠道ID
    NSString *signature = result.loginInfo.signature; // 签名
}

- (void)onLogoutWithResult:(OmniSDKLogoutResult *)result error:(OmniSDKError *)error {
    [self logResultWithOperation:@"登出" message:result.userId error:error];
}

- (void)onLinkAccountWithResult:(OmniSDKLinkAccountResult *)result error:(OmniSDKError *)error {
    [self logResultWithOperation:@"关联账号" message:[NSString stringWithFormat:@"%@", result.idps] error:error];
}

- (void)onDeleteAccountWithResult:(OmniSDKDeleteAccountResult *)result error:(OmniSDKError *)error {
    [self logResultWithOperation:@"删除账号" message:result.userId error:error];
}

- (void)onRestoreAccountWithResult:(OmniSDKRestoreAccountResult *)result error:(OmniSDKError *)error {
    [self logResultWithOperation:@"撤销删除账号" message:result.userId error:error];
}

- (void)onPurchaseWithResult:(OmniSDKPurchaseResult *)result error:(OmniSDKError *)error {
    
    [self logResultWithOperation:@"应用内购买" message:result.orderId error:error];
    
    if (error != nil) {
        // 失败
        NSInteger code = error.code; // 错误码
        NSString *message = error.message; // 错误信息
        NSString *detailMessage = error.description; // 错误详细信息
        if (code == OmniSDKErrorCodeUserCancelled) {
            NSLog(@"取消支付");
        }
        return;
    }
    
    // 成功(根据实际需求取 result 中参数)
    NSString *sdkOrderId = result.orderId; // SDK订单ID
    NSString *gameOrderId = result.purchaseInfo.gameOrderId; // 游戏订单ID
    NSString *productId = result.purchaseInfo.productId; // 商品ID
    
    // 游戏内发货成功后调用以下事件
    [self trackPurchaseEvent: sdkOrderId];
}

- (void)onSocialShareWithResult:(OmniSDKSocialShareResult *)result error:(OmniSDKError *)error {
    [self logResultWithOperation:@"社交分享" message:result.options.linkUrl.absoluteString error:error];
}

- (void)onCollectLogRecordWithResult:(OmniSDKLogRecord *)result {
    [self.console updateLogWithLevel:result.level message:result.msg];
}

- (void)logResultWithOperation:(NSString *)opt message:(NSString *)msg error:(OmniSDKError *)error{
    if (error == nil) {
        [self logCallBack:[NSString stringWithFormat:@"%@成功", opt] msg:msg];
    } else {
        [self logCallBack:[NSString stringWithFormat:@"%@失败", opt] msg:error.message];
    }
}

#pragma mark - Other Function
- (void) trackPurchaseEvent: (NSString *) orderId{
    OmniSDKPurchaseEvent *event = [[OmniSDKPurchaseEvent alloc] init];
    event.orderId = orderId;
    event.purchase = self.purchaseOptions;
    event.userId = [OmniSDKv3.shared getLoginInfo].userId;
    [OmniSDKv3.shared trackEventWithEvent:event];
}

- (void)getStatusBarHeight {
    self.statusBarHeight = 0.0;
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        self.statusBarHeight = window.safeAreaInsets.top;
    }
}

- (void)addButtonContainerView {
    UIView *selectedView = [Utils isLandScape] ? self.tableView : self.collectionView;
    [self.view addSubview:selectedView];
}

- (void)addVersionLabel {
    self.version = [[UILabel alloc] initWithFrame:CGRectZero];
    NSMutableString *labelContent = [NSMutableString stringWithString:@"version:"];
    [labelContent appendString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    self.version.text = labelContent;
    self.version.font = [UIFont systemFontOfSize: 15];
    [self.version sizeToFit];
    self.version.textColor = [UIColor blackColor];
    [self.view addSubview: self.version];
}

- (void)setItems:(NSArray *)items {
    NSDictionary *enterGame = @{@"进入游戏":NSStringFromSelector(@selector(enterGame))};
    NSDictionary *createRole = @{@"创建角色":NSStringFromSelector(@selector(createRole))};
    NSDictionary *roleLevelUp = @{@"角色升级":NSStringFromSelector(@selector(roleLevelUp))};
    NSDictionary *copyLog = @{@"复制日志":NSStringFromSelector(@selector(copyLog))};
    NSDictionary *clearLog = @{@"清空日志":NSStringFromSelector(@selector(clearLog))};
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:items];
    [arr addObject:enterGame];
    [arr addObject:createRole];
    [arr addObject:roleLevelUp];
    [arr addObject:copyLog];
    [arr addObject:clearLog];
    _items = arr;
}

- (void)selectProduct:(SelectProductBlock)complete{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请输入支付信息" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"商品ID (6,30,98,198,328,648)";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"支付金额";
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *productPrice = alert.textFields.firstObject.text;
        NSString *paidPrice = alert.textFields.lastObject.text;
        NSString *rex = @"^[-\\d]\\d*";
        NSPredicate *re = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", rex];
        if (![re evaluateWithObject:paidPrice] || productPrice.length == 0){
            [Utils showAlertWithContrller:self msg:@"参数错误,请重新输入"];
            return;
        }
        complete(productPrice, paidPrice);
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)logCallBack:(NSString *)cb msg:(NSString *)msg{
    NSString *formatMsg = [NSString stringWithFormat:@"caller=SDK回调(%@) label=Demo ", cb];
    if (msg.length != 0) {
        formatMsg = [formatMsg stringByAppendingFormat:@"result=%@", msg];
    }
    NSLog(@"%@",formatMsg);
    [self.console updateLogWithLevel:INFO message:formatMsg];
}

- (BOOL)isLogin{
    OmniSDKLoginInfo *loginInfo = [OmniSDKv3 shared].getLoginInfo;
    return loginInfo.userId.length != 0 && loginInfo.userId.length != 1;
}

//进入游戏
- (void)enterGame{
    OmniSDKEnterGameEvent *event = [[OmniSDKEnterGameEvent alloc] init];
    event.roleInfo = [self testRoleInfo: @"1"];
    [[OmniSDKv3 shared] trackEventWithEvent:event];
}

//创建角色
- (void)createRole{
    OmniSDKCreateRoleEvent *event = [[OmniSDKCreateRoleEvent alloc] init];
    event.roleInfo = [self testRoleInfo: @"1"];
    [[OmniSDKv3 shared] trackEventWithEvent:event];
}

//角色升级
- (void)roleLevelUp{
    OmniSDKRoleLevelUpEvent *event = [[OmniSDKRoleLevelUpEvent alloc] init];
    NSString *level = [NSString stringWithFormat:@"%li", ++self.roleLevel];
    event.roleInfo = [self testRoleInfo: level];
    [[OmniSDKv3 shared] trackEventWithEvent:event];
}

- (void)clearLog{
    [self.console clearLog];
}

- (void)copyLog{
    UIPasteboard.generalPasteboard.string = self.console.textView.text;
}

- (OmniSDKRoleInfo *)testRoleInfo: (NSString *)level {
    OmniSDKRoleInfo *role = [[OmniSDKRoleInfo alloc] init];
    role.userId = @"123";
    role.gameRoleId = @"11";
    role.gameRoleName = @"小王";
    role.gameRoleLevel = level;
    role.gameRoleVipLevel = @"v8";
    role.gameServerName = @"1服";
    role.gameServerId = @"8区";
    role.extJson = @"";
    return role;
}

- (UITableView *)tableView{
    if(_tableView == nil){
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.layer.cornerRadius = 5;
        _tableView.separatorColor = [UIColor whiteColor];
        _tableView.backgroundColor = [UIColor whiteColor];
    }
    return _tableView;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
        CGFloat collectionViewWidth = UIScreen.mainScreen.bounds.size.width - 20;
        CGFloat minimumInteritemSpacing = 1;
        CGFloat minimumLineSpacing = 1;
        NSInteger numberOfItemsPerRow = 3;
        CGFloat itemWidth = (collectionViewWidth - (minimumInteritemSpacing * (numberOfItemsPerRow - 1))) / numberOfItemsPerRow - 1;
        CGFloat itemHeight = 50;
        CGFloat cornerRadius = 5;
        
        layout.itemSize = CGSizeMake(itemWidth, itemHeight);
        layout.minimumInteritemSpacing = minimumInteritemSpacing;
        layout.minimumLineSpacing = minimumLineSpacing;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.layer.cornerRadius = cornerRadius;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"default"];
    }
    return _collectionView;
}

- (void)addLogConsole {
    self.console = [[ConsoleView alloc] init];
    [self.view addSubview:self.console];
}

- (void)setConsoleLayout {
    BOOL isLandscape = [Utils isLandScape];
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    CGFloat screenHeight = UIScreen.mainScreen.bounds.size.height;
    CGFloat lanscapeX = CGRectGetMaxX(self.tableView.frame) + 10;
    CGFloat lanscapeY = 0;
    CGFloat portraitX = 10;
    CGFloat portraitY = CGRectGetMaxY(self.collectionView.frame) + 10;
    CGFloat width = isLandscape ? screenWidth - lanscapeX : screenWidth - 20;
    CGFloat height = isLandscape ? screenHeight : screenHeight - (210 + self.statusBarHeight);

    CGRect consoleFrame;
    if (isLandscape) {
        consoleFrame = CGRectMake(lanscapeX, lanscapeY, width, height);
    } else {
        consoleFrame = CGRectMake(portraitX, portraitY, width, height);
    }
    self.console.frame = consoleFrame;
}

- (void)setVersionLayout {
    CGFloat kLabelTopMargin = [Utils isLandScape] ? 8.0 : self.statusBarHeight;
    CGFloat kLabelRightMargin = 15.0;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGRect versionFrame = self.version.frame;
    versionFrame.origin.x = screenWidth - self.version.frame.size.width - kLabelRightMargin;
    versionFrame.origin.y = kLabelTopMargin;
    self.version.frame = versionFrame;
}

- (void)setTableViewLayout {
    self.tableView.frame = CGRectMake(44, 10, 180, UIScreen.mainScreen.bounds.size.height - 20);
}

- (void)setCollectionViewLayout {
    self.collectionView.frame = CGRectMake(10, self.statusBarHeight + 20, UIScreen.mainScreen.bounds.size.width - 20, 150);
}

#pragma mark - UITableViewDataSource，UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    static NSString *identifier = @"default";
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = kCellBackgroundColor;
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
        cell.selectedBackgroundView.backgroundColor = [UIColor lightGrayColor];
    }
    NSDictionary *d = self.items[indexPath.row];
    cell.textLabel.text = d.allKeys.firstObject;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *d = self.items[indexPath.row];
    NSString *method = d.allValues.firstObject;
    [self performSelector:NSSelectorFromString(method)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"default";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSDictionary *d = self.items[indexPath.row];
    
    cell.contentView.backgroundColor = kCellBackgroundColor;
    
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = cell.contentView.bounds;
    label.textColor = [UIColor whiteColor];
    label.text = d.allKeys.firstObject;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:15];
    label.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:label];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
    selectedCell.contentView.backgroundColor = [UIColor lightGrayColor];
    [UIView animateWithDuration: 0.5 animations:^{
        selectedCell.contentView.backgroundColor = kCellBackgroundColor;
    }];
    NSDictionary *d = self.items[indexPath.row];
    NSString *method = d.allValues.firstObject;
    [self performSelector:NSSelectorFromString(method)];
}

@end
