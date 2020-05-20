//
//  ATRegisView.h
//  Information
//
//  Created by 刘涛 on 2020/5/20.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATRegisView : UIView

@property(strong,nonatomic)UITextField *username;

@property(strong,nonatomic)UITextField *useremail;

@property(strong,nonatomic)UITextField *usersec;

@property(strong,nonatomic)UITextField *usersecs;

@property(strong,nonatomic)UIButton *regis_sure;

@property(strong,nonatomic)UIButton *jumpload;

@property(strong,nonatomic)UIButton *backbtn;

- (instancetype)initWithFrame:(CGRect)frame WithDelegate:(id)delegate;

@end

NS_ASSUME_NONNULL_END
