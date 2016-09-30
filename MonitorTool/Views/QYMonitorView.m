//
//  QYMonitorView.m
//  MonitorTool
//
//  Created by liuming on 16/9/29.
//  Copyright © 2016年 burning. All rights reserved.
//

#import "QYMonitorView.h"
#import "QYMonitorItem.h"
#import "QYMonitorTool.h"
#import "NXSendMail.h"
#import "NXLogManager.h"
#define itemWidth 40.0f
#define itemHeight 40.0f

#define itemTitle @"title"
#define itemCategory @"itemCategory"
#define itemCanClicked @"itemCanClicked"
@interface QYMonitorView ()<QYMonitorToolDelegate>
@property(nonatomic, strong) UIView* contentView;
@property(nonatomic, strong) NSArray* monitors;
@property(nonatomic, assign) CGPoint oldPoint;
@property(nonatomic, strong) UIButton* btn;
@property(nonatomic, strong) QYMonitorTool* monitorTool;
@property(nonatomic, strong) NSMutableDictionary* mapDic;

@end
@implementation QYMonitorView

- (NSMutableDictionary*)mapDic
{
    if (_mapDic == nil)
    {
        _mapDic = [[NSMutableDictionary alloc] init];
    }

    return _mapDic;
}
- (QYMonitorTool*)monitorTool
{
    if (_monitorTool == nil)
    {
        _monitorTool = [[QYMonitorTool alloc] init];
        _monitorTool.delegate = self;
    }
    return _monitorTool;
}
- (double)screenHeight { return [UIScreen mainScreen].bounds.size.height; }
- (double)screenWidhth { return [UIScreen mainScreen].bounds.size.width; }
- (NSArray*)monitors
{
    if (_monitors == nil)
    {
        _monitors = @[
            @{ itemTitle : @"FPS",
               itemCategory : @(QYMonitorCategoryOfFPS),
               itemCanClicked : @(NO) },
            @{ itemTitle : @"CPU",
               itemCategory : @(QYMonitorCategoryOfCPU),
               itemCanClicked : @(NO) },
            @{ itemTitle : @"Memory",
               itemCategory : @(QYMonitorCategoryOfMemory),
               itemCanClicked : @(NO) },
            @{ itemTitle : @"Email",
               itemCategory : @(QYMonitorCategoryOfSendEmail),
               itemCanClicked : @(YES) },
        ];
    }
    return _monitors;
}
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initSubView];
        [self startMonitor];
    }

    return self;
}
- (void)initSubView
{
    self.clipsToBounds = YES;
    NSUInteger count = self.monitors.count;
    self.frame = CGRectMake(0, 100, itemWidth * (self.monitors.count + 1), itemHeight);
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor colorWithRed:0 / 255.0f green:0 blue:0 alpha:1];
    self.contentView =
        [[UIView alloc] initWithFrame:CGRectMake(itemWidth, 0, itemWidth * self.monitors.count, itemHeight)];
    self.contentView.clipsToBounds = YES;
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    scrollView.backgroundColor = [UIColor whiteColor];
    for (NSInteger i = 0; i < count; i++)
    {
        double r = (random() % 255) / 255.0f;
        double g = (random() % 255) / 255.0f;
        double b = (random() % 255) / 255.0f;
        UIColor* color = [UIColor colorWithRed:r green:g blue:b alpha:1];
        double x = i * itemWidth;
        QYMonitorItem* item = [[QYMonitorItem alloc] initWithFrame:CGRectMake(x, 0, itemWidth, itemHeight)];
        NSDictionary* configDic = [self.monitors objectAtIndex:i];
        [item setTitleString:[configDic objectForKey:itemTitle]];
        [item setDataString:@"0.0%"];
        item.backgroundColor = color;
        item.tag = [[configDic objectForKey:itemCategory] integerValue];
        if ([[configDic objectForKey:itemCanClicked] boolValue])
        {
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = item.tag;
            [button addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
            button.frame = item.bounds;
            [item addSubview:button];
        }
        [scrollView addSubview:item];
        [self.mapDic setObject:item forKey:[configDic objectForKey:itemCategory]];
    }
    double content_x = self.monitors.count * itemWidth;
    scrollView.contentSize = CGSizeMake(content_x, scrollView.contentOffset.y);
    [self.contentView addSubview:scrollView];
    [self addSubview:self.contentView];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, itemWidth, itemHeight);
    [button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"⚒" forState:UIControlStateNormal];
    [button setTitle:@"⚒" forState:UIControlStateHighlighted];
    button.selected = YES;
    button.backgroundColor = [UIColor redColor];
    self.btn = button;
    [self addSubview:button];
    //添加拖拽手势
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:pan];
}

