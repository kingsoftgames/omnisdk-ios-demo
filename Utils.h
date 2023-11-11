//
//  Tool.h
//  OmniSDKDemo
//
//  Created by 程小康 on 2023/3/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

typedef NS_ENUM(NSInteger, ChannelType) {
    Passport,
    Oversea,
    Seayoo
};

+ (NSString *)convertDictToJsonString:(NSDictionary *)dict;
+ (NSDictionary *)convertJsonStringToDict:(NSString *)json;
+ (void)showAlertWithContrller:(UIViewController *)vc msg:(NSString *)msg;
+ (NSString*)getCurrentTimes;
+ (NSDictionary *)dictFromJsonFile:(NSString *)fileName;
+ (NSString *)signWithParams:(NSDictionary *)params key: (NSString *)key;
+ (Boolean)isLandScape;
+ (NSDictionary *)getOmniSDKCache;
+ (void)removeCache;
+ (Boolean)isDomestic;
+ (ChannelType)getChannelType;
@end

NS_ASSUME_NONNULL_END
