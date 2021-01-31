//
//  GCDTimer.m
//  GCDTimerDemo
//
//  Created by allison on 2021/1/30.
//

#import "GCDTimer.h"

@implementation GCDTimer

static NSMutableDictionary *timerDict;
dispatch_semaphore_t semaphore;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timerDict = [NSMutableDictionary dictionary];
        semaphore = dispatch_semaphore_create(1);
    });
}

+ (NSString *)executeTask:(void(^)(void))task
              start:(NSTimeInterval)start
           interval:(NSTimeInterval)interval
             repeat:(BOOL)repeat
              async:(BOOL)async {
    if (!task || start < 0 || (interval <= 0 && repeat)) return nil;
    
    //队列
    dispatch_queue_t queue = async ? dispatch_get_global_queue(0, 0): dispatch_get_main_queue();
    //创建定时器
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //设置时间
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, start * NSEC_PER_SEC, interval * NSEC_PER_SEC);
    
    //加锁
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSUInteger intIdentifier = timerDict.count;
    //定时器唯一标识
    NSString *timerName = [NSString stringWithFormat:@"%zd",intIdentifier];
    //存放到字典中
    timerDict[timerName] = timer;
    //解锁
    dispatch_semaphore_signal(semaphore);

    //设置回调
    dispatch_source_set_event_handler(timer, ^{
        task();
        if (!repeat) {//不重复任务
            [self cancleTask:timerName];
        }
    });
    //启动执行定时器
    dispatch_resume(timer);
    return timerName;
}

+ (NSString *)executeTarget:(id)target selector:(SEL)selector start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async {
    if (!target || !selector) return nil;
    return [self executeTask:^{
        if ([target respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector:selector];
#pragma clang diagnostic pop
        }
    } start:start interval:interval repeat:repeats async:async];
}

+ (void)cancleTask:(NSString *)taskName {
    if (taskName.length == 0) return;
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_source_t _timerName = timerDict[taskName];
    if (_timerName) {
        dispatch_source_cancel(_timerName);
        [timerDict removeObjectForKey:taskName];
    }
    dispatch_semaphore_signal(semaphore);
}

@end
