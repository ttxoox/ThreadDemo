//
//  ViewController.m
//  GCD_Test
//
//  Created by zemel on 2018/7/26.
//  Copyright © 2018年 zemel. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    //1.队列与任务
    [self queueAndTask];
    
    //2.任务的执行
    //2.1 同步执行+串行队列
//    [self syncHandleWithSerial];
    
    //2.2 同步执行+并发队列
//    [self syncHandleWithConcurrent];
    
    //2.3 异步执行+串行队列
//    [self asyncHandleWithSerial];
    
    //2.4 异步执行+并发队列
//    [self asyncWithConcurrent];
    
    //2.5 同步执行+主队列，在主线程内调用
//    [self syncHandleWithMainQueue];
    
    //2.6 同步执行+主队列，在其他线程内调用
    //detachNewThreadSelector会自动创建一个新的线程并开启
//    [NSThread detachNewThreadSelector:@selector(syncHandleWithMainQueue) toTarget:self withObject:nil];
    
    //2.7 异步执行+主队列
//    [self asyncHandleWithMainQueue];
    
    //2.8 栅栏方法
//    [self barrieHandle];
    
    //2.9 快速迭代
//    [self applyHandle];
    
    //3.0 线程组
//    [self groupHandle];
    //3.1 阻塞进程
//    [self groupWaitHandle];
    
    //3.1 信号量
//    [self semaphoreHandle];
}
- (void)queueAndTask
{
    /*
     任务的执行方式分为同步执行和异步执行，区别是：是否等待任务的执行结束，和是否具有创建新线程的能力
     同步执行：等待任务执行结束，不具有创建新线程的能力
     异步执行：不等待任务执行结束，具有创建新线程的能力
     队列：采用先进先出的原则，新任务插入至队尾，读取任务时从队首开始
     队列分为串行队列和并发队列
     串行队列：每次只有一个任务执行，等待该任务执行结束后再执行下一个任务，不新建线程或只创建一个线程
     并发队列：每次有多个任务同时执行，开启多个线程
     并发队列只在异步函数下有效
     */
    
    //1.创建队列
    //第一个参数代表队列名，第二个参数表示该队列是串行队列还是并发队列
    //串行队列:DISPATCH_QUEUE_SERIAL
    //并发队列:DISPATCH_QUEUE_CONCURRENT
    //创建一个名为com.gvs.gcd_test的串行队列
    dispatch_queue_t queue = dispatch_queue_create("com.gvs.gcd_test", DISPATCH_QUEUE_SERIAL);
    NSLog(@"创建了一个串行队列:%@",queue);
    
    //对于串行队列，系统提供了一个特殊的串行队列---主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    NSLog(@"主队列:%@",mainQueue);
    
    //对于并发队列，系统提供了一个特殊的并发队列---全局并发队列
    //全局并发队列需要两个参数，第一个是队列优先级，一般使用DISPATCH_QUEUE_PRIORITY_DEFAULT，第二个参数无用，填0即可
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"全局并发队列:%@",globalQueue);
    
    //2.任务，有两种队列，两种执行任务的方式，组合起来就有四种
    /*
     1.同步执行+串行队列
     2.同步执行+并发队列
     3.异步执行+串行队列
     4.异步执行+并发队列
     */
}
/**
 同步执行+串行队列
 */
- (void)syncHandleWithSerial
{
    dispatch_queue_t queue = dispatch_queue_create("com.gvs.syncSerial", DISPATCH_QUEUE_SERIAL);
    NSLog(@"begin:%@",[NSThread currentThread]);//使用currentThread获取当前线程
    dispatch_sync(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"1:%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"2:%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"3:%@",[NSThread currentThread]);
    });
    NSLog(@"end:%@",[NSThread currentThread]);
    /*
     结果分析:
     2018-07-26 09:56:06.281445+0800 GCD_Test[1524:167703] begin:<NSThread: 0x604000064c00>{number = 1, name = main}
     2018-07-26 09:56:08.282767+0800 GCD_Test[1524:167703] 1:<NSThread: 0x604000064c00>{number = 1, name = main}
     2018-07-26 09:56:10.284126+0800 GCD_Test[1524:167703] 2:<NSThread: 0x604000064c00>{number = 1, name = main}
     2018-07-26 09:56:12.285504+0800 GCD_Test[1524:167703] 3:<NSThread: 0x604000064c00>{number = 1, name = main}
     2018-07-26 09:56:12.285690+0800 GCD_Test[1524:167703] end:<NSThread: 0x604000064c00>{number = 1, name = main}
     
     从打印结果可以看到：
     每个任务都是在主线程中执行的，没有创建新的线程，它不具备开启新线程的能力
     每个任务都是等待前一个任务执行结束后再执行，任务1--3之间大致间隔2s
     每个任务都是按顺序执行的，begin-1-2-3-end
     */
}

