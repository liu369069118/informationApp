
#import "JKRTestViewController.h"
#import <WebKit/WebKit.h>

@interface JKRTestViewController ()

@property (nonatomic, strong) WKWebView *webview;

@end

@implementation JKRTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] init];
    label.text = @"详情";
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:20];
    
    UIButton *searchBtn = [[UIButton alloc] init];
    [searchBtn setImage:[UIImage imageNamed:@"btn_navigation_close"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(closeVc) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *titleView = [[UIView alloc] init];
    [titleView addSubview:label];
    [titleView addSubview:searchBtn];
    [self.view addSubview:titleView];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(-12);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(label.mas_centerY).offset(0);
        make.left.mas_equalTo(16);
    }];
    
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(kATNavigationBarHeight);
    }];
    
    [self.view addSubview:self.webview];
    
    [self.webview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.equalTo(titleView.mas_bottom).offset(0);
    }];
    
    if (self.detailUrl && self.detailUrl.length > 0) {
        [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.detailUrl]]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}


- (void)closeVc {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (WKWebView *)webview {
    if (!_webview) {
        _webview = [[WKWebView alloc] init];
    }
    return _webview;
}

@end
