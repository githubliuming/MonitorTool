//
//  QYMonitorTool.m
//  MonitorTool
//
//  Created by liuming on 16/9/30.
//  Copyright © 2016年 burning. All rights reserved.
//

#import "QYMonitorTool.h"
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <sys/sysctl.h>
@interface QYMonitorTool ()
@property(nonatomic, strong) CADisplayLink *link;
@property(nonatomic, assign) NSUInteger count;
@property(nonatomic, assign) NSTimeInterval lastTime;
@property(nonatomic, assign) NSInteger fpsCount;
@end
@implementation QYMonitorTool

- (NSArray *)getMonitors
{
    return @[
        newModel(@"", @"FPS", NO, QYMonitorCategoryOfFPS),
        newModel(@"", @"CPU", NO, QYMonitorCategoryOfCPU),
        newModel(@"", @"Memory", NO, QYMonitorCategoryOfMemory),
        newModel([self currentSysLanguage], @"Language", NO, QYMonitorCategoryOfLanguage),
        newModel([self currenCountryDec], @"Country", NO, QYMonitorCategoryOfCountry),
        newModel(@"", @"More", YES, QYMonitorCategoryOfCustom),
        newModel(@"", @"Email", YES, QYMonitorCategoryOfSendEmail),
    ];
}

- (instancetype)shareInstaced
{
    static QYMonitorTool *toolObj = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (toolObj == nil)
        {
            toolObj = [[QYMonitorTool alloc] init];
        }
    });

    return toolObj;
}

- (void)startMonitor
{
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)tick:(CADisplayLink *)link
{
    if (_lastTime == 0)
    {
        _lastTime = link.timestamp;
        return;
    }

    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) return;
    _lastTime = link.timestamp;
    float fps = _count / delta;
    _count = 0;

    NSString *fps_ = [NSString stringWithFormat:@"%.2f", fps];
    [self sendDelegate:QYMonitorCategoryOfFPS andData:fps_];

    if (self.fpsCount % 2 == 0)
    {
        NSString *cpu = [NSString stringWithFormat:@"%.1f%%", cpu_usage()];
        [self sendDelegate:QYMonitorCategoryOfCPU andData:cpu];
        double totolMemory = [self getTotalMemorySize];
        double canUserMemory = [self usedMemory];
        NSString *data = [NSString stringWithFormat:@"%.1f%%", (canUserMemory / totolMemory) * 100];
        [self sendDelegate:QYMonitorCategoryOfMemory andData:data];
    }
    self.fpsCount = (++self.fpsCount) % 10001;
}

- (void)sendDelegate:(QYMonitorCategory)category andData:(NSString *)data
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(monitor:category:data:)])
    {
        [self.delegate monitor:self category:category data:data];
    }
}

float cpu_usage()
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;

    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS)
    {
        return -1;
    }

    task_basic_info_t basic_info;
    thread_array_t thread_list;
    mach_msg_type_number_t thread_count;

    thread_info_data_t thinfo;
    mach_msg_type_number_t thread_info_count;

    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0;  // Mach threads

    basic_info = (task_basic_info_t)tinfo;

    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS)
    {
        return -1;
    }
    if (thread_count > 0) stat_thread += thread_count;

    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;

    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS)
        {
            return -1;
        }

        basic_info_th = (thread_basic_info_t)thinfo;

        if (!(basic_info_th->flags & TH_FLAGS_IDLE))
        {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }

    }  // for each thread

    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);

    return tot_cpu;
}

// 获取当前设备可用内存(单位：MB）
- (double)availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);

    if (kernReturn != KERN_SUCCESS)
    {
        return NSNotFound;
    }

    return ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;
}
//获取设备总类存
- (double)getTotalMemorySize { return ([NSProcessInfo processInfo].physicalMemory) / 1024.0f / 1024.0f; }
//获取当前任务所占用的内存（单位：MB）
- (double)usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&taskInfo, &infoCount);

    if (kernReturn != KERN_SUCCESS)
    {
        return NSNotFound;
    }

    return taskInfo.resident_size / 1024.0 / 1024.0;
}
- (void)freeTimer
{
    [self.link invalidate];
    self.link = nil;
}

- (NSString *)currentSysLanguage { return [[NSLocale preferredLanguages] objectAtIndex:0]; }
- (NSString *)currentSysVersion { return [[UIDevice currentDevice] systemVersion]; }
- (NSString *)currenCountryCode { return [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]; }
- (NSString *)currenCountryDec
{
    return [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:[self currenCountryCode]];
}
@end

