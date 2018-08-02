//
//  OperationViewController.m
//  GCD_Test
//
//  Created by zemel on 2018/8/2.
//  Copyright © 2018年 zemel. All rights reserved.
//

#import "OperationViewController.h"

@interface OperationViewController ()

@end

@implementation OperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    //1.简介
//    [self introduction];
    //2.NSOperationQueue
//    [self operationQueue];
    //3.自定义队列
    [self customQueue];
    
}
- (void)introduction
{
    //1. NSOperation是基类，NSInvocationOperation,NSBlockOperation是子类
    //基类并不能直接使用，一般使用其子类
    NSInvocationOperation * invocation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task) object:nil];
    
    /*
     2018-08-02 16:11:58.782100+0800 GCD_Test[4354:709598] begin
     2018-08-02 16:12:00.783378+0800 GCD_Test[4354:709598] <NSThread: 0x60400006f200>{number = 1, name = main}
     2018-08-02 16:12:00.783503+0800 GCD_Test[4354:709598] end
     主线程，主队列中执行
     */
    
    NSBlockOperation * block = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"1:%@",[NSThread currentThread]);
    }];
    
    [block addExecutionBlock:^{
        NSLog(@"2:%@",[NSThread currentThread]);
    }];
    
    [block addExecutionBlock:^{
        NSLog(@"3:%@",[NSThread currentThread]);
    }];
  
    /*
     2018-08-02 16:12:00.850997+0800 GCD_Test[4354:709598] 1:<NSThread: 0x60400006f200>{number = 1, name = main}
     2018-08-02 16:12:00.851028+0800 GCD_Test[4354:710008] 2:<NSThread: 0x60c00006f540>{number = 3, name = (null)}
     2018-08-02 16:12:00.851026+0800 GCD_Test[4354:710803] 3:<NSThread: 0x60400046c240>{number = 4, name = (null)}
     第一个任务在主线程，主队列中执行
     第二个和第三个任务在其他线程中执行
     */
    //2. setCompletionBlock监听执行情况
    [invocation setCompletionBlock:^{
        NSLog(@"invocation 完成");
    }];
    [block setCompletionBlock:^{
        NSLog(@"block 完成");
    }];
    //所有操作都必须在开启线程/任务之前创建完毕
    [invocation start];
    [block start];
}
- (void)operationQueue
{
    NSInvocationOperation * invo = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task) object:nil];
    NSOperationQueue * queue = [NSOperationQueue mainQueue];
    [queue addOperation:invo];
    /*
     2018-08-02 16:34:49.605180+0800 GCD_Test[4597:782424] 第1个任务----<NSThread: 0x608000066180>{number = 1, name = main}
     2018-08-02 16:34:49.605398+0800 GCD_Test[4597:782424] 第2个任务----<NSThread: 0x608000066180>{number = 1, name = main}
     2018-08-02 16:34:49.605629+0800 GCD_Test[4597:782424] 第3个任务----<NSThread: 0x608000066180>{number = 1, name = main}
     */
    [queue addOperationWithBlock:^{
        NSLog(@"queue:%@",[NSThread currentThread]);
    }];
    /*
     2018-08-02 16:53:30.597261+0800 GCD_Test[4616:787166] queue:<NSThread: 0x60800007d340>{number = 1, name = main}
     */
}
- (void)customQueue
{
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    NSInvocationOperation * invo1 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task:) object:@"1"];
    NSInvocationOperation * invo2 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task:) object:@"2"];
    NSInvocationOperation * invo3 = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task:) object:@"3"];
    //设置最大并发数
    //默认为-1，系统调配，当设置为1时，可以认为是串行任务
    queue.maxConcurrentOperationCount = 3;
    //设置依赖
    //invo1依赖invo2，所以只有当invo2执行完毕后，才会执行invo1
    //不能设置双向依赖，设置invo1依赖invo2后，不能设置invo2依赖invo1，否则会造成死锁
    [invo1 addDependency:invo2];
    //所有设置必须在start方法和addOperation方法之前设置，否则无效
    [queue addOperation:invo1];
    [queue addOperation:invo2];
    [queue addOperation:invo3];
    /*
     2018-08-02 17:02:15.396422+0800 GCD_Test[4877:837007] 第3个任务----<NSThread: 0x60000026a1c0>{number = 4, name = (null)}
     2018-08-02 17:02:15.396424+0800 GCD_Test[4877:837008] 第2个任务----<NSThread: 0x608000465900>{number = 3, name = (null)}
     2018-08-02 17:02:15.396674+0800 GCD_Test[4877:837007] 第3个任务----<NSThread: 0x60000026a1c0>{number = 4, name = (null)}
     2018-08-02 17:02:15.396683+0800 GCD_Test[4877:837008] 第2个任务----<NSThread: 0x608000465900>{number = 3, name = (null)}
     2018-08-02 17:02:15.396755+0800 GCD_Test[4877:837007] 第3个任务----<NSThread: 0x60000026a1c0>{number = 4, name = (null)}
     2018-08-02 17:02:15.396760+0800 GCD_Test[4877:837008] 第2个任务----<NSThread: 0x608000465900>{number = 3, name = (null)}
     2018-08-02 17:02:15.397029+0800 GCD_Test[4877:837008] 第1个任务----<NSThread: 0x608000465900>{number = 3, name = (null)}
     2018-08-02 17:02:15.397090+0800 GCD_Test[4877:837008] 第1个任务----<NSThread: 0x608000465900>{number = 3, name = (null)}
     2018-08-02 17:02:15.397184+0800 GCD_Test[4877:837008] 第1个任务----<NSThread: 0x608000465900>{number = 3, name = (null)}
     */
}
- (void)task:(NSString *)params
{
    /*
    NSLog(@"begin");
    [NSThread sleepForTimeInterval:2];
    NSLog(@"%@",[NSThread currentThread]);
    NSLog(@"end");
     */
    for (int i=1; i<=3; i++) {
        NSLog(@"第%@个任务----%@",params,[NSThread currentThread]);
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
