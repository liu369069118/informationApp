//
//  ATUtil.h
//  Information
//
//  Created by 刘涛 on 2020/5/20.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATUtil : NSObject

+ (NSDictionary *)readLocalFileWithName:(NSString *)name;

+ (BOOL)isFullScreenIPhone;

+ (NSMutableArray *)mainDataList;

@end

NS_ASSUME_NONNULL_END