/**
 同步执行+并发队列
 */
- (void)syncHandleWithConcurrent
{
    dispatch_queue_t queue = dispatch_queue_create("com.gvs.syncConcurrent", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"begin:%@",[NSThread currentThread]);//使用currentThread获取当前线程
    dispatch_sync(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"1:%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"2:%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"3:%@",[NSThread currentThread]);
    });
    NSLog(@"end:%@",[NSThread currentThread]);
    
    /*
     结果分析:
     2018-07-26 10:04:10.192729+0800 GCD_Test[1609:190666] begin:<NSThread: 0x608000260d00>{number = 1, name = main}
     2018-07-26 10:04:12.194118+0800 GCD_Test[1609:190666] 1:<NSThread: 0x608000260d00>{number = 1, name = main}
     2018-07-26 10:04:14.195407+0800 GCD_Test[1609:190666] 2:<NSThread: 0x608000260d00>{number = 1, name = main}
     2018-07-26 10:04:16.195845+0800 GCD_Test[1609:190666] 3:<NSThread: 0x608000260d00>{number = 1, name = main}
     2018-07-26 10:04:16.196008+0800 GCD_Test[1609:190666] end:<NSThread: 0x608000260d00>{number = 1, name = main}
     
     可以看到：
     1. 由于同步任务不具备开启新线程的能力，所以每个任务都是在主线程内执行的
     2. 所有任务都需要等待前一个任务执行完后才会执行
     3. 虽然并发队列可以开启多个线程，同时执行多个任务，但其本身不能创建线程，所以所有任务都是按顺序执行的，begin-1-2-3-end
     */
}

/**
 异步执行+串行队列
 */
- (void)asyncHandleWithSerial
{
    dispatch_queue_t queue = dispatch_queue_create("com.gvs.asyncSerial", DISPATCH_QUEUE_SERIAL);
    NSLog(@"begin:%@",[NSThread currentThread]);//使用currentThread获取当前线程
    dispatch_async(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"1:%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"2:%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"3:%@",[NSThread currentThread]);
    });
    NSLog(@"end:%@",[NSThread currentThread]);
    /*
     结果分析:
     2018-07-26 10:13:57.431246+0800 GCD_Test[1697:216112] begin:<NSThread: 0x604000260ec0>{number = 1, name = main}
     2018-07-26 10:13:57.431426+0800 GCD_Test[1697:216112] end:<NSThread: 0x604000260ec0>{number = 1, name = main}
     2018-07-26 10:13:59.436722+0800 GCD_Test[1697:216201] 1:<NSThread: 0x600000274740>{number = 3, name = (null)}
     2018-07-26 10:14:01.439407+0800 GCD_Test[1697:216201] 2:<NSThread: 0x600000274740>{number = 3, name = (null)}
     2018-07-26 10:14:03.440870+0800 GCD_Test[1697:216201] 3:<NSThread: 0x600000274740>{number = 3, name = (null)}
     
     1. 异步操作不会等待任务的执行，先输出begin然后再输出end
     2. 异步执行可以开启一个线程处理任务
     3. 由于是串行队列，任务是按顺序执行的
     */
}

/**
 异步执行+并发队列
 */
