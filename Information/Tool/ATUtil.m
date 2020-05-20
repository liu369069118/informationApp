//
//  ATUtil.m
//  Information
//
//  Created by 刘涛 on 2020/5/20.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import "ATUtil.h"

@implementation ATUtil

+ (BOOL)isFullScreenIPhone {
    CGSize size = [[UIScreen mainScreen] currentMode].size;
    if (CGSizeEqualToSize(size, CGSizeMake(640, 960))       // 3.5  >>> iPhone 4/4s 纵向
        || CGSizeEqualToSize(size, CGSizeMake(960, 640))    // 3.5  >>> iPhone 4/4s 横向
        || CGSizeEqualToSize(size, CGSizeMake(640, 1136))   // 4.0  >>> iPhone 5/5s/5c/SE   纵向
        || CGSizeEqualToSize(size, CGSizeMake(1136, 640))   // 4.0  >>> iPhone 5/5s/5c/SE   横向
        || CGSizeEqualToSize(size, CGSizeMake(750, 1334))   // 4.7  >>> iPhone 6/6s/7/8 纵向
        || CGSizeEqualToSize(size, CGSizeMake(1334, 750))   // 4.7  >>> iPhone 6/6s/7/8 横向
        || CGSizeEqualToSize(size, CGSizeMake(1242, 2208))  // 5.5  >>> iPhone 6P/6sP/7P/8P 纵向
        || CGSizeEqualToSize(size, CGSizeMake(2208, 1242))  // 5.5  >>> iPhone 6P/6sP/7P/8P 横向
        ) {
        return NO;
    } else {
        return YES;
    }
}

+ (NSMutableArray *)mainDataList {
    NSDictionary *homeDict = [ATUtil readLocalFileWithName:@"mainJsonList"];
    NSMutableArray *list  = [homeDict objectForKey:@"list"];
    return list;
}

// 读取本地JSON文件
+ (NSDictionary *)readLocalFileWithName:(NSString *)name {
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"geojson"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    // 对数据进行JSON格式化并返回字典形式
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

@end
