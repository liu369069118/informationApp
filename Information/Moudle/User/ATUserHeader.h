//
//  ATUserHeader.h
//  Information
//
//  Created by 刘涛 on 2020/5/21.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATUserHeader : UIView

@property (nonatomic, copy) void(^kClickEventBlock)(void);

- (void)updateUI;

@end

NS_ASSUME_NONNULL_END
