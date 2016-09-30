//
//  ViewController.m
//  MonitorTool
//
//  Created by liuming on 16/9/30.
//  Copyright © 2016年 burning. All rights reserved.
//

#import "ViewController.h"
#import "QYMonitorView.h"
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) NSMutableArray* dataSource;
@end

@implementation ViewController
- (NSMutableArray*)dataSource
{
    if (_dataSource == nil)
    {
        _dataSource = [[NSMutableArray alloc] init];

        for (NSInteger i = 0; i < 1000; i++)
        {
            [_dataSource addObject:[NSString stringWithFormat:@"%ld", i + 1]];
        }
    }
    return _dataSource;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UITableView* table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 560) style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"123"];
    [self.view addSubview:table];

    QYMonitorView* view = [[QYMonitorView alloc] init];
    [view showToWindow];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView { return 1; }
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"123"];
    cell.textLabel.text = @"一点也不卡";
    return cell;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
