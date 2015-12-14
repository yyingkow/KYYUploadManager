//
//  KYYUploadManager.m
//  KYYUploadManager
//
//  Created by rk on 15/12/15.
//  Copyright © 2015年 kyy. All rights reserved.
//

#import "KYYUploadManager.h"

@implementation KYYUploadManager

// 获得单例对象
+ (instancetype)shareManager{

    static id _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super alloc]init];
    });
    return _instance;
}

// 单文件上传 (异步)
- (void)uploadFileWithURLString:(NSString *)urlString filePath:(NSString *)filePath fileKey:(NSString *)fileKey fileName:(NSString *)fileName{

    //创建请求
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    request.HTTPMethod = @"POST";
    request.HTTPBody = [self getHttpBodyWithFilePath:filePath fileKey:fileKey fileName:fileName];
    //若是文件上传, 还需告知服务器,上传的是文件信息而不是普通文本
    NSString *type = [NSString stringWithFormat:@"multipart/form-data;boundary=%@",kBoundary];
    [request setValue:type forHTTPHeaderField:@"Content-Type"];
  
    //发送请求
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"response : %@",response);
            
            NSLog(@"data : %@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        });
       
    }];
    [dataTask resume];
    
}

// 多文件上传 (异步)
- (void)uploadFilesWithURLString:(NSString *)urlString fileDict:(NSDictionary *)fileDict fileKey:(NSString *)fileKey paramater:(NSDictionary *)paramater{
    //创建请求
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.HTTPMethod = @"POST";
    request.HTTPBody = [self getHttpBodyWithFileDict:fileDict fileKey:fileKey paramater:paramater];
    //若是文件上传, 还需告知服务器,上传的是文件信息而不是普通文本
    NSString *type = [NSString stringWithFormat:@"multipart/form-data;boundary=%@",kBoundary];
    [request setValue:type forHTTPHeaderField:@"Content-Type"];
    
    //发送请求
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"response : %@",response);
            
            NSLog(@"data : %@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
        });
        
    }];
    [dataTask resume];
}

/**
 *  获取单文件上传的请求体
 *
 *  @param filePath 需要上传的文件的文件路径
 *  @param fileKey  服务器接收上传文件的key值
 *  @param fileName 上传文件在服务器中所保存的名称
 *
 *  @return 封装好的请求体内容
 */
- (NSData *)getHttpBodyWithFilePath:(NSString *)filePath fileKey:(NSString *)fileKey fileName:(NSString *)fileName{
    
    NSMutableData *data = [NSMutableData data];
    
  //设置上传文件的上边界
    NSMutableString *headerStrM = [NSMutableString stringWithFormat:@"--%@\r\n",kBoundary];
    
    //文件非文本
    [headerStrM appendFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n",fileKey,fileName];
    
    //上传文件的文件类型
    NSString *fileType = [self getFileTypeWithFilePath:filePath];
    [headerStrM appendFormat:@"Content-Type: %@\r\n\r\n",fileType];
    
    //将上边界转换成二进制数据
    NSData *headerData = [headerStrM dataUsingEncoding:NSUTF8StringEncoding];
    [data appendData:headerData];
    
  //上传文件内容
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    [data appendData:fileData];
    
  //设置上传文件的下边界
    NSMutableString *footerStrM = [NSMutableString stringWithFormat:@"\r\n--%@--\r\n",kBoundary];
    NSData *footerData = [footerStrM dataUsingEncoding:NSUTF8StringEncoding];
    
    [data appendData:footerData];

    return data;
}

/**
  获取多文件上传的请求体
  多文件上传,将需要上传的文件封装起来.用字典封装需要上传的文件.
  文件上传需要的参数: 文件的路径, 在服务器中文件保存的名称 服务器接收文件的 key 值.
  字典: key = value  key = 文件在服务器保存的名称 value = 文件的路径
  服务区接收文件的 key 值单独作为一个参数.
 
  普通文本信息字典:()
  对于普通的文本信息(字符串),有时候也需要很多个 key 值
  将服务器接收普通文本信息的 key 值作为字典的key ,将文本信息作为 value .
 
 */

/**
 *  获取多文件上传的请求体
 *
 *  @param fileDict  文件参数的封装
 *  @param fileKey   服务器接收文件参数的key值
 *  @param paramater 上传文件在服务器中保存的名称
 *
 *  @return 格式化后的上传数据
 */
- (NSData *)getHttpBodyWithFileDict:(NSDictionary *)fileDict fileKey:(NSString *)fileKey paramater:(NSDictionary *)paramater{
    
    KYYUploadManager *manager = [KYYUploadManager shareManager];
    NSMutableData *data = [NSMutableData data];
    
  //设置需要上传文件的格式; 遍历文件参数字典,得到的就是格式化后的文件参数
    [fileDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *fileName = key;
        NSString *filePath = obj;
        
        //文件上边界
        NSMutableString *headerStrM = [NSMutableString stringWithFormat:@"\r\n--%@\r\n",kBoundary];
        [headerStrM appendFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n",fileKey,fileName];
        
        //动态获取文件类型
        NSString *type = [manager getFileTypeWithFilePath:filePath];
        [headerStrM appendFormat:@"Content-Type: %@\r\n\r\n",type];
        [data appendData:[headerStrM dataUsingEncoding:NSUTF8StringEncoding]];
        
        //文件内容
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        [data appendData:fileData];

        //文件下边界
        NSMutableString *footerStrM = [NSMutableString stringWithFormat:@"\r\n--%@--\r\n",kBoundary];
        [data appendData:[footerStrM dataUsingEncoding:NSUTF8StringEncoding]];
        
    }];
    
  //遍历普通文本参数字典, 得到的即是格式化后的文本文件
    [paramater enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        // 服务器接收文本参数的 key
        NSString *userKey = key;
        // 我们告诉服务器的内容
        NSString *userInfo = obj;
        
        // 普通文本消息的上边界
        NSMutableString *headerStrM = [NSMutableString stringWithFormat:@"--%@\r\n",kBoundary];
        [headerStrM appendFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n",userKey];
        
        [data appendData:[headerStrM dataUsingEncoding:NSUTF8StringEncoding]];
        
        // 普通文本信息
        [data appendData:[userInfo dataUsingEncoding:NSUTF8StringEncoding]];
        
        // 普通文本信息的下边界
        NSMutableString *footerStrM = [NSMutableString stringWithFormat:@"\r\n--%@--\r\n",kBoundary];
        
        [data appendData:[footerStrM dataUsingEncoding:NSUTF8StringEncoding]];
    }];

    return 0;
}

/**
 *  动态获取文件类型 (同步)
 *
 *  @param filePath 文件地址
 *
 *  @return 文件类型
 */
- (NSString *)getFileTypeWithFilePath:(NSString *)filePath{
    
    NSString *urlString = [NSString stringWithFormat:@"file://%@",filePath];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLResponse *response = nil;
    
    //发送同步请求
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    
    NSString *type = response.MIMEType;
    

    return type;
}
@end
