//
//  PersonalViewController.m
//  YSProject
//
//  Created by cuiw on 15/5/30.
//  Copyright (c) 2015年 cuiw. All rights reserved.
//

#import "PersonalViewController.h"
#import "DoctorViewController.h"
#import "ProjectViewController.h"
#import "ExperienceViewController.h"
#import "TabBarViewController.h"
@interface PersonalViewController ()
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@end

@implementation PersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatNavgationBarWithTitle:@"个人资料"];
    [self addBackButt];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [(TabBarViewController*)self.tabBarController  tabbarImageView].hidden=YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"0_403"];
        cell.textLabel.text = @"医生简介";
        cell.detailTextLabel.text = @"个人资料与联系方式";
    } else if (indexPath.row == 1) {
        cell.imageView.image = [UIImage imageNamed:@"0_403"];
        cell.textLabel.text = @"服务项目";
        cell.detailTextLabel.text = @"擅长科目、服务项目及收费标准";
    } else if (indexPath.row == 2) {
        cell.imageView.image = [UIImage imageNamed:@"0_406"];
        cell.textLabel.text = @"个人经历";
        cell.detailTextLabel.text = @"学习和工作经历";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        DoctorViewController *doctorVC = [[DoctorViewController alloc] init];
        doctorVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:doctorVC animated:YES];
    } else if (indexPath.row == 1) {
        ProjectViewController *projectVC = [[ProjectViewController alloc] init];
        projectVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:projectVC animated:YES];
    } else if (indexPath.row == 2) {
        ExperienceViewController *experienceVC = [[ExperienceViewController alloc] init];
        experienceVC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:experienceVC animated:YES];
    }
}
@end
