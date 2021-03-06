//
//  ATTextTableViewCell.h
//  Information
//
//  Created by 刘涛 on 2020/5/21.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATTextTableViewCell : UITableViewCell

@property(nonatomic, copy) NSString *contentStr;

+ (NSString *)indentifier;

+ (CGFloat)cellHeight;

@end

NS_ASSUME_NONNULL_END
