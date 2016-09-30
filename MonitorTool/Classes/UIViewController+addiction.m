//
//  UIViewController+addiction.m
//  YOYO
//
//  Created by 王 成 on 8/1/14.
//  Copyright (c) 2014 yoyo-corp.com. All rights reserved.
//

#import "UIViewController+addiction.h"

@implementation UIViewController (addiction)



- (void)setExtraCellLineHidden:(UITableView *)tableView
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    [tableView setTableHeaderView:view];
}
+ (UIViewController *)nx_currentViewController
{
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    return [UIViewController findBestViewController:viewController];
}

+ (UIViewController *)findBestViewController:(UIViewController *)vc
{
    if (vc.presentedViewController)
    {
        // Return presented view controller
        return [UIViewController findBestViewController:vc.presentedViewController];
    }
    else if ([vc isKindOfClass:[UISplitViewController class]])
    {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *)vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
    }
    else if ([vc isKindOfClass:[UINavigationController class]])
    {
        // Return top view
        UINavigationController *svc = (UINavigationController *)vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findBestViewController:svc.topViewController];
        else
            return vc;
    }
    else if ([vc isKindOfClass:[UITabBarController class]])
    {
        // Return visible view
        UITabBarController *svc = (UITabBarController *)vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findBestViewController:svc.selectedViewController];
        else
            return vc;
    }
    else
    {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}
@end
