//
//  WeSignAPI.m
//  WeSignSDK
//
//  Created by signit.cn on 15/9/9.
//  Copyright (c) 2015年 signit.cn All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeSignAPI : NSObject

/*
 注册APP
 */
+(BOOL)registerAPP:(NSString *)appid;

/*
 返回API版本号
 */
+(NSString *) getAPIVersion;

@end
