//
//  ATLoginViewController.h
//  Information
//
//  Created by 刘涛 on 2020/5/20.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^loadStatusBlook)(void);

@interface ATLoginViewController : UIViewController

@property (copy, nonatomic) loadStatusBlook loadStatus;

@end

NS_ASSUME_NONNULL_END
