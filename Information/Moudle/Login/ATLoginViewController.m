//
//  ATLoginViewController.m
//  Information
//
//  Created by 刘涛 on 2020/5/20.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import "ATLoginViewController.h"
#import "ATLoginWebViewController.h"
#import "ATRegisViewController.h"
#import "ATLoginView.h"

@interface ATLoginViewController ()<UITextFieldDelegate>

@property (strong,nonatomic)ATLoginView *loginView;

@end

@implementation ATLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLayoutView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupLayoutView {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    _loginView = [[ATLoginView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_loginView];
    _loginView.username.delegate =  self;
    _loginView.userpass.delegate =  self;
    [_loginView.log_sure addTarget:self action:@selector(loginSure:) forControlEvents:UIControlEventTouchUpInside];//登录
    [_loginView.regisAcc addTarget:self action:@selector(loginSure:) forControlEvents:UIControlEventTouchUpInside];//注册
    [_loginView.backbtn addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];//随便逛逛
    [_loginView.loginAgreement addTarget:self action:@selector(jumpWebViewVcPr) forControlEvents:UIControlEventTouchUpInside];
    [_loginView.regisAgreement addTarget:self action:@selector(jumpWebViewVcRe) forControlEvents:UIControlEventTouchUpInside];
}

#pragma -mark - TextDelegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
   return [textField resignFirstResponder];
}

#pragma -mark -events response

- (void)loginSure:(UIButton *)btn{
    if (btn.tag == 1003) {
        //登陆
        BOOL loginstate = [[ATLoginTool sharedInstance] UserLoginWithAccount:_loginView.username.text password:_loginView.userpass.text];
        if (loginstate) {
            if (self.loadStatus) {
                self.loadStatus();
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [[ATToast shareToast] initWithText:@"账号密码错误"];
        }
    }else if (btn.tag == 1004){
        //注册
        ATRegisViewController *regis = [[ATRegisViewController alloc] init];
        regis.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:regis animated:YES completion:nil];
    }
}
- (void)goBack:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)jumpWebViewVcPr {
    ATLoginWebViewController *web = [[ATLoginWebViewController alloc] init];
    web.titleStr = @"隐私协议";
    web.type = 1;
    [self.navigationController pushViewController:web animated:YES];
}

- (void)jumpWebViewVcRe {
    ATLoginWebViewController *web = [[ATLoginWebViewController alloc] init];
    web.titleStr = @"注册协议";
    web.type = 2;
    [self.navigationController pushViewController:web animated:YES];
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