- (void)asyncWithConcurrent
{
    dispatch_queue_t queue = dispatch_queue_create("com.gvs.asyncConcurrent", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"begin:%@",[NSThread currentThread]);//使用currentThread获取当前线程
    dispatch_async(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"1:%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"2:%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"3:%@",[NSThread currentThread]);
    });
    NSLog(@"end:%@",[NSThread currentThread]);
    /*
     结果分析:
     2018-07-26 10:22:51.794501+0800 GCD_Test[1795:237796] begin:<NSThread: 0x60c000074280>{number = 1, name = main}
     2018-07-26 10:22:51.794629+0800 GCD_Test[1795:237796] end:<NSThread: 0x60c000074280>{number = 1, name = main}
     2018-07-26 10:22:53.794998+0800 GCD_Test[1795:237857] 2:<NSThread: 0x60c000268880>{number = 4, name = (null)}
     2018-07-26 10:22:53.794998+0800 GCD_Test[1795:237860] 1:<NSThread: 0x604000264080>{number = 3, name = (null)}
     2018-07-26 10:22:53.795012+0800 GCD_Test[1795:237858] 3:<NSThread: 0x608000266080>{number = 5, name = (null)}
     
     1.异步执行创建了3个线程，交叉执行任务（并发队列具有开启线程，同时执行多个任务的特点)
     2.不等待前一个任务执行完再执行
     */
}

/**
 同步执行+主队列
 */
- (void)syncHandleWithMainQueue
{
    dispatch_queue_t queue = dispatch_get_main_queue();
    NSLog(@"begin:%@",[NSThread currentThread]);//使用currentThread获取当前线程
    dispatch_sync(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"1:%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"2:%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"3:%@",[NSThread currentThread]);
    });
    NSLog(@"end:%@",[NSThread currentThread]);
    /*
     主线程调用：
     结果分析:
     2018-07-26 10:29:09.719670+0800 GCD_Test[1868:255234] begin:<NSThread: 0x60000007ee00>{number = 1, name = main}
     (lldb)
     
     我们发现，输出begin后程序崩溃了，这是什么原因呢？
     由于串行队列需要等待前一个任务执行完后才会执行，也就是说，我们的任务1需要等待主队列的任务（syncHandleWithMainQueue）执行完成后才会执行，而前面说过，主队列也是一种特殊的串行队列，它也需要等待，所以两个任务在互相等待，从而造成了程序崩溃。这种现象我们称为死锁。
     
     在主线程中调用主队列，会造成线程死锁。
     */
    
    /*
     在新线程调用：
     2018-07-26 10:41:22.006729+0800 GCD_Test[1975:288393] begin:<NSThread: 0x6040002620c0>{number = 3, name = (null)}
     2018-07-26 10:41:24.010572+0800 GCD_Test[1975:287987] 1:<NSThread: 0x60000006fa40>{number = 1, name = main}
     2018-07-26 10:41:26.012581+0800 GCD_Test[1975:287987] 2:<NSThread: 0x60000006fa40>{number = 1, name = main}
     2018-07-26 10:41:28.014613+0800 GCD_Test[1975:287987] 3:<NSThread: 0x60000006fa40>{number = 1, name = main}
     2018-07-26 10:41:28.014879+0800 GCD_Test[1975:288393] end:<NSThread: 0x6040002620c0>{number = 3, name = (null)}

     我们主动新建了一个线程，发现任务都是在主线程内执行的，并且是按顺序执行的，所有主队列的任务，都会放到主线程内执行。
     为什么现在不会死锁了？
     由于我们把syncHandleWithMainQueue任务放到了一个新的线程里面执行，主线程内没有任务等待执行。
     */
}

/*
 异步执行与+主队列
 */
- (void)asyncHandleWithMainQueue
{
    dispatch_queue_t queue = dispatch_get_main_queue();
    NSLog(@"begin:%@",[NSThread currentThread]);//使用currentThread获取当前线程
    dispatch_async(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"1:%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"2:%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"3:%@",[NSThread currentThread]);
    });
    NSLog(@"end:%@",[NSThread currentThread]);
    /*
     2018-07-26 10:49:34.466779+0800 GCD_Test[2090:313236] begin:<NSThread: 0x600000072700>{number = 1, name = main}
     2018-07-26 10:49:34.466946+0800 GCD_Test[2090:313236] end:<NSThread: 0x600000072700>{number = 1, name = main}
     2018-07-26 10:49:36.471102+0800 GCD_Test[2090:313236] 1:<NSThread: 0x600000072700>{number = 1, name = main}
     2018-07-26 10:49:38.472437+0800 GCD_Test[2090:313236] 2:<NSThread: 0x600000072700>{number = 1, name = main}
     2018-07-26 10:49:40.473759+0800 GCD_Test[2090:313236] 3:<NSThread: 0x600000072700>{number = 1, name = main}
     
     由于异步执行不会等待，所以先输出begin再输出end
     由于是主队列，所以没有开启新的线程，所有任务在主队列中执行
     由于是串行队列，任务是按顺序执行的
     */
}

