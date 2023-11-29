//
//  ConsoleView.m
//  OmniSDKDemo
//
//  Created by 程小康 on 2023/2/8.
//

#import "ConsoleView.h"

@interface ConsoleView ()
@property (nonatomic, copy) NSString *allStr;
@property (nonatomic, copy) NSString *infoStr;
@property (nonatomic, copy) NSString *noticeStr;
@property (nonatomic, copy) NSString *waringStr;
@property (nonatomic, copy) NSString *errorStr;
@property (nonatomic, copy) NSString * currentLevel;
@end

@implementation ConsoleView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.allStr = @"";
    self.infoStr = @"";
    self.noticeStr = @"";
    self.waringStr = @"";
    self.errorStr = @"";
    self.currentLevel = @"0";
    [self addComponent];
    return self;
}

- (void)layoutSubviews {
    _textView.frame = CGRectMake(0, 35, self.bounds.size.width, self.bounds.size.height - 35);
}

- (void)addComponent{
    _sgView = [[UISegmentedControl alloc] initWithItems:@[@"All", @"Notice", @"Warning", @"Error"]];
    _sgView.selectedSegmentIndex = 0;
    _sgView.layer.borderWidth = 1;
    _sgView.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.sgView addTarget:self action:@selector(didClicksegmentedControlAction:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.sgView];
    
    _textView = [[UITextView alloc] init];
    _textView.editable = NO;
    _textView.backgroundColor = [UIColor blackColor];
    _textView.textColor = [UIColor whiteColor];
    _textView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    _textView.accessibilityIdentifier = @"ConsoleView";
    [self addSubview:_textView];
}

- (void)didClicksegmentedControlAction:(UISegmentedControl *)segmentedControl {
    NSInteger index = segmentedControl.selectedSegmentIndex;
    switch (index) {
        case 0:
            self.currentLevel = @"0";
            [self switchLevel];
            break;
        case 1:
            self.currentLevel = NOTICE;
            [self switchLevel];
            break;
        case 2:
            self.currentLevel = WARNING;
            [self switchLevel];
            break;
        case 3:
            self.currentLevel = ERROR;
            [self switchLevel];
            break;
    }
}

- (void)updateLogWithLevel:(NSString *)level message:(NSString *)str{
    NSString *mark = [self levelToMark:level];
    self.allStr = [self.allStr stringByAppendingFormat:@"\n%@%@",mark,str];
    if ([INFO isEqualToString:level]) {
        self.infoStr = [self.infoStr stringByAppendingFormat:@"\n%@%@",mark,str];
    }else if ([NOTICE isEqualToString:level]) {
        self.noticeStr = [self.noticeStr stringByAppendingFormat:@"\n%@%@",mark,str];
    }else if ([WARNING isEqualToString:level]){
        self.waringStr = [self.waringStr stringByAppendingFormat:@"\n%@%@",mark,str];
    }else{
        self.errorStr = [self.errorStr stringByAppendingFormat:@"\n%@%@",mark,str];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self switchLevel];
        self.textView.layoutManager.allowsNonContiguousLayout = NO;
        [self.textView scrollRangeToVisible: NSMakeRange(self.textView.text.length + 90, 1)];
    });
}

- (void)switchLevel{
    if ([@"0" isEqualToString:self.currentLevel]) {
        self.textView.text = self.allStr;
    }else if ([NOTICE isEqualToString:self.currentLevel]){
        self.textView.text = self.noticeStr;
    }else if ([WARNING isEqualToString:self.currentLevel]){
        self.textView.text = self.waringStr;
    }else {
        self.textView.text = self.errorStr;
    }
}

- (NSString *)levelToMark:(NSString *)level{
    if (@available(iOS 13, *)) {
        if ([INFO isEqualToString:level]){
            return @"🟢";
        }else if ([WARNING isEqualToString:level]){
            return @"🟡";
        }else if ([NOTICE isEqualToString:level]){
            return @"🟠";
        }else {
            return @"🔴";
        }
    }
    return @"";
}

- (void)clearLog{
    self.allStr = @"";
    self.infoStr = @"";
    self.waringStr = @"";
    self.errorStr = @"";
    [self switchLevel];
}

@end

