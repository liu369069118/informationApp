//
//  ATLoginView.h
//  Information
//
//  Created by 刘涛 on 2020/5/20.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATLoginView : UIView

@property(strong,nonatomic)UITextField *username;

@property(strong,nonatomic)UITextField *userpass;

@property(strong,nonatomic)UIButton *log_sure;

@property(strong,nonatomic)UIButton *regisAcc;

@property(strong,nonatomic)UIButton *backbtn;

@property(strong,nonatomic)UIButton *regisAgreement;

@property(strong,nonatomic)UIButton *loginAgreement;

@end

NS_ASSUME_NONNULL_END
