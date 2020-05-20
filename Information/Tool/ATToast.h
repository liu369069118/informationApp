//
//  ATToast.h
//  Information
//
//  Created by 刘涛 on 2020/5/20.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATToast : UIView

+ (instancetype)shareToast;

- (void)initWithText:(NSString *)text;
- (void)initWithText:(NSString *)text offSetY:(CGFloat)offsetY;

- (void)initWithText:(NSString *)text duration:(NSInteger)duration;
- (void)initWithText:(NSString *)text duration:(NSInteger)duration offSetY:(CGFloat)offsetY;


@end

NS_ASSUME_NONNULL_END
