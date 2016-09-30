//
//  QYMonitorTool.h
//  MonitorTool
//
//  Created by liuming on 16/9/30.
//  Copyright © 2016年 burning. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, QYMonitorCategory) {
    QYMonitorCategoryOfFPS,
    QYMonitorCategoryOfCPU,
    QYMonitorCategoryOfMemory,
    QYMonitorCategoryOfSendEmail
};

@class QYMonitorTool;
@protocol QYMonitorToolDelegate<NSObject>

- (void)monitor:(QYMonitorTool *)monitor category:(QYMonitorCategory)category data:(double)data;

@end

@interface QYMonitorTool : NSObject
//- (instancetype)shareInstaced;

@property(nonatomic, assign) id<QYMonitorToolDelegate> delegate;
- (void)startMonitor;

- (void)freeTimer;
@end
