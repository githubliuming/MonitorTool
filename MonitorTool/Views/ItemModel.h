//
//  ItemModel.h
//  MonitorTool
//
//  Created by liuming on 16/11/11.
//  Copyright © 2016年 burning. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, QYMonitorCategory) {
    QYMonitorCategoryOfFPS,
    QYMonitorCategoryOfCPU,
    QYMonitorCategoryOfMemory,
    QYMonitorCategoryOfCountry,
    QYMonitorCategoryOfLanguage,
    QYMonitorCategoryOfSendEmail,
    QYMonitorCategoryOfCustom
};
@interface ItemModel : NSObject

@property(nonatomic, strong) NSString* data;              ///< 显示的数据
@property(nonatomic, assign) BOOL canClicked;             ///< 是否可点击
@property(nonatomic, strong) NSString* title;             ///< 标题
@property(nonatomic, assign) QYMonitorCategory category;  ///< 类型
@end


ItemModel * newModel(NSString * data,NSString * title,BOOL canClicked,QYMonitorCategory category);
