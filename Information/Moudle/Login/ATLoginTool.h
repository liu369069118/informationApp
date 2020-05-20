//
//  ATLoginTool.h
//  Information
//
//  Created by 刘涛 on 2020/5/20.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATLoginTool : NSObject

@property (nonatomic, assign) BOOL isLogin; //登录态
@property (nonatomic, copy) NSString *userAccount; //已登录用户
@property (nonatomic, assign) NSInteger userIntegral; //用户积分

+ (instancetype)sharedInstance;

- (BOOL)UserLoginWithAccount:(NSString *)account password:(NSString *)key;

- (BOOL)UserRegisWithAccount:(NSString *)account password:(NSString *)key;

- (BOOL)LoginOut;

- (void)UpdateIntergral:(NSInteger)value;

@end

NS_ASSUME_NONNULL_END
