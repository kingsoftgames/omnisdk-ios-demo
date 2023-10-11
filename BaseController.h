//
//  BaseController.h
//  OmniSDKDemo
//
//  Created by 程小康 on 2023/2/9.
//

#import <UIKit/UIKit.h>
#import <OmniAPI/OmniAPI-Swift.h>
#import "ConsoleView.h"
#import "Utils.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^SelectProductBlock)(NSString* productPrice, NSString *paidPrice);
@interface BaseController : UIViewController<OmniSDKCallBackDelegate>
@property (nonatomic, strong) ConsoleView *console;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *version;
@property (nonatomic, assign) CGFloat statusBarHeight;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, copy) NSString *testUserInfo;
@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, strong) OmniSDKPurchaseOptions *purchaseOptions;
@property (nonatomic, assign) NSInteger roleLevel;

- (void)logCallBack:(NSString *)cb msg:(NSString *)msg;
- (void)copyLog;
- (void)sentryCrash;
- (void)clearLog;
- (void)selectProduct: (SelectProductBlock) complete;
- (void)removeCache;

@end

NS_ASSUME_NONNULL_END