- (void)startMonitor { [self.monitorTool startMonitor]; }
- (void)btnClicked:(UIButton*)sender
{
    //    [self changeCloseBtnTransform];
    if (sender.selected)
    {
        //关闭
        if ([self isRightBottom])
        {
            if ([self closeBtnIsRight])
            {
                //
                [self closeFromLeftToRight];
            }
            else
            {
                [self closeFromLeftToRight];
            }
        }
        else
        {
            if ([self closeBtnIsRight])
            {
                [self closeFromRightToLeft];
            }
            else
            {
                [self closeFromLeft];
            }
        }
    }
    else
    {
        //打开
        if ([self isRightBottom])
        {
            [self showFromRight];
        }
        else
        {
            [self showFromLeft];
        }
    }
    sender.selected = !sender.selected;
}
- (void)panAction:(UIPanGestureRecognizer*)pan
{
    if (pan.state == UIGestureRecognizerStateBegan)
    {
        self.oldPoint = [pan locationInView:[UIApplication sharedApplication].keyWindow];
    }
    if (pan.state == UIGestureRecognizerStateChanged)
    {
        [self moving:[pan locationInView:[UIApplication sharedApplication].keyWindow]];
    }
    if (pan.state == UIGestureRecognizerStateEnded)
    {
        [self endMove:[pan locationInView:[UIApplication sharedApplication].keyWindow]];
    }
}
- (void)moving:(CGPoint)point
{
    double width = self.frame.size.width;
    double height = self.frame.size.height;
    double dx = point.x - self.oldPoint.x;
    double dy = point.y - self.oldPoint.y;
    double tx = self.center.x + dx;
    double ty = self.center.y + dy;
    if (tx <= width / 2.0f)
    {
        tx = width / 2.0f;
    }
    if (([self screenWidhth] - tx) <= width / 2.0f)
    {
        tx = [self screenWidhth] - width / 2.0f;
    }

    if (ty - height / 2.0f <= 0)
    {
        ty = height / 2.0f;
    }
    if (([self screenHeight] - ty) <= height / 2.0f)
    {
        ty = [self screenHeight] - height / 2.0f;
    }
    self.center = CGPointMake(tx, ty);
    self.oldPoint = point;
}
- (void)endMove:(CGPoint)point
{
    //限定区间
    double x = 0;
    if (point.x > [self screenWidhth] / 2.0f)
    {
        //靠右
        x = [self screenWidhth] - self.frame.size.width;
    }
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.frame = CGRectMake(x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
                     }];
}
- (BOOL)isRightBottom { return (self.frame.size.width + self.frame.origin.x) >= [self screenWidhth]; }
- (BOOL)closeBtnIsRight
{
    return (self.btn.frame.size.width + self.btn.frame.origin.x) >= (itemWidth + 1) * self.monitors.count;
}
#pragma 所有动画方法

/**
 从左到右打开
 */
- (void)showFromLeft
{
    //靠左
    double x = itemWidth;
    double width = itemWidth * self.monitors.count;
    double sw = width + itemWidth;
    [UIView animateWithDuration:0.25
        animations:^{
            self.contentView.frame = CGRectMake(x, 0, width, itemHeight);
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, sw, itemHeight);
            self.btn.frame = CGRectMake(0, 0, itemWidth, itemHeight);
        }
        completion:^(BOOL finished){

        }];
}
/**
 从右到左打开
 */
- (void)showFromRight
{
    //靠右 向左打开
    double width = itemWidth * self.monitors.count;
    double sw = width + itemWidth;
    double x = [self screenWidhth] - sw;
    self.contentView.frame = CGRectMake(0, 0, width, itemHeight);
    [UIView animateWithDuration:0.25
        animations:^{
            self.frame = CGRectMake(x, self.frame.origin.y, sw, itemHeight);
            self.btn.frame = CGRectMake(width, 0, itemWidth, itemHeight);
        }
        completion:^(BOOL finished){
        }];
}
/**
   从左边开始关闭
 */
- (void)closeFromLeft
{
    //整体靠左 关闭按钮在左边
    double x = itemWidth;
    double selfWidth = itemWidth;
    [UIView animateWithDuration:0.25
        animations:^{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, selfWidth, itemHeight);
            self.btn.frame = CGRectMake(0, 0, itemWidth, itemHeight);
        }
        completion:^(BOOL finished) {
            self.contentView.frame = CGRectMake(x, 0, 0, itemHeight);
        }];
}

/**
 从右边开始关闭
 */
