//
//  PatientViewController.m
//  YSProject
//
//  Created by cuiw on 15/5/30.
//  Copyright (c) 2015年 cuiw. All rights reserved.
//

#import "PatientViewController.h"
#import "TabBarViewController.h"
#import "PatientCell.h"
#import "SearchPatientController.h"
#import "UIImageView+WebCache.h"
#import "UIBlockAlertView.h"
#import "EaseMob.h"
#import "ChatViewController.h"
#import "TTGlobalUICommon.h"
@interface PatientViewController ()
{
    NSMutableArray *dataArray;
    CWHttpRequest *request;
    NSInteger morePage;
    NSInteger totalDataNum;
}
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (weak, nonatomic) IBOutlet UIView *backGrayView;
@property (weak, nonatomic) IBOutlet UIView *alertBackView;
@property (weak, nonatomic) IBOutlet UIButton *sureButt;
@property (weak, nonatomic) IBOutlet UIButton *cancelButt;
@property(assign,nonatomic) NSInteger totalDataNum;

@end

@implementation PatientViewController
@synthesize totalDataNum;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets=NO;
    [self.contentTableView registerNib:[UINib nibWithNibName:@"PatientCell" bundle:nil] forCellReuseIdentifier:@"PatientCell"];
    [self creatNavgationBarWithTitle:[NSString stringWithFormat:@"我的患者(%lu)", (unsigned long)totalDataNum]];
     morePage=1;
    [self getPatientListFromService:YES page:1];
    [self addBackButt];
    [self settingUIState];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [(TabBarViewController*)self.tabBarController  tabbarImageView].hidden=YES;
    if (![[EaseMob sharedInstance].chatManager isLoggedIn] || ![[EaseMob sharedInstance].chatManager isAutoLoginEnabled]) {
        [self loginEaseMob];
    }
}
-(void)loginEaseMob{
    NSString *userid = [UserManager currentUserManager].user.uid;
    NSString *password = [UserManager currentUserManager].user.hxPassword;
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:userid
                                                        password:password
                                                      completion:
     ^(NSDictionary *loginInfo, EMError *error) {
         if (loginInfo && !error){
             NSLog(@"😓😓😓😓😓😓😓😓😓😓😓😓😓😓😓😓😓😓😓😓😓😓====%@",loginInfo);
             [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
             [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
         }else {
             switch (error.errorCode) {
                 case EMErrorServerNotReachable: {
                     TTAlertNoTitle(@"连接服务器失败,无法正常聊天,请重新登录");
                 }
                     break;
                 case EMErrorServerAuthenticationFailure: {
                     TTAlertNoTitle(@"用户名或密码错误,无法正常聊天,请重新登录");
                 }
                     break;
                 case EMErrorServerTimeout: {
                     TTAlertNoTitle(@"连接服务器超时,无法正常聊天,请重新登录");
                 }
                     break;
                 default:{
                     //                     [self clearLocalData];
                     TTAlertNoTitle(@"登录失败,无法正常聊天,请重新登录");
                 }

                     break;
             }
         }
     } onQueue:nil];
}

#pragma  mark----creatUI------
-(void)settingUIState
{
    
    [self.contentTableView addLegendHeaderWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    [self.contentTableView addLegendFooterWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    UIButton *searchButt=[UIButton buttonWithType:UIButtonTypeCustom];
    searchButt.frame=CGRectMake(kSCREEN_WIDTH-30, 20, 20, 20);
    [searchButt setImage:[UIImage imageNamed:@"fangdajing"] forState:UIControlStateNormal];
    [searchButt addTarget:self action:@selector(searchAction) forControlEvents:UIControlEventTouchUpInside];
    [[self.view viewWithTag:10000] addSubview:searchButt];
    
}
-(void)searchAction
{
    SearchPatientController *searchPatientController=[[SearchPatientController alloc]init];
    [self.navigationController pushViewController:searchPatientController animated:YES];
}
-(void)refreshData
{
    [self getPatientListFromService:YES page:1];
}
-(void)loadMoreData
{
    morePage++;
    if ([dataArray count]==totalDataNum) {
        [self.contentTableView.footer noticeNoMoreData];
    }else
    {
        [self getPatientListFromService:NO page:morePage];
        [self.contentTableView.footer beginRefreshing];
    }
}
-(void)getPatientListFromService:(BOOL)refresh page:(NSInteger)page
{
    if ([Reachability checkNetCanUse]) {
        if (!request) {
            request = [[CWHttpRequest alloc] init];
        }
        [SVProgressHUD showWithStatus:@"正在请求数据..." maskType:SVProgressHUDMaskTypeClear];
       NSString *sessionID=[UserManager currentUserManager].sessionID;
        NSDictionary *jsonDictionary = @{@"page":[NSNumber numberWithInteger:page],@"SessionID":sessionID,@"size":@5};
         NSLog(@"jsonDictionary====%@",jsonDictionary);
        [request JSONRequestOperationWithURL:[NSString stringWithFormat:@"%@%@", HOST_URL, GetFiend] path:nil parameters:jsonDictionary successBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
            NSLog(@"病人列表接口成功%@", responseObject);
            [SVProgressHUD dismiss];
            NSString *code = [responseObject valueForKeyWithOutNSNull:@"code"];
               NSLog(@"sessionID😳😳😳😳😳😳😳😳😳😳=======%@",[responseObject valueForKeyWithOutNSNull:@"SessionID"]);
            totalDataNum=[[[responseObject objectForKey:@"data"] objectForKey:@"total"] integerValue];
            UILabel *label=(UILabel*)[[self.view viewWithTag:10000] viewWithTag:20000];
            label.text=[NSString stringWithFormat:@"我的患者(%lu)", (unsigned long)totalDataNum];
            if ([code integerValue]==0) {
                UserManager *userManager=[UserManager currentUserManager];
                userManager.sessionID=[responseObject objectForKey:@"SessionID"];
                
                [userManager synchronize];
                if (refresh) {
                    [dataArray removeAllObjects];
                    dataArray =[[[responseObject objectForKey:@"data"]  objectForKey:@"rs"]mutableCopy];
                    morePage=1;
                    [self.contentTableView.header endRefreshing];
                    [self.contentTableView.footer resetNoMoreData];
                }else
                {
                    [dataArray addObjectsFromArray:[[responseObject objectForKey:@"data"]  objectForKey:@"rs"]];
                    [self.contentTableView.footer endRefreshing];
                }
                [self.contentTableView reloadData];
            }
        } failBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id responseObject) {
            NSLog(@"病人列表接口失败=======%@", responseObject);
            [ShowViewCenter netError];
        }];
    } else {
        [ShowViewCenter netNotAvailable];
    }
}
-(void)deleteFriendFromServiceWith:(NSInteger)patientID
{
    if ([Reachability checkNetCanUse]) {
        if (!request) {
            request = [[CWHttpRequest alloc] init];
        }
        
        [SVProgressHUD showWithStatus:@"正在请求数据..." maskType:SVProgressHUDMaskTypeClear];
       NSString *sessionID=[UserManager currentUserManager].sessionID;
        NSDictionary *jsonDictionary = @{@"uid":[NSNumber numberWithInteger:patientID],@"SessionID":sessionID};
         NSLog(@"jsonDictionary====%@",jsonDictionary);
        [request JSONRequestOperationWithURL:[NSString stringWithFormat:@"%@%@", HOST_URL, DeletFriend] path:nil parameters:jsonDictionary successBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
            NSLog(@"病人列表接口成功%@", responseObject);
            [SVProgressHUD dismiss];
            NSString *code = [responseObject valueForKeyWithOutNSNull:@"code"];
               NSLog(@"sessionID😳😳😳😳😳😳😳😳😳😳=======%@",[responseObject valueForKeyWithOutNSNull:@"SessionID"]);
            if ([code integerValue]==0) {
            UserManager *userManager=[UserManager currentUserManager];
            userManager.sessionID=[responseObject objectForKey:@"SessionID"];
            [userManager synchronize];
            [SVProgressHUD showSuccessWithStatus:@"删除成功"];
                NSDictionary *tempDic=@{@"patientID":[NSNumber numberWithInteger:patientID]};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateChatList" object:nil userInfo:tempDic];
             [self.contentTableView reloadData];
            }
        } failBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id responseObject) {
            NSLog(@"病人列表接口失败=======%@", responseObject);
            [ShowViewCenter netError];
        }];
    } else {
        [ShowViewCenter netNotAvailable];
    }
}
-(void)getSpicfyUserInfo:(NSString*)uid
{
    if ([Reachability checkNetCanUse]) {
        if (!request) {
            request = [[CWHttpRequest alloc] init];
        }
        [SVProgressHUD showWithStatus:@"正在请求数据..." maskType:SVProgressHUDMaskTypeClear];
        NSString *sessionID=[UserManager currentUserManager].sessionID;
        NSDictionary *jsonDictionary= @{@"uid":uid,@"SessionID":sessionID};
         NSLog(@"jsonDictionary====%@",jsonDictionary);
        [request JSONRequestOperationWithURL:[NSString stringWithFormat:@"%@%@", HOST_URL, GetSpecialUserInfo] path:nil parameters:jsonDictionary successBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
            NSLog(@"好友请求接口成功%@", responseObject);
            [SVProgressHUD dismiss];
            NSString *code = [responseObject valueForKeyWithOutNSNull:@"code"];
               NSLog(@"sessionID😳😳😳😳😳😳😳😳😳😳=======%@",[responseObject valueForKeyWithOutNSNull:@"SessionID"]);
            if ([code integerValue]==0){
                UserManager *userManager=[UserManager currentUserManager];
                userManager.sessionID=[responseObject objectForKey:@"SessionID"];
                
                [userManager synchronize];
                ChatViewController *chatController = [[ChatViewController alloc]initWithChatter:[[responseObject objectForKey:@"data"] objectForKey:@"uid"] conversationType:eConversationTypeChat];
                chatController.hidesBottomBarWhenPushed = YES;
                chatController.titleName = [[responseObject objectForKey:@"data"] objectForKey:@"name"];
                chatController.extDictionary=[responseObject objectForKey:@"data"];
                [self.navigationController pushViewController:chatController animated:YES];
            }else
            {
                [SVProgressHUD showErrorWithStatus:[responseObject valueForKeyWithOutNSNull:@"text"]];
            }
        } failBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id responseObject) {
            NSLog(@"好友请求接口失败=======%@", responseObject);
            [ShowViewCenter netError];
        }];
    } else {
        [ShowViewCenter netNotAvailable];
    }
}
#pragma mark - TableView Delegate and DataSource
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    return [dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PatientCell *cell=[tableView dequeueReusableCellWithIdentifier:@"PatientCell"];
       [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [cell.photoImage sd_setImageWithURL:[NSURL URLWithString:[[dataArray objectAtIndex:indexPath.row] objectForKey:@"picUrl"]] placeholderImage:[UIImage imageNamed:@"doctorDefault.png"] options:SDWebImageDelayPlaceholder];
    [cell.nameButt setTitle:[[dataArray objectAtIndex:indexPath.row] objectForKey:@"name" ]forState:UIControlStateNormal];
    cell.sexLabel.text=[[[dataArray objectAtIndex:indexPath.row] objectForKey:@"sex"] integerValue]==0?@"女":@"男";
    cell.ageLabel.text=[NSString stringWithFormat:@"%@",[[dataArray objectAtIndex:indexPath.row] objectForKey:@"age"]];
    
    UIButton *deletButt=[UIButton buttonWithType:UIButtonTypeCustom];
    deletButt.frame=CGRectMake(kSCREEN_WIDTH, 0, kSCREEN_WIDTH, 71);
    [deletButt setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [deletButt setImage:[UIImage imageNamed:@"0_26"] forState:UIControlStateNormal];
    [deletButt setTitle:@"删除" forState:UIControlStateNormal];
    deletButt.imageEdgeInsets=UIEdgeInsetsMake(0, 25, 0, 0);
    deletButt.titleEdgeInsets=UIEdgeInsetsMake(0, 25, 0, 0);
    deletButt.tag=indexPath.row;
    [deletButt setBackgroundColor:[CWNSFileUtil colorWithHexString:@"#eeeeee"]];
    [cell.contentView addSubview:deletButt];
    tableView.tableFooterView=[UIView new];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 71;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self getSpicfyUserInfo:[[dataArray objectAtIndex:indexPath.row] objectForKey:@"uid"]];
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"真的删除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
          UIBlockAlertView *alerView=[[UIBlockAlertView alloc]initWithTitle:@"" message:@"确定删除该好友？" cancelButtonTitle:@"取消" otherButtonTitles:@"确定" cancelblock:^{
            [self.contentTableView reloadData];
        } otherBlock:^{
             [self deleteFriendFromServiceWith:[[[dataArray objectAtIndex:indexPath.row] objectForKey:@"uid"]integerValue]];
               //删除对应数据的cell
            [dataArray removeObjectAtIndex:[indexPath row]];  //删除数组里的数据
            [tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }];
        [alerView show];
    }
}
-(void)deletePatient:(UIButton*)butt
{
    self.backGrayView.hidden=NO;
    self.alertBackView.hidden=NO;
    self.sureButt.tag=butt.tag;
    
}
- (IBAction)commitDeletePatient:(UIButton *)sender {
    [self deleteFriendFromServiceWith:[[[dataArray objectAtIndex:sender.tag] objectForKey:@"uid"]integerValue]];
     [dataArray removeObjectAtIndex:sender.tag];
}
- (IBAction)cancelDeletePatient:(UIButton *)sender {
    self.backGrayView.hidden=YES;
    self.alertBackView.hidden=YES;
    [self.contentTableView reloadData];
}
@end
