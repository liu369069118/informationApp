//
//  ATLocationCache.h
//  Information
//
//  Created by 刘涛 on 2020/5/21.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATLocationCache : NSObject


/**
 缓存网络数据,根据请求的urlString与parameters做key存储数据, 这样就能缓存多级页面的数据
 
 @param requestCache 服务器返回的数据
 @param urlString 请求的url字符串
 @param parameters 请求的参数
 */
+ (void)setRequestCache:(id)requestCache urlString:(NSString *)urlString parameters:(NSDictionary *)parameters;

+ (void)setModifiedTimestamp:(id)modifiedTimestamp urlString:(NSString *)urlString parameters:(NSDictionary *)parameters;
/**
 根据请求的url与parameters 取出缓存数据
 
 @param urlString 请求的url字符串
 @param parameters 请求的参数
 @return 缓存的服务器数据
 */
+ (id)requestCacheForUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters;

+ (id)localTimestampCacheForUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters;

+ (id)modifiedTimestampCacheForUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters;
/**
 获取网络缓存的总大小
 
 @return 缓存数据的大小（单位：bytes）
 */
+ (NSInteger)allRequestCacheSize;

/**
 *  删除所有网络缓存,
 */
+ (void)removeAllRequestCache;

/**
 文件夹大小
 
 @param folderPath 文件夹路径
 @return 文件夹大小，返回M
 */
+ (CGFloat)folderSizeAtPath:(NSString*)folderPath;

@end

NS_ASSUME_NONNULL_END