- (void)closeFromRight
{
    //整体靠右 关闭按钮在左边
    double x = [self screenWidhth] - itemWidth;
    double sw = itemWidth;
    [UIView animateWithDuration:0.25
        animations:^{
            self.frame = CGRectMake(x, self.frame.origin.y, sw, itemHeight);
            self.btn.frame = CGRectMake(0, 0, itemWidth, itemHeight);

        }
        completion:^(BOOL finished) {

            self.contentView.frame = CGRectMake(0, 0, sw, itemHeight);
        }];
}
/**
从左至右开始关闭
 */
- (void)closeFromLeftToRight
{
    //整体靠右 关闭按钮靠右边
    double x = [self screenWidhth] - itemWidth;
    double sw = itemWidth;
    [UIView animateWithDuration:0.25
        animations:^{

            self.frame = CGRectMake(x, self.frame.origin.y, sw, itemHeight);
            self.btn.frame = CGRectMake(0, 0, itemWidth, itemHeight);

        }
        completion:^(BOOL finished) {

            self.contentView.frame = CGRectMake(itemWidth, 0, 0, itemHeight);
        }];
}
/**
 从右到左开始关闭
 */
- (void)closeFromRightToLeft
{
    //整体靠左 关闭按钮在右边
    double x = 0.0f;
    double sw = itemWidth;
    [UIView animateWithDuration:0.25
        animations:^{
            self.frame = CGRectMake(x, self.frame.origin.y, sw, itemHeight);

            self.btn.frame = CGRectMake(0, 0, itemWidth, itemHeight);
        }
        completion:^(BOOL finished) {
            self.contentView.frame = CGRectMake(0, 0, sw, itemHeight);
        }];
}

- (void)changeCloseBtnTransform
{
    CGAffineTransform transform =
        !self.btn.selected ? CGAffineTransformIdentity : CGAffineTransformRotate(self.btn.transform, M_PI_4);
    self.btn.transform = transform;
}

#pragma mark QYMonitorToolDelegate
- (void)monitor:(QYMonitorTool*)monitor category:(QYMonitorCategory)category data:(double)data
{
    QYMonitorItem* item = [self.mapDic objectForKey:@(category)];
    switch (category)
    {
        case QYMonitorCategoryOfFPS:
        {
            [item setDataString:[NSString stringWithFormat:@"%d FPS", (int)round(data)]];
        }
        break;
        case QYMonitorCategoryOfCPU:
        {
            [item setDataString:[NSString stringWithFormat:@"%.2f%%", data]];
        }
        break;
        case QYMonitorCategoryOfMemory:
        {
            [item setDataString:[NSString stringWithFormat:@"%.2f%%", data]];
        }
        break;
        case QYMonitorCategoryOfSendEmail:

            break;
    }
}

- (void)showToWindow
{
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    if (window)
    {
        [window addSubview:self];
    }

    //    NSEnumerator* frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    //    ;
    //
    //    UIWindow* _window = nil;
    //    for (UIWindow* window in frontToBackWindows)
    //    {
    //        //条件1. 是否处于当前主屏幕
    //        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
    //
    //        //条件2. 屏幕是否可见
    //        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
    //        //条件3. 屏幕的优先级为normal（排除AlertView所在的Window、排除StatusBar所在的Window）
    //        BOOL windowLevelNormal = window.windowLevel == UIWindowLevelAlert;
    //        //找到正常显示的Window
    //        if (windowOnMainScreen && windowIsVisible && windowLevelNormal)
    //        {
    //            _window = window;
    //            break;
    //        }
    //    }
    //    if (_window)
    //    {
    //        [_window addSubview:self];
    //    }
}

- (void)itemClick:(UIButton*)btn
{
    QYMonitorCategory category = btn.tag;
    //    QYMonitorItem* item = [self.mapDic objectForKey:@(category)];

    if (category == QYMonitorCategoryOfSendEmail)
    {
        NSLog(@"收集日志");
        if ([[NXSendMail sharedInstance] isSendMail])
        {
            return;
        }

        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];

        NSMutableArray* logs = [NXLogManager allLogMessagesForCurrentProcess];
        //        NSString* logstr = [NSString stringWithFormat:@"uid:%d\n agent:%@\n", dataStore.currMine.userId,
        //                                                      [[YOYOSystemInfo getInstance] yoyoAgent]];
        NSString* logstr = @"";

        for (SystemLogMessage* log in logs)
        {
            logstr = [NSString
                stringWithFormat:@"%@%@%@\n", logstr, [dateFormatter stringFromDate:log.date], log.messageText];
        }

        [NXSendMail setMailrecipients:@[ @"1969489778@qq.com" ] subject:@"日志收集" messageBody:logstr isHTML:NO];
    }
}
- (void)dealloc
{
    [self.monitorTool freeTimer];
    self.monitorTool.delegate = nil;
    NSLog(@"dealloc");
}
@end
