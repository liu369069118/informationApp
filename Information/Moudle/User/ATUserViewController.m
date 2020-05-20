//
//  ATUserViewController.m
//  Information
//
//  Created by 刘涛 on 2020/5/21.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import "ATUserViewController.h"
#import "ATLoginViewController.h"
#import "ATLoginWebViewController.h"
#import "ATTextTableViewCell.h"
#import "ATFunTableViewCell.h"
#import "ATUserHeader.h"
#import "ATUserFooter.h"
#import "ATActionSheet.h"
#import "ATLocationCache.h"

@interface ATUserViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) ATUserHeader *header;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation ATUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLayoutView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)setupLayoutView{
    self.navigationItem.title = @"用户中心";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_navigation_back_white"] style:UIBarButtonItemStyleDone target:self action:@selector(goHome)];
    
    _header = [[ATUserHeader alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 150)];
    MJWeakSelf
    _header.kClickEventBlock = ^{
        if (![ATLoginTool sharedInstance].isLogin) {
            ATLoginViewController *desVc = [[ATLoginViewController alloc] init];
            desVc.loadStatus = ^{
                //登录成功回调
                [weakSelf.header updateUI];
            };
            [weakSelf.navigationController pushViewController:desVc animated:YES];
        }
    };
    
    ATUserFooter *footer = [[ATUserFooter alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 50)];
    
    
    _tableview = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableview.tableHeaderView = _header;
    _tableview.tableFooterView = footer;
    [self.view addSubview:_tableview];
    [_tableview registerClass:ATTextTableViewCell.class forCellReuseIdentifier:ATTextTableViewCell.indentifier];
    [_tableview registerClass:ATFunTableViewCell.class forCellReuseIdentifier:ATFunTableViewCell.indentifier];
    
    [_tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ATTextTableViewCell.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *data = [self.dataArray objectAtIndex:section];
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *data = [self.dataArray objectAtIndex:indexPath.section];

    if (indexPath.section == 0) {
        ATFunTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ATFunTableViewCell.indentifier forIndexPath:indexPath];
        cell.contentStr = [data objectAtIndex:indexPath.row];
        return cell;
    } else {
        ATTextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ATTextTableViewCell.indentifier forIndexPath:indexPath];
        cell.contentStr = [data objectAtIndex:indexPath.row];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            MJWeakSelf
            NSString *cacheString = [NSString stringWithFormat:@"是否清空 %@ 缓存?",[self getCacheSize]];
            ATActionSheet *actionSheet = [[ATActionSheet alloc] initActionSheetWithTitle:@"" descriptiveText:cacheString cancelButtonTitle:@"取消" destructiveButtonTitles:@[@"清空"] otherButtonTitles:@[] itemAction:^(ATActionSheet *actionSheet, NSString *title, NSInteger index) {
                if ([title isEqualToString:@"清空"]) {
                    [weakSelf clearCache];
                } else {
                    
                }
            }];
            [actionSheet showAction];
        } else if (indexPath.row == 1) {
            ATLoginWebViewController *web = [[ATLoginWebViewController alloc] init];
            web.titleStr = @"关于我们";
            web.type = 3;
            [self.navigationController pushViewController:web animated:YES];
        } else if (indexPath.row == 2) {
            ATLoginWebViewController *web = [[ATLoginWebViewController alloc] init];
            web.titleStr = @"隐私协议";
            web.type = 1;
            [self.navigationController pushViewController:web animated:YES];
        } else if (indexPath.row == 3) {
            ATLoginWebViewController *web = [[ATLoginWebViewController alloc] init];
            web.titleStr = @"注册协议";
            web.type = 2;
            [self.navigationController pushViewController:web animated:YES];
        } else if (indexPath.row == 4) {
            if ([ATLoginTool sharedInstance].isLogin) {
                MJWeakSelf
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确认退出当前账号吗？" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [[ATLoginTool sharedInstance] LoginOut];
                    [weakSelf.header updateUI];
                }];
                UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [alert addAction:action1];
                [alert addAction:action2];
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                [[ATToast shareToast] initWithText:@"未登录不需要退出登录哦~"];
            }
        }
    }
}

- (NSString *)getCacheSize{
    CGFloat imageCacheSize = ((CGFloat)[[SDImageCache sharedImageCache] totalDiskSize])/1024.0/1024.0;
    CGFloat localCacheSize = ((CGFloat)[ATLocationCache allRequestCacheSize])/1024.0/1024.0;
    return [NSString stringWithFormat:@"%.2fM",imageCacheSize + localCacheSize];
}

- (void)clearCache{
    [ATLocationCache removeAllRequestCache];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        [[ATToast shareToast] initWithText:@"清空成功"];
    }];
}

- (void)goHome {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[
                        @[@"护眼模式"],
                        @[@"清空缓存",@"关于我们",@"隐私协议",@"注册协议",@"退出账号"]
                    ];
    }
    return _dataArray;
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
