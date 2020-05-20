//
//  ATActionSheet.h
//  Information
//
//  Created by 刘涛 on 2020/5/20.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATActionSheet : UIView

- (instancetype)initActionSheetWithTitle:(NSString *)title
                         descriptiveText:(NSString *)descriptive
                       cancelButtonTitle:(NSString *)cancelButtonTitle
                 destructiveButtonTitles:(NSArray *)destructiveButtonTitles
                       otherButtonTitles:(NSArray *)otherButtonTitles
                              itemAction:(void(^)(ATActionSheet *actionSheet, NSString *title, NSInteger index))itemAction;

- (void)showAction;
- (void)dismissAction;

@end

NS_ASSUME_NONNULL_END
