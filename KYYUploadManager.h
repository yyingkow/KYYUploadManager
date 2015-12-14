//
//  KYYUploadManager.h
//  KYYUploadManager
//
//  Created by rk on 15/12/15.
//  Copyright © 2015年 kyy. All rights reserved.
//

/**
 
  该类包含了单文件 和 多文件 上传的实现
  以及动态获取所要知道的文件的类型的方法
 
 */

#define kBoundary @"kboundary"

#import <Foundation/Foundation.h>

@interface KYYUploadManager : NSObject

// 工具类
+ (instancetype)shareManager;

/**
 *  单文件上传
 *
 *  @param urlString 单文件 上传接口 (请询问后端人员)
 *  @param filePath  需要上传的文件的文件路径
 *  @param fileKey   服务器接收上传文件的 key 值 (请询问后台人员)
 *  @param fileName  上传文件在服务器中锁保存的名称
 */
- (void)uploadFileWithURLString:(NSString *)urlString
                       filePath:(NSString *)filePath
                        fileKey:(NSString *)fileKey
                       fileName:(NSString *)fileName;

/**
 *  多文件上传
 *
 *  @param urlString 多文件 上传接口 (请询问后端人员)
 *  @param fileDict  对文件参数的封装 (key:服务器中文件保存的名称,value:需要上传文件的路径)
 *  @param fileKey   服务器接收上传文件的 key 值
 *  @param paramater 普通文本参数的封装 (key:服务器接收字符串的key, value: 需要告诉服务器的字符串)
 */
- (void)uploadFilesWithURLString:(NSString *)urlString
                       fileDict:(NSDictionary *)fileDict
                        fileKey:(NSString *)fileKey
                      paramater:(NSDictionary *)paramater;

/**
 *  单文件上传 - 封装请求体内容
 *
 *  @param filePath 需要上传的文件的文件路径
 *  @param fileKey  服务器接收上传文件的 key 值 (请询问后端人员)
 *  @param fileName 上传文件在服务器中保存的名称
 *
 *  @return 封装好的请求体内容 (单文件)
 */
- (NSData *)getHttpBodyWithFilePath:(NSString *)filePath
                            fileKey:(NSString *)fileKey
                           fileName:(NSString *)fileName;
/**
 *  多文件上传 - 封装请求体内容
 *
 *  @param fileDict  文件参数的封装 (key:服务器中文件保存的名称.value:需要上传文件的路径)
 *  @param fileKey   服务器接收文件参数的 key 值
 *  @param paramater 普通文本参数的封装 (key:服务器接收字符串的key.value:需要告诉服务器的字符串)
 *
 *  @return 格式化后的上传数据 (包括 文件参数 和 普通文本参数)
 */
- (NSData *)getHttpBodyWithFileDict:(NSDictionary *)fileDict
                            fileKey:(NSString *)fileKey
                          paramater:(NSDictionary *)paramater;

/**
 *  动态获取文件类型
 *
 *  @param filePath 需要获取类型的文件的路径
 *
 *  @return 文件类型
 */
- (NSString *)getFileTypeWithFilePath:(NSString *)filePath;


@end
