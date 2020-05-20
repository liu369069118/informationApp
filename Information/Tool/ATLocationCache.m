//
//  ATLocationCache.m
//  Information
//
//  Created by 刘涛 on 2020/5/21.
//  Copyright © 2020 刘涛. All rights reserved.
//

#import "ATLocationCache.h"
#import <YYCache/YYCache.h>
#import <CommonCrypto/CommonDigest.h>

@implementation ATLocationCache

static NSString *const kHCRequestResponseCache = @"kHCRequestResponseCache";
static YYCache *_dataCache;

#pragma mark - Public Method
+ (void)setRequestCache:(id)requestCache urlString:(NSString *)urlString parameters:(NSDictionary *)parameters {
    NSString *cacheKey = [self cacheKeyWithUrlString:urlString parameters:parameters];
    NSString *localTimestampKey = [self localTimestampKeyWithUrlString:urlString parameters:parameters];
    [_dataCache setObject:[NSDate date] forKey:localTimestampKey withBlock:nil];
    [_dataCache setObject:requestCache forKey:cacheKey withBlock:nil];
}

+ (void)setModifiedTimestamp:(id)modifiedTimestamp urlString:(NSString *)urlString parameters:(NSDictionary *)parameters {
    NSString *modifiedTimestampKey = [self modifiedTimestampKeyWithUrlString:urlString parameters:parameters];
    [_dataCache setObject:modifiedTimestamp forKey:modifiedTimestampKey];
}

+ (id)requestCacheForUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters {
    NSString *cacheKey = [self cacheKeyWithUrlString:urlString parameters:parameters];
    return [_dataCache objectForKey:cacheKey];
}

// 上次请求的时间戳，是本地的当前时间
+ (id)localTimestampCacheForUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters {
    NSString *localTimestampKey = [self localTimestampKeyWithUrlString:urlString parameters:parameters];
    return [_dataCache objectForKey:localTimestampKey];
}

// 上次请求时服务器返回的Last-Modified
+ (id)modifiedTimestampCacheForUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters {
    NSString *modifiedTimestampKey = [self modifiedTimestampKeyWithUrlString:urlString parameters:parameters];
    return [_dataCache objectForKey:modifiedTimestampKey];
}

+ (NSInteger)allRequestCacheSize {
    return [_dataCache.diskCache totalCost];
}

+ (void)removeAllRequestCache {
    [_dataCache.memoryCache removeAllObjects];
    [_dataCache.diskCache removeAllObjects];
}

#pragma mark - Override
+ (void)initialize {
    _dataCache = [YYCache cacheWithName:kHCRequestResponseCache];
}

#pragma mark - Private Method
+ (NSString *)cacheKeyWithUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters {
    if (!urlString || 0 == urlString.length) {
        urlString = @"";
    }
    
    NSString *cacheKey = [self hashWithString:[NSString stringWithFormat:@"%@%@", urlString, parameters]];
    
    return cacheKey;
}

// 本地时间戳存储时使用的key，时间戳用于本地过期判断
+ (NSString *)localTimestampKeyWithUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters {
    if (!urlString || 0 == urlString.length) {
        urlString = @"";
    }
    
    NSString *localTimestampKey = [self hashWithString:[NSString stringWithFormat:@"%@%@_date", urlString, parameters]];
    
    return localTimestampKey;
}

// 存储Last-Modified时使用的key
+ (NSString *)modifiedTimestampKeyWithUrlString:(NSString *)urlString parameters:(NSDictionary *)parameters {
    if (!urlString || 0 == urlString.length) {
        urlString = @"";
    }
    
    NSString *modifiedTimestampKey = [self hashWithString:[NSString stringWithFormat:@"%@%@_modify", urlString, parameters]];
    
    return modifiedTimestampKey;
}

+ (CGFloat)folderSizeAtPath:(NSString*)folderPath {
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

//单个文件的大小
+ (long long)fileSizeAtPath:(NSString*)filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

+ (NSString *)hashWithString:(NSString *)string {
    // Create pointer to the string as UTF8
    const char *ptr = [string UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (int)strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", md5Buffer[i]];
    }
    
    return output;
}

@end
