//
//  QYMonitorView.h
//  MonitorTool
//
//  Created by liuming on 16/9/29.
//  Copyright © 2016年 burning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYMonitorTool.h"
@interface QYMonitorView : UIView

- (instancetype) initWithCustomArr:(NSArray<ItemModel *> *)customArr;
- (void)showToWindow;
@end


@interface QYMOnitorCustView : UIView

@property(nonatomic,strong)NSArray<ItemModel *>* moreArr; ///< 更多信息

- (void)refreshData:(NSArray<ItemModel *> *) moreArr;
@end
