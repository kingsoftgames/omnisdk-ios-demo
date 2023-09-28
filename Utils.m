//
//  Tool.m
//  OmniSDKDemo
//
//  Created by 程小康 on 2023/3/3.
//

#import "Utils.h"
#include <CommonCrypto/CommonHMAC.h>

#define kOmniSDKRegion @"OmniSDKRegion"
#define kOmniSDKServerUrl @"OmniSDKServerUrl"

@implementation Utils

+ (NSString *)convertDictToJsonString:(NSDictionary *)dict{
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingFragmentsAllowed error:nil];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}

+ (NSDictionary *)convertJsonStringToDict:(NSString *)json{
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
}

+ (void)showAlertWithContrller:(UIViewController *)vc msg:(NSString *)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:ok];
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc presentViewController:alert animated:YES completion:nil];
    });
}

+ (NSString*)getCurrentTimes{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    return timeString;
}

+ (NSDictionary *)dictFromJsonFile:(NSString *)fileName{
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:urlStr];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error;
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingFragmentsAllowed error:&error];
}

+ (NSString *)signWithParams:(NSDictionary *)params key: (NSString *)key
{
    NSMutableString *signStr = [[NSMutableString alloc] init];   //签名串
    Boolean isFirst = YES;
    NSArray *sortedArray = [[params allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (id key in sortedArray) {
        id value = [params objectForKey:key];
        if (value == nil) {
            continue;
        }
        if (isFirst) {
            [signStr appendFormat:@"%@=%@", key, value];
            isFirst = NO;
        } else {
            [signStr appendFormat:@"&%@=%@", key, value];
        }
    }

    return [self hmacSha1: key text:signStr];
}

// Sign
+ (NSString *)hmacSha1:(NSString *)key text:(NSString *)text
{
    const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [text cStringUsingEncoding:NSUTF8StringEncoding];
    uint8_t cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSString *hash;
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", cHMAC[i]];
    }
    hash = output;
    return hash;
}

+ (void)removeCache {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths firstObject];
    NSString *filePath = [cachePath stringByAppendingPathComponent:@"com.seayoo.omnisdk"];
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    if (error) {
        NSLog(@"删除缓存失败: %@", error.localizedDescription);
    }
}

+ (Boolean)isLandScape{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return UIInterfaceOrientationIsLandscape(orientation);
}

+ (Boolean)isDomestic{
    return [[NSBundle mainBundle].infoDictionary[kOmniSDKRegion] isEqual:@"domestic"];
}

@end
