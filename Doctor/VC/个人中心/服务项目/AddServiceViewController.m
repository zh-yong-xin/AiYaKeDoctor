//
//  AddServiceViewController.m
//  YSProject
//
//  Created by MrZhang on 15/6/16.
//  Copyright (c) 2015年 cuiw. All rights reserved.
//

#import "AddServiceViewController.h"
#import "SelectesItemTypeViewController.h"
#import "UIPlaceHolderTextView.h"
@interface AddServiceViewController ()<UITextViewDelegate,ItemSelectDelegate>
{
    CWHttpRequest *request;
 
}
@property (weak, nonatomic) IBOutlet UITextField *selectedTypeField;
@property (weak, nonatomic) IBOutlet UIButton *selectedItemButt;
@property (weak, nonatomic) IBOutlet UITextField *feeMinField;
@property (weak, nonatomic) IBOutlet UITextField *feeMaxField;
@property (strong, nonatomic) UIPlaceHolderTextView *contentTextview;
@property (strong,nonatomic) NSDictionary *recieveDic;
@end

@implementation AddServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatNavgationBarWithTitle:@"添加服务项目"];
    [self addBackButt];
    [self creatUIItem];
    
    _contentTextview=[[UIPlaceHolderTextView alloc]initWithFrame:CGRectMake(20, 270, kSCREEN_WIDTH-40, 150) andPlaceholder:@"请输入项目描述" andLayerRadius:5.0f andBorderColor:[UIColor lightGrayColor] andBorderWidth:0.5f];
    _contentTextview.delegate=self;
    _contentTextview.layer.cornerRadius=5.0f;
    _contentTextview.layer.borderColor=[UIColor lightGrayColor].CGColor;
    _contentTextview.layer.borderWidth=1.0f;
    [self.view addSubview:_contentTextview];
    if (_type==1) {
        self.selectedTypeField.text=[_edittingDic objectForKey:@"typeName"];
        self.feeMaxField.text=[_edittingDic objectForKey:@"feeMax"];
        self.feeMinField.text=[_edittingDic objectForKey:@"feeMin"];
        self.contentTextview.text=[_edittingDic objectForKey:@"content"];
        self.selectedItemButt.hidden=YES;
    }
}
- (IBAction)selectedAction:(id)sender {
    
    SelectesItemTypeViewController *selectedItemController=[[SelectesItemTypeViewController alloc]init];
    selectedItemController.delegate=self;
    [self.navigationController pushViewController:selectedItemController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)creatUIItem
{
    UIImageView* OneButtImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, kSCREEN_HEIGHT-80, kSCREEN_WIDTH, 80)];
    OneButtImageView.image=[UIImage imageNamed:@"0_359"];
    [self.view addSubview:OneButtImageView];
    OneButtImageView.userInteractionEnabled=YES;
    UIButton *itemButt=[UIButton buttonWithType:UIButtonTypeCustom];
    itemButt.frame=CGRectMake(kSCREEN_WIDTH/2-20, 20, 40, 40);
    [itemButt setImage:[UIImage imageNamed:@"0_173"] forState:UIControlStateNormal];
    [itemButt addTarget:self action:@selector(sureButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [OneButtImageView addSubview:itemButt];
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(kSCREEN_WIDTH/2-20, 60, 40, 20)];
    titleLabel.text=@"确定";
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.font=[UIFont systemFontOfSize:10];
    [OneButtImageView addSubview:titleLabel];
}
-(void)sureButtonAction
{
    NSString *feeMin = [_feeMinField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([feeMin length] == 0) {
        [ShowViewCenterViewController showAlertViewWithTitle:nil message:@"请输入最低价!" cancelButtonTitle:@"确定" otherButtonTitles:nil delegate:nil cancelBlock:nil otherBlock:nil];
        return;
    }
    NSString *feeMax = [_feeMaxField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([feeMax length] == 0) {
        [ShowViewCenterViewController showAlertViewWithTitle:nil message:@"请输入最高价格!" cancelButtonTitle:@"确定" otherButtonTitles:nil delegate:nil cancelBlock:nil otherBlock:nil];
        return;
    }
    if([feeMin integerValue]>[feeMax integerValue])
    {
        [ShowViewCenterViewController showAlertViewWithTitle:nil message:@"最低价格不能大于最高价格!" cancelButtonTitle:@"确定" otherButtonTitles:nil delegate:nil cancelBlock:nil otherBlock:nil];
        return;
    }
    NSString *content = [_contentTextview.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([content length] == 0) {
        [ShowViewCenterViewController showAlertViewWithTitle:nil message:@"请输入项目描述!" cancelButtonTitle:@"确定" otherButtonTitles:nil delegate:nil cancelBlock:nil otherBlock:nil];
        return;
    }
    [self  addOrEditServiceProjectRequest:[[_recieveDic objectForKey:@"id"] integerValue]  andType:self.type andMinFree:[_feeMinField.text integerValue] andMaxFree:[_feeMaxField.text integerValue] andContent:_contentTextview.text];
}
-(void)addOrEditServiceProjectRequest:(NSInteger)uid andType:(NSInteger)type andMinFree:(NSInteger)minfree andMaxFree:(NSInteger)maxFree andContent:(NSString*)detail
{
    if ([Reachability checkNetCanUse]) {
        if (!request) {
            request = [[CWHttpRequest alloc] init];
        }
        [SVProgressHUD showWithStatus:@"正在请求数据..." maskType:SVProgressHUDMaskTypeClear];
        NSString *sessionID=[UserManager currentUserManager].sessionID;
        NSDictionary *jsonDictionary= @{@"type":[NSNumber numberWithInteger:uid],@"SessionID":sessionID,@"feeMin":[NSNumber numberWithInteger:minfree],@"feeMax":[NSNumber numberWithInteger:maxFree],@"content":detail};
         NSLog(@"jsonDictionary====%@",jsonDictionary);
        [request JSONRequestOperationWithURL:[NSString stringWithFormat:@"%@%@", HOST_URL, AddAndEditService] path:nil parameters:jsonDictionary successBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, id responseObject) {
            NSLog(@"好友请求接口成功%@", responseObject);
            [SVProgressHUD dismiss];
            NSString *code = [responseObject valueForKeyWithOutNSNull:@"code"];
               NSLog(@"sessionID😳😳😳😳😳😳😳😳😳😳=======%@",[responseObject valueForKeyWithOutNSNull:@"SessionID"]);
            if ([code integerValue]==0) {
                UserManager *userManager=[UserManager currentUserManager];
                userManager.sessionID=[responseObject objectForKey:@"SessionID"];
                [userManager synchronize];
                [self.navigationController popViewControllerAnimated:YES];
            }
        } failBlock:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id responseObject) {
            NSLog(@"好友请求接口失败=======%@", responseObject);
            [ShowViewCenter netError];
        }];
    } else {
        [ShowViewCenter netNotAvailable];
    }
}
-(void)projectPassDelegate:(NSDictionary *)dic
{
    self.selectedTypeField.text=[dic objectForKey:@"name"];
    self.recieveDic=dic;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self makeKeyboardDisappear];
}
-(void)makeKeyboardDisappear
{
    [_feeMinField resignFirstResponder];
    [_feeMaxField resignFirstResponder];
    [_contentTextview resignFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
