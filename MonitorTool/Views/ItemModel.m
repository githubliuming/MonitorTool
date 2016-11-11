//
//  ItemModel.m
//  MonitorTool
//
//  Created by liuming on 16/11/11.
//  Copyright © 2016年 burning. All rights reserved.
//

#import "ItemModel.h"

@implementation ItemModel

@end

ItemModel *newModel(NSString *data, NSString *title, BOOL canClicked, QYMonitorCategory category)
{
    ItemModel *model = [[ItemModel alloc] init];
    model.data = data;
    model.title = title;
    model.canClicked = canClicked;
    model.category = category;
    return  model;
}

