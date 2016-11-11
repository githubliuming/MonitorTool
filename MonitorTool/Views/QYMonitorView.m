//
//  QYMonitorView.m
//  MonitorTool
//
//  Created by liuming on 16/9/29.
//  Copyright © 2016年 burning. All rights reserved.
//

#import "QYMonitorView.h"
#import "QYMonitorItem.h"
#import "NXSendMail.h"
#import "NXLogManager.h"
#import "QYMonitorMoreCell.h"
#define itemWidth 40.0f
#define itemHeight 40.0f

@interface QYMonitorView ()<QYMonitorToolDelegate>
@property(nonatomic, strong) UIView* contentView;
@property(nonatomic, strong) NSArray* monitors;
@property(nonatomic, assign) CGPoint oldPoint;
@property(nonatomic, strong) UIButton* btn;
@property(nonatomic, strong) QYMonitorTool* monitorTool;
@property(nonatomic, strong) NSMutableDictionary* mapDic;
@property(nonatomic, strong) QYMOnitorCustView* customView;
@property(nonatomic, strong) NSArray<ItemModel*>* customArr;
@property(nonatomic, strong) UIView* bgView;
@end
@implementation QYMonitorView

- (instancetype)initWithCustomArr:(NSArray<ItemModel*>*)customArr
{
    self = [super init];
    if (self)
    {
        self.customArr = customArr;
        [self initSubView];
        [self startMonitor];
    }

    return self;
}
- (NSArray*)monitors
{
    if (_monitors == nil)
    {
        _monitors = [self.monitorTool getMonitors];
    }
    return _monitors;
}
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

- (double)contentWidth { return self.monitors.count >= 5 ? itemWidth * 5 : self.monitors.count * 5; }
- (void)initSubView
{
    self.clipsToBounds = YES;
    NSUInteger count = self.monitors.count;
    self.frame = CGRectMake(0, 100, itemWidth + [self contentWidth], itemHeight);
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor colorWithRed:0 / 255.0f green:0 blue:0 alpha:1];
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(itemWidth, 0, [self contentWidth], itemHeight)];
    self.contentView.clipsToBounds = YES;
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    for (NSInteger i = 0; i < count; i++)
    {
        double r = (arc4random() % 255) / 255.0f;
        double g = (arc4random() % 255) / 255.0f;
        double b = (arc4random() % 255) / 255.0f;
        UIColor* color = [UIColor colorWithRed:r green:g blue:b alpha:1];
        double x = i * itemWidth;
        ItemModel* model = [self.monitors objectAtIndex:i];
        QYMonitorItem* item = [[QYMonitorItem alloc] initWithFrame:CGRectMake(x, 0, itemWidth, itemHeight)];
        [item setDataString:model.data];
        [item setTitleString:model.title];
        item.backgroundColor = color;
        item.tag = model.category;
        if (model.canClicked)
        {
            [item setDataString:@""];
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = item.tag;
            [button addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
            button.frame = item.bounds;
            [item addSubview:button];
        }
        [scrollView addSubview:item];
        [self.mapDic setObject:item forKey:@(model.category)];
    }
    double content_x = self.monitors.count * itemWidth;
    scrollView.contentSize = CGSizeMake(content_x, scrollView.contentOffset.y);
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, itemWidth, itemHeight);
    [button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"⚒" forState:UIControlStateNormal];
    [button setTitle:@"⚒" forState:UIControlStateHighlighted];
    button.selected = YES;
    button.backgroundColor = [UIColor redColor];
    self.btn = button;
    //添加拖拽手势
    UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:pan];

    [self.contentView addSubview:scrollView];
    [self addSubview:self.contentView];
    [self addSubview:button];
    //默认关闭状态
    [self btnClicked:self.btn];
}