/**
 栅栏方法
 目的：将两组耗时操作分开执行，先执行耗时操作A，再执行耗时操作B
 */
- (void)barrieHandle
{
    //采用异步执行+异步队列的方式
    dispatch_queue_t queue = dispatch_queue_create("com.gvs.barrie", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"begin:%@",[NSThread currentThread]);//使用currentThread获取当前线程
    dispatch_async(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"1:%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"2:%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"3:%@",[NSThread currentThread]);
    });
    dispatch_barrier_async(queue, ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"barrie:%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"4:%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"5:%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        //模拟耗时操作
        [NSThread sleepForTimeInterval:2];
        
        NSLog(@"6:%@",[NSThread currentThread]);
    });
    NSLog(@"end:%@",[NSThread currentThread]);
    
    /*
     结果分析:
     2018-07-26 11:43:19.286388+0800 GCD_Test[2547:421269] begin:<NSThread: 0x60800007b240>{number = 1, name = main}
     2018-07-26 11:43:19.286613+0800 GCD_Test[2547:421269] end:<NSThread: 0x60800007b240>{number = 1, name = main}
     2018-07-26 11:43:21.290972+0800 GCD_Test[2547:422140] 1:<NSThread: 0x6040004620c0>{number = 3, name = (null)}
     2018-07-26 11:43:21.290986+0800 GCD_Test[2547:422141] 3:<NSThread: 0x60c00007ae40>{number = 5, name = (null)}
     2018-07-26 11:43:21.290972+0800 GCD_Test[2547:422143] 2:<NSThread: 0x6080002791c0>{number = 4, name = (null)}
     2018-07-26 11:43:23.294702+0800 GCD_Test[2547:422143] barrie:<NSThread: 0x6080002791c0>{number = 4, name = (null)}
     2018-07-26 11:43:25.298147+0800 GCD_Test[2547:422143] 4:<NSThread: 0x6080002791c0>{number = 4, name = (null)}
     2018-07-26 11:43:25.298147+0800 GCD_Test[2547:422140] 6:<NSThread: 0x6040004620c0>{number = 3, name = (null)}
     2018-07-26 11:43:25.298153+0800 GCD_Test[2547:422141] 5:<NSThread: 0x60c00007ae40>{number = 5, name = (null)}
     
     
     可以看到，先执行任务1，2，3，顺序不定，再执行任务4，5，6
     */
}


/**
 快速迭代
 */
