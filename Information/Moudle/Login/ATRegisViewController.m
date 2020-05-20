//
//  ATRegisViewController.m
//  Information
//
//  Created by 刘涛 on 2020/5/20.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import "ATRegisViewController.h"
#import "ATRegisView.h"

@interface ATRegisViewController ()

@property(copy,nonatomic)NSString *myName;

@property(copy,nonatomic)NSString *myEmail;

@property(copy,nonatomic)NSString *mysec;

@property(copy,nonatomic)NSString *mysecs;

@end

@implementation ATRegisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLayoutView];
}


- (void)setupLayoutView {
    ATRegisView *regis = [[ATRegisView alloc] initWithFrame:self.view.frame WithDelegate:self];
    [regis.regis_sure addTarget:self action:@selector(regisMyAccount:) forControlEvents:UIControlEventTouchUpInside];
    [regis.jumpload addTarget:self action:@selector(jumpLoading:) forControlEvents:UIControlEventTouchUpInside];
    [regis.backbtn addTarget:self action:@selector(backFirstView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:regis];
}

#pragma -mark TextFieldDelegate
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    switch (textField.tag) {
        case 1:
        {
            _myName = textField.text;
        }
            break;
        case 2:
        {
            _myEmail = textField.text;
        }
            break;
        case 3:
        {
            _mysec = [NSString stringWithFormat:@"%@",textField.text];
        }
            break;
        case 4:
        {
            _mysecs = [NSString stringWithFormat:@"%@",textField.text];
        }
            break;
    }
}

#pragma -mark -events response

- (void)regisMyAccount:(UIButton *)btn{
    if ([_mysec isEqualToString:_mysecs]&&_myEmail.length!=0&&_myName.length!=0&&_mysec.length!=0&&_mysecs.length!=0) {
        if ([[ATLoginTool sharedInstance] UserRegisWithAccount:_myName password:_mysec]) {
            [[ATToast shareToast] initWithText:@"注册成功"];
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [[ATToast shareToast] initWithText:@"注册失败"];
        }
    }else{
        [[ATToast shareToast] initWithText:@"不符合条件"];
    }
}
- (void)jumpLoading:(UIButton *)btn{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)backFirstView:(UIButton *)btn{
    [self dismissViewControllerAnimated:YES completion:nil];
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
