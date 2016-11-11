//
//  QYMonitorTool.h
//  MonitorTool
//
//  Created by liuming on 16/9/30.
//  Copyright © 2016年 burning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemModel.h"



#define itemTitle @"title"
#define itemCategory @"itemCategory"
#define itemCanClicked @"itemCanClicked"

@class QYMonitorTool;
@protocol QYMonitorToolDelegate<NSObject>

- (void)monitor:(QYMonitorTool *)monitor category:(QYMonitorCategory)category data:(NSString *)data;

@end

@interface QYMonitorTool : NSObject
//- (instancetype)shareInstaced;

@property(nonatomic, assign) id<QYMonitorToolDelegate> delegate;

- (NSArray*)getMonitors;

- (void)startMonitor;

- (void)freeTimer;
@end