- (void)applyHandle
{
    NSLog(@"begin");
    dispatch_queue_t queue = dispatch_queue_create("com.gvs.apply", DISPATCH_QUEUE_CONCURRENT);
    dispatch_apply(6, queue, ^(size_t index) {
        NSLog(@"%ld----%@",index,[NSThread currentThread]);
    });
    NSLog(@"end");
    /*
     结果分析:
     2018-07-26 14:47:35.334361+0800 GCD_Test[3910:770415] begin
     2018-07-26 14:47:35.334576+0800 GCD_Test[3910:770415] 0----<NSThread: 0x60c000079480>{number = 1, name = main}
     2018-07-26 14:47:35.334606+0800 GCD_Test[3910:770701] 2----<NSThread: 0x60c000273c40>{number = 4, name = (null)}
     2018-07-26 14:47:35.334612+0800 GCD_Test[3910:770702] 1----<NSThread: 0x608000460640>{number = 3, name = (null)}
     2018-07-26 14:47:35.334638+0800 GCD_Test[3910:770703] 3----<NSThread: 0x60c000273ec0>{number = 5, name = (null)}
     2018-07-26 14:47:35.334706+0800 GCD_Test[3910:770415] 4----<NSThread: 0x60c000079480>{number = 1, name = main}
     2018-07-26 14:47:35.334731+0800 GCD_Test[3910:770701] 5----<NSThread: 0x60c000273c40>{number = 4, name = (null)}
     2018-07-26 14:47:35.334900+0800 GCD_Test[3910:770415] end

     在不同的线程内遍历6个数，可以看到，任务是无序的执行的，多个线程同时执行
     */
}
- (void)groupHandle
{
    /*
     场景：等待所有任务执行完成后，进入主队列做UI处理
     1. 添加任务到dispatch_group_async，利用dispatch_group_notify监听group内任务的完成状态，全部完成后进入主队列执行任务
     */
    dispatch_group_t group = dispatch_group_create();
    NSLog(@"begin");
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"1:%@",[NSThread currentThread]);
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"2:%@",[NSThread currentThread]);
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"3:%@",[NSThread currentThread]);
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"4:%@",[NSThread currentThread]);
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"5:%@",[NSThread currentThread]);
    });
    NSLog(@"end");
    /*
     结果分析:
     2018-07-26 14:57:39.411702+0800 GCD_Test[4059:796280] begin
     2018-07-26 14:57:39.411843+0800 GCD_Test[4059:796280] end
     2018-07-26 14:57:41.412972+0800 GCD_Test[4059:796319] 3:<NSThread: 0x608000463b00>{number = 4, name = (null)}
     2018-07-26 14:57:41.412973+0800 GCD_Test[4059:796316] 4:<NSThread: 0x600000276ac0>{number = 3, name = (null)}
     2018-07-26 14:57:41.412974+0800 GCD_Test[4059:796317] 2:<NSThread: 0x600000277f00>{number = 5, name = (null)}
     2018-07-26 14:57:41.412995+0800 GCD_Test[4059:796318] 1:<NSThread: 0x604000265f80>{number = 6, name = (null)}
     2018-07-26 14:57:41.413167+0800 GCD_Test[4059:796280] 5:<NSThread: 0x6040002604c0>{number = 1, name = main}

     从结果中可以看到，所有任务都是异步执行的，且创建了多个线程去交叉执行
     当所有任务完成后，最后进入主队列执行任务5
     */
    
}
- (void)groupWaitHandle
{
    dispatch_group_t group = dispatch_group_create();
    NSLog(@"begin");
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"1:%@",[NSThread currentThread]);
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"2:%@",[NSThread currentThread]);
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"3:%@",[NSThread currentThread]);
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"4:%@",[NSThread currentThread]);
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"end");
    /*
     2018-07-26 15:09:52.428653+0800 GCD_Test[4177:827613] begin
     2018-07-26 15:09:54.433937+0800 GCD_Test[4177:827659] 2:<NSThread: 0x604000263100>{number = 4, name = (null)}
     2018-07-26 15:09:54.433973+0800 GCD_Test[4177:827660] 3:<NSThread: 0x60c00007bf00>{number = 3, name = (null)}
     2018-07-26 15:09:54.433973+0800 GCD_Test[4177:827661] 4:<NSThread: 0x6080000679c0>{number = 6, name = (null)}
     2018-07-26 15:09:54.433981+0800 GCD_Test[4177:827658] 1:<NSThread: 0x608000067ac0>{number = 5, name = (null)}
     2018-07-26 15:09:54.434122+0800 GCD_Test[4177:827613] end
     
     dispatch_group_wait将会等待任务全部执行完成，才会执行下面的任务，这会阻塞当前线程
     */
}
- (void)semaphoreHandle
{
    /*
     dispatch_semaphore_create() : 初始化一个信号量
     dispatch_semaphore_signal() : 使信号量+1
     dispatch_semaphore_wait() : 使信号量-1，当信号量为0时一直等待，否则通过，执行任务
     */
    //在这个例子中，初始化一个信号量为0，由于任务采用异步执行的方式，所以不等待，执行dispatch_semaphore_wait函数，由于信号量为0，故一直等待，直到执行任务1，dispatch_semaphore_signal()后信号量+1，输出end
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //初始化信号量为0
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSLog(@"begin");
    dispatch_async(queue, ^{
        NSLog(@"1:%@",[NSThread currentThread]);
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"end");
     
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
