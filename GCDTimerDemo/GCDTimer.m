//
//  GCDTimer.m
//  GCDTimerDemo
//
//  Created by allison on 2021/1/30.
//

#import "GCDTimer.h"

@implementation GCDTimer
static NSMutableDictionary *timerDict;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timerDict = [NSMutableDictionary dictionary];
    });
}

+ (NSString *)executeTask:(void(^)(void))task
              start:(NSTimeInterval)start
           interval:(NSTimeInterval)interval
             repeat:(BOOL)repeat
              async:(BOOL)async {
    if (!task) return nil;
    
    NSUInteger intIdentifier = timerDict.count;
    //定时器唯一标识
    NSString *timerName = [NSString stringWithFormat:@"%zd",intIdentifier];
    //队列
    dispatch_queue_t queue = async ? dispatch_get_global_queue(0, 0): dispatch_get_main_queue();
    //创建定时器
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //设置时间
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, start * NSEC_PER_SEC, interval * NSEC_PER_SEC);
    //设置回调
    dispatch_source_set_event_handler(timer, ^{
        task();
        if (!repeat) {//不重复任务
            [self cancleTask:timerName];
        }
    });
    //启动执行定时器
    dispatch_resume(timer);
    //存放到字典中
    timerDict[timerName] = timer;
    return timerName;
}

+ (void)cancleTask:(NSString *)taskName {
    dispatch_source_cancel(timerDict[taskName]);
    [timerDict removeObjectForKey:taskName];
}

@end
