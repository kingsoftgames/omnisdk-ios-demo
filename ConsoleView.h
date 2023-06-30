//
//  ConsoleView.h
//  OmniSDKDemo
//
//  Created by 程小康 on 2023/2/8.
//

#import <UIKit/UIKit.h>
#define INFO @"info"
#define WARNING @"warning"
#define ERROR @"error"
NS_ASSUME_NONNULL_BEGIN

@interface ConsoleView : UIView
@property (nonatomic, strong) UISegmentedControl *sgView;
@property (nonatomic, strong) UITextView *textView;
- (void)updateLogWithLevel:(NSString *)level message:(NSString *)str;
- (void)clearLog;
@end

NS_ASSUME_NONNULL_END