- (void)startMonitor { [self.monitorTool startMonitor]; }
- (void)btnClicked:(UIButton*)sender
{
    //    [self changeCloseBtnTransform];
    if (self.customView)
    {
        [self.customView removeFromSuperview];
        self.customView = nil;
    }
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
    double cHeight = self.customView.frame.size.height;
    double dx = point.x - self.oldPoint.x;
    double dy = point.y - self.oldPoint.y;
    double tx = self.center.x + dx;
    double ty = self.center.y + dy;
    double cty = self.customView.center.y + dy;
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
    if (cty <= cHeight / 2.0)
    {
        cty = ty + cHeight / 2.0 + height / 2.0;
    }
    if (cty >= [self screenHeight] - cHeight / 2.0)
    {
        cty = ty - height / 2.0 - cHeight / 2.0;
    }
    if (cty < ty)
    {
        cty = MIN(cty, ty - height / 2.0 - cHeight / 2.0);
    }
    else
    {
        cty = MAX(cty, ty + height / 2.0 + cHeight / 2.0);
    }
    self.customView.center = CGPointMake(tx, cty);
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
                         self.customView.frame =
                             CGRectMake(x, self.customView.frame.origin.y, self.customView.frame.size.width,
                                        self.customView.frame.size.height);
                     }];
}
- (BOOL)isRightBottom { return (self.frame.size.width + self.frame.origin.x) >= [self screenWidhth]; }
- (BOOL)closeBtnIsRight
{
    return (self.btn.frame.size.width + self.btn.frame.origin.x) >= self.frame.size.width;
}
#pragma 所有动画方法
/**
 从左到右打开
 */
- (void)showFromLeft
{
    //靠左
    double x = itemWidth;
    double width = [self contentWidth];
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
    double width = [self contentWidth];
    double sw = width + itemWidth;
    double x = [self screenWidhth] - sw;
    self.contentView.frame = CGRectMake(0, 0, width, itemHeight);
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.btn.frame = CGRectMake(width, 0, itemWidth, itemHeight);
                         self.frame = CGRectMake(x, self.frame.origin.y, sw, itemHeight);
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
            self.btn.frame = CGRectMake(0, 0, itemWidth, itemHeight);
            self.frame = CGRectMake(x, self.frame.origin.y, sw, itemHeight);
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
- (void)monitor:(QYMonitorTool*)monitor category:(QYMonitorCategory)category data:(NSString*)data
{
    QYMonitorItem* item = [self.mapDic objectForKey:@(category)];
    [item setDataString:data];
}

- (void)showToWindow
{
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    if (window)
    {
        [window addSubview:self];
    }
}

- (void)itemClick:(UIButton*)btn
{
    QYMonitorCategory category = btn.tag;

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

    if (category == QYMonitorCategoryOfCustom)
    {
        if (self.customArr.count > 0)
        {
            if (self.customView == nil)
            {
                double w = self.frame.size.width;
                double h = self.customArr.count >= 5 ? 200 : self.customArr.count * 50;
                //计算更多view显示的位置
                double y = self.frame.origin.y >= h ? self.frame.origin.y - h : CGRectGetMaxY(self.frame);
                self.customView = [[QYMOnitorCustView alloc] initWithFrame:CGRectMake(self.frame.origin.x, y, w, h)];
                [self.customView refreshData:self.customArr];
                UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
                [keyWindow addSubview:self.customView];
            }
            else
            {
                [self.customView removeFromSuperview];
                self.customView = nil;
            }
        }
    }
}
- (void)dealloc
{
    [self.monitorTool freeTimer];
    self.monitorTool.delegate = nil;
    NSLog(@"dealloc");
}
@end

//更多信息
@interface QYMOnitorCustView ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UITableView* tableView;
@property(nonatomic, strong) UILabel* txtLabel;
@end

@implementation QYMOnitorCustView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor grayColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10;
        self.layer.borderColor = [UIColor grayColor].CGColor;
        self.layer.borderWidth = 2;
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.rowHeight = 50;
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.showsHorizontalScrollIndicator = NO;
        self.tableView.tableFooterView = [[UIView alloc] init];
        [self addSubview:self.tableView];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView { return 1; }
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section { return self.moreArr.count; }
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* identifier = @"moreCellId";
    QYMonitorMoreCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[QYMonitorMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    [cell setItemModel:self.moreArr[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)refreshData:(NSArray<ItemModel*>*)moreArr
{
    if (moreArr)
    {
        self.moreArr = moreArr;
    }

    [self.tableView reloadData];
}
@end

