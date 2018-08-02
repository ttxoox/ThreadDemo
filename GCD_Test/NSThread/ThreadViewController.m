//
//  ThreadViewController.m
//  GCD_Test
//
//  Created by zemel on 2018/8/2.
//  Copyright © 2018年 zemel. All rights reserved.
//

#import "ThreadViewController.h"

@interface ThreadViewController ()
@property (nonatomic, assign)NSInteger ticket;//总票数
@end

@implementation ThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.ticket = 50;//初始化票数
    NSThread * windowForBeijing = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicket) object:nil];
    windowForBeijing.name = @"北京的窗口";
    NSThread * windowForGuangzhou = [[NSThread alloc] initWithTarget:self selector:@selector(saleTicket) object:nil];
    windowForGuangzhou.name = @"广州的窗口";
    [windowForBeijing start];
    [windowForGuangzhou start];
    
    //创建线程后自动启动
//    [NSThread detachNewThreadSelector:@selector(saleTicket) toTarget:self withObject:nil];
}
- (void)saleTicket
{
    //在未加锁的情况下，票数是无序的，可能已经无票了，但是还会输出有票，此时需要给线程加锁
    //加锁的目的：保证当前任务只有一个线程执行
    while (1) {
        @synchronized(self){
            if (self.ticket > 0) {
                self.ticket --;
                NSLog(@"剩余票数:%ld---窗口:%@----线程:%@",self.ticket,[NSThread currentThread].name,[NSThread currentThread]);
                [NSThread sleepForTimeInterval:0.5];
            }else{
                NSLog(@"所有票已经售完");
                break;
                
            }
        }
        
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
