//
//  ATUserHeader.m
//  Information
//
//  Created by 刘涛 on 2020/5/21.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import "ATUserHeader.h"

@interface ATUserHeader ()

@property (nonatomic, strong) UIImageView *userIcon;

@property (nonatomic, strong) UILabel *userName;

@property (nonatomic, strong) UILabel *userIntegral;

@property (nonatomic, strong) UIButton *signBtn;

@end

@implementation ATUserHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayoutView];
    }
    return self;
}

- (void)setupLayoutView {
    UITapGestureRecognizer *iconTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpLogin)];
    
    _userIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_default_avatar_n"]];
    _userIcon.userInteractionEnabled = YES;
    _userIcon.layer.cornerRadius = 30;
    _userIcon.layer.masksToBounds = YES;
    _userIcon.contentMode = UIViewContentModeScaleAspectFill;
    [_userIcon addGestureRecognizer:iconTap];
    [self addSubview:_userIcon];
    
    UITapGestureRecognizer *nameTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpLogin)];
    
    _userName = [[UILabel alloc] init];
    _userName.userInteractionEnabled = YES;
    _userName.textColor = [UIColor colorWithHexString:@"333333"];
    _userName.font = [UIFont systemFontOfSize:16];
    [_userName addGestureRecognizer:nameTap];
    [self addSubview:_userName];
    
    _userIntegral = [[UILabel alloc] init];
    _userIntegral.userInteractionEnabled = YES;
    _userIntegral.textColor = [UIColor colorWithHexString:@"333333"];
    _userIntegral.font = [UIFont systemFontOfSize:14];
    [self addSubview:_userIntegral];
    
    _signBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_signBtn setTitle:@"签到" forState:UIControlStateNormal];
    [_signBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _signBtn.layer.cornerRadius = 15;
    _signBtn.layer.masksToBounds = YES;
    _signBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    _signBtn.backgroundColor = [UIColor colorWithRed:228/255.0 green:87/255.0 blue:28/255.0 alpha:1.0];
    [_signBtn addTarget:self action:@selector(userSignIn) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_signBtn];
    
    [_userIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(30);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    [_userName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_userIcon.mas_centerY).offset(-10);
        make.left.equalTo(_userIcon.mas_right).offset(16);
    }];
    [_userIntegral mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_userIcon.mas_right).offset(16);
        make.top.equalTo(_userName.mas_bottom).offset(5);
    }];
    [_signBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_userIcon.mas_centerY).offset(0);
        make.right.mas_equalTo(-32);
        make.size.mas_equalTo(CGSizeMake(80, 30));
    }];
    
    [self updateUI];
    
}

- (void)jumpLogin {
    if (self.kClickEventBlock) {
        self.kClickEventBlock();
    }
}

- (void)userSignIn {
    if ([ATLoginTool sharedInstance].isLogin) {
        BOOL lock = NO;
        
        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"signDate"];
        if (value) {
            NSTimeInterval current = [NSDate date].timeIntervalSince1970;
            if (current-value.doubleValue > 24*3600) {
                lock = YES;
            } else {
                lock = NO;
            }
        } else {
            lock = YES;
        }
        if (lock) {
            [[ATLoginTool sharedInstance] UpdateIntergral:[ATLoginTool sharedInstance].userIntegral+1];
            [[NSUserDefaults standardUserDefaults] setObject:@([NSDate date].timeIntervalSince1970) forKey:@"signDate"];
            [self updateUI];
        }
    } else {
        [[ATToast shareToast] initWithText:@"登录后才能签到哦！~"];
    }
}

- (void)updateUI {
    if ([ATLoginTool sharedInstance].isLogin) {
        _userName.text = [ATLoginTool sharedInstance].userAccount;
        _userIntegral.text = [NSString stringWithFormat:@"积分 %ld",[ATLoginTool sharedInstance].userIntegral];
        
        NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:@"signDate"];
        if (value) {
            NSTimeInterval current = [NSDate date].timeIntervalSince1970;
            if (current-value.doubleValue > 24*3600) {
                [_signBtn setTitle:@"签到" forState:UIControlStateNormal];
                _signBtn.userInteractionEnabled = YES;
            } else {
                [_signBtn setTitle:@"已签到" forState:UIControlStateNormal];
                _signBtn.userInteractionEnabled = NO;
            }
        } else {
            [_signBtn setTitle:@"签到" forState:UIControlStateNormal];
            _signBtn.userInteractionEnabled = YES;
        }
    } else {
        _userName.text = @"未登录";
        _userIntegral.text = @"积分 0";
    }
}

@end
