//
//  ViewController.m
//  GCDTimerDemo
//
//  Created by allison on 2021/1/30.
//

#import "ViewController.h"
#import "GCDTimer.h"

@interface ViewController ()
/// gcd timer
@property (nonatomic, strong) dispatch_source_t timer;
/// 定时器名字
@property (nonatomic, copy) NSString  * timerName;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSLog(@"begin");
    //创建定时器
    self.timerName =  [GCDTimer executeTask:^{
        NSLog(@">>>>> GCDTimer %@",[NSThread currentThread]);
    } start:1.0 interval:1.0 repeat:YES async:NO];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"----点击取消------");
    [GCDTimer cancleTask:self.timerName];
//    NSLog(@"----点击了------");
//    [self testGCDTimer];
}

- (void)testGCDTimer {
    
    //1.创建GCD中的定时器
    /**
     参数1:source的类型DISPATCH_SOURCE_TYPE_TIMER，表示定时器
     参数2:描述信息
     参数3:更详细的描述信息
     参数4:队列，决定GCD定时器中的任务在那线程中执行
     */
//    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
//    dispatch_queue_t queue = dispatch_get_main_queue();
    dispatch_queue_t queue = dispatch_queue_create("timerQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //2.设置定时器(起始时间 | 间隔时间 | 精准度)
    /**
     参数1：定时器对象timer
     参数2：起始时间，DISPATCH_TIME_NOW，从现在开始计时
     参数3：时间间隔1.0 ,时间间隔为纳秒
     参数4：精准度，绝对精准为0
     */
    uint64_t start = 2.0; //2后开始执行
    uint64_t interval = 1.0;//每隔1s执行
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, start * NSEC_PER_SEC, interval * NSEC_PER_SEC);
    //3.设置定时器要执行的任务
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"GCD----%@",[NSThread currentThread]);
    });

//    dispatch_source_set_event_handler_f(timer, timerFire);
    
    //4.启动执行定时器
    dispatch_resume(timer);
    self.timer = timer;

    
}

void timerFire(void *param) {
    
    NSLog(@"_event_handler_f %@",[NSThread currentThread]);
}



@end
