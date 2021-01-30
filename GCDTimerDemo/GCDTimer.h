//
//  GCDTimer.h
//  GCDTimerDemo
//
//  Created by allison on 2021/1/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GCDTimer : NSObject


/// 创建定时器
/// @param task 任务回调
/// @param start 开始时间
/// @param interval 间隔时间
/// @param repeat 是否重复
/// @param async 是否异步
+ (NSString *)executeTask:(void(^)(void))task
              start:(NSTimeInterval)start
           interval:(NSTimeInterval)interval
             repeat:(BOOL)repeat
              async:(BOOL)async;


/// 取消任务
/// @param taskName 任务唯一标识
+ (void)cancleTask:(NSString *)taskName;
@end

NS_ASSUME_NONNULL_END
