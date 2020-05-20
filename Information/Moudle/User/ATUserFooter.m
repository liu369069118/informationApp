//
//  ATUserFooter.m
//  Information
//
//  Created by 刘涛 on 2020/5/21.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import "ATUserFooter.h"

@implementation ATUserFooter

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *content = [[UILabel alloc] init];
        content.textColor = [UIColor colorWithHexString:@"666666"];
        content.font  = [UIFont systemFontOfSize:12];
        content.text = @"请谨慎投资~";
        [self addSubview:content];
        [content mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.centerX.mas_equalTo(0);
        }];
    }
    return self;
}

@end
