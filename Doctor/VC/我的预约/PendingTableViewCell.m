//
//  PendingTableViewCell.m
//  YSProject
//
//  Created by cuiw on 15/5/26.
//  Copyright (c) 2015年 cuiw. All rights reserved.
//

#import "PendingTableViewCell.h"

@implementation PendingTableViewCell

- (void)awakeFromNib {
//    self.backView.layer.borderWidth=1.0f;
//    self.backView.layer.borderColor=[UIColor lightGrayColor].CGColor;
    self.backView.layer.cornerRadius=5.0f;
   
}
-(void)configeCellData:(NSDictionary*)cellDic andSatusDic:(NSDictionary*)statusDic
{
    self.nameLabel.text=[cellDic objectForKey:@"name"];
    self.sexLabel.text=[[cellDic objectForKey:@"sex"] integerValue]==0?@"女":@"男";
    self.timeLabel.text=[NSString stringWithFormat:@"预约时间:%@",[cellDic objectForKey:@"createTime"]];
    self.stateLabel.text=[statusDic objectForKey:[cellDic objectForKey:@"status"]];
    
    NSMutableAttributedString *typeAttributString=[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"症状描述:%@",[cellDic objectForKey:@"itemsName"]]];
    NSRange range=NSMakeRange(0, 5);
    [typeAttributString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range];
    [typeAttributString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:range];
    self.sickTypeLabel.attributedText=typeAttributString;
    
    NSMutableAttributedString *contentAttributString=[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"症状描述:%@",[cellDic objectForKey:@"remark"]]];
    [contentAttributString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range];
    [contentAttributString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:range];
    self.sickCommentLabel.attributedText=contentAttributString;
    
    NSInteger status=[[cellDic objectForKey:@"status"] integerValue];
    switch (status) {
        case -99://已取消
            self.photoImageView.image=[UIImage imageNamed:@"0_204"];
            break;
        case 1:
        case 3://已确认
            self.photoImageView.image=[UIImage imageNamed:@"0_85"];
            break;
        case 0:
        case 2://待确认
            self.photoImageView.image=[UIImage imageNamed:@"0_47"];
            break;
        case 99://已完成
            self.photoImageView.image=[UIImage imageNamed:@"0_102"];
            break;
        case -2:
        case -1://已拒绝
            self.photoImageView.image=[UIImage imageNamed:@"0_128"];
            break;
        default:
            break;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
