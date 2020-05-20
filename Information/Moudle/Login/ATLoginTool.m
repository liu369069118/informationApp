//
//  ATLoginTool.m
//  Information
//
//  Created by 刘涛 on 2020/5/20.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import "ATLoginTool.h"

@interface ATLoginTool ()

@property (nonatomic, strong) NSMutableDictionary *accountDic;

@end

@implementation ATLoginTool

+ (instancetype)sharedInstance {
    static ATLoginTool *tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[ATLoginTool alloc] init];
    });
    return tool;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self CheckoutLoginData];
    }
    return self;
}

- (void)CheckoutLoginData {
    NSDictionary *accountDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginData"];
    if (!accountDic) {
        _accountDic = [NSMutableDictionary dictionary];
        [_accountDic setObject:@"qwe123456" forKey:@"15811884326"];
        [[NSUserDefaults standardUserDefaults] setObject:_accountDic.copy forKey:@"loginData"];
    } else {
        _accountDic = accountDic.mutableCopy;
    }
    
    NSDictionary *login = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginStatus"];
    if (login) {
        NSTimeInterval ago = [[login objectForKey:@"times"] doubleValue];
        if ([NSDate date].timeIntervalSince1970-ago > 7*24*3600) {
            self.isLogin = NO;
            self.userIntegral = 0;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loginStatus"];
        } else {
            self.isLogin = YES;
            self.userAccount = [login objectForKey:@"account"];
            self.userIntegral = [self GetUserIntergralWithAccount:_userAccount];
        }
    } else {
        self.isLogin = NO;
    }
}

- (BOOL)UserLoginWithAccount:(NSString *)account password:(NSString *)key {
    if (!account || account.length == 0) {
        return NO;
    }
    if (!key || key.length == 0) {
        return NO;
    }
    if ([_accountDic.allKeys containsObject:account]) {
        NSString *saveKey = [_accountDic objectForKey:account];
        if ([saveKey isEqualToString:key]) {
            NSTimeInterval currentTime = [NSDate date].timeIntervalSince1970;
            NSDictionary *loginStatus = @{@"account":account,@"times":@(currentTime)};
            [[NSUserDefaults standardUserDefaults] setObject:loginStatus forKey:@"loginStatus"];
            self.isLogin = YES;
            self.userAccount = account;
            self.userIntegral = [self GetUserIntergralWithAccount:_userAccount];
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (BOOL)UserRegisWithAccount:(NSString *)account password:(NSString *)key {
    if (!account || account.length == 0) {
        return NO;
    }
    if (!key || key.length == 0) {
        return NO;
    }
    [_accountDic setObject:key forKey:account];
    [[NSUserDefaults standardUserDefaults] setObject:_accountDic forKey:@"loginData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

- (BOOL)LoginOut {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loginStatus"];
    self.isLogin = NO;
    self.userAccount = @"";
    self.userIntegral = 0;
    return YES;
}

- (void)UpdateIntergral:(NSInteger)value {
    if (!self.isLogin) {
        return;
    }
    NSDictionary *intergralData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userIntergral"];
    if (!intergralData) {
        return;
    }
    if ([intergralData.allKeys containsObject:_userAccount]) {
        NSMutableDictionary *mObj = intergralData.mutableCopy;
        [mObj setObject:@(value) forKey:_userAccount];
        [[NSUserDefaults standardUserDefaults] setObject:mObj.copy forKey:@"userIntergral"];
        _userIntegral = value;
    } else {
        NSMutableDictionary *mObj = intergralData.mutableCopy;
        [mObj setObject:@(0) forKey:_userAccount];
        [[NSUserDefaults standardUserDefaults] setObject:mObj.copy forKey:@"userIntergral"];
        _userIntegral = 0;
    }
}

- (NSInteger)GetUserIntergralWithAccount:(NSString *)account {
    if (account) {
        NSDictionary *intergralData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userIntergral"];
        if (intergralData) {
            if ([intergralData.allKeys containsObject:account]) {
                return [[intergralData objectForKey:account] integerValue];
            } else {
                NSMutableDictionary *mObj = intergralData.mutableCopy;
                [mObj setObject:@(0) forKey:account];
                [[NSUserDefaults standardUserDefaults] setObject:mObj.copy forKey:@"userIntergral"];
                return 0;
            }
        } else {
            NSDictionary *obj = @{account:@(0)};
            [[NSUserDefaults standardUserDefaults] setObject:obj forKey:@"userIntergral"];
            return 0;
        }
    }
    return 0;
}

@end
