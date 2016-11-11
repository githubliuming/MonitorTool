//
//  QYMonitorMoreCell.m
//  MonitorTool
//
//  Created by liuming on 16/11/11.
//  Copyright © 2016年 burning. All rights reserved.
//

#import "QYMonitorMoreCell.h"

@interface QYMonitorMoreCell ()
@property(nonatomic,strong) ItemModel * model;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel * contentLabel;
@end

@implementation QYMonitorMoreCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {

        [self initSubView];
    }
    return self;
}

- (void) initSubView{
    
    CGRect frame = CGRectMake(0, 0, 60, CGRectGetHeight(self.bounds));
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:frame];
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.text = @"";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor greenColor];
    [self.contentView addSubview:titleLabel];
    
    CGRect frame1 = CGRectMake(frame.size.width, 0,CGRectGetWidth(self.bounds) - frame.size.width , CGRectGetHeight(self.bounds) );
    UILabel* contentLabel = [[UILabel alloc] initWithFrame:frame1];
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.text = @"";
    contentLabel.numberOfLines = 0;
    contentLabel.textAlignment = NSTextAlignmentLeft;
    contentLabel.textColor = [UIColor blueColor];
    [self.contentView addSubview:contentLabel];
    
    self.titleLabel  = titleLabel;
    self.contentLabel =contentLabel;
}
- (void) setItemModel:(ItemModel *)model{

    _model = model;
    self.titleLabel.text = _model.title;
    self.contentLabel.text = _model.data;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
