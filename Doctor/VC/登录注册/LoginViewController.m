//
//  ViewController.m
//  YSProject
//
//  Created by cuiw on 15/5/20.
//  Copyright (c) 2015年 cuiw. All rights reserved.
//

#import "LoginViewController.h"
#import "ResetPwdViewController.h"
#import "RegisterViewController.h"
#import "HomeViewController.h"
#import "AppDelegate.h"
#import "TabBarViewController.h"
#import "ParserCenter.h"
#import "TTGlobalUICommon.h"
@interface LoginViewController ()<UITextFieldDelegate>
{
    CWHttpRequest *_loginRequest;
}
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *backScrollView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatUIItem];
    self.edgesForExtendedLayout=UIRectEdgeNone;
     self.automaticallyAdjustsScrollViewInsets=NO;
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoLoginForRegister:) name:@"login" object:nil];
//    _accountTextField.text = @"18307210261";
//    _passwordTextField.text = @"zzzzzz";
//    _accountTextField.text = @"15201308857";
//    _passwordTextField.text = @"222222";
//    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resignKeyboard)];
//    [self.backView addGestureRecognizer:tapGesture];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
//-(void)resignKeyboard
//{
//    [_accountTextField resignFirstResponder];
//    [_passwordTextField resignFirstResponder];
//    if (self.view.frame.origin.y!=0) {
//        [UIView animateWithDuration:0.5 animations:^{
//            self.backScrollView.frame=CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT);
//        }];
//    }
//}
-(void)creatUIItem
{
    UIImageView* OneButtImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, kSCREEN_HEIGHT-80, kSCREEN_WIDTH, 80)];
    OneButtImageView.image=[UIImage imageNamed:@"0_359"];
    [self.backView addSubview:OneButtImageView];
    OneButtImageView.userInteractionEnabled=YES;
    NSArray *imageArray=@[@"0_132",@"0_134"];
    NSArray *titleArray=@[@"找回密码",@"注册帐号"];
    for (int i=0; i<2; i++) {
        UIButton *itemButt=[UIButton buttonWithType:UIButtonTypeCustom];
        itemButt.tag=(i+1)*100;
        itemButt.frame=CGRectMake(i*kSCREEN_WIDTH/2, 20, kSCREEN_WIDTH/2, 40);
        [itemButt setImage:[UIImage imageNamed:[imageArray objectAtIndex:i]] forState:UIControlStateNormal];
        [itemButt addTarget:self action:@selector(twoButtAction:) forControlEvents:UIControlEventTouchUpInside];
        [OneButtImageView addSubview:itemButt];
        UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(itemButt.center.x-40, 60, 80, 20)];
        titleLabel.text=[titleArray objectAtIndex:i];
        titleLabel.textColor=[UIColor whiteColor];
        titleLabel.textAlignment=NSTextAlignmentCenter;
        titleLabel.font=[UIFont systemFontOfSize:10];
        [OneButtImageView addSubview:titleLabel];
        
    }
}
-(void)twoButtAction:(UIButton*)butt
{
    if (butt.tag==100) {
        ResetPwdViewController *resetPwdVC = [[ResetPwdViewController alloc] init];
        [self.navigationController pushViewController:resetPwdVC animated:YES];
    }else
    {
        RegisterViewController *registerVC = [[RegisterViewController alloc] init];
        [self.navigationController pushViewController:registerVC animated:YES];
      }
}
-(void)autoLoginForRegister:(NSNotification*)notification
{
    _accountTextField.text=[notification.userInfo objectForKey:@"phone"];
    _passwordTextField.text=[notification.userInfo objectForKey:@"password"];
    [self sendLoginRequest];
    
}
- (IBAction)loginButtonAction:(id)sender {
    [self sendLoginRequest];
}
#pragma mark - 登录接口
- (void)sendLoginRequest {
    if ([Reachability checkNetCanUse]) {
        if (!_loginRequest) {
            _loginRequest = [[CWHttpRequest alloc] init];
        }
         [UserManager logout];
        [SVProgressHUD showWithStatus:@"正在登录..." maskType:SVProgressHUDMaskTypeClear];
        NSString *account = [_accountTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *password = [_passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSDictionary *jsonDictionary = @{@"username": account, @"password": password, @"userType": @"1"};
         NSLog(@"jsonDictionary====%@",jsonDictionary);
        [_loginRequest JSONRequestOperationWithURL:[NSString stringWithFormat:@"%@%@", HOST_URL, Login_URL] path:nil parameters:jsonDictionary successBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
            NSLog(@"登录接口=======%@", responseObject);
            NSLog(@"登录接口=======%@", [responseObject valueForKeyWithOutNSNull:@"text"]);
            [SVProgressHUD dismiss];
            NSString *code = [responseObject valueForKeyWithOutNSNull:@"code"];
               NSLog(@"sessionID😳😳😳😳😳😳😳😳😳😳=======%@",[responseObject valueForKeyWithOutNSNull:@"SessionID"]);
            if ([code integerValue]==0) {
                
                [self loginEaseMobWithUsername:account password:password withResponseObject:responseObject];
            }else
            {
              [SVProgressHUD showErrorWithStatus:[responseObject objectForKey:@"text"]];
            }
        } failBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id responseObject) {
            NSLog(@"登录接口失败=======%@", responseObject);
            [ShowViewCenter netError];
        }];
    } else {
        [ShowViewCenter netNotAvailable];
    }
}

-(void)loginEaseMobWithUsername:(NSString*)username password:(NSString*)password withResponseObject:(id)responseObject{

    NSLog(@"%@-%@",username,password);
    [[EaseMob sharedInstance].chatManager enableDeliveryNotification];
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:responseObject[@"data"][@"uid"]
                                                        password:responseObject[@"data"][@"hxPassword"]
                                                      completion:
     ^(NSDictionary *loginInfo, EMError *error) {
         if (loginInfo && !error){
             NSLog(@"😓😓😓😓😓😓😓😓😓😓😓😓😓😓😓😓😓😓😓😓😓😓====%@",loginInfo);
             UserManager *userManager=[UserManager currentUserManager];
             userManager.sessionID=[responseObject objectForKey:@"SessionID"];
             userManager.userState=UserStateLogin;
             userManager.loginName=username;
             userManager.password=password;
             [userManager synchronize];
             NSDictionary *tempDic=[responseObject objectForKey:@"data"];
             ParserCenter *parser=[[ParserCenter alloc]init];
             [parser parserUser:tempDic];
             [[CWNSFileUtil sharedInstance] setNSModelToUserDefaults:[responseObject objectForKey:@"data"] withKey:@"userData"];
             TabBarViewController *rootVC=[[TabBarViewController alloc]init];
             AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
             appDelegate.window.rootViewController = rootVC;
             
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

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.backScrollView.frame=CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-216);
    self.backScrollView.contentSize=CGSizeMake(kSCREEN_WIDTH, kSCREEN_HEIGHT);
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    if (self.view.frame.origin.y!=0) {
        [UIView animateWithDuration:0.5 animations:^{
            self.backScrollView.frame=CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT);
        }];
    }
    [self sendLoginRequest];
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.backView endEditing:YES];
    self.backScrollView.frame=CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
