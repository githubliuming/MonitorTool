//
//  NXLogManager.h
//  YOSticker
//
//  Created by AK on 16/7/15.
//  Copyright © 2016年 Catch app. All rights reserved.
//

/**
 *  收集当前设备LOG
 e.g.
 `
    NSMutableArray *logs = [NXLogManager allLogMessagesForCurrentProcess];
 `
 */

#import <Foundation/Foundation.h>

@interface SystemLogMessage : NSObject
{
}
@property(nonatomic) NSTimeInterval timeInterval;

@property(nonatomic, retain) NSDate* date;
@property(nonatomic, retain) NSString* sender;
@property(nonatomic, retain) NSString* messageText;
@property(nonatomic) long long messageID;
@end

@interface NXLogManager : NSObject
{
}

/**
 *  取LOG 信息
 *
 *  @return LOGS
 */
+ (NSMutableArray<SystemLogMessage*>*)allLogMessagesForCurrentProcess;
@end
