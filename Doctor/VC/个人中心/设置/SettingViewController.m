//
//  SettingViewController.m
//  YSProject
//
//  Created by cuiw on 15/5/31.
//  Copyright (c) 2015年 cuiw. All rights reserved.
//

#import "SettingViewController.h"
#import "AboutViewController.h"
#import "SettingDateViewController.h"
#import "TabBarViewController.h"
@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatNavgationBarWithTitle:@"设置"];
     [self addBackButt];
    _contentTableView.layer.cornerRadius = 4;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [(TabBarViewController*)self.tabBarController  tabbarImageView].hidden=YES;
}
#pragma mark - TableView Delegate and DataSource
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"设置预约时间";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"消息提醒";
        cell.accessoryType = UITableViewCellAccessoryNone;
        UISwitch *switchView = [[UISwitch alloc] init];
        switchView.on = YES;
        [switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchView;
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = @"关于我们";
    }
    tableView.tableFooterView=[UIView new];
    return cell;
}

- (void)switchAction:(id)sender{
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        SettingDateViewController *settingDateVC = [[SettingDateViewController alloc] init];
        [self.navigationController pushViewController:settingDateVC animated:YES];
    } else if (indexPath.row == 1) {
//        [self.navigationController pushViewController:projectVC animated:YES];
    } else if (indexPath.row == 2) {
        AboutViewController *aboutVC = [[AboutViewController alloc] init];
        [self.navigationController pushViewController:aboutVC animated:YES];
    }
}
@end
